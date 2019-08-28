```
FROM centos:6


# 时间
RUN cp -f /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime \
    && echo 'ZONE="Asia/Hong_Kong"' >/etc/sysconfig/clock

# 更新
RUN yum install -y epel-release yum-utils   \
    && yum makecache                        \
    && yum update -y                        \
    && yum upgrade -y                       \
    && yum clean all

# 安装
RUN echo \
    && echo '[influxdb]'                                                                    >/etc/yum.repos.d/influxdb.repo \
    && echo 'name = InfluxDB Repository - RHEL \$releasever'                               >>/etc/yum.repos.d/influxdb.repo \
    && echo 'baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable'   >>/etc/yum.repos.d/influxdb.repo \
    && echo 'enabled = 1'                                                                  >>/etc/yum.repos.d/influxdb.repo \
    && echo 'gpgcheck = 1'                                                                 >>/etc/yum.repos.d/influxdb.repo \
    && echo 'gpgkey = https://repos.influxdata.com/influxdb.key'                           >>/etc/yum.repos.d/influxdb.repo \
    && yum install -y telegraf influxdb chronograf kapacitor    \
    && touch /var/run/utmp                                      \
    && yum clean all

# 配置
RUN echo \
    && echo 'chown influxdb:influxdb /var/lib/influxdb'  >/start.sh \
    && echo '/etc/init.d/influxdb   start'              >>/start.sh \
    && echo '/etc/init.d/chronograf start'              >>/start.sh \
    && echo '/etc/init.d/kapacitor  start'              >>/start.sh \
    && echo 'tail -f /dev/null'                         >>/start.sh

# 运行
CMD    ["/bin/bash", "/start.sh"]
```

```
$ sudo docker build -t tick:v0.1 .
```



