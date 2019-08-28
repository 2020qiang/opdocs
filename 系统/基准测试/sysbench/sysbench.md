[https://github.com/akopytov/sysbench](https://github.com/akopytov/sysbench)

```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum install -y sysbench
```

准备测试

```sql
当然测试帐户可以直接使用root，但测试库是一定要创建的

sql> create database db00;
```

```
sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua    \
    --mysql-host=localhost                                         \
    --mysql-user=root                                              \
    --mysql-password=qweQWE123                                     \
    --mysql-db=db00                                                \
    --oltp-tables-count=60                                         \
    --oltp-table-size=10000                                        \
    --oltp-dist-type=special                                       \
    --oltp-read-only=off                                           \
    --report-interval=10                                           \
    --rand-init=on                                                 \
    --max-requests=0                                               \
    --threads=8                                                    \
    --time=120                                                     \
    --db-driver=mysql                                              \
    prepare
```

开始测试

```
sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua    \
    --mysql-host=localhost                                         \
    --mysql-user=root                                              \
    --mysql-password=qweQWE123                                     \
    --mysql-db=db00                                                \
    --oltp-tables-count=60                                         \
    --oltp-table-size=10000                                        \
    --oltp-dist-type=special                                       \
    --oltp-read-only=off                                           \
    --report-interval=10                                           \
    --rand-init=on                                                 \
    --max-requests=0                                               \
    --threads=8                                                    \
    --time=120                                                     \
    --db-driver=mysql                                              \
    run
```



