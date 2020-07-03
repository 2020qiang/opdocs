## webvirtmgr

[https://github.com/retspen/webvirtmgr/wiki/Install-WebVirtMgr](https://www.gitbook.com/book/liuq369/linuxer/edit#)  
WebVirtMgr是一个用于管理虚拟机的基于libvirt的Web界面  
它允许您创建和配置新的域，并调整域的资源分配。VNC查看器向访客域提供完整的图形控制台。KVM目前是唯一支持的虚拟机管理程序。

已经制作成docker镜像

[https://github.com/liuq369/docker-webvirtmgr](https://github.com/liuq369/docker-webvirtmgr)

---

#### 服务端配置

开启指定USE标记

* 全局USE开启`sasl`
* 安装`app-emulation/qemu`
* 安装`app-emulation/libvirt`
  * 局部USE开启`libvirtd`
  * 局部USE开启`virt-network`

安装`app-emulation/libvirt`和`app-emulation/qemu`，根据错误提示编译内核

关键性tcp配置`/etc/libvirt/libvirtd.conf`

```
listen_tls = 0
listen_tcp = 1
tcp_port = "16509"
listen_addr = "192.168.1.222"
auth_tcp = "sasl"
```

`systemctl status libvirtd.service`输出如下

```
● libvirtd.service - Virtualization daemon
   Loaded: loaded (/usr/lib/systemd/system/libvirtd.service; enabled; vendor pre
  Drop-In: /etc/systemd/system/libvirtd.service.d
           └─00gentoo.conf
   Active: active (running) since Mon 2017-05-01 12:32:59 HKT; 53min ago
     Docs: man:libvirtd(8)
           http://libvirt.org
 Main PID: 2237 (libvirtd)
    Tasks: 17 (limit: 4915)
   Memory: 23.2M
      CPU: 2.169s
   CGroup: /system.slice/libvirtd.service
           └─2237 /usr/sbin/libvirtd --listen

May 01 12:43:56 test libvirtd[2237]: 2017-05-01 04:43:56.347+0000: 2346: error :
May 01 12:44:09 test libvirtd[2237]: 2017-05-01 04:44:09.782+0000: 2354: error :
```

编辑`/etc/systemd/system/libvirtd.service.d/00gentoo.conf`文件

打开`--listen`启动参数，使用sock连接可不打开，但作为监听port必须打开

```
[Service]
ExecStart=
ExecStart=/usr/sbin/libvirtd --listen
```

### libvirt服务端配置连接密码验证

[https://libvirt.org/auth.html\#ACL\_server\_username](https://libvirt.org/auth.html#ACL_server_username)  
[https://github.com/novnc/noVNC/issues/254](https://github.com/novnc/noVNC/issues/254)

创建名为libvirtd的用户

```
＃saslpasswd2 -a libvirt libvirtd
密码：xxxxxx
再次（验证）：xxxxxx
```

要查看所有帐户的列表，sasldblistusers2可以使用该命令。该命令希望获得保留在libvirt用户数据库中的路径/etc/libvirt/passwd.db

```
＃sasldblistusers2 -f /etc/libvirt/passwd.db
fred@t60wlan.home.berrange.com：userPassword
```

最后，要禁用用户的访问，saslpasswd2可以重新使用该命令：

```
＃saslpasswd2 -a libvirt -d libvirtd
```

> 数据包没加密，存在泄密风险

### libvirt服务端配置连接密钥验证

[创建服务端和客户端的私钥及公钥](https://liuq.org/Tools/openssl.html)

* 公私钥分发：
  * libvirt 服务端
    * `cp cacert.pem /etc/pki/CA/cacert.pem`
    * `cp servercert.pem /etc/pki/libvirt/servercert.pem`
    * `cp serverkey.pem /etc/pki/libvirt/private/serverkey.pem`
  * virsh 客户端
    * `cp cacert.pem /etc/pki/CA/cacert.pem`
    * `cp clientcert.pem /etc/pki/libvirt/clientcert.pem`
    * `cp clientkey.pem /etc/pki/libvirt/private/clientkey.pem`

验证`virsh -c qemu+tls://test.liuq.org/system list --all`

