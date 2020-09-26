



## 安装 

官网 <https://tecadmin.net/install-php7-on-centos7/>

```shell
# php7.3
yum localinstall -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi-php73 install -y php php-fpm php-mysqlnd php-pecl-redis php-gd
systemctl enable php-fpm
php -m |grep -E '(mysql|redis)'
```

```shell
# php7.0（新）
yum localinstall -y http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum --enablerepo=remi-php70 install -y php php-fpm php-mysqlnd php-pecl-redis
yum --enablerepo=remi-php70 install -y php-gd php-bcmath php-dom php-gmp php-igbinary \
                                       php-mbstring php-mcrypt php-posix php-soap \
                                       php-xmlrpc php-zip
```

```shell
# php7.0（旧）
sudo yum localinstall -y http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
sudo yum localinstall -y https://mirror.webtatic.com/yum/el6/latest.rpm
sudo yum install -y php70w php70w-fpm php70w-mysql php70w-pecl-redis php70w-xml php70w-soap php70w-xmlrpc php70w-pdo php70w-bcmath php70w-mbstring php70w-gd php70w-mcrypt php70w-pdo_dblib 
```





---





## 从源码编译扩展

下载解压 php 源码包

```shell
tar -xvf /admin/php-7.0.23.tar.xz
```

编译和安装

```shell
cd php-7.0.23/ext/mbstring/
/opt/php-fpm/bin/phpize
./configure --with-php-config=$(which php-config)
make
make install
```

安装到

```
/opt/php-fpm/lib/php/extensions/no-debug-non-zts-20151012/mbstring.so
```

修改 php.ini

```
php.ini中追加extension=mbstring.so
```

重新加载 php 进程

> [https://my.oschina.net/u/2245781/blog/913938](https://my.oschina.net/u/2245781/blog/913938)





---





## 项目用的配置

1. 使用固定的子进程数量（下面配置500）
2. 单个子进程处理这些量的请求，就关闭，重新在起，防止内存泄露，（下面配置1000）
3. php脚本最长只能执行40秒，防止阻塞

```
pid       = /var/run/php-fpm/php-fpm.pid
error_log = /var/log/phpfpm-error.log

emergency_restart_threshold = 10
emergency_restart_interval  = 60s
process_control_timeout     = 10s

daemonize        = yes
events.mechanism = epoll


;include=/etc/php-fpm.d/*.conf
[www]

user  = apache
group = apache

listen = 127.0.0.1:9000

pm = static
pm.max_children = 500
pm.max_requests = 1000

pm.status_path = /phpfpm-status
;ping.path     = /ping
;ping.response = pong

request_slowlog_timeout   = 20s
slowlog                   = /var/log/php-fpm/www-slow.log

request_terminate_timeout     = 40s
php_value[max_execution_time] = 40s

catch_workers_output = yes
php_flag[expose_php] = off
```
