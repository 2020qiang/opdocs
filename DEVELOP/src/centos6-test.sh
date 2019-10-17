#!/usr/bin/env bash

# 毅哥
#
# 初始化脚本在一台机器上直接批量执行
# 执行只要执行修改必要的东西，不必要的东西会增加隐患，增加不确定性，增加复杂性，不容易维护
# 一键比对，清楚明了，不要做重复的事，重复做相同的工作很容易犯错
# 在其中一台机器上执行就好，不要增加复杂性

# 2018/03/15
#
# [用户账号登录]
#     user 用户可以远程登录，可以 su 切换
#     root 用户默认不能远程登录，仅仅能 su 切换
#     仅仅在 sshd  组中的用户才能 ssh 远程登录
#     仅仅在 wheel 组中的用户才能 su  切换到 root 环境
#     首次运行本脚本会踢下线除自己所有已登陆用户
#     所有用户登陆成功后如 300 秒没有操作，将会掉线
#     ssh客户端不允许传递任何环境变量
#
# [目录权限限制]
#     单独使用虚拟硬盘，文件存在于 /var/cache 目录中，umask为 1700
#     /tmp、/var/tmp、/var/log 目录禁用 不存在设备、suid、执行程序
#     /home 目录禁用 不存在设备、suid 文件
#     /home 目录大小 10G 上限
#     /tmp、/var/tmp、/var/log 每个目录 1G 上限
#     /tmp、/var/tmp 挂载权限为 1777 接近默认
#     /home、/var/log 挂载权限为 1755 接近默认
#
# [日志限制]
#     不使用日志分割/旋转功能
#     更改为友好记录格式
#     文件保存类型为 /var/log/程序名-等级.log
#     限制体积，每晚4点多检查，默认保留最后 20行及inode
#
# [网络]
#     删除网卡dns，仅仅使用 resolv.conf 全局dns
#     DNS优先级 (208.67.222.222 8.8.8.8 114.114.114.114)
#
# [时区/时间]
#     Asia/Hong_Kong 时区
#     运行本脚本会立马同步一次
#     每隔 6h 同步一次时间，如果本次同步失败，则下次1小时同步
#
# [安全限制]
#     文件描述符 sysctl.conf 为 655350
#     文件描述符 limits.conf 为 65535
#     暂时关闭防火墙，已配好默认规则，可选开启防火墙
#     禁用外部存储 usb/cdrom
#     孤儿文件先给予 属主/属组
#     tty 控制台仅仅允许打开一个


# 检查运行环境
export LC_ALL='C'
set-check () {
    if [[ $(id -u) != '0' ]]; then
        echo 'need root run'
        exit 1
    elif [[ -z $SSH_TTY ]]; then
        echo 'need ssh connect run'
        exit 1
    elif [[ -z $(cat /etc/redhat-release 2>/dev/null |grep -i -E 'centos.+6') ]]; then
        echo 'noly support centos 6'
        exit 1
    fi
}
set-check

# 输出相关信息，是否同意
set-echo () {

    # 随机密码
    user=$(echo $RANDOM  |md5sum)
    user=${user:1:24}
    root=$(echo $RANDOM  |md5sum)
    root=${root:1:24}

    echo
    read -p '    hostname: ' hostname
    if [[ -z $hostname ]]; then
        echo 'need set hostname'
        exit 1
    fi
    read -p """
    Warning:

        user: root - $root
        user: user - $user


    Enter [y/N]: """ check
    if [[ $check != 'y' ]]; then
        exit 1
    fi

    # 清屏，隐藏刚输出的密码
    printf '\033c'
}
set-echo

# 防止突然掉线
set-keep () {
    while true; do
        sleep 6s
        cat /dev/null
    done
}
set-keep &

# 检查默认配置文件是否存在
copy-file () {
    file=$1
    if [[ ! -f $file ]]; then
        cp -vf /dev/null $file
    fi

    dfile="$file.default"
    if [[ -f $dfile ]]; then
        cp -vf $dfile $file
    elif [[ ! -f $dfile ]]; then
        cp -vf $file $dfile
    fi
}

