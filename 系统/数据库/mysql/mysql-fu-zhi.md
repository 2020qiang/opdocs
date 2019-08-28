![](/assets/screenshot_2018_04_24T20_53_11+0759.png)

---

#### binlog 文件位置复制

```sql
sql> show master status;

sql> CHANGE MASTER TO
   > MASTER_HOST='192.168.100.68',
   > MASTER_PORT=3306,
   > MASTER_USER='user',
   > MASTER_PASSWORD='passwd',
   > MASTER_LOG_FILE='name',
   > MASTER_LOG_POS=int;
```

---

#### GTID 复制

相关配置

```
log_bin
server_id         = 1
binlog_do_db      = test
replicate-do-db   = test
sync_binlog       = 2
binlog_format     = row
log_slave_updates = on
expire_logs_days  = 7
```

> binlog\_do\_db 及 replicate-do-db 参数必须在 binlog\_format=row 才能使用
>
> ```
> 如果 binlog_format != row，因为 binlog_do_db 和 replicate-do-db 这些是使用 use 语句来检测是否符合过滤条件
> 如果 binlog_do_db = test，replicate-do-db = test
>
> 语句
> use test
> inset valu from test
> 将符合条件
>
> 语句
> use test
> inset valu from db00.test
> 本不该符合条件，却符合条件了
>
> 语句
> use db00
> inset valu from test.test
> 本该符合条件，却不符合条件了
>
> 语句
> use db00
> inset valu from test
> 将不符合条件
> ```

一、复制sql文件，清空数据库

```sql
[master]
shell> mysqldump -p dbname --set-gtid-purged=OFF -r name.sql
sql> drop database dbname;
sql> create database dbname;
shell> scp name.sql 192.168.100.68:

[slave]
sql> stop slave;
sql> drop database dbname;
sql> create database dbname;
```

二、清空二进制日志，创建连接信息

```sql
[master]
sql> reset master;
sql> GRANT REPLICATION SLAVE ON *.* TO 'sync'@'192.168.%' IDENTIFIED BY 'passwd';

[slave]
sql> reset master;
sql> reset slave all;
sql> CHANGE MASTER TO
   > MASTER_HOST="hotname",
   > MASTER_PORT=3306,
   > MASTER_USER='sync',
   > MASTER_PASSWORD='qweQWE123',
   > MASTER_AUTO_POSITION=1;
sql> start slave;
sql> show slave status \G
```

三、导入sql，检查同步状态

```sql
[master]
sql> use dbname
sql> source name.sql;
sql> show tables;

[slave]
sql> use dbname
sql> show tables;
sql> show slave status \G
```

或者可以使用xtrabackup热备，从机恢复，从机清空二进制日志，再同步

##### slave 产生间隔

* 设定 MASTER\_AUTO\_POSITION = 1，slave 将根据 GTID 自动选择适当的事务点进行复制
* 配置 slave\_skip\_errors = all，导致某些错误的复制事务被跳过

```sql
[slave]
sql> show slave status \G
Retrieved_Gtid_Set: 7a0afe3f-24e0-11e8-889d-080027ee1167:1-320
 Executed_Gtid_Set: 7a0afe3f-24e0-11e8-889d-080027ee1167:1-316:319-320,
e9ce3bc1-24e0-11e8-8d48-080027df0d3d:1-9
     Auto_Position: 1
```

slave 修复：

1. 配置 slave\_skip\_errors = off
2. 暂时停止复制
3. 手动设置 GTID 值为第一个被跳过的值，这里就像 7a0afe3f-24e0-11e8-889d-080027ee1167:317
4. 暂时启动复制
5. 查看复制状态，将会出错，意料之中，暂时停止复制
6. 检查 MySQL 日志错误文件
7. 手动修复相关数据不一致的问题
8. 再暂时启动复制，查看是否报错
   1. 报错：重复以上 8 个步骤仔细检查数据不一致的问题
   2. 不报错：
      1. 查看复制状态，快接近复制完全的时候，暂时停止复制
      2. 配置 slave\_skip\_errors = all
      3. 再启用复制
9. 最后检查复制状态，是否报错，或执行的事务跳过

##### slave 复制错误

slave 修复：

1. 查看 slave 复制状态中的报错信息
2. 查看 MySQL 错误日志文件
3. 解决错误的问题，或跳过错误继续复制
   1. 解决
      1. 解决数据中的不一致状况
   2. 跳过
      1. 手动设置 GTID 值为第一个被跳过的值，这里就像 7a0afe3f-24e0-11e8-889d-080027ee1167:317
      2. 暂时启动复制，还错误，就从第一步继续排查



