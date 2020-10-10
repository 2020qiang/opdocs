## 安装

官网：[https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html](https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html)

```bash
cat > /etc/yum.repos.d/mysql-community.repo << EOF
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=https://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
EOF
   yum makecache \
&& yum install -y mysql-community-client mysql-community-server \
&& systemctl enable mysqld \
&& systemctl start  mysqld \
&& systemctl status mysqld
```

初始化

```sql
mysql -u root -p$(grep 'temporary password' /var/log/mysqld.log |tail -n 1 |awk '{print $NF}')
SET GLOBAL validate_password_special_char_count = 0;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'passWord';
```

权限

```sql
mysql> SELECT user,host FROM mysql.user;
+---------------+-----------+
| user          | host      |
+---------------+-----------+
| root          | localhost |  # 特权用户
| status        | 127.0.0.1 |  # 监控用
| replication   | 192.168.% |  # 主从复制用
| peeker        | %         |  # 远程只读用户
| editor        | %         |  # 远程可写用户
| www           | 10.0.1.8  |  # 生产项目用
| mysql.session | localhost |
| mysql.sys     | localhost |
+---------------+-----------+
8 rows in set (0.00 sec)


GRANT REPLICATION CLIENT ON *.* TO      'status'@'127.0.0.1' IDENTIFIED BY 'passWord';
GRANT REPLICATION SLAVE  ON *.* TO 'replication'@'192.168.%' IDENTIFIED BY 'passWord';

GRANT                 SELECT         ON `dbname`.* TO 'peeker'@'%' IDENTIFIED BY 'passWord';
GRANT INSERT, DELETE, SELECT, UPDATE ON `dbname`.* TO 'editor'@'%' IDENTIFIED BY 'passWord';

GRANT ALL PRIVILEGES ON `dbname`.* TO 'www'@'10.0.1.8' IDENTIFIED BY 'passWord';
```



## 忘记密码

```shell
# 安全模式
vi /etc/my.cnf
service mysqld restart
skip-grant-tables

# 重置密码
update mysql.user set authentication_string=password('qweQWE123') where user='root';
or
update mysql.user set password=password('qweQWE123') where host='localhost' and user='root';
```



## 转储SQL文件

### 常用参数列表

```
-h hostname
从给定主机上的MySQL服务器转储数据。默认是localhost

-P port
用于连接的TCP/IP端口号。默认是3306

-q
通常先将表缓存在数据中，但是在大数据情况下不适用，需要直接使用磁盘中的数据

-c , --complete-insert
使用包含列名的完整INSERT语句

-u username
连接到服务器时使用的MySQL用户名。默认是root

-p'password' / -p
命令行密码 / 交互式输入密码

-d
仅仅包含表结构，只有CREATE TABLE 语句

-t
仅仅包含数据内容，没有只有CREATE TABLE 语句

--set-gtid-purged=OFF
忽略set语句导出gtid值

--master-data
会生成 CHANGE MASTER TO MASTER_LOG_FILE='mysql2-bin.000049', MASTER_LOG_POS=587; 语句

--single-transaction
innodb 将不会锁表，因为会在转储之前使用指定事务级别，然后开始事务，使用事务中的快照读，这样既能保证一致性读，也不会锁表

--databases, -B
通常命令行后面的参数视为数据库名称，后面的名称作为表名称
使用此选项，它将所有名称参数视为数据库名称。每个新数据库之前，输出中都包含CREATE DATABASE和USE语句

--tables
--databases或-B选项。 mysqldump将选项后面的所有名称参数视为表名

-r name.sql
直接输出到指定的文件，会覆盖原文件
```

### 导出

```shell
mysqldump -q -c -u root -p db00 --single-transaction --set-gtid-purged=OFF -r filename.sql
Enter password:
```

### 导入

```
sql> source name.sql;
```

>   [**mysqldump** — A Database Backup Program](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html)



## 增量备份（文件级）

### 安装

```shell
yum localinstall -y http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
yum install -y percona-xtrabackup-24
```

### 全备

```shell
xtrabackup --backup --user=root --password=passwd --databases=dbname --host=127.0.0.1 --port=3306 --target-dir=./full
```

### 增备

```shell
xtrabackup --backup --user=root --password=passwd --databases=dbname --host=127.0.0.1 --port=3306 --incremental-basedir=./full --target-dir=./inc1
xtrabackup --backup --user=root --password=passwd --databases=dbname --host=127.0.0.1 --port=3306 --incremental-basedir=./inc1 --target-dir=./inc2
xtrabackup --backup --user=root --password=passwd --databases=dbname --host=127.0.0.1 --port=3306 --incremental-basedir=./inc2 --target-dir=./inc3
```