# 目录限额
# lvm 分区不适用缩小已挂载的磁盘，必须注意
set-fstab () {
    file='/etc/fstab'
    chattr -i $file
    copy-file $file

    # 卸载其余 lvm 卷
    tmp=$(lvs|grep -v -E 'lv_(root|swap)'|awk '{print $2"-"$1}')
    for x in ${tmp[@]}; do
        if [[ $x != 'VG-LV' ]]; then
            umount "/dev/mapper/$x"
        fi
    done

    # 删除其余 lvm 卷
    tmp=$(lvs|grep -v -E 'lv_(root|swap)'|awk '{print $2"/"$1}')
    for x in ${tmp[@]}; do
        if [[ $x != 'VG/LV' ]]; then
            lvremove -f $x
        fi
    done

    # root卷使用所有空闲
    lvresize -l +100%FREE /dev/mapper/VolGroup-lv_root
    resize2fs /dev/mapper/VolGroup-lv_root

    # shm 大小及安全限制
    sed -i '/\/shm/d' $file
    echo 'tmpfs /dev/shm tmpfs rw,nosuid,noexec,nodev,size=100m 0 0' >>$file

    # 磁盘配额限制
    sed -i '/\/home/d'     $file
    sed -i '/\/tmp/d'      $file
    sed -i '/\/var\/tmp/d' $file
    sed -i '/\/var\/log/d' $file
    echo '/var/cache/home   /home    ext4 loop,rw,nosuid,nodev        0 0' >>$file
    echo '/var/cache/tmp    /tmp     ext4 loop,rw,nosuid,noexec,nodev 0 0' >>$file
    echo '/var/cache/vartmp /var/tmp ext4 loop,rw,nosuid,noexec,nodev 0 0' >>$file
    echo '/var/cache/varlog /var/log ext4 loop,rw,nosuid,noexec,nodev 0 0' >>$file
    rm -vf /var/cache/home
    rm -vf /var/cache/tmp
    rm -vf /var/cache/vartmp
    rm -vf /var/cache/varlog
    dd if=/dev/zero of=/var/cache/home   bs=1M count=0 seek=10000
    dd if=/dev/zero of=/var/cache/tmp    bs=1M count=0 seek=1000
    dd if=/dev/zero of=/var/cache/vartmp bs=1M count=0 seek=1000
    dd if=/dev/zero of=/var/cache/varlog bs=1M count=0 seek=1000
    chmod -v 1700 /var/cache/home
    chmod -v 1700 /var/cache/tmp
    chmod -v 1700 /var/cache/vartmp
    chmod -v 1700 /var/cache/varlog
    mkfs.ext4 -F /var/cache/home
    mkfs.ext4 -F /var/cache/tmp
    mkfs.ext4 -F /var/cache/vartmp
    mkfs.ext4 -F /var/cache/varlog
    mount -o loop /var/cache/home   /home
    mount -o loop /var/cache/tmp    /tmp
    mount -o loop /var/cache/vartmp /var/tmp
    mount -o loop /var/cache/varlog /var/log
    chmod -v 1755 /home
    chmod -v 1777 /tmp
    chmod -v 1777 /var/tmp
    chmod -v 1755 /var/log

    chattr +i $file
}
set-fstab

