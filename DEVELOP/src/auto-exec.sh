#!/usr/bin/env bash



#  0 09 * * *  source /etc/init.d/auto-exec; cronPHP think stock --action=updateStockList
# 15 09 * * *  source /etc/init.d/auto-exec; cronPHP think stock --action=updateCategory
#  0 16 * * *  source /etc/init.d/auto-exec; cronPHP think order --action=cancel
execPHP ()
{
    export args="${@}"
    cd "/opt/www/php"
    local dir="${logDir}/$(date '+%Y%m%d')"
    [[ ! -d "${dir}" ]] && mkdir -p "${dir}"
    local file="$(echo ${args} |sed 's#[^a-zA-Z0-9]#_#g')"
    local log="${dir}/${file}.log"

    echo "$(date '+%Y/%m/%d %H:%M:%S') start"                 >>${log}
    echo "${PWD}; ${phpUser}; php ${args}"                    >>${log}
    sudo su "${phpUser}" -s "$(which bash)" -c "php ${args}"  >>${log} 2>&1
    echo "$(date '+%Y/%m/%d %H:%M:%S') end"                   >>${log}
    echo -e "\n\n"                                            >>${log}
}
cronPHP ()
{
    export args="${@}"
    su "${runUser}" -s "$(which bash)" -c  "execPHP ${args}"
}
export -f execPHP
export -f cronPHP

# 10s php think stock --action=update
# 5s  php think stock --action=match
me_where ()
{
    (
    while :;do
        execPHP think stock --action=update
        sleep 10s
    done
    )&

    (
    while :;do
	    execPHP think order --action=match
        sleep 5s
    done
    )&

    (
    while :;do
	    execPHP think stock --action=notify
        sleep 1s
    done
    )&
}


main ()
{
    export -f execPHP
    export -f me_where
    su "${runUser}" -s "$(which bash)" -c  "me_where &"
}

####################################################################################################
#
# 必须满足的要求
#
startCheck ()
{
    # 必须的工具
    local list=( which bash su sudo id awk date head grep ps pstree wc php )
    for x in ${list[@]}; do
        if [[ "$( which ${x} >/dev/null 2>&1 ; echo $? )" != "0" ]]; then
            echo "[ NO ] need command ${x}"
            exit 1
        fi
    done

    # 必须的用户
    if [[ "$(id -u)" != "0" ]]; then
        echo '[ NO ] need root run'
        exit 1
    fi
    id "${runUser}" >/dev/null 2>&1
    if [[ "$?" != "0" ]]; then
        useradd "${runUser}" -s /bin/false -M >/dev/null 2>&1
    fi

    # 用户权限
    su "${runUser}" -s "$(which bash)" -c "sudo su ${phpUser} -s "$(which bash)" -c id" >/dev/nill 2>&1
    if [[ "${?}" != "0" ]]; then
        echo "need visudo"
        echo "Cmnd_Alias SU=/bin/su"
        echo "auto-exec ALL=(ALL) NOPASSWD:SU"
        exit 1
    fi

    # 必须的日志文件存放位置
    if [[ ! -d "${logDir}" ]]; then
        rm -f "${logDir}"                            >/dev/null 2>&1
        mkdir -p "${logDir}"                         >/dev/null 2>&1
        chown "${runUser}:${runUser}" -R "${logDir}" >/dev/null 2>&1
    fi
    chown "${runUser}:${runUser}" -R "${logDir}"     >/dev/null 2>&1
}

####################################################################################################
#
# 每日定时清理日志
#
cleanLog ()
{
    while :; do
        rm -rf "${logDir}/$(date +%Y%m%d --date='6 days ago')/"
        rm -rf "${logDir}/$(date +%Y%m%d --date='6 week ago')/"
        sleep 23h
    done
}

####################################################################################################
#
# return 0, 运行中
# return 1, 停止中
#
running ()
{
    if [[ "$( ps -u ${runUser} -f |wc -l )" == "1" ]]; then
        return 1
    else
        return 0
    fi
}

####################################################################################################

export runUser="auto-exec"
export logDir="/var/log/${runUser}"
export phpUser="$(ps -ef|grep -w 'php-fpm' |awk '{print $1}' |sort |uniq -c |sort -n |tail -n 1 |awk '{print $NF}')"

# 必须满足的要求
startCheck

case $1 in
    'start')

        # 必须满足的要求
        [[ "$( ps -u ${runUser} -f |wc -l )" != "1" ]] && echo '[ OK ] already running' && exit 0

        # 每日定时清理日志
        export -f cleanLog
        su "${runUser}" -s "$(which bash)" -c "cleanLog &"

        # 启动自动执行
        main

        # 返回启动结果
        for (( i=0; i<12; i++ )) {
            running && sleep 0.5s && echo "[ OK ] startup success" && exit 0
        }
        echo "[ NO ] startup failed"
        exit 1
        ;;
    'stop')
        i=0
        while :; do
            running
            if [[ "$?" == "0" ]]; then
                ppids="$(ps -u "${runUser}" -f |awk '{print $2}')"
                for ppid in ${ppids[@]}; do
                    pids="$(pstree -p ${ppid} 2>/dev/null)"
                    echo ${pids} |sed 's#[^0-9]# #g' |xargs -n 99 kill -9 >/dev/null 2>&1
                done
            else
                [[ "${i}" == "0" ]] && echo "[ OK ] already stop"
                [[ "${i}" != "0" ]] && echo "[ OK ] stop success"
                exit 0
            fi
            sleep 0.5s
            let i++
        done
        echo "[ NO ] stop failed"
        ;;
    'status')
        running && ( echo "[ OK ] already running" && exit 0 )
        running || ( echo "[ NO ] already stop"    && exit 1 )
        ;;
    'restart')
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        ;;
esac
