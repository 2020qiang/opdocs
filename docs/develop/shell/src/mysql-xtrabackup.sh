#!/usr/bin/env bash


# 2019/07/18
#
# mysql 数据库热备脚本，使用 xtrabackup 进行备份
#
# 说明：
#    定时任务执行，将会执行一次全备，之后 $ran -1 次执行增备，以此重复
#    每完成一套 $ran 次备份后，将会腾出位置以准备下次备份，并用tar打包
#    备份数据库中全部表，和备份数据库中重要的表（可以排除数据量大且不重要的表）
#    之后使用xz强压缩，为节省磁盘空间
#    如果磁盘最大使用量浮动 96% 以上，则自动删除最多个2 tar.xz 历史文件
#    备份失败则表示之前的备份已经损坏，删除上次所有备份和此次备份，然后本次重新全备
#    损坏原因可能是两个 xtrabackup 程序同时执行一个目录，或者掉电
#    全备名为 0,增备名为其他数字
#
#    使用：
#        # chown root:root /opt/scripts/db-backup.sh
#        # chmod 0500 /opt/scripts/db-backup.sh
#        # crontab -l
#        */15 * * * *  /opt/db-backup.sh 500w       3316 password
#        */15 * * * *  /opt/db-backup.sh shuangying 3326 password
#
#    恢复：
#        $ tar -xvf /opt/db-backup-old/db-20180516-001122.tar.xz
#        $ cat ./db-backup/time.log
#        $    xtrabackup --prepare --apply-log-only --target-dir=./0 \
#        $ && xtrabackup --prepare --apply-log-only --target-dir=./0 --incremental-dir=./1 \
#        $ && xtrabackup --prepare --apply-log-only --target-dir=./0 --incremental-dir=./2 \
#        $ && tar -czvf 0.tar.gz 0
#        ...
#        # service mysqld stop
#        # rsync -avrP ./0/ /var/lib/mysql
#        # chown -R mysql:mysql /var/lib/mysql
#        # service mysqld start
#
# 以下字段必须准确无误


project="${1}"                                       # 项目名
databaseName="${2}"                                  # 数据库名
databasePort="${3}"                                  # 数据库端口
databasePass="${4}"                                  # root用户密码
newDirFull="/opt/db-backup/full/${project}"          # 主目录，必须绝对路径
oldDirFull="/opt/db-backup/full-old/${project}"      # 旧的历史
newDirCore="/opt/db-backup/core/${project}"          # 主目录，必须绝对路径
oldDirCore="/opt/db-backup/core-old/${project}"      # 旧的历史
Secondary=".+jbc_order_m.+"                          # 排除出core，数据量很大且不怎么重要的表
ran="12"                                             # 一个备份周期，有多少次备份（其中一次全备，数次增备）
old="12"                                              # 保留多少个 "备份周期"
log="/var/log/xtrabackup.log-${project}"


# [centos@aws-dbbackup ~]$ sudo crontab -l
# ############  数据库备份                项目                 数据库        端口  root 密码
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-wu-bai      dbname        3316  password
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-feng-huang  dbname        3326  password
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-bi-ying     dbname        3336  password
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-nwu-bai     dbname        3346  password
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-x-88        dbname        3356  password
# */15 * * * *  /opt/script/dbbackup.sh  db-slave-xiaojufu    dbname        3366  password
# */15 * * * *  /opt/script/dbbackup.sh  xingyun              dbname        3376  password
# */15 * * * *  /opt/script/dbbackup.sh  quanmin              dbname        3386  password
# */15 * * * *  /opt/script/dbbackup.sh  shuangying           dbname        3396  password
# 0 0 */1 * *   /opt/script/dbbackup.sh  kaijiangwang         dbname        3406  password
# */15 * * * *  /opt/script/dbbackup.sh  dazhong              dbname        3407  password


###
### 检查信息
###

# 必须工具
list=( which bash xtrabackup awk date head grep ps wc mkdir sort xargs tail df find mktemp xz )
for x in ${list[@]}; do
    if [[ "$( which ${x} >/dev/null 2>&1 ; echo $? )" != "0" ]]; then
        echo "$(date '+%Y/%m/%d %H:%M:%S') need ${x}, now exit" >>"${newDirFull}/time.log"
        exit 1
    fi
done
unset list

# 必须参数
if [[ "$(echo ${@} |wc -w)" != "4" ]]; then
    echo "Method unknown"
    exit 1
fi

# 目录存在性
[[ ! -d "${newDirFull}" ]] && mkdir -p "${newDirFull}"
[[ ! -d "${oldDirFull}" ]] && mkdir -p "${oldDirFull}"
[[ ! -d "${newDirCore}" ]] && mkdir -p "${newDirCore}"
[[ ! -d "${oldDirCore}" ]] && mkdir -p "${oldDirCore}"

# 当上一个备份脚本还在运行，则本次退出
if [[ "$(ps -ef |grep -E ".*${0}.*${1}.*${2}.*${3}.*" |grep -v grep |wc -l)" != "2" ]]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') exist" >>"${newDirFull}/time.log"
    echo "Already running"
    exit 1
fi


###
### 清理旧备份
###

# 清理历史备份周期
lens="$(find ${oldDirFull} -type f -name 'db-*.tar.xz' |wc -l)"
if [[ ${lens} -gt ${old} ]]; then
    let rm=$lens-$old
    find ${oldDirFull} -type f -name 'db-*.tar.xz' |sort |head -n ${rm} |xargs rm -f