# 新建用户模板/更改root密码/创建user用户及密码/su切换用户白名单/踢下其他所有用户
set-user () {
    # 新建用户配置文件模板
    file='/etc/default/useradd'
    copy-file $file
    cp -vf /dev/null $file
    chattr -i $file
    echo 'GROUP=100'       | tee -a $file
    echo 'HOME=/home'      | tee -a $file
    echo 'SHELL=/bin/bash' | tee -a $file
    chattr +i $file

    # 更改密码，新建用户及密码
    echo $root | passwd --stdin root
    useradd user
    echo $user | passwd --stdin user
    usermod -a -G sshd user

    # 添加允许su特权的用户
    file='/etc/pam.d/su'
    chattr -i $file
    copy-file $file
    sed -i '/pam_wheel.so/d' $file
    sed -i '2a auth required pam_wheel.so use_uid' $file
    chattr +i $file
    usermod -a -G wheel user

    # 踢下线其他所有终端
    kill $(ps -ef                       \
        |awk '{print $3 " " $6}'        \
        |grep -E '(tty|pts)'            \
        |grep -v                        \
            $(echo "pts/$(echo $SSH_TTY \
            |awk -F '/' '{print $NF}')" \
        )|                              \
        grep -v ^'1 tty'                \
        |awk '{print $1}')

    # 需要的环境变量
    file='/etc/profile'
    copy-file $file
    echo 'LC_ALL=C'                      |tee -a $file
    echo 'TMOUT=300'                     |tee -a $file
    echo 'TIMEOUT=300'                   |tee -a $file
    echo 'export LC_ALL TMOUT TIMEOUT'   |tee -a $file
    echo 'readonly LC_ALL TMOUT TIMEOUT' |tee -a $file
    echo 'export PS1="[\u@\h \W]\\$ "'   |tee -a $file
}
set-user

# 更新软件包/安装软件包
set-package () {
    yum update -y
    yum upgrade -y
    yum install -y epel-release yum-utils
    yum install -y htop lsof iftop iotop screen wget tree zip unzip screen ntpdate mlocate rsync bc git extundelete telnet mailx rsyslog-relp
}
set-package

# 优化 sshd
file='/etc/ssh/sshd_config'
sshd-config () {
    if [[ -z $(grep -E ^"#*${1}" $file) ]]; then
        echo "$1 $2" >>$file
    else
        sed -i "s/^#*${1} .*[yes|no|22|::|0|3]$/${1} ${2}/g" $file
    fi
}
set-sshd-config () {
    chattr -i $file
    copy-file $file
    # sshd-config ListenAddress $sshHost     # SSH 监听地址
    # sshd-config Port 1022                  # SSH 监听端口
    sshd-config Protocol 2                 # 使用的SSH协议
    sshd-config PermitRootLogin no         # 禁止root远程登陆
    sshd-config AddressFamily inet         # 仅使用IPv4地址族
    sshd-config UseDNS no                  # 禁用反向解析
    sshd-config GSSAPIAuthentication no    # 不使用GSSAPI进行验证
    sshd-config X11Forwarding no           # 不允许X11转发
    sshd-config PermitEmptyPasswords no    # 不允许空密码
    sshd-config ClientAliveInterval 100    # 减少空闲登录时间
    sshd-config ClientAliveCountMax 2      # 减少空闲登录时间
    sshd-config AllowGroups sshd           # 仅仅允许特定的组远程ssh
    sshd-config Compression yes            # 始终对通信数据进行加密
    sed -i '/AcceptEnv/d' $file            # 不允许传递任何环境变量
    chattr +i $file
}
set-sshd-config

# 时区/时间
set-zone-time () {
    cp -vf /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
    echo 'ZONE="Asia/Hong_Kong"' |tee /etc/sysconfig/clock

    file='/etc/init.d/auto-ntpdate'
    url='https://wiki.liuq.org/script/auto-ntpdate.sh.txt'
    rm -vf $file
    wget -c $url -O $file
    chmod 0700 $file
    chkconfig auto-ntpdate on

    ntpdate pool.ntp.org
}
set-zone-time

# 主机名/DNS
set-my-name () {

    # 更改主机名
    file='/etc/sysconfig/network'
    chattr -i $file
    copy-file $file
    sed -i "/HOSTNAME=/d" $file
    echo "HOSTNAME=$hostname" |tee -a $file
    chattr +i $file

    # 更改主机名
    file='/etc/hosts'
    chattr -i $file
    copy-file $file
    sed -i "s#localhost\ #$hostname\ localhost\ #g" $file
    chattr +i $file

    # 更改指定DNS
    tmp=$(find /etc/sysconfig/network-scripts -name 'ifcfg-*'|grep -v lo)
    for x in ${tmp[@]}; do
        chattr -i $x
        sed -i '/DNS/d' $x
        chattr +i $x
    done
    file='/etc/resolv.conf'
    chattr -i $file
    rm -vf $file
    echo 'nameserver 208.67.222.222'  |tee -a $file
    echo 'nameserver 8.8.8.8'         |tee -a $file
    echo 'nameserver 114.114.114.114' |tee -a $file
    chattr +i $file
}
set-my-name

