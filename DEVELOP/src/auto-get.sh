#!/usr/bin/env bash
#chkconfig: 2345 90 10


# crontab -l
# */30 * * * *  /etc/init.d/auto-get cronGET all/task_Clear_killOnlinePayOverHalfhour
# 10   6 * * *  /etc/init.d/auto-get cronGET all/task_ReportedData_reportMoney
# 10   6 * * *  /etc/init.d/auto-get cronGET all/task_Clear_clearWinOrLose
# 10   6 * * *  /etc/init.d/auto-get cronGET all/task_Clear_updateTopDew
# 10   6 * * *  /etc/init.d/auto-get cronGET all/task_Clear_clearTrialWinOrLose
# */1  * * * *  /etc/init.d/auto-get cronGET all/task_Wallet_send
# */10 * * * *  /etc/init.d/auto-get cronGET all/task_Wallet_summary
# */1  * * * *  /etc/init.d/auto-get cronGET all/task_RedPackGame_sendWelfare


#
# 必须满足的要求
#
startCheck ()
{
    # 必须的工具
    local list=( su curl wget awk date head grep ps jq tee wc dirname basename )
    for x in ${list[@]}; do
        if [[ "$( which ${x} >/dev/null 2>&1 ; echo $? )" != "0" ]]; then
            echo "need command $x, exit now"
            exit
        fi
    done

    # 必须的用户
    if [[ "$(id -u)" != "0" ]]; then
        echo 'need root run'
        exit
    fi
    id "${runUser}" >/dev/null 2>&1
    if [[ "$?" != "0" ]]; then
        useradd "${runUser}" -s /bin/false -M >/dev/null 2>&1
    fi

    # 必须的目录
    local logDir="/var/log/${runUser}"
    if [[ ! -d "${logDir}" ]]; then
        mkdir -p "${logDir}"
        chown "${runUser}:${runUser}" "${logDir}"
    fi
}


#
# http Get 请求并获取 resCode
#
GET ()
{
    local tag="${1}"  # 日志标识
    local arg="${2}"  # 请求地址

    local Time="$(date +%s)"
    local logDir="/var/log/${runUser}"
    local logNew="${logDir}/$(date -d @${Time} +%Y%m%d).log"
    local logDel="${logDir}/old_$(date -d @${Time} +%Y%m%d --date='60 days ago').log.gz"

    local out=$( curl -s \
          --connect-timeout "20" -m "40" \
          -H "X-Requested-With:XMLHttpRequest" -H "Content-Type:application/x-www-form-urlencoded" \
          -x "http://127.0.0.1:80" \
          "api.local/${arg}" 2>/dev/null )
    local status="${?}"

    # format
    local resCode=$( echo ${out} |jq '.resCode' 2>/dev/null )
    [[ -z "${out}" ]]        && resCode="null"
    [[ -z "${resCode}" ]]    && resCode="$(echo ${out} |head -n 1 |awk '{print $1}')"
    [[ "${status}" != "0" ]] && resCode="error"

    # recording
    echo "$( date -d @${Time} '+%Y/%m/%d %H:%M:%S' ) ${tag} ${resCode}:$(echo ${out}| wc -m) ${arg}" >>"${logNew}"

    # clear old
    [[ -f "${logDel}" ]] && rm -f "${logDel}"
    # compression
    local old="${logDir}/$(date -d @${Time} +%Y%m%d --date='1 days ago').log"
    if [[ -f "${old}" ]] && [[ ! -f "${old}.gz" ]]; then
        mv "${old}" "$(dirname ${old})/old_$(basename ${old})"
        gzip        "$(dirname ${old})/old_$(basename ${old})"
    fi

    echo "${resCode}"
    return "${status}"
}


############################################################
#
# 投注站彩种规则
#
newbcRun ()
{
    for (( i = 0; i < 5; i++ )) {

        # 第二次
                          GET "12" "all/task_TaskOrder_action?code=${1}&queuetype=1" >/dev/null &
                          GET "12" "all/task_TaskOrder_action?code=${1}&queuetype=2" >/dev/null &
        local resCode="$( GET "12" "all/task_TaskOrder_action?code=${1}&queuetype=3" )"
        if [[ "${resCode}" == "1000" ]]; then

            # 第三次
            GET "13" "all/task_WeSend_sendNewCodeData?code=${1}" &
            break
        fi

        sleep 1s
    }
}

# 重点 txffc
newbcRun-txffc ()
{
    for (( i=0; i<5; i++ )) {

        # 第二次
                          GET "22" "all/task_TaskOrder_action?code=${1}&queuetype=1&type=2" >/dev/null &
                          GET "22" "all/task_TaskOrder_action?code=${1}&queuetype=2&type=2" >/dev/null &
        local resCode="$( GET "22" "all/task_TaskOrder_action?code=${1}&queuetype=3&type=2" )"
        if [[ "${resCode}" == "1000" ]]; then

            # 第三次
            GET "23" "all/task_WeSend_sendNewCodeData?code=${1}" &
            break
        fi

        sleep 1s
    }
}


newbcRely ()
{
    local masterCode="${1}"  # 主要的彩种code
    local slaveCode="${2}"   # 次要的彩种code

    while true; do

        # 第一次
        local resCode=$( GET "01" "all/task_CodeData_getCodeResult?code=${masterCode}" )

        # 第二次
        if [[ "${resCode}" == "1000" ]]; then
            newbcRun "${masterCode}"
            newbcRun "${slaveCode}"
        fi

        sleep 3s
    done
}

