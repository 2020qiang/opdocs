#!/usr/bin/env bash

# 创建时间 2020/06/18
# 更新时间 2020/06/18
#
# 作用
#     telegraf监控，使用path;ip分析客户端经常请求的接口 - （是异常）
#     用于让开发为指定接口添加验证码（因为总不能有接口都加验证码）
# 配置
#     /etc/telegraf/telegraf.conf
#     [[inputs.exec]]
#       commands = ["/etc/telegraf/nginx-request-frequency-json.sh base"]
#       timeout = "5s"
#       name_suffix = "_req"
#       data_format = "json"
#       data_type = "integer"
#     [[inputs.exec]]
#       commands = ["/etc/telegraf/nginx-request-frequency-json.sh ip"]
#       timeout = "5s"
#       name_suffix = "_req_ip"
#       data_format = "json"
#       data_type = "integer"
# 测试
#     telegraf -input-filter exec -test
# 说明
#     用telegraf触发，这属于抽查；但是也很有效，因为总异常时间越长，抽查中的概率越大
#     用telegraf每5秒触发，日志只分析一秒
#     为什么不分析日志5秒：不好处理格式，需要时也能优化


case "${1}" in
"base")
    # shellcheck disable=SC2016
    format='{print $3}' # path
    ;;
"ip")
    # shellcheck disable=SC2016
    format='{print $3";"$NF}' # path;ip
    ;;
*)
    echo 'arg {base|ip}, now exit'
    exit 1
    ;;
esac

export LC_ALL="C"
nginx_log="/opt/log/nginx/access.log"
[[ ! -f "${nginx_log}" ]] && echo "${nginx_log} does not exist, now exit" && exit 1

# nginx日志时间格式（上一秒: 因为是完整的一秒，这一秒表示还没到终点）
#tag="[17/Jun/2020:03:35:01 +0800]"
tag="$(date '+[%d/%b/%Y:%H:%M:%S +0800]' --date='1 seconds ago')"

tail -n 100000 "${nginx_log}" | # 为了性能
    grep -v -E '^127\.0\.0\.1.+' | # 排除自动执行
    grep -F ' POST ' | # 只关注POST
    grep -F "${tag}" | # 获取上一秒的完整信息
    awk -F '"' '{print $2" "$(NF-1)}' | awk "${format}" | # 简单获取key
    sed 's/\?.*;/;/g' | sed 's/\?.*"/"/g' | # 移除http请求路径参数信息（通常像 GET /path/id?u=100 改为 /path/id）
    sort | uniq -c | sort -n | # 统计频率
    awk '{print "    \""$2"\": "$1","}' | sed '1i\{' | sed '$s/,$/\n}/' # 格式化为json (telegraf推荐的数据格式)