# 内核参数优化/关闭防火墙/关闭selinux/禁用外部存储/grub/tty/ctrl+alt+del
set-security () {

    # 文件描述符总体大小
    file='/etc/sysctl.conf'
    chattr -i $file
    copy-file $file
    rm -vf $file
    wget -c https://wiki.liuq.org/script/sysctl.conf.txt -O $file
    chmod -v 1600 $file
    chattr +i $file

    # 文件描述符单用户大小
    file='/etc/security/limits.conf'
    chattr -i $file
    copy-file $file
    sed -i '/\ nofile\ /d' $file
    echo '* hard nofile 65535' |tee -a $file
    echo '* soft nofile 65535' |tee -a $file
    chattr +i $file

    # 关闭 防火墙
    iptables  -P INPUT ACCEPT
    ip6tables -P INPUT ACCEPT
    iptables  -F
    ip6tables -F
    iptables  -X
    ip6tables -X
    iptables -t filter -A INPUT -i lo -j ACCEPT
    iptables -t filter -A INPUT -p icmp -j ACCEPT
    iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -t filter -A INPUT -j DROP
    ip6tables -t filter -A INPUT -j DROP
    /etc/init.d/iptables  save
    /etc/init.d/ip6tables save
    /etc/init.d/iptables  stop
    /etc/init.d/ip6tables stop
    chkconfig iptables  off
    chkconfig ip6tables off

    # 关闭 selinux
    file='/etc/selinux/config'
    chattr -i $file
    copy-file $file
    sed -i '/SELINUX=/d' $file
    echo 'SELINUX=disabled' >>$file
    chattr +i $file

    # 禁用 USB/cdrom 存储
    rm -vf /lib/modules/*/kernel/drivers/usb/storage/usb-storage.ko
    rm -vf /lib/modules/*/kernel/drivers/cdrom/cdrom.ko

    # 配置grub启动时间
    # 移除 plymouthd 进程占用cpu的隐患
    file='/etc/grub.conf'
    copy-file $file
    sed -i 's/^timeout=.*$/timeout=0/' $file
    sed -i 's/^default=.*$/default=0/' $file
    sed -i 's/rhgb//g'                 $file
    cp -vf $file /boot/grub/grub.conf

    # 禁用多个tty
    file='/etc/sysconfig/init'
    copy-file $file
    sed -i 's#tty\[1-6\]#tty1#' $file
    
    # 禁用ctrl+alt+del重启
    file='/etc/init/control-alt-delete.conf'
    copy-file $file
    cp -vf /dev/null $file
}
set-security