newbcMain ()
{
    local sleepTime="${1}"
    local lotteryCode="${2}"

    while true; do

        # 第一次
        # resCode == 1000
        local code=$( GET "01" "all/task_CodeData_getCodeResult?code=${lotteryCode}" )

        # 第二次
        if [[ "${code}" == "1000" ]]; then
            newbcRun "${lotteryCode}"
        fi

        # 第二次
        # 重点 txffc
        if [[ "${lotteryCode}" == "txffc" ]] && [[ "${code}" == "20100" ]]; then
            newbcRun-txffc "${lotteryCode}"
        fi

        sleep "${sleepTime}"
    done
}


newbcStart ()
{
    local newbc3s=( jsk3  jsssc  jsft  mlaft  cqssc  cqklsf gd11x5 gdklsf
                    hk6   xyhk6  txffc jx11x5 sd11x5 xjssc  tjssc  shk3
                    bjk3  jlk3   mjsk3 hlsc   hlft   hlssc  fc3d   pl3
                    azxy5 azxy10 hubk3 gxk3   ahk3   hebk3  gsk3   gzk3
                    hlk3  )

    for x in ${newbc3s[@]}; do
        newbcMain "3s" "${x}" >/dev/null 2>&1 &
    done

    newbcMain 8s fc3d   >/dev/null 2>&1 &
    newbcMain 8s pl3    >/dev/null 2>&1 &

    newbcRely bjkl8  pcdd   >/dev/null 2>&1 &
    newbcRely bjpk10 pk10nn >/dev/null 2>&1 &
    newbcRely jssc   jsnn   >/dev/null 2>&1 &
}


###########################################################
#
# 循环简单执行，入参 "1间隔时间 2请求参数"
#
simpleWhile ()
{
    while true; do
        GET "simple:${1}" "${2}" >/dev/null
        sleep "${1}"
    done
}

simpleStart ()
{
    simpleWhile "20s" "all/task_WeSend_sendNewInfo" &
    simpleWhile "10s" "all/task_ReportedData_orderReportedQueue" &
    simpleWhile "10s" "all/task_ReportedData_rechargeReportedQueue" &
    simpleWhile "10s" "all/task_ReGameReported_reGameReportQueue" &
}


###########################################################
#
# 红包任务
#
rbStart ()
{
    while :; do
        for (( i=0; i<3; i++ )); do
            [[ "$(GET "rb" "all/task_redPackGame_action")" == "1000" ]] \
            && break
        done
        sleep "10s"
    done
}


###########################################################

main ()
{
    # 启动简单任务
    export -f simpleWhile
    export -f simpleStart
    su "${runUser}" -s "$(which bash)" -c "simpleStart &"

    # 启动newbc项目任务
    export -f newbcRun
    export -f newbcRun-txffc
    export -f newbcRely
    export -f newbcMain
    export -f newbcStart
    su "${runUser}" -s "$(which bash)" -c "newbcStart &"

    # 启动红包任务
    export -f rbStart
    su "${runUser}" -s "$(which bash)" -c "rbStart &"
}

# return 1, 停止中
# return 0, 运行中
is_running ()
{
    if [[ "$( ps -u ${runUser} -f |wc -l )" == "1" ]]; then
        return 1
    else
        return 0
    fi
}

cronGET ()
{
    local arg="${1}"
    [[ -z "${arg}" ]] && echo "GET arg is null" && return 1
    su "${runUser}" -s "$(which bash)" -c "GET cron ${arg} >/dev/null 2>&1 &"
}


###########################################################

# 必须满足的要求
export runUser="auto-get"
startCheck

case "${1}" in
    'start')

        # 必须满足的要求
        [[ "$( ps -u ${runUser} -f |wc -l )" != "1" ]] \
        && echo '[ OK ] already running' \
        && exit 0

        export -f GET
        main

        # 返回启动结果
        for (( i=0; i<12; i++ )) {
            is_running && sleep 0.5s \
            && echo "[ OK ] startup success" \
            && exit 0
        }
        echo "[ NO ] startup failed"
        exit 1
        ;;

    'stop')
        for (( i=0; i<6; i++ )) {
            is_running
            if [[ "${?}" == "0" ]]; then
                ps -u "${runUser}" -f |awk '{print $2}' \
                |xargs -n 10 kill -9 >/dev/null 2>&1
            else
                [[ "${i}" == "0" ]] && echo "[ OK ] already stop"
                [[ "${i}" != "0" ]] && echo "[ OK ] stop success"
                exit 0
            fi
            sleep 0.5s
        }
        echo "[ NO ] stop failed"
        exit 1
        ;;

    'status')
        is_running && ( echo "[ OK ] already running" && exit 0 )
        is_running || ( echo "[ NO ] already stop"    && exit 1 )
        ;;

    'cronGET')
        [[ -z "${2}" ]] && echo "error: GET arg is null" && exit 1
        export -f GET
        su "${runUser}" -s "$(which bash)" -c "GET cron ${2} >/dev/null 2>&1 &"
        ;;

    'restart')
        $0 stop
        $0 start
        ;;

    *)
        echo "Usage: ${0} {start|stop|status|cronGET|restart}"
        exit 1
        ;;
esac
exit 0
