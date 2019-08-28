准备环境

```
   45  export LC_ALL='C'
   65  apt-get install ntpdate 
   68  ntpdate pool.nto.org
```

安装编译环境及基础环境

```
   74  apt-get install build-essential g++ libgd-dev libgd3 libgd3 libgd3 libgd-dev apache2 php5 php5-gd
```

建立用户及组，并更改用户组

```
   82  useradd nagios
   83  useradd apache
   84  groupadd nagcmd
   85  usermod -a -G nagcmd nagios
   86  usermod -a -G nagcmd apache
```

编译安装 nagios，并安装示例配置文件及其他

```
  101  apt-get install unzip
  102  ./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/conf-enabled
  103  echo $?
  104  make all
  105  make install
  106  make install-init
  107  make install-commandmode
  108  make install-config
  109  make install-webconf
```

新建 nagios web 用户及密码，并验证

```
  117  htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagios passwd
  113  systemctl enable apache2.service
  114  systemctl restart apache2.service
  99  lsof -i:80
chromium http://192.168.1.200/nagios
```

使用邮箱报警服务

```
  122  apt-get install sendmail-bin 
  123  apt-get install sendmail
  127  systemctl enable sendmail.service
  127  systemctl restart sendmail.service
  118  vi /usr/local/nagios/etc/objects/contacts.cfg
        :34,liuq369@126.com
  130  lsof -i:25
```

安装插件

```
   57  tar -xvf /home/test/nagios-plugins-2.2.1.tar.gz 
   58  cd nagios-plugins-2.2.1/
   59  ./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules
```

检查配置

```
   68  /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg 
   69  /etc/init.d/nagios chkconfig
```

安装 nrpe

```
   78  apt-get install libssl-dev 
   89  ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/
   90  ./configure 
   91  make alll
   92  make all
   93  make install-plugin
   94  make install-daemon
   95  make install-daemon-config
   97  ls /usr/local/nagios/libexec/check_nrpe
```



