#### 配置

```
# vi /etc/my.cnf
transaction_isolation = { read-uncommitted | read-committed | repeatable-read | serializable }
```

| 隔离级别 | 读数据一致性 | 脏读 | 不可重复读 | 幻读 |
| :--- | :--- | :---: | :---: | :---: |
| read-uncommitted | 最低级别 | 是 | 是 | 是 |
| read-committed | 语句级 | 否 | 是 | 是 |
| repeatable-read | 事务级 | 否 | 否 | 是 |
| serializable | 最高级别，事务级 | 否 | 否 | 否 |

* 脏读（dirty read）
* [https://dev.mysql.com/doc/refman/5.7/en/glossary.html\#glos\_dirty\_read](https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_dirty_read)

一个事务修改/添加某个数据，另一个事务却获取了这个事务尚未提交成功的数据。这种操作不符合 ACID 数据库设计原则。这被认为是**非常危险**的，因为数据可能会被回滚，或在提交之前进一步更新;那么，执行脏读的事务将使用未被确认为准确的数据。

* 不可重复读（non-repeatable read）
* [https://dev.mysql.com/doc/refman/5.7/en/glossary.html\#glos\_non\_repeatable\_read](https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_non_repeatable_read)

一个事务，查询同样的数据两次及多次，却得到不同的结果。原来是另一个事务在此事务两次读取之间进行了修改并提交。这种操作违背了ACID数据库设计的原则。在一个交易中，数据应该是一致的，具有可预测和稳定的关系。

* 幻读（phantom）
* [https://dev.mysql.com/doc/refman/5.7/en/glossary.html\#glos\_phantom](https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_phantom)

一个事务，查询同样的数据两次及多次，第二次查询结果包含了第一次未出现的数据。这是因为两次查询过程中有另外一个事务插入了数据。**默认启用**，这种情况称为幻影读取。

#### 选择

隔离级别越高，越能保证数据的完整行和一致性，但对并发性能的影响越大，对于多数应用程序，可以优先将数据库的隔离级别设为 **read-committed** ，它能够避免脏读，并且有较好的性能。尽管它会导致它会导致不可重复读、虚读和第二类丢失更新这些并发问题，一般还是在可接受的范围内，因为读到的还是之前已经提交的数据，本身不会有太大的问题。Oracle、SQL Server 默认隔离级别就是为 **read-committed**。

> ```
> https://dev.mysql.com/doc/refman/5.7/en/glossary.html
> http://www.cnblogs.com/zhoujinyi/p/3437475.html
> ```



