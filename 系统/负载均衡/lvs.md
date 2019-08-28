安装

```
yum -y install ipvsadm
ipvsadm --save >/etc/sysconfig/ipvsadm
systemctl enable ipvsadm
systemctl start ipvsadm
systemctl status ipvsadm
```

命令

```
# 清除规则表
ipvsadm -C

# 列出规则表
ipvsadm -l

# 添加虚拟服务
# ipvsadm -A -t (Service IP:Port) -s (Distribution method)
ipvsadm -A -t 0.0.0.0:80 -s wlc

# 添加后端节点
# ipvsadm -a -t (Service IP:Port) -r (Real Server's IP:Port) -m ] ("m" means masquerading (NAT)
ipvsadm -a -t 0.0.0.0:80 -r 192.168.100.112:80 -m
ipvsadm -a -t 0.0.0.0:80 -r 192.168.100.113:80 -m
```

> [CentOS 7 : Install LVS : Server World](https://legacy.gitbook.com/book/liuq369/operations/edit#)

---

术语：

* 调度器：Director
  * 接受用户请求
* 真实主机：RealServer
  * 处理用户请求

---

#### 调度算法

静态：

* RR：（Round Robin）一个一个轮询
* WRR：（Weighted RR）加权轮询，手动让能者多劳
* SH：（SourceIP Hash）同一个IP的客户端，一直连接同一个后端
* DH：（Destination Hash）根据请求的目标IP地址,作为散列键\(Hash Key\)从静态分配的散列表找出对应的服务器,若该服务器是可用的且未超载,将请求发送到该服务器,否则返回空｡主要用于缓存服务器的场景

动态

* LC：（least connections）最小连接数，谁的连接数小，就指向它。例如都一样，就使用至上而下调度
* **WLC**：（Weighted Least Connection）加权最小连接数，连接数加权能者多劳
* SED：（Shortest Expection Delay）最短期望延时，基于WLC算法，具体算法`(active+1)*256/weight`
* NQ：（Never Queue）最少队列，如果有台的连接数为0，就直接分配过去，否则使用 SED 算法

---

#### NAT 模式

原理：

1. 客户端发起请求到调度器
2. 调度器接受到请求，修改目标地址为选举出来的后端真实主机
3. 后端主机根据路由发送消息到调度器
4. 通过调度器转发真实主机的响应到客户端，并修改源地址为调度器的 VIP

优点：

* 支持端口映射
* 支持任意操作系统
* 节省公网IP
* nat 后端主机安全一点

缺点：

* 所有流量都要经过调度器，负载高时，调度器可能成为瓶颈

要求：

* LVS 机器需要双网卡，一个外网一个内网
* Real Server 的网关设置为 Director 的内网 IP 即 DIP

实现：

```
                               |
                               | eth0
                               | IP: 192.168.0.30
                               | GW: 可选
        WLAN             +----------+
-------------------------|    LVS   |--------------------------------
         LAN             +-----+----+
                               | eth1
                               | IP: 10.0.0.30
                               | GW: 可选
                               |
+------------+ eth0            |         +------------+ eth0
|            | IP: 10.0.0.51   |         |            | IP: 10.0.0.52
|     RS1    | GW: 10.0.0.30   |         |  Backend02 | GW: 10.0.0.30
|------------+-----------------+---------+------------+
```

```
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward = 1' >>/etc/sysctl.conf
sysctl -p
cat /proc/sys/net/ipv4/ip_forward

ipvsadm -A -t 192.168.0.30:80 -s wlc
ipvsadm -a -t 192.168.0.30:80 -r 10.0.0.51:80 -m
ipvsadm -a -t 192.168.0.30:80 -r 10.0.0.52:80 -m
```

> [LVS负载均衡之LVS-NAT搭建Web群集](https://www.linuxidc.com/Linux/2018-11/155543.htm)
>
> uuidgen eth1 \# 获取网卡UUID

---

#### TUN 模式

原理：

1. 客户端发起请求到调度器
2. 调度器接受到请求，在 IP 报文外加上一层 IP 报文
3. 发送加好的数据报文到后端某台真实服务器
4. 后端接收到报文，才开报文，获取原始报文
5. 后端通过其他路由响应，响应报文不通过调度器

优点：

* RIP、VIP、DIP 可以在同一个网段，也可以跨网段
* 相对于 NAT 模式，只需要处理入站数据，可以减少负载

缺点：

* 不支持端口映射
* RS 的 OS 必须支持隧道功能
* 隧道技术会额外花费性能，增大开销

要求：

* 后端服务器可以在任何网络中具有任何真实IP地址
* 可以在地理上分布，但它们必须支持IP封装协议
* 它们的隧道设备都已配置好，以便系统可以正确解封所接收的封装数据包
* 并且必须在非arp设备或非arp设备的任何别名上配置&lt;虚拟IP地址&gt;，或者可以将系统配置为将&lt;虚拟IP地址&gt;的数据包重定向到本地套接字

实现相同网段：

```
     +----------+                        +----------+
     |  Client  |------------------------|    LVS   |
     +----------+              +---------+----------+
      192.168.1.1              |          192.168.1.2
                               |          192.168.1.3(VIP)
                               |
                               |
+------------+                 |         +------------+
|            | 192.168.1.10    |         |            | 192.168.1.11
|     RS1    +-----------------+---------+     RS2    |
+------------+                           +------------+
```

```
------------ LVS ------------
VIP=192.168.1.3
RIP1=192.168.1.10
RIP2=192.168.1.11
modprobe tun
modprobe ipip
ip addr add $VIP dev tunl0
ip link set tunl0 up
ip route add $VIP dev tunl0
ipvsadm -C
ipvsadm -A -t $VIP:80 -s wlc
ipvsadm -a -t $VIP:80 -r $RIP1 -i -w 1
ipvsadm -a -t $VIP:80 -r $RIP2 -i -w 1
ipvsadm -l

------------ RS1/RS2 ------------
VIP=192.168.1.3
modprobe tun
modprobe ipip
ip addr add $VIP dev tunl0
ip link set tunl0 up
ip route add $VIP dev tunl0
echo "2" >/proc/sys/net/ipv4/conf/tunl0/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/tunl0/arp_ignore
echo "0" >/proc/sys/net/ipv4/conf/tunl0/rp_filter
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "0" >/proc/sys/net/ipv4/conf/all/rp_filter

------------ Client ------------
VIP=192.168.1.3
curl -v $VIP
curl -v $VIP
```

> [LVS负载均衡之LVS-TUN实例部署（案例篇）](http://blog.51cto.com/blief/1747656)

实现不同网段

