## 系统基准性能测试工具

[https://github.com/kdlucas/byte-unixbench](https://github.com/kdlucas/byte-unixbench)

安装

```
sudo yum install -y gcc wget perl perl-Time-HiRes
wget -c https://github.com/kdlucas/byte-unixbench/archive/v5.1.3.tar.gz
tar -xvf v5.1.3.tar.gz
cd byte-unixbench-5.1.3/UnixBench
make
sudo nohup ./Run &
```

结果

```
Benchmark Run: 五 12月 29 2017 22:07:21 - 22:35:27
32 CPUs in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       34315740.1 lps   (10.0 s, 7 samples)     测试字符串处理
Double-Precision Whetstone                     3658.4 MWIPS (9.9 s, 7 samples)      浮点数操作的速度和效率
Execl Throughput                               1344.7 lps   (30.0 s, 2 samples)     每秒钟可以执行的 execl 系统调用的次数
File Copy 1024 bufsize 2000 maxblocks        872514.4 KBps  (30.0 s, 2 samples)     从一个文件向另外一个文件传输数据的速率
File Copy 256 bufsize 500 maxblocks          233264.5 KBps  (30.0 s, 2 samples)     从一个文件向另外一个文件传输数据的速率
File Copy 4096 bufsize 8000 maxblocks       2679100.3 KBps  (30.0 s, 2 samples)     从一个文件向另外一个文件传输数据的速率
Pipe Throughput                             1547200.9 lps   (10.0 s, 7 samples)     一秒钟内一个进程可以向一个管道写 512 字节数据然后再读回的次数
Pipe-based Context Switching                  84957.2 lps   (10.0 s, 7 samples)     两个进程（每秒钟）通过一个管道交换一个不断增长的整数的次数
Process Creation                               4102.3 lps   (30.0 s, 2 samples)     每秒钟一个进程可以创建子进程然后收回子进程的次数（子进程一定立即退出）
Shell Scripts (1 concurrent)                   2868.9 lpm   (60.0 s, 2 samples)     测试一秒钟内一个进程可以并发地开始一个 shell 脚本的 1 个拷贝的次数
Shell Scripts (8 concurrent)                   1758.5 lpm   (60.0 s, 2 samples)     测试一秒钟内一个进程可以并发地开始一个 shell 脚本的 8 个拷贝的次数
System Call Overhead                        2413565.0 lps   (10.0 s, 7 samples)     一次系统调用的代价，反复地调用 getpid 函数达到此目的

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   34315740.1   2940.5
Double-Precision Whetstone                       55.0       3658.4    665.2     浮点数操作的速度和效率
Execl Throughput                                 43.0       1344.7    312.7     每秒钟可以执行的 execl 系统调用的次数
File Copy 1024 bufsize 2000 maxblocks          3960.0     872514.4   2203.3     从一个文件向另外一个文件传输数据的速率
File Copy 256 bufsize 500 maxblocks            1655.0     233264.5   1409.5     从一个文件向另外一个文件传输数据的速率
File Copy 4096 bufsize 8000 maxblocks          5800.0    2679100.3   4619.1     从一个文件向另外一个文件传输数据的速率
Pipe Throughput                               12440.0    1547200.9   1243.7     一秒钟内一个进程可以向一个管道写 512 字节数据然后再读回的次数
Pipe-based Context Switching                   4000.0      84957.2    212.4     两个进程（每秒钟）通过一个管道交换一个不断增长的整数的次数
Process Creation                                126.0       4102.3    325.6     每秒钟一个进程可以创建子进程然后收回子进程的次数（子进程一定立即退出）
Shell Scripts (1 concurrent)                     42.4       2868.9    676.6     测试一秒钟内一个进程可以并发地开始一个 shell 脚本的 1 个拷贝的次数
Shell Scripts (8 concurrent)                      6.0       1758.5   2930.8     测试一秒钟内一个进程可以并发地开始一个 shell 脚本的 8 个拷贝的次数
System Call Overhead                          15000.0    2413565.0   1609.0     一次系统调用的代价，反复地调用 getpid 函数达到此目的
                                                                   ========
System Benchmarks Index Score                                        1076.0
```



