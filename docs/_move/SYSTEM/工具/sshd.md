### 仅允许在`192.168.1.222`中以`443`端口开启`sshd.service`

修改`/etc/ssh/sshd_config`

```
Port 443
ListenAddress 192.168.1.222
```

修改`/etc/systemd/system/multi-user.target.wants/sshd.service`

> `systemd`是一个异步启动的进程。如果绑定`sshd`到某个特定的`ip`地址，它可能会在引导时启动失败，因为默认的`sshd.service`单元文件没有对网络接口启动的依赖，需要手动添加

```
After=network.target
```

修改`/etc/systemd/system/sockets.target.wants/sshd.socket`

> 如果使用非默认端口`22`，必须在文件`sshd.socket`中设置`ListenStream`为相应的端口。

```
[Socket]
ListenStream=443
```

启动`sshd.service`

```
systemctl disable sshd.service
systemctl enable sshd.socket
systemctl stop sshd.service
systemctl start sshd.socket
```

检查 测试

```
systemctl status sshd.socket
systemctl status sshd.service
ps -ef|grep ssh
lsof -i:443
```

在本示例中使用systemd启动ssh，打开sshd连接的是systemd这个进程，而不是sshd守护进程

```
systemd─┬─agetty
        ├─dbus-daemon
        ├─sshd───sshd─┬─bash───pstree
                      └─4*[{sshd}]
```

### `sshd.socket`与`sshd.service`

* 如果服务由`sshd.socket`提供，配置端口需要配置`sshd.socket`文件
* 如果服务由`sshd.service`提供，配置端口则需要配置传统的`sshd_config`文件

`sshd.service`模式首先旧有的方式会在后台保持一个sshd的守护进程，每当有ssh连接要建立时，就创建一个新进程，比较适合SSH下有大量流量的系统

新的`sshd.socket`方式也是在每次要建立新的ssh连接时生成一个守护进程的实例，不过监听端口则是交给了systemd来完成，意味着没有ssh连接的时候，也不会有sshd守护进程运行，大部分情况下，使用sshd.socket服务更为合适。

另外，通过使用 .socket 文件来管理需要监听端口的服务，可以直接通过 systemctl 来查看一些网络相关的信息，如监听的端口、目前已经接受的连接数、正连接的连接数等。

##### 确认sshd启动方式

```
test linux # lsof -i:443
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd     1 root   16u  IPv4   7986      0t0  TCP 192.168.1.222:443->192.168.1.102:45022 (ESTABLISHED)
systemd     1 root   18u  IPv4  12591      0t0  TCP 192.168.1.222:443->192.168.1.102:48801 (ESTABLISHED)
systemd     1 root   36u  IPv4   6254      0t0  TCP *:443 (LISTEN)
sshd     2407 root    3u  IPv4   7986      0t0  TCP 192.168.1.222:443->192.168.1.102:45022 (ESTABLISHED)
sshd     2407 root    4u  IPv4   7986      0t0  TCP 192.168.1.222:443->192.168.1.102:45022 (ESTABLISHED)
sshd     2410 test    3u  IPv4   7986      0t0  TCP 192.168.1.222:443->192.168.1.102:45022 (ESTABLISHED)
sshd     2410 test    4u  IPv4   7986      0t0  TCP 192.168.1.222:443->192.168.1.102:45022 (ESTABLISHED)
sshd    12634 root    3u  IPv4  12591      0t0  TCP 192.168.1.222:443->192.168.1.102:48801 (ESTABLISHED)
sshd    12634 root    4u  IPv4  12591      0t0  TCP 192.168.1.222:443->192.168.1.102:48801 (ESTABLISHED)
sshd    12637 test    3u  IPv4  12591      0t0  TCP 192.168.1.222:443->192.168.1.102:48801 (ESTABLISHED)
sshd    12637 test    4u  IPv4  12591      0t0  TCP 192.168.1.222:443->192.168.1.102:48801 (ESTABLISHED)
```

从这里得知sshd父进程为systemd，说明sshd启动方式为`sshd.socket`

> 参考
>
> [https://wiki.archlinux.org/index.php/Secure\_Shell\_\(简体中文\)](https://wiki.archlinux.org/index.php/Secure_Shell_%28简体中文%29）)  
> [https://wiki.gentoo.org/wiki/SSH/zh-cn](https://wiki.gentoo.org/wiki/SSH/zh-cn)  
> [https://zzz.buzz/zh/2015/12/26/configure-port-of-sshd-in-systemd-environment/](https://zzz.buzz/zh/2015/12/26/configure-port-of-sshd-in-systemd-environment/)

---

每隔 30 秒向 server 端发送心跳包，持续 6 次

/etc/ssh/sshd\_config

```
ClientAliveInterval 30
ClientAliveCountMax 6
```

sshd\_config 开启 Compression 启用压缩

---

开启 X 转发

vi /etc/ssh/sshd\_config

```
X11Forwarding yes
```

报错

```
Gtk-WARNING **: cannot open display:
```

解决

```
install xauth
```


