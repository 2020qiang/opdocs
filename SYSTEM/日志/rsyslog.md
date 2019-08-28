一台服务器的日志对系统工程师来说是至关重要的，一旦服务器出现故障或被入侵，我们需要查看日志来定位问题的关键所在,所以说对于线上跑的服务器而言日志应该合理的处理及管理

在老版本的 Linux 系统上是使用 syslog，现在默认使用 rsyslog ，其配置文件为 /etc/rsyslog.conf，信息如下介绍：

#### 常见日志路径及信息

```
/var/log/message    标准系统错误信息
/var/log/maillog    邮件系统产生的日志信息
/var/log/secure     记录系统的登录情况
/var/log/dmesg      记录linux系统在引导过程中的各种记录信息
/var/log/cron       记录crond计划任务产生的时间信息
/var/log/lastlog    记录每个用户最近的登录事件
/var/log/wtmp       记录每个用户登录、注销及系统启动和停机事件
/var/run/btmp       记录失败的、错误的登录尝试及验证事件
```

#### syslog协议格式定义如下

```
facility.priority action
[设施]   [级别]    [动作]
```

facility（设施）：标识系统需要记录日志的子系统

```
代码          关键字          描述
0            kern            内核消息  - 通常只有内核才能登录到
1            user            用户级消息
2            mail            邮件系统
3            daemon          系统守护进程
4            auth            安全/授权消息
5            syslog          由syslogd内部生成的消息
6            lpr             行打印机子系统
7            news            网络新闻子系统
8            uucp            UUCP子系统
9                            时钟守护进程
10            authpriv       安全/授权消息
11            ftp            FTP守护进程
12            -              NTP子系统
13            -              日志审计
14            -              记录警报
15            cron           调度守护进程
16            local0         local用户自定义程序使用0 (local0)
17            local1         local用户自定义程序使用1 (local1)
18            local2         local用户自定义程序使用2 (local2)
19            local3         local用户自定义程序使用3 (local3)
20            local4         local用户自定义程序使用4 (local4)
21            local5         local用户自定义程序使用5 (local5)
22            local6         local用户自定义程序使用6 (local6)
23            local7         local用户自定义程序使用7 (local7)
```

priority（级别）：用来标识日志级别,级别越低信息越详细

```
代码         等级      关键字    描述
0           急        emerg    系统无法使用
1           警报      alert     必须立即采取行动
2           危急      crit      严重的情况，如硬件设备错误
3           错误      err       错误条件
4           警告      warning   警告条件
5           注意      notice    正常但重要的条件
6           信息      info      信息消息
7           调试      debug     调试级别的消息
                      *        表示所有日志级别
                      none      跟*相反表示什么都没有
```

action（动作）：

```
1）记录到普通文件或设备文件
    *.*     /var/log/file.log   绝对路径
    *.*     /dev/pts/0          设备文件
2）”|”，表示将日志送给其他命令处理
3）”@HOST”，表示将日志发送到特定的主机
    *.emerg                     @192.168.10.1
4）”用户”，表示将日志发送到特定的用户
5）”*”，表示将日志发送所有登录到系统上的用户

可以在每个条目前添加一个减号 "-"，以避免在每条日志消息之后同步文件
注意，如果在写入尝试后系统崩溃，则可能会丢失信息。尽管如此，这可能会给你一些性能，特别是如果你运行的程序使用非常详细的日志记录的话。
```

连接符号

```
.                  表示大于等于xxx级别的信息
.=                 表示等于xxx级别的信息
.!                 表示在xxx之外的等级的信息
```

示例

```
# 表示将mail相关的,info级别及以上级别都记录到mail.log文件中
mail.info  /var/log/mail.log

# 表示将auth相关的基本为info信息记录到远程主机
auth.=info @192.168.10.1

# 表示记录与user和error相反的
user.!error

# 表示记录所有日志信息的info级别及以上级别
*.info

# 所有日志及所有级别信息都记录下来
*.*

# 表示将mail相关的,info级别及以上级别都记录到mail.log文件中
mail.info  /var/log/mail.log

# 表示将auth相关的基本为info信息记录到远程主机
auth.=info @192.168.10.1

# 表示记录与user和error相反的
user.!error

# 表示记录所有日志信息的info级别及以上级别
*.info

# 所有日志及所有级别信息都记录下来
*.*

PS：多个日志来源可以使用,号隔开,如cron.info;mail.info
```

> ```
> http://www.ywnds.com/?p=1304
> https://linux.cn/article-5023-1.html
> https://en.wikipedia.org/wiki/Syslog
> https://docs.logtrust.com/confluence/docs/system-configuration/sending-the-data/sending-from-unix-based-operating-systems/file-monitoring-via-rsyslog
> http://www.rsyslog.com/doc/v5-stable/configuration/modules/imfile.html
> http://kumu-linux.github.io/blog/2013/08/28/rsyslog-remote/
> ```



