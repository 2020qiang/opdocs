#### 安装

```bash
# yum localinstall -y http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
# yum install -y percona-toolkit
```

#### 检查

推荐配置

```
log_bin
server_id         = 1
binlog_do_db      = web
replicate-do-db   = web
sync_binlog       = 2
binlog_format     = row
log_slave_updates = on
expire_logs_days  = 7
slave_skip_errors = all
```

最小权限

```sql
[master]
sql> create database percona;
sql> CREATE USER 'percona'@'127.0.0.1' IDENTIFIED BY 'passwd';
sql> GRANT SELECT,PROCESS,SUPER ON *.* TO 'percona'@'127.0.0.1';
sql> GRANT ALL PRIVILEGES ON percona.* TO 'percona'@'127.0.0.1';
sql> GRANT REPLICATION SLAVE ON *.* TO 'percona'@'127.0.0.1';

[slave]
sql> CREATE USER 'percona'@'192.168.%' IDENTIFIED BY 'passwd';
sql> GRANT SELECT,PROCESS,SUPER ON *.* TO 'percona'@'192.168.%';
sql> GRANT ALL PRIVILEGES ON percona.* TO 'percona'@'192.168.%';
sql> GRANT REPLICATION SLAVE ON *.* TO 'percona'@'192.168.%';
```

使用命令

```bash
$ pt-table-checksum                        \
    --user=percona                         \
    --(ask-pass|password='passwd')         \
    --replicate=db00.percona_checksums     \ # 默认为 percona.checksums
    --host=127.0.0.1                       \
    --port=3306                            \
    --databases=db00                       \ # 检查数据库，多个使用逗号','分隔
    --no-check-binlog-format               \ # 因为使用了行复制模式，这里忽略检查二进制日志
    --no-check-replication-filters           # 因为启用了复制过滤，语句复制模式加上复制过滤，复制会产生问题，这里忽略
```

输出结果

```
Checking if all tables can be checksummed ...
Starting checksum ...
            TS ERRORS  DIFFS     ROWS  CHUNKS SKIPPED    TIME TABLE
03-14T13:17:17      0      1        4       1       0   0.010 web.fff
03-14T13:17:17      0      0        2       1       0   0.010 web.aaa
```

* 正常情况下，ERRORS 及 DIFFS 都为空 0
  * DIFFS
    * 校验表时发生的错误和警告的数量
  * ERRORS
    * 一个或多个副本上与主节点不同块

参考：[https://www.percona.com/doc/percona-toolkit/LATEST/pt-table-checksum.html\#output](https://www.percona.com/doc/percona-toolkit/LATEST/pt-table-checksum.html#output)

#### 修复

缺陷：

* 此工具将改变原有master数据，为了最大限度的安全，在使用之前备份数据
* 无法同步表结构，和索引等对象，只能同步数据
* 不适用于双主架构，但可用

最小权限

```sql
[master]+[slave]
sql> CREATE USER 'reload'@'192.168.%' IDENTIFIED BY 'passwd';
sql> GRANT super,PROCESS ON *.* TO 'reload'@'192.168.%';
sql> GRANT select ON db00.* TO 'reload'@'192.168.%';
sql> GRANT select ON percona.* TO 'reload'@'192.168.%';
sql> GRANT REPLICATION SLAVE ON *.* TO 'reload'@'192.168.%';
```

使用命令

```bash
$ pt-table-sync                           \
    --(print|execute)                     \ # 输出不一致的数据，来手动修复，或直接执行修复
    --sync-to-master                      \
    (--replicate percona.checksums)       \ # （可选）
    --databases=db00                      \ # 恢复的库名
    h=192.168.100.143,u=reload,p='passwd' \ # slave的信息
    h=192.168.100.144
```

输出结果

    REPLACE INTO `db00`.`table_02`(`id`, `valu`) VALUES ('18', 'kk') 
    /*percona-toolkit src_db:db00 src_tbl:table_02 src_dsn:P=3306,h=192.168.100.205,p=...,u=reload dst_db:db00 
    dst_tbl:table_02 dst_dsn:h=192.168.100.206,p=...,u=reload lock:1 transaction:1 changing_src:1 replicate:0 
    bidirectional:0 pid:5616 user:root host:test-200-5*/;



