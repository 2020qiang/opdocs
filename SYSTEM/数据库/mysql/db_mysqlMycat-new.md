仅仅适用于 **写少/读多** 架构

因为我们写操作比读的频繁，而且要求写和读实时性很高，需要刚写入数据库，就要马上读出来，但是中间有一定的时间差，数据的金额就会计算错误

![](/assets/111fsdfsd.png)

* /usr/local/mycat/conf/server.xml
* ```xml
  <user name="web">                                  <!-- php客户端 连接的用户     -->
      <property name="password">qweQWE123</property> <!-- php客户端 连接的密码     -->
      <property name="schemas">web</property>        <!-- php客户端 连接的库名     -->
  <!--<property name="readOnly">true</property>-->
  </user>
  ```
* /usr/local/mycat/conf/schema.xml

```xml
<!-- 将 one 表和 two 表放入节点 dn1 中 -->
<schema name="web" checkSQLschema="false" sqlMaxLimit="100">
    <table name="one"  dataNode="dn1" />
    <table name="two"  dataNode="dn1" />
</schema>

<!-- 节点 dn1 使用 oneHost 主机，并使用它的 db00 数据库 -->
<!-- 节点 dn2 使用 twoHost 主机，并使用它的 db00 数据库 -->
<dataNode name="dn1" dataHost="oneHost" database="db00" />
<dataNode name="dn2" dataHost="twoHost" database="db00" />

<!-- 写入真实 mysql 主机的 用户名 密码 -->
<dataHost name="oneHost" maxCon="3000" minCon="10" balance="3" writeType="0" dbType="mysql" dbDriver="native" switchType="2"  slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="test-mysql-1" url="192.168.200.11:3306" user="mycat" password="qweQWE123">
        <readHost host="test-mysql-3" url="192.168.200.13:3306" user="mycat" password="qweQWE123" />
    </writeHost>
    <writeHost host="test-mysql-3" url="192.168.200.13:3306" user="mycat" password="qweQWE123" />
    <writeHost host="test-mysql-5" url="192.168.200.10:3306" user="mycat" password="qweQWE123" />
</dataHost>
<dataHost name="twoHost" maxCon="3000" minCon="10" balance="3" writeType="0" dbType="mysql" dbDriver="native" switchType="2"  slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="test-mysql-2" url="192.168.200.12:3306" user="mycat" password="qweQWE123">
        <readHost host="test-mysql-4" url="192.168.200.14:3306" user="mycat" password="qweQWE123" />
    </writeHost>
    <writeHost host="test-mysql-4" url="192.168.200.14:3306" user="mycat" password="qweQWE123" />
    <writeHost host="test-mysql-5" url="192.168.200.10:3306" user="mycat" password="qweQWE123" />
</dataHost>
```

```
balance 属性
1. balance="0", 不开启读写分离机制，所有读操作都发送到当前可用的 writeHost 上。
2. balance="1"，全部的 readHost 与 stand by writeHost 参与 select 语句的负载均衡
                简单的说，当双主双从模式(M1->S1，M2->S2，并且 M1 与 M2 互为主备)，正常情况下，
                M2,S1,S2 都参与select 语句的负载均衡。
3. balance="2"，所有读操作都随机的在 writeHost、readhost 上分发。
4. balance="3"，所有读请求随机的分发到 wiriterHost 对应的 readhost 执行，writerHost 不负担读压力，


writeType 属性
1. writeType="-1", 表示不自动切换
2. writeType="0", 所有写操作发送到配置的第一个 writeHost，第一个挂了切到还生存的第二个writeHost，
                  重新启动后已切换后的为准，切换记录在配置文件中:dnindex.properties .
4. writeType="2"，基于 MySQL 主从同步的状态决定是否切换


switchType 属性
-1 表示不自动切换
1 默认值，自动切换
2 基于 MySQL 主从同步的状态决定是否切换 心跳语句为 show slave status
3 基于 MySQL galary cluster 的切换机制（适合集群）（1.4.1）心跳语句为 show status like ‘wsrep%’.
```

使用配置

```
balance="0"
writeType="0"
switchType="2"
<heartbeat>show slave status</heartbeat>
```



