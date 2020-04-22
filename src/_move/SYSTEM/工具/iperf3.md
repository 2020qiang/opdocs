## TCP、UDP、SCTP 网络测试工具

安装

```
# yum install -y iperf3
```

服务端

```
# iperf3 -D -s
```

客户端

```
$ iperf3 -c 192.168.100.3 -t 60
```

结果

```
user@host:~$ iperf3 -c 192.168.100.3 -t 60
Connecting to host 192.168.100.3, port 5201
[  4] local 192.168.100.3 port 38416 connected to 192.168.100.3 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  1.62 MBytes  13.6 Mbits/sec    0    128 KBytes
[  4]   1.00-2.00   sec  1.59 MBytes  13.3 Mbits/sec    0    128 KBytes
...
[  4]  58.00-59.00  sec  1.57 MBytes  13.2 Mbits/sec    0   88.6 KBytes
[  4]  59.00-60.00  sec  1.47 MBytes  12.3 Mbits/sec    2   88.6 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-60.00  sec  93.0 MBytes  13.0 Mbits/sec    7             sender
[  4]   0.00-60.00  sec  92.8 MBytes  13.0 Mbits/sec                  receiver
```

结论

```
极限带宽： 13M
极限速率： 1.6M
```


