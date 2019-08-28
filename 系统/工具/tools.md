#### openssh-clients

一级跳板

```
+--------+    +------+    +--------+
| Client +--->+ Jump +--->+ Server |
+--------+    +------+    +--------+

Client:
ssh user@Server -p 22 -o "ProxyCommand ssh user@Jump -p 22 -W %h:%p"
```

二级跳板

```
+--------+    +-------+    +-------+    +--------+
| Client +--->+ Jump1 +--->+ Jump2 +--->+ Server |
+--------+    +-------+    +-------+    +--------+

Client:
ssh Server -o 'ProxyCommand ssh Jump2 -o "ProxyCommand ssh Jump1 -W Jump2:22" -W %h:%p'
```

---

#### tcpdump

```
-n   不要将主机地址反向解析为域名
-nn  不要将协议和端口号等转换为名称
-q   安静输出，打印较少的协议信息
```

```
tcpdump -n -nn -q 'ip and port ! 22'
```

---

#### find

```
----(+n)---------|------------(n)--------------|---------(-n)----
   (n+1)*24H前   |    (n+1)*24H ~ n*24H之间     |  n*24H以内

-ctime +n    查找距现在 (n+1)*24H 前修改过的文件
-ctime n     查找距现在 n*24H 前, (n+1)*24H 内修改过的文件
-ctime -n    查找距现在 n*24H 内修改过的文件

[a|c|m]min     (最后访问|最后状态修改|最后内容修改)min （分钟）
[a|c|m]time    (最后访问|最后状态修改|最后内容修改)time（天）
```

查找 10天 都没访问过的文件，并删除它

```
find /path -atime +10 -type f -exec rm -vf {} \;
```

---

#### mailx

```
$ sudo yum install -y mailx
```

使用外部 smtp 服务器，如 smtp.gmail.com，发送邮件及附件

```
echo 'body' | mailx -v -s 'title'                             \
    -S smtp-use-starttls                                      \
    -S ssl-verify=ignore                                      \
    -S smtp-auth=login                                        \
    -S smtp=smtp://smtp.gmail.com:587                         \
    -S from=user@gmail.com                                    \
    -S smtp-auth-user=user@gmail.com                          \
    -S smtp-auth-password=passwd                              \
    -S ssl-verify=ignore                                      \
    -S nss-config-dir=/etc/pki/nssdb                          \
    -a /etc/hosts -a /etc/services                            \
    status0status@gmail.com,sta@asd.com                       \
    >/dev/null 2>&1
```

---

### dd

dd 命令可以轻易实现创建指定大小的文件，如

```
$ dd if=/dev/zero of=test bs=1M count=1000
```

在当前目录下会生成一个1000M的test文件，文件内容为全0（因从/dev/zero中读取，/dev/zero为0源），但是这样为实际写入硬盘，文件产生速度取决于硬盘读写速度，如果欲产生超大文件，速度很慢。在某种场景下，我们只想让文件系统认为存在一个超大文件在此，但是并不实际写入硬盘

则可以

```
$ dd if=/dev/zero of=test bs=1M count=0 seek=100000
```

此时创建的文件在文件系统中的显示大小为100000MB，但是并不实际占用block，因此创建速度与内存速度相当，seek的作用是跳过输出文件中指定大小的部分，这就达到了创建大文件，但是并不实际写入的目的。当然，因为不实际写入硬盘，所以你在容量只有10G的硬盘上创建100G的此类文件都是可以的。

---

### mkfifo

命名管道，实现进程之间通信的桥梁

创建一个 fifo 特殊文件，是一个命名管道

默认大小为 1048576 字节（byte）（1MB）

```
admin@debian:~$ cat /proc/sys/fs/pipe-max-size
1048576
```

一个 fifo 专用命名管道文件，它只是作为文件系统的一部分被访问。当进程通过 fifo 交换数据时，内核在内部传递所有数据而不写入文件系统。因此，FIFO专用文件在文件系统上没有内容，更不会操作磁盘，除非内存不够了，才会操作 swap

---

### logrotate

logrotate 程序是一个日志文件管理工具。用来把旧的日志文件删除，并创建新的日志文件，我们把它叫做“转储”。我们可以根据日志文件的大小，也可以根据其天数来转储，这个过程一般通过 cron 程序来执行。

logrotate 程序还可以用于压缩日志文件，以及发送日志到指定的E-mail 。

logrotate 的配置文件是 /etc/logrotate.conf

---

### timeout

运行指定的命令，如果在指定时间后仍在运行，则杀死该进程。用来控制程序运行的时间

    portCheckInfo=`timeout 0.01 telnet $host $port 2>/dev/null`
    if [[ $portCheckInfo =~ 'Escape character is' ]]; then
        # echo "包含"
        return 0
    else
        # echo "不包含"
        return 1
    fi

---

### date

显示今天日期（输出为 2019/03/11 18:42:35）

```
date '+%Y/%m/%d %H:%M:%S'
```

显示前 1 天日期（输出为 2017/03/25）

```
date +%G/%m/%e --date='1 days ago'
```

输出 UNIX 时间戳

```
$ date +%s
1518245625
```

UNIX 时间转换

```
$ date -d @1518245625 +%Y/%m/%d-%H:%M:%S
2018/02/10-14:53:45
```

---

### vim

##### 指定行替换

`:2,6s/^/#/g`将2~6行添加`#`注释

`:2,6s/^#//g`将2~6行取消`#`注释

> `^a`表示以a开始，`a&`表示以a结束
>
> [查看正则表达式](/jiao-ben/zheng-ze-biao-da-shi.html)

##### 显示行号

在`/etc/vim/vimrc`或`~/.vimrc`中打开`set number`选项

更改 tab 按键空格数

`set tabstop=4`

