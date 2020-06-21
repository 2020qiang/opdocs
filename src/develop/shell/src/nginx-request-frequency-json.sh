#!/usr/bin/env bash

# 创建时间 2020/06/18
# 更新时间 2020/06/21
#
# 作用
#     telegraf监控，使用path;ip分析客户端经常请求的接口 - （是异常）
#     用于让开发为指定接口添加验证码（因为总不能有接口都加验证码）
# 说明
#     telegraf每10s触发一次此脚本，并获取输出，将监控数据提交到influxdb
#     使用nginx日志和临时文件，得出的数据
# 配置
#     /etc/telegraf/telegraf.conf
#     [[inputs.exec]]
#       commands = ["/etc/telegraf/nginx-request-frequency-json.sh"]
#       timeout = "5s"
#       name_suffix = "_req"
#       data_format = "json"
#       data_type = "integer"
# 测试
#     telegraf -input-filter exec -test

set -eu
set -o pipefail

export LC_ALL="C"

nginx_log="/opt/log/nginx/access.log"
[[ ! -f "${nginx_log}" ]] && echo "${nginx_log} does not exist, now exit" && exit 1

# 开始时间/格式化之前时间
#time="1592336070"
time="$(date +%s)"
# shellcheck disable=SC2004  # centos7 $((1 - 1)) 不推荐这样加引号 $(("1" - 1))
get_format_time() { date -d "@$((${time} - ${1}))" "+[%d/%b/%Y:%H:%M:%S +0800]"; } # $1=几秒前 [17/Jun/2020:03:34:30 +0800]

# 分析10秒日志
# 从每秒一秒前开始，因为这秒还没过完
# 到前10秒，因为telegraf每10秒触发一次
value=""
for i in {1..10}; do
    value="${value}?$(
        tail -n 10000 "${nginx_log}" | # 为了性能和速度
            grep -v -E '^127\.0\.0\.1.+' | # 排除自动执行
            grep -F ' POST ' | # 只关注POST
            grep -F "$(get_format_time ${i})" | # 获取指定时间的完整信息
            awk '{print $8}' | awk -F '?' '{print $1}' | # 请求的路径（已剔除参数例如 GET /path/id?u=100 改为 /path/id）
            tr '\n' '?' # 分隔符为 ? （因为上面已经将这个符号剔除）（shell变量不能存放换行）
    )"
done

# 合并分析以上数据
echo "${value}" |
    tr '?' '\n' | # 还原，按照换行分隔
    sed '/^$/d' | # 清理空白行
    sort | uniq -c | sort -n | # 统计频率
    grep -v -F ' 1 ' | # 10秒只有一个请求不统计（方便分析）
    grep -v -F ' 2 ' | # 10秒只有两个请求不统计（方便分析）
    grep -v -F ' 3 ' | # 10秒只有三个请求不统计（方便分析）
    grep -v -F ' 4 ' | # 10秒只有四个请求不统计（方便分析）
    awk '{print "    \""$2"\": "$1","}' | sed '1i\{' | sed '$s/,$/\n}/' # 格式化为json
