**minion** 运行启动关闭某些服务，会产生**僵尸进程**

例如

* `service mysqld restart`，僵尸进程的命令就是 service
* `/etc/init.d/mysqld restart`，僵尸进程的命令就是 mysqld

它们的父进程就是 minion 守护程序，启动重启其他服务没出现僵尸进程，因为其他服务启动重启较快

出现这样的原因就是 salt-minion 运行的子进程超时执行，间接解决方式：

```
screen -dm service mysqld start
```

使它这个任务后台执行



