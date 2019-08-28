## 语句

连接

```she
shell> sqlite3 /tmp/naem.db
```

查看表

```sql
sqlite> .tables
userinfo
```

查看表结构

```sql
sqlite> .schema
CREATE TABLE userinfo (username VARCHAR(32) NOT NULL, password CHAR(32) NOT NULL);
```

查看表数据

```sql
sqlite> select * from userinfo;
```





