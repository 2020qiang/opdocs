### 多线路多 IP 同时都能连接

可实现网通电信教育网等双线连接及高可用

```
# 查看路由状态
ip route show

# 创建路由表
echo '101 ChinaNet' >> /etc/iproute2/rt_tables
echo '102 ChinaCnc' >> /etc/iproute2/rt_tables
echo '103 ChinaEdu' >> /etc/iproute2/rt_tables

# 添加至路由表
ip route add default via 1.1.1.254 dev eth0 table ChinaNet
ip route add default via 2.2.2.254 dev eth1 table ChinaCnc
ip route add default via 3.3.3.254 dev eth2 table ChinaEdu

# 使来自不同的接口的走不同的路由表
ip rule add from 1.1.1.1 table ChinaNet
ip rule add from 2.2.2.2 table ChinaCnc
ip rule add from 3.3.3.3 table ChinaEdu
```

也可实现单线路多 IP，多网关

```
ip route add default via 192.168.1.1 src 192.168.1.252 table one
ip route add default via 192.168.1.2 src 192.168.1.253 table two
ip rule add from 192.168.1.252 table one
ip rule add from 192.168.1.253 table two
```

> [http://memoryboxes.github.io/blog/2014/12/30/linuxshuang-wang-qia-shuang-lu-you-she-zhi/](http://memoryboxes.github.io/blog/2014/12/30/linuxshuang-wang-qia-shuang-lu-you-she-zhi/)