### 组合各增备至全备，并恢复

```shell
xtrabackup --prepare --apply-log-only --target-dir=./full
xtrabackup --prepare --apply-log-only --target-dir=./full --incremental-dir=./inc1
xtrabackup --prepare --apply-log-only --target-dir=./full --incremental-dir=./inc2
service mysqld stop
rsync -avrP ./full/ /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
service mysqld start
```



## 监控

### 查询吞吐量

值以次数累加

*   `Queries`：服务器执行的语句数（包括在存储的程序中执行的语句）
*   `Questions`：服务器执行的语句数（仅包括客户端发送到服务器的语句）
*   `Com_select`：执行查询语句的数量，通常也就是QPS
*   `Com_insert`：执行插入语句的数量
*   `Com_update`：执行更新语句的数量
*   `Com_delete`：执行删除语句的数量

#### 语句

```
MySQL [sys]> SHOW STATUS LIKE 'Queries';
MySQL [sys]> SHOW STATUS LIKE 'Questions';
MySQL [sys]> SHOW STATUS LIKE 'Com_select';
MySQL [sys]> SHOW STATUS LIKE 'Com_insert';
MySQL [sys]> SHOW STATUS LIKE 'Com_update';
MySQL [sys]> SHOW STATUS LIKE 'Com_delete';
```

#### 监控

```
Questions        已执行的由客户端发出的语句统计数量
Com_select       执行SELECT语句的数量，通常也就是QPS
Writes           Com_insert+Com_update+Com_delete，也就是TPS
```

### 查询执行性能

数据库中的值默认以微秒为单位

-   `count`：数据库运行次数
-   `avg_microsec`：平均运行时间（微秒）
-   `err_count`：出现的错误语句总数
-   `Slow_queries`：慢查询次数（执行时间超过`long_query_time`参数指定的值）
    -   `long_query_time`：默认为 10 秒

#### 语句

```
MySQL [sys]> SELECT schema_name, SUM(count_star) count, \
             ROUND((SUM(sum_timer_wait)/SUM(count_star))/1000000) AS avg_microsec \
             FROM performance_schema.events_statements_summary_by_digest
             WHERE schema_name IS NOT NULL GROUP BY schema_name;
MySQL [sys]> SELECT schema_name, SUM(sum_errors) err_count \
             FROM performance_schema.events_statements_summary_by_digest \
             WHERE schema_name IS NOT NULL GROUP BY schema_name;
MySQL [sys]> SHOW STATUS LIKE "Slow_queries";
MySQL [sys]> SHOW VARIABLES LIKE 'long_query_time';
```

#### 监控

```
Slow_queries         慢查询的数量
```

### 连接情况

*   `max_connections`：最大客户端连接数（默认150）
*   `Threads_connected`：已经建立的连接数（如果采用每个连接一个线程的方式）
*   `Threads_running`：连接被占用但是却没有处理任何请求的次数
*   `Connection_errors_internal`：达到最大连接数，就会拒绝新的连接请求的次数
*   `Aborted_connects`：尝试与服务器建立连接但是失败的次数
*   `Connection_errors_max_connections`：服务器本身导致的错误（例如内存不足）

#### 语句

```
MySQL [sys]> SHOW VARIABLES LIKE 'max_connections';
MySQL [sys]> SHOW STATUS LIKE 'Threads_connected';
MySQL [sys]> SHOW STATUS LIKE 'Threads_running';
MySQL [sys]> SHOW STATUS LIKE 'Connection_errors_internal';
MySQL [sys]> SHOW STATUS LIKE 'Aborted_connects';
MySQL [sys]> SHOW STATUS LIKE 'Connection_errors_max_connections';
```

#### 监控

```
Threads_connected                   已经建立的连接
Threads_running                     正在运行的连接
Connection_errors_internal          由于服务器内部本身导致的错误
Aborted_connects                    尝试与服务器建立连接但是失败的次数
Connection_errors_max_connections   由于到达最大连接数导致的错误
```

### 缓冲池使用情况

*   `innodb_buffer_pool_chunk_size`：缓冲池大小
*   `innodb_buffer_pool_instances`：缓冲池实例
*   `Innodb_buffer_pool_read_requests`：读取请求的数量
*   `Innodb_buffer_pool_reads：`缓冲池无法满足，因而只能从磁盘读取的请求数量
*   `Innodb_buffer_pool_pages_free`：空闲缓存页数
*   `Innodb_buffer_pool_pages_total`：BP 中总页面数
*   `Innodb_buffer_pool_read_requests`：BP 的读请求

