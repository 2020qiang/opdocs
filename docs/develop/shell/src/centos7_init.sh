#!/usr/bin/env bash


# 2019/10/19
#
# ssh -q centos@example.com -p 22 'curl -s -o /tmp/init.sh init.todb.nl -L && sudo bash /tmp/init.sh ### ### 0'

if [[ "$#" != "3" ]]; then
    echo
    echo 'need 1=${hostname} 2=${password} 3=${install_env}'
    echo '${install_env}=0:docker:telegraf:iptables'
    echo
    exit 1
fi


Lock="/etc/init_already"
if [[ -f "${Lock}" ]]; then
    echo "already init, now exit"
    exit 1
fi
set -x
set -e
sudo touch "${Lock}"
chattr +i "${Lock}"
unset Lock


hostname="${1}"
password="${2}"
install_env="${3}"  # 0:docker:telegraf

# 主机名
hostnamectl --static set-hostname "${hostname}"
sed -i "s#localhost\ #${hostname}\ localhost\ #g" /etc/hosts

# 用户
id centos || useradd centos
echo "${password}"                                            |passwd --stdin centos
echo "$(echo ${password}${RANDOM} |md5sum |awk '{print $1}')" |passwd --stdin root
unset password
chmod 0600 -v                          /etc/sudoers
sed  -i '/^centos.*NOPASSWD:ALL/d'     /etc/sudoers
echo 'centos ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
chmod 0400 -v                          /etc/sudoers

# 优化 sshd
usermod -a -G sshd centos
echo -en '\n'                      >>/etc/ssh/sshd_config
sed -i '/Port/d'                     /etc/ssh/sshd_config
sed -i '/Protocol/d'                 /etc/ssh/sshd_config
sed -i '/AllowUsers/d'               /etc/ssh/sshd_config
sed -i '/AllowGroups/d'              /etc/ssh/sshd_config
sed -i '/PermitRootLogin/d'          /etc/ssh/sshd_config
sed -i '/PasswordAuthentication/d'   /etc/ssh/sshd_config
sed -i '/PermitEmptyPasswords/d'     /etc/ssh/sshd_config
sed -i '/PubkeyAuthentication/d'     /etc/ssh/sshd_config
sed -i '/AuthorizedKeysFile/d'       /etc/ssh/sshd_config
sed -i '/AddressFamily/d'            /etc/ssh/sshd_config
sed -i '/UseDNS/d'                   /etc/ssh/sshd_config
sed -i '/GSSAPIAuthentication/d'     /etc/ssh/sshd_config
sed -i '/X11Forwarding/d'            /etc/ssh/sshd_config
sed -i '/ClientAliveInterval/d'      /etc/ssh/sshd_config
sed -i '/ClientAliveCountMax/d'      /etc/ssh/sshd_config
sed -i '/Compression/d'              /etc/ssh/sshd_config
sed -i '/AcceptEnv/d'                /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF
Port                   22
Protocol               2
AllowGroups            sshd
PermitRootLogin        no
PasswordAuthentication yes
PermitEmptyPasswords   no
PubkeyAuthentication   no
AuthorizedKeysFile     /dev/null
AddressFamily          inet
UseDNS                 no
GSSAPIAuthentication   no
X11Forwarding          no
ClientAliveInterval    100
ClientAliveCountMax    2
Compression            yes
EOF
systemctl restart sshd

# 时区
ln -svf /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
echo 'ZONE="Asia/Hong_Kong"' >/etc/sysconfig/clock

# DNS
tmp="$( find /etc/sysconfig/network-scripts -name 'ifcfg-*'|grep -v lo )"
for x in ${tmp[@]}; do
    sed -i '/DNS/d'     ${x}
    sed -i '/PEERDNS/d' ${x}
    echo 'PEERDNS=no' >>${x}
done
rm -vf /etc/resolv.conf
cat > /etc/resolv.conf << EOF
nameserver 208.67.222.222
nameserver 8.8.8.8
nameserver 114.114.114.114
EOF
chattr +i /etc/resolv.conf
unset tmp

# 时间
yum makecache
yum install -y ntpdate
cat > /etc/cron.hourly/ntpdate << EOF
#!/usr/bin/env bash
$(which ntpdate) pool.ntp.org >/var/log/ntpdate.log 2>&1
EOF
chmod +x /etc/cron.hourly/ntpdate
/etc/cron.hourly/ntpdate
cat /var/log/ntpdate.log

# 文件描述符
# 1048576 其实它等于 1024*1024 也就是 1024K个
sed -i '/fs.file-max/d'   /etc/sysctl.conf
sed -i '/fs.aio-max-nr/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
fs.file-max   = 6815744
fs.aio-max-nr = 1048576
EOF
sed -i '/* - nofile 1048576/d' /etc/security/limits.conf
sed -i '/* - nproc  1048576/d' /etc/security/limits.conf
cat >> /etc/security/limits.conf << EOF
* - nofile 1048576
* - nproc  1048576
EOF

