#!/usr/bin/env bash


#
# 获取剪切板及选中区域数据
#
arg="$1"
getStrings ()
{
    # 需要的工具
    local list=( xsel chromium )
    for x in ${list[@]}; do
        if [[ "$( which "$x" >/dev/null 2>&1 ; echo $? )" != "0" ]]; then
            echo "need command $x, exit now"
            exit
        fi
    done

    if [[ -z ${arg} ]]; then
        echo "$( xsel -o )"
    else
        echo "${arg}"
    fi
}


#
# 解析出URL
#
getUrls ()
{
    local returnStrings=""

    # 单独处理单个域名
    local dataString="$@"
    for x in ${dataString[@]}; do

        # 原始数据是否包含协议
        local protocol="$( echo $x | grep -E '^(http|HTTP)[sS]?://' | wc -l )"
        local url=""

        # 没有
        if [[ "$protocol" == 0 ]]; then
            url="$( echo $x |sed 's#^#http://#' )"
        else
        # 有
            url="$x"
        fi

        # 准备返回数据
        returnStrings="$returnStrings $url"
    done

    echo $returnStrings
}


#
# 打开浏览器
#
chromium                            \
    --temp-profile                  \
    --new-window                    \
    --disable-gpu                   \
    --disable-3d-apis               \
    --disable-accelerated-video     \
    --disable-background-mode       \
    --disable-plugins               \
    --disable-translate	            \
    --disable-extensions            \
    --disable-notifications         \
    --dns-prefetch-disable          \
    --no-default-browser-check      \
    --window-size=1200,800          \
    $(getUrls $(getStrings) )

#--ignore-certificate-errors     \

