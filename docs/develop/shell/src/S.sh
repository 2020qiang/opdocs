#!/usr/bin/env bash


# 接受参数
set -e
export LC_ALL="C"
proxyPL="$1"  # P = jumpConnection / L = directConnection
hostRaw="$2"
passRaw="$3"
userName="${4:-centos}"
servPoer="${5:-22}"
term="terminator"


#
# 直接连接
#
directConnection ()
{
    # 主机名
    local head=$( timeout --signal=SIGKILL 4s                                   \
        sshpass -p ${passRaw}                                                   \
            ssh -q -o 'StrictHostKeyChecking no'                                \
                   -o 'UserKnownHostsFile /dev/null'                            \
                   -o 'ServerAliveInterval 10'                                  \
                      ${userName}@${hostRaw} -p ${servPoer} 'echo $HOSTNAME' )

    # 连接失败
    if [[ -z "${head}" ]]; then
        xterm -T asd -e 'echo -e "\n timeout ${hostRaw}" && sleep 4s && exit 1'
        exit
    fi

    # 连接
    ${term} -T "${head}" -e "sshpass -p ${passRaw}                              \
           ssh -q -o 'StrictHostKeyChecking no'                                 \
                  -o 'UserKnownHostsFile /dev/null'                             \
                  -o 'ServerAliveInterval 10'                                   \
                  ${userName}@${hostRaw} -p ${servPoer}"
}


#
# 使用跳板机跳转连接
#
jumpConnection ()
{
    # 跳板机用户名及密码
    # useradd jumpUser -s /bin/false -d /dev/null
    # usermod -a -G sshd jumpUser
    # echo passWord |passwd --stdin jumpUser
    local jumpHost=""
    local jumpPort="22"
    local jumpUser=""
    local jumpPass=""

    # 主机名
    local head=$( timeout --signal=SIGKILL 4s                                                                   \
                    sshpass -p ${passRaw}                                                                       \
                    ssh -q -o 'StrictHostKeyChecking no'                                                        \
                           -o 'UserKnownHostsFile /dev/null'                                                    \
                           -o 'ServerAliveInterval 10'                                                          \
                           ${userName}@${hostRaw} -p ${servPoer} -o "ProxyCommand sshpass -p ${jumpPass}        \
                                ssh -q -o 'StrictHostKeyChecking no'                                            \
                                       -o 'UserKnownHostsFile /dev/null'                                        \
                                       -o 'ServerAliveInterval 10'                                              \
                                       ${jumpUser}@${jumpHost} -p ${jumpPort} -W %h:%p" 'echo $HOSTNAME' )

    # 连接失败
    if [[ -z "${head}" ]]; then
        xterm -T asd -e 'echo -e "\n timeout ${hostRaw} / ${jumpHost}" && sleep 4s && exit 1'
        exit
    fi

    # 登陆
    ${term} -T "${head}" -e "sshpass -p ${passRaw}                                                              \
        ssh -q -o 'StrictHostKeyChecking no'                                                                    \
               -o 'UserKnownHostsFile /dev/null'                                                                \
               -o 'ServerAliveInterval 10'                                                                      \
               ${userName}@${hostRaw}                                                                           \
                    -o \"ProxyCommand sshpass -p ${jumpPass}                                                    \
                        ssh -q -o 'StrictHostKeyChecking no'                                                    \
                               -o 'UserKnownHostsFile /dev/null'                                                \
                               -o 'ServerAliveInterval 10'                                                      \
                               ${jumpUser}@${jumpHost} -p ${jumpPort} -W %h:%p\""
}


ibus engine xkb:us::eng
case "${proxyPL}" in
    'L')
        directConnection
        ;;
    "P")
        jumpConnection
        ;;
    *)
        echo "入参错误"
        exit 1
        ;;
esac
ibus engine sunpinyin