# 日志格式/禁用日志分割/限制日志
set-log () {
    # 不使用日志分割
    copy-file /etc/logrotate.conf
    cp -vf /dev/null /etc/logrotate.conf
    rm -vrf /etc/logrotate.d

    # 日志记录格式
    file='/etc/rsyslog.conf'
    copy-file $file
    /etc/init.d/rsyslog stop
    cp -vf /dev/null $file
    echo '$ModLoad          imklog'                                               >>$file
    echo '$ModLoad          imuxsock'                                             >>$file
    echo '$ModLoad          imudp'                                                >>$file
    echo '$UDPServerRun     514'                                                  >>$file
    echo '$UDPServerAddress 127.0.0.1 '                                           >>$file
    echo '$template xsformat, "%$YEAR%/%$MONTH%/%$DAY%_%TIMESTAMP:8:15% %msg%\n"' >>$file
    echo '$ActionFileDefaultTemplate xsformat'                                    >>$file
    echo '$ActionResumeRetryCount     -1'                                         >>$file
    echo '$ActionQueueSaveOnShutdown  on'                                         >>$file
    echo '$ActionQueueMaxDiskSpace    5g'                                         >>$file
    echo '$ActionQueueType            LinkedList'                                 >>$file
    echo '$ActionQueueFileName        fwdRule1'                                   >>$file
    echo '$WorkDirectory              /var/lib/rsyslog'                           >>$file
    echo '$PreserveFQDN               on'                                         >>$file
    echo '$InputFilePollingInterval   10'                                         >>$file
    echo '$template loca, "/var/log/%programname%-%syslogseverity-text%.log"'     >>$file
    echo ':fromhost-ip, isequal, "127.0.0.1" ?loca'                               >>$file
    echo '& ~'                                                                    >>$file
    chkconfig rsyslog on

    # 限制日志体积
    file='/etc/init.d/auto-clean-log'
    url='https://wiki.liuq.org/script/auto-clean-log.sh.txt'
    rm -vf $file
    wget -c $url -O $file
    chmod 0700 $file
    chkconfig auto-clean-log on
}
set-log

# 配置rm/rc.local
set-rm-rc () {
    wget -c 'https://wiki.liuq.org/script/rm-check.sh.txt' -O /bin/rm-check
    chmod +x /bin/rm-check
    rm -vrf /root/* 
    rm -vrf /root/.*
    echo "unalias -a"                |tee -a /etc/profile /root/.bashrc
    echo "alias rm='/bin/rm-check'"  |tee -a /etc/profile /root/.bashrc
    echo "alias cp='cp -i'"          |tee -a /etc/profile /root/.bashrc
    echo "alias ls='ls --color'"     |tee -a /etc/profile /root/.bashrc
    echo "alias grep='grep --color'" |tee -a /etc/profile /root/.bashrc

    file='/etc/rc.d/rc.local'
    cp -vf /dev/null $file
    echo '#/usr/bin/env bash'           |tee -a $file
    echo 'touch /var/lock/subsys/local' |tee -a $file
    ln -vsf $file /etc/rc.local
    chmod -v +x $file
    chmod -v +x /etc/rc.local
}
set-rm-rc

# 精简 没用服务/包/用户组/用户/配置文件/孤儿文件
set-remove () {

    # 服务
    tmp=(netfs ntpdate postfix nfs nfs-rdma postfix rpcbind rpcgssd rpcgssd)
    for x in ${tmp[@]}; do
        chkconfig $x off
    done

    # 软件包
    yum remove -y postfix man xinetd vim
    rm -vrf /etc/cron*
    yum install -y crontabs
    yum clean all
    package-cleanup --leaves -q|xargs yum -y remove

    # 删除用户
    for (( i = 0; i < 3; i++ )); do
        tmp='(root|bin|daemon|nobody|sshd|user)'
        tmp=$(grep -v -E ^$tmp /etc/passwd|awk -F ':' '{print $1}')
        for x in ${tmp[@]}; do
            userdel $x
        done
    done

    # 删除用户组
    for (( i = 0; i < 3; i++ )); do
        tmp='(root|bin|daemon|nobody|sshd|wheel|users|user)'
        tmp=$(grep -v -E ^$tmp /etc/group|awk -F ':' '{print $1}')
        for x in ${tmp[@]}; do
            groupdel $x
        done
    done

    # 删除残留
    rm -vrf /var/spool/mail
    rm -vrf /var/lib/postfix
    rm -vrf /var/spool/postfix
    rm -vrf /etc/init.d/ntpdate
    rm -vrf /home/user/*
    rm -vrf /home/user/.*

    # 更改没有属主和属组的文件及目录
    file=$(find / -nouser -o -nogroup 2>/dev/null)
    for x in ${file[@]}; do
        if [[ -f $x ]] || [[ -d $x ]]; then
            chown -v root:root $x
        fi
    done
}
set-remove

# 重启生效
shutdown -r 0