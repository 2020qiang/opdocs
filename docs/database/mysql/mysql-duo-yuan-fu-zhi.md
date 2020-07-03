#### 多源复制概述

MySQL多源复制使复制从服务器可以同时接收来自多个来源的事务。

多源复制可用于将多台服务器备份到单台服务器，合并表分片并将多台服务器的数据合并到单台服务器。

多源复制在应用事务时不会执行任何冲突检测或解决方案，并且如果需要，这些任务将留给应用程序。

slave 必须更改

```
决定从站是否将主站状态和连接信息记录到 FILE（master.info）或TABLE （mysql.slave_master_info）
master_info_repository = table

决定 从站在继电器日志中的位置是写入FILE （relay-log.info）还是 写入TABLE （mysql.slave_relay_log_info）
relay_log_info_repository = table
```

因为默认此 slave 每连接一个 master，将会写入 master 信息（CHANGE MASTER 和 GTID 位置）到本地一个指定的文件，这两个文件是唯一性的，表示同时只能使用一个 CHANGE MASTER 和 GTID 位置 信息，使用多源复制必须不能使用此机制。而是将信息存放在库表中，当然 master 及 slave 都可以同时指定 master\_info\_repository 和 relay\_log\_info\_repository

##### 创建

```sql
[slave]

sql> CHANGE MASTER TO
   > MASTER_HOST='192.168.100.131',
   > MASTER_USER='sync',
   > MASTER_PORT=3306,
   > MASTER_PASSWORD='qweQWE123',
   > MASTER_AUTO_POSITION = 1
   > FOR CHANNEL 'master-1';

sql> CHANGE MASTER TO
   > MASTER_HOST='192.168.100.132',
   > MASTER_USER='sync',
   > MASTER_PORT=3306,
   > MASTER_PASSWORD='qweQWE123',
   > MASTER_AUTO_POSITION = 1
   > FOR CHANNEL 'master-2';
```

##### 查看/停止/启动/清除

```sql
[slave]

sql> show slave status \G
sql> show slave status FOR CHANNEL 'master-1' \G
sql> show slave status FOR CHANNEL 'master-2' \G

sql> stop slave;
sql> stop slave FOR CHANNEL 'master-1';
sql> stop slave FOR CHANNEL 'master-2';

sql> start slave;
sql> start slave FOR CHANNEL 'master-1';
sql> start slave FOR CHANNEL 'master-2';

sql> reset slave;
sql> reset slave FOR CHANNEL 'master-1';
sql> reset slave FOR CHANNEL 'master-2';

sql> reset slave all;
sql> reset slave all FOR CHANNEL 'master-1';
sql> reset slave all FOR CHANNEL 'master-2';
```