fi
lens="$(find ${oldDirCore} -type f -name 'db-*.tar.xz' |wc -l)"
if [[ ${lens} -gt ${old} ]]; then
    let rm=$lens-$old
    find ${oldDirCore} -type f -name 'db-*.tar.xz' |sort |head -n ${rm} |xargs rm -f
fi
unset lens

# 如果快没空间，则腾出空间
for (( i = 0; i < 2; i++ )); do
    if [[ "$(df -h ${oldDirFull} |tail -n 1 |awk '{print $(NF-1)}' |awk -F '%' '{print $1}')" -ge 96 ]]; then
        find "${oldDirFull}" -type f -name 'db-*.tar.xz' |sort |head -n 1 |xargs rm -f
    elif [[ "$(df -h ${oldDirCore} |tail -n 1 |awk '{print $(NF-1)}' |awk -F '%' '{print $1}')" -ge 96 ]]; then
        find "${oldDirCore}" -type f -name 'db-*.tar.xz' |sort |head -n 1 |xargs rm -f
    else
        break
    fi
done


###
### 开始备份
###

# 现在要执行第几次备份
number=0
for (( i = 0; i < ${ran}; i++ )); do
    if [[ ! -d "${newDirFull}/${i}" ]]; then
        number=${i}
        break
    fi
done

# 执行备份
ExecXtrabackup () { xtrabackup --backup --datadir="/opt/db/${project}" --host="127.0.0.1" --port="${databasePort}" --user="root" --password="${databasePass}" --databases="${databaseName}" $@ >${log} 2>&1; echo $?; }
timeStart="$(date '+%Y/%m/%d %H:%M:%S')"
for (( i = 0; i < 2; i++ )); do
    if [[ "${number}" == "0" ]]; then
        # 全备目录
        targetDirFull="${newDirFull}/0"
        targetDirCore="${newDirCore}/0"
        [[ -e "${targetDirFull}" ]] && rm -rf "${targetDirFull}"
        [[ -e "${targetDirCore}" ]] && rm -rf "${targetDirCore}"
        # 全备操作
        codeFull=$( ExecXtrabackup --target-dir="${targetDirFull}" )
        timeFull="$(date '+%Y/%m/%d %H:%M:%S')"
        codeCore=$( ExecXtrabackup --target-dir="${targetDirCore}" --tables-exclude="${Secondary}" )
        timeCore="$(date '+%Y/%m/%d %H:%M:%S')"
        # 全备完成
        unset targetDirFull
        unset targetDirCore
    else
        # 增备目录
        r="${number}"
        let r--
        targetDirFull="${newDirFull}/${number}"
        targetDirCore="${newDirCore}/${number}"
        [[ -e "${targetDirFull}" ]] && rm -rf "${targetDirFull}"
        [[ -e "${targetDirCore}" ]] && rm -rf "${targetDirCore}"
        baseDirFull="${newDirFull}/${r}"
        baseDirCore="${newDirCore}/${r}"
        # 增备操作
        codeFull=$( ExecXtrabackup --target-dir="${targetDirFull}" --incremental-basedir="${baseDirFull}" )
        timeFull="$(date '+%Y/%m/%d %H:%M:%S')"
        codeCore=$( ExecXtrabackup --target-dir="${targetDirCore}" --incremental-basedir="${baseDirCore}" --tables-exclude="${Secondary}" )
        timeCore="$(date '+%Y/%m/%d %H:%M:%S')"
        # 增备完成
        unset targetDirFull
        unset targetDirCore
        unset baseDirFull
        unset baseDirCore
        unset r
    fi

    # 备份失败则表示之前的备份已经损坏，删除上次所有备份和此次备份，然后重新全备
    if [[ "${codeFull}" == "0" ]] && [[ "${codeCore}" == "0" ]]; then
        break
    else
        rm -rf   "${newDirFull}" "${newDirCore}"
        mkdir -p "${newDirFull}" "${newDirCore}"
        number=0
        echo "${timeStart} error" >>"${newDirFull}/time.log"
        echo "${timeStart} error" >>"${newDirCore}/time.log"
    fi
done
echo "${timeFull} ${timeStart} ${number}" >>"${newDirFull}/time.log"
echo "${timeCore} ${timeStart} ${number}" >>"${newDirCore}/time.log"


# 一个完整备份周期完成，现在慢慢打包并压缩
integrate ()
{
    local whileDir="${1}"
    local fullDir="${2}"

    local fileName=$( awk '{print $1"-"$2}' "${whileDir}/time.log" |tail -n 1 |sed 's#/##g; s#:##g')
    local timeStart="$(date '+%Y/%m/%d %H:%M:%S')"

    local tmpDir="/tmp"
    while :; do
        tmpDir="${whileDir}_$(echo "${RANDOM}$(date '+%Y%m%d%H%M%S')" |md5sum |awk '{print $1}')"
        [[ ! -e "${tmpDir}" ]] && break
    done

    mkdir -p "${tmpDir}"
    mv "${whileDir}" "${tmpDir}"
    cd "${tmpDir}"

    tar -cf "${fullDir}/db-${fileName}.tar" '.'
    cd "/tmp"
    rm -rf "${tmpDir}"
    xz -4 "${fullDir}/db-${fileName}.tar"
    chmod 0440 "${fullDir}/db-${fileName}.tar.xz"

    local timeEnd="$(date '+%Y/%m/%d %H:%M:%S')"
    echo "db-${fileName}.tar.xz ${timeStart} ${timeEnd}" >>"${fullDir}/time.log"
}

let d=$ran-1
if [[ ${d} = ${number} ]]; then
    export -f integrate
    bash -c "integrate ${newDirFull} ${oldDirFull} &"
    bash -c "integrate ${newDirCore} ${oldDirCore} &"
fi