# 防火墙
yum makecache
if [[ "$(systemctl list-units |grep firewalld |wc -l)" != "0" ]]; then
    systemctl disable firewalld
    systemctl stop    firewalld
fi
yum install -y iptables-services
iptables  -P INPUT ACCEPT
ip6tables -P INPUT ACCEPT
iptables  -F
ip6tables -F
iptables  -X
ip6tables -X
if [[ "$(echo ${install_env} |grep -w iptables |wc -l)" == "1" ]]; then
    iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
    iptables -A INPUT -s 10.0.0.0/8     -j ACCEPT
    iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p icmp -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -m state --state NEW -j REJECT
fi
service iptables  save
service ip6tables save
systemctl enable iptables
systemctl enable ip6tables

# 关闭 selinux
sed -i '/SELINUX=/d'      /etc/selinux/config
echo 'SELINUX=disabled' >>/etc/selinux/config

# 更新软件包/安装软件包
yum makecache
yum install -y epel-release yum-utils
yum makecache
yum update -y
yum upgrade -y
yum install -y bash-completion htop lsof iftop iotop screen wget tree xz zip unzip screen mlocate rsync bc git extundelete telnet

# 安装 docker
if [[ "$(echo ${install_env} |grep -w docker |wc -l)" == "1" ]]; then
    yum install -y "docker-io"
    systemctl enable "docker"
    mkdir -vp "/root/.docker"
    chmod -v 0700 "/root/.docker"
    echo '{"auths":{"docker.e2048.com":{"auth":"cHVsbDpkOThUNWJqQk5keVNUQVd0VlZEUA=="}}}' >"/root/.docker/config.json"
    chmod -v 0600 "/root/.docker/config.json"
    # systemctl start docker
    # systemctl stop  docker
    # ip addr del 172.17.0.1/16 dev docker0
    # ip addr add 10.1.0.1/30   dev docker0
    # echo "{\"bip\": \"$3\"}" >/etc/docker/daemon.json
fi

# 常用服务客户端
cat > /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=https://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
EOF
yum makecache
yum install -y mysql-community-client redis

# 开机启动
file="$(systemctl cat rc-local |head -n 1 |awk '{print $NF}')"
cat > /etc/rc.local << EOF
#!/bin/sh
touch /var/lock/subsys/local
EOF
chmod +x /etc/rc.d/rc.local
sed -i "/^ExecStart.*/i\ExecStartPre=$(which sleep) 2m" "${file}"
cat >> "${file}" << EOF
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable rc-local
unset file


# 安装监控客户端
if [[ "$(echo ${install_env} |grep telegraf |wc -l)" == "1" ]]; then
    yum localinstall -y https://repos.influxdata.com/rhel/7/x86_64/stable/telegraf-1.5.3-1.x86_64.rpm
    systemctl enable telegraf

    wget -c https://download.ikk.icu/init.ikk.icu/mysql_status -O /etc/telegraf/mysql_status
    chmod -v 0555 /etc/telegraf/mysql_status
    cat > /etc/telegraf/mysql_status.json << EOF
[{
    "name": "master",
    "host": "127.0.0.1",
    "port": "3306",
    "user": "status",
    "pass": "FEybaC8iPMqR3cuFr3ks"
}]
EOF

    cat > /etc/telegraf/telegraf.conf << EOF
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  debug = false
  quiet = false
  logfile = ""
  hostname = ""
  omit_hostname = false
[[outputs.influxdb]]
  urls = ["https://e2048.com:8086"]
  database = "fbc"
  timeout = "5s"
  username = "flyingbird"
  password = "LshqUGLnvV7tnmRaRtTm"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.net]]
[[inputs.netstat]]

[[inputs.mysql]]
  servers = ["status:FEybaC8iPMqR3cuFr3ks@tcp(127.0.0.1:3306)/?tls=false"]
  gather_slave_status = true
[[inputs.phpfpm]]
  urls = ["http://127.0.0.1:81/phpfpm-status"]
[[inputs.nginx]]
  urls = ["http://127.0.0.1:81/nginx-status"]
[[inputs.redis]]
  servers = ["tcp://127.0.0.1:6379","tcp://127.0.0.1:6380","tcp://127.0.0.1:6381","tcp://127.0.0.1:6382","tcp://127.0.0.1:6383"]
[[inputs.elasticsearch]]
  servers = ["http://127.0.0.1:9200"]
  http_timeout = "5s"

[[inputs.exec]]
  commands = ["/etc/telegraf/mysql_status"]
  timeout = "5s"
  name_suffix = "_mysql"
  data_format = "json"
  data_type = "integer"
EOF
fi


# 其他可选
yum clean all
rm -vrf /var/cache/yum/*
cat > /etc/rc.local << EOF
#!/bin/sh
touch /var/lock/subsys/local
EOF
cat >> /etc/profile << EOF
export LC_ALL=en_US.UTF-8
export PS1='[\u@\h \W]\\$ '
EOF
find /root /home/* -type f |grep -v '/root/.docker/config.json' |xargs -n 99 rm -vf
echo "${hostname}"
shutdown -r 0
exit 0
