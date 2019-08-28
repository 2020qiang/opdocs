### install

```
# apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-agent php-mysql
# systemctl enable zabbix-server.service
# systemctl enable zabbix-agent.service
# systemctl start zabbix-server.service
# systemctl start zabbix-agent.service
```

### sql

```
sql> create database zabbix character set utf8;
sql> grant all privileges on zabbix.* to zabbix@127.0.0.1 identified by 'zabbix';
sql> flush privileges;
# cp /usr/share/zabbix-server-mysql/schema.sql.gz .
# cp /usr/share/zabbix-server-mysql/images.sql.gz .
# cp /usr/share/zabbix-server-mysql/data.sql.gz .
# gunzip schema.sql.gz images.sql.gz data.sql.gz
# mysql -u zabbix -p zabbix -h 127.0.0.1 <schema.sql
# mysql -u zabbix -p zabbix -h 127.0.0.1 <images.sql
# mysql -u zabbix -p zabbix -h 127.0.0.1 <data.sql
```

### web ui

```
# a2enconf zabbix-frontend-php
# sed -i 's/;date.timezone\ =/date.timezone\ =\ Asia\/Hong_Kong/g' /etc/php/7.0/apache2/php.ini
# systemctl reload apache2
```

#### /etc/zabbix/zabbix.conf.php

```
<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '127.0.0.1';
$DB['PORT']     = '3306';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'localhost';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = '';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
```

##### 中文界面

```
# WEB 界面中文
# dpkg-reconfigure locales
│    [*] zh_CN.UTF-8 UTF-8
# systemctl restart apache2.service

# 绘图中文
# apt-get install -y ttf-wqy-zenhei
# ln -sf /usr/share/fonts/truetype/wqy/wqy-zenhei.ttc /usr/share/zabbix/fonts/DejaVuSans.ttf
```

##### /etc/zabbix/zabbix\_server.conf

```
DBHost=127.0.0.1
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
ListenIP=127.0.0.1
# systemctl restart zabbix-server.service
```

---

安装客户端

```
# yum localinstall -y http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.7-1.el6.x86_64.rpm
# chkconfig zabbix-agent on
```

监控 mysqld

```
# vi /etc/zabbix/zabbix_agentd.conf
UnsafeUserParameters=1
Include=/etc/zabbix/zabbix_agentd.d/*.conf
Server=192.168.1.1

# vi /etc/zabbix/zabbix_agentd.d/mysqld_status.conf
UserParameter=mysqld_[*], HOME=/var/lib/zabbix /etc/zabbix/zabbix_agentd.d/Zcontrol /etc/zabbix/zabbix_agentd.d/mysqld_status.yml | grep $1 | sed 's#$1 ##g'
UserParameter=mysqld_ping,HOME=/var/lib/zabbix mysqladmin ping 2>/dev/null | grep -c alive | wc -l
UserParameter=mysqld_version, mysqld -V | awk '{print $3}'
```

监控程序

```
# wget -c https://github.com/liuq369/Zcontrol/releases/download/test/Zcontrol -P /etc/zabbix/zabbix_agentd.d
# chmod +x /etc/zabbix/zabbix_agentd.d/Zcontrol
# wget -c https://raw.githubusercontent.com/liuq369/Zcontrol/master/conf/mysqld_status.yml -P /etc/zabbix/zabbix_agentd.d/
```

配置

```
# vi /etc/zabbix/zabbix_agentd.d/mysqld_status.yml
```

启动

```
/etc/init.d/zabbix-agent start
```

测试

```
/etc/zabbix/zabbix_agentd.d/Zcontrol /etc/zabbix/zabbix_agentd.d/mysqld_status.yml
zabbix_get -s 192.168.1.6 -p 10050 -k "mysqld_[Innodb_buffer_pool_pages_data]"
```



