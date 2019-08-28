查看是否已经开启实时SQL语句记录

```
mysql> SHOW VARIABLES LIKE 'general_log%';
+------------------+----------------------------------+
| Variable_name    | Value                            |
+------------------+----------------------------------+
| general_log      | OFF                              |
| general_log_file | /var/lib/mysql/galley-pc.log     |
+------------------+----------------------------------+
```

临时开启

```
mysql> SET GLOBAL general_log = 'ON';
mysql> SET GLOBAL general_log_file = '/var/log/mysqld-access.log';
```

永久开启

```
# vi /etc/my.cnf

general_log = 1
general_log_file = /var/log/mysql/general_sql.log
```

实时查看

```
$ tail -f /var/lib/mysql/general_sql.log
```

过滤查看

```
$ tail -f /var/lib/mysql/php-test.log |grep -v -E '(SELECT|SHOW|Connect|Quit|SET NAMES utf8)'
```

> 参考
>
> ```
> https://www.awaimai.com/1910.html
> ```



