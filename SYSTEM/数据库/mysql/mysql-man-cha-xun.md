查看是否已经开启慢查询日志记录

```
MySQL [(none)]> SHOW VARIABLES LIKE '%slow_query_log%';
+---------------------+----------------------------------+
| Variable_name       | Value                            |
+---------------------+----------------------------------+
| slow_query_log      | OFF                              |
| slow_query_log_file | /var/lib/mysql/php-test-slow.log |
+---------------------+----------------------------------+
```

查看慢查询触发时间

```
MySQL [(none)]> SHOW VARIABLES LIKE 'long_query_time%';
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| long_query_time | 10.000000 |
+-----------------+-----------+
```

临时开启

```
mysql> SET GLOBAL slow_query_log = 'ON';
mysql> SET GLOBAL slow_query_log_file = '/var/log/mysql_slow.log';
```

永久开启

```
# vi /etc/my.cnf

slow_query_log = 1
slow_query_log_file = /var/log/mysql/general_sql.log
long_query_time = 2
```

> 参考
>
> ```
> http://www.cnblogs.com/kerrycode/p/5593204.html
> ```