##### 替换

例如：`%s/111/222/g`会在全局范围`(%)`查找`111`并替换为`222`，所有出现都会被替换`（g）`

#### 常用配置

```
autocmd BufEnter * set mouse=
set expandtab
set tabstop=4
set hlsearch
set ignorecase
set smartcase
```

---

### wget

#### 下载同时完成了SHA-1和MD5校验工作

`bash`在某些系统中的特性，可以将输入输出转到另一个程序中去，可以同时输出个多个程序，使用方法是`>(list)`或`<(list)`

```
wget -O - http://example.com/dvd.iso \
       | tee >(sha1sum > dvd.sha1) \
             >(md5sum > dvd.md5) \
       > dvd.iso
```

不检查https的ssl证书

```
wget --no-check-certificate https://liuq.org/file
```

---

#### automake

```
# apt-get install -y autoconf automake libtool autopoint
```

---

### expect

```
#!/usr/bin/expect
```

```
spawn su root  
expect "password: "  
send "123456\r"  
expect eof  
exit
```

---

### vmstat

```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 4  0 510016 2505900  17340 643624   68  312   398  1488  417  446 92  5  3  0  0
 5  0 509992 2490444  17352 646884    0    0     4  3780 1156  601 95  5  0  0  0
 4  0 509984 2407028  17352 646736   12    0   296  7592 1198  484 96  4  0  0  0
 4  0 509960 2194912  17352 646308    4    0     4     0 1526  480 96  4  0  0  0
```

* procs
  * r：等待运行的进程数
  * b：非中断睡眠状态的进程数
* memory
  * swpd：swap 使用情况 M
  * free：空闲的内存 M
  * buff：缓存使用情况 M
  * cache：文件缓冲使用情况 M
* swap
  * si：磁盘交换至内存的交换页数量 kb/s
  * so：内存交换至磁盘的交换页数量 kb/s
* system
  * in：每秒的中断数，包括时钟中断
  * cs：每表上下文环境切换次数
* cpu
  * us：cpu 使用时间
  * sy：cpu 系统使用时间
  * id：cpu 闲置时间
  * wa：io 等待时间
  * st：被虚拟处理器专用的时间

---

### make

make 使用多逻辑 cpu 编译

```
export MAKEFLAGS='-j 8'
[or]
make -j8
```

---

### sudo

完全授权

```
user ALL=(ALL) NOPASSWD:ALL
```

部分命令授权

```
Cmnd_Alias ADMIN=/usr/bin/du,/usr/bin/find
user ALL=(ALL) NOPASSWD:ADMIN
```

---

### gentoo manager tool

```
app-portage/gentoolkit
```

```
app-portage/eix
```

> 参考
>
> [Gentoo 发行版漫游指南](http://book42qu.readthedocs.io/en/latest/linux/gentoo.html)

安装指定版本

```
emerge -av "=media-libs/jpeg-6b-r9"
```

---

### chkconfig

`chkconfig servername on` 提示服务不支持 chkconfig

servername 文件必须包含以下内容

```
1  #!/bin/bash
2  #chkconfig:    2345 80 90
```

1. 告诉系统此文件使用的 shell
2. chkconfig 后面有三个参数 345、80、90
   1. 2345：需要在 rc32.d、rc3.d、rc4.d、rc5.d 目录下创建链接（相应启动项启动）
   2. 80：创建到名字为 S97servername 文件的连接（表示 stop 动作）（数字越小表示越先执行）
   3. 90：创建到名字为 K04servername 文件的连接（表示 start 动作）（数字越小表示越先执行）

如果 chkconfig 老是报错，脚本没有问题，直接在 rc0.d~rc6.d 下面创建到脚本的文件链接来解决，原理都是一样

> [http://17610376.blog.51cto.com/366886/322834](http://17610376.blog.51cto.com/366886/322834)

---

### curl

获取网站 http code，如果有 301 就跟着跳转

```
curl -o /dev/null -s -w %{http_code} 'liuq.org' -L
```

无需更改 hosts 使用域名访问指定主机

```
$ curl -s -v -x "http://127.0.0.1:80" domain.sh
* About to connect() to proxy 127.0.0.1 port 80 (#0)
*   Trying 127.0.0.1... connected
* Connected to 127.0.0.1 (127.0.0.1) port 80 (#0)
> GET http://ip/ HTTP/1.1
> User-Agent: curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.27.1 zlib/1.2.3 libidn/1.18 libssh2/1.4.2
> Host: ip
> Accept: */*
> Proxy-Connection: Keep-Alive
> 
< HTTP/1.1 200 OK
< Server: nginx
< Date: Fri, 28 Sep 2018 05:12:44 GMT
< Content-Type: text/html; charset=UTF-8
< Transfer-Encoding: chunked
< Connection: keep-alive
< 
11
12
```

---

### iproute2

查看端口占用情况

```
ss -tunlp | grep 80
```

查看 80 端口并发数

```
ss -tn -o state established|awk -F ':' '{print $2}'|grep ^80|wc -l
```

查看系统并发数

```
ss -t -o state established |wc -l
```

```
ss -tan |grep TIME-WAIT |wc -l
```

添加/删除 静态路由

```
# ip route add 172.16.32.0/24 via 192.168.1.1 dev eth0
# ip route del 172.16.32.0/24
```

---

### xz-utils

将 file 压缩为 file.xz，然后删除源文件，压缩等级最高，但是也最慢，`-k` 表示不删除源文件

```
xz file.tar -T 8 -9 -k

-T 8 : 8个线程执行压缩
-9   : 最高压缩等级
-k   : 不删除源文件
```



### iftop

查看指定端口的流量，可以得到公网的流量

```shell
# BPF filter rule
iftop -f 'port 80 || port 443'
```