#### 语句

```
MySQL [mysql]> SHOW VARIABLES LIKE 'innodb_buffer_pool_chunk_size';
MySQL [mysql]> SHOW VARIABLES LIKE 'innodb_buffer_pool_instances';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_reads';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_pages_total';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_pages_data';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_pages_free';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_pages_total';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests';
MySQL [mysql]> SHOW STATUS LIKE 'Innodb_buffer_pool_pages_data';
```

```
InnoDB 缓存的使用率：
    Innodb_buffer_pool_pages_data / Innodb_buffer_pool_pages_total

缓存的命中率：
(Innodb_buffer_pool_read_requests - Innodb_buffer_pool_reads) / Innodb_buffer_pool_read_requests * 100%
```

#### 监控

```
Innodb_buffer_pool_pages_total          InnoDB BP中总页面数
Innodb_*_data / Innodb_*_total          InnoDB BP中使用的使用率
Innodb_buffer_pool_read_requests        InnoDB BP的读请求
Innodb_buffer_pool_reads                需要读取磁盘的请求数
```

>   ```ur
>   https://kknews.cc/zh-sg/news/en8bvgq.html
>   https://jin-yang.github.io/post/mysql-monitor.html
>   https://oxnz.github.io/2015/12/27/mysql-primer-measurements/
>   ```



## SQL语句

### 变量

```sql
查看变量值
sql> SHOW VARIABLES LIKE 'general_log%';
sql> SHOW VARIABLES LIKE 'general_log';

用户变量赋值，私有变量，退出失效
sql> SET @GLOBAL.GTID_PURGED = '35cc99c6-0297-11e4-9916-782bcb2c9453:1-2455';

系统变量赋值，公共变量，重启失效
sql> SET GLOBAL validate_password_special_char_count = 0;
sql> SET @@validate_password_special_char_count = 0;

查看正在执行的事务
sql> SHOW FULL PROCESSLIST;
```

------

### 用户

```sql
查看用户
sql> SELECT user,host FROM mysql.user;

新建用户
sql> CREATE USER 'name'@'192.168.%' IDENTIFIED BY 'qweQWE123';

更改密码
sql> alter user 'root'@'localhost' IDENTIFIED by 'qweQWE123';
sql> alter user 'www'@'192.168.%' IDENTIFIED by 'qweQWE123';

忘记密码
sql> UPDATE mysql.user set authentication_string=PASSWORD('qweQWE123') where User='root';

删除用户
sql> DROP USER 'web'@'%';
```

---

### 权限

```sql
显示权限
sql> show grants;
sql> show grants for username@'192.168.%';

完全授权
sql> GRANT ALL PRIVILEGES ON db00.* TO 'www'@'10.0.%' IDENTIFIED BY 'qweQWE123';
sql> GRANT ALL PRIVILEGES ON db00.* TO 'www'@'10.0.%';

项目授权
sql> GRANT insert,delete,update,select ON db00.* TO 'web'@'192.168.%';

复制授权
sql> GRANT REPLICATION SLAVE ON *.* TO 'sync'@'192.168.%';
sql> GRANT REPLICATION CLIENT ON *.* TO 'sync'@'192.168.%';

撤销权限
sql> REVOKE privilege ON dbname.tablename FROM 'name'@'host';
sql> REVOKE insert,delete ON dbname.tablename FROM 'name'@'host';

刷新权限
sql> flush privileges;
```

---

### 二进制日志

```sql
查看所有二进制日志列表
sql> SHOW MASTER LOGS;
sql> SHOW BINARY LOGS;

查看master状态
sql> SHOW MASTER STATUS \G

刷新二进制日志，产生一个新编号的binlog日志文件
sql> FLUSH LOGS;

删除所有二进制日志文件，并新创建
sql> RESET MASTER;

忘记master的二进制日志中的复制位置
sql> RESET SLAVE;
sql> RESET SLAVE ALL;

-- Row模式下解析binlog日志
--  @1 不显示二进制部分
--  @2 开始时间
--  @3 结束时间
--  @4 不显示多余的事件信息
--  @5 binlog文件
--  @6 输出解析后的日志
mysqlbinlog --base64-output="decode-rows"   \
    --start-datetime='2020-04-08 00:00:00'  \
    --stop-datetime='2020-04-08 04:00:00'   \
    -v mysql-bin.000014 >mysql-bin.000014.log
```

