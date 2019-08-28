* 日期：2018/03/21
* 故障：数据库 load 飙得很高，最高超过 40 多，满载 32
* 原因：Innodb 引擎表事务锁等待，引起系统资源的大量浪费
* 解决：kill 掉长时间锁等待的事务 id

```sql
sql> SELECT * FROM information_schema.INNODB_TRX \G
sql> kill (trx_mysql_thread_id);
```

写锁

当一个连接线程开始一个事务，还没来的及提交，但是第二个连接线程需要更改这个数据，一直在等待第一个事物提交