---

### 解锁

```sql
临时锁库，仅仅能读，退出失效
sql> FLUSH TABLE WITH READ LOCK;

锁库，除super权限用户
sql> SET GLOBAL read_only = 'on';

解锁
sql> SET GLOBAL read_only = 'off';
sql> UNLOCK TABLES;

最终解锁
sql> kill (show processlist);
sql> shutdown;
```

---

### 索引

```sql
查看索引
sql> show index from tablename \G

删除索引
sql> drop index (Key_name) on tablename;
```

---

### 连接

```sql
查看所有连接线程
sql> show full processlist;

查看前100条
sql> show processlist;

杀死连接
sql> kill (Id);

查看执行的语句，可以 kill trx_mysql_thread_id
sql> SELECT * FROM information_schema.INNODB_TRX \G
```

---

### 数据

```sql
更新数据
sql> UPDATE tablename SET valu='aa' WHERE id=1;

清空数据，保留表结构
sql> truncate tablename;
```

---

### 事务

```sql
开始事务
sql> BEGIN;

回滚事务
sql> ROLLBACK;

提交事务
sql> COMMIT;
```

---

### 其它

```sql
创建数据库
sql> CREATE DATABASE name;

删除数据库
sql> DROP DATABASE name;

查看表数据条目行数
会锁表，并全表扫描，数据量够大会导致机器崩掉
sql> SELECT COUNT(*) FROM name;
sql> SELECT SUM() FROM name;

手动设定GTID值
sql> stop slave;
sql> reset master;
sql> SET GLOBAL GTID_PURGED = '35cc99c6-0297-11e4-9916-782bcb2c9453:1-2455';
sql> SET @@GLOBAL.GTID_PURGED = '35cc99c6-0297-11e4-9916-782bcb2c9453:1-2455';
sql> start slave;
sql> show slave status \G

查看表结构
sql> desc table_name;
sql> show create table table_name;
```



## 定时事件

>   目的：自动迁移数据、自动清理

```mysql
mysql> delimiter $$   # 将语句的结束符号从分号;暂时改为两个$$(可以是自定义)
mysql> delimiter ;　　# 将语句的结束符号恢复为分号
```



创建一个函数，上一条语句失败，下一条语句不会执行

```sql
DROP PROCEDURE IF EXISTS tansfer_wallet_income_3daysago;

CREATE PROCEDURE tansfer_wallet_income_3daysago()
BEGIN

  -- backup table data
 WHILE ( SELECT DISTINCT IF(  EXISTS(  SELECT * FROM jbc_wallet_income WHERE (date < DATE_SUB(CURDATE(),INTERVAL 3 DAY)) ORDER BY uid DESC LIMIT 1 ),1,0 ) AS exist ) = 1 DO
    START TRANSACTION;
  INSERT INTO jbc_wallet_income_back ( SELECT * FROM jbc_wallet_income WHERE (date < DATE_SUB(CURDATE(),INTERVAL 3 DAY)) ORDER BY uid DESC LIMIT 10000 );
  DELETE FROM jbc_wallet_income                                        WHERE (date < DATE_SUB(CURDATE(),INTERVAL 3 DAY)) ORDER BY uid DESC LIMIT 10000;
    COMMIT;
 END WHILE;

  -- clean old backup
  WHILE ( SELECT DISTINCT IF(  EXISTS(  SELECT * FROM jbc_wallet_income_back WHERE (date < DATE_SUB(CURDATE(),INTERVAL 90 DAY)) ORDER BY uid DESC LIMIT 1 ),1,0 ) AS exist ) = 1 DO
                                        DELETE   FROM jbc_wallet_income_back WHERE (date < DATE_SUB(CURDATE(),INTERVAL 90 DAY)) ORDER BY uid DESC LIMIT 10000;
  END WHILE;

END
```

定时触发函数，STARTS 参数要更改为下次执行时间

```sql
CREATE EVENT tansfer_wallet_income
  ON SCHEDULE EVERY 1 DAY STARTS '2019-06-29 06:35:00'
  ON COMPLETION PRESERVE
DO call tansfer_wallet_income_3daysago();
```

开启事件

```sql
SHOW VARIABLES LIKE 'event_scheduler';
SET GLOBAL event_scheduler=ON;

show events;
alter event tansfer_wallet_income ON COMPLETION PRESERVE ENABLE;
alter event tansfer_wallet_income ON COMPLETION PRESERVE DISABLE;
```

