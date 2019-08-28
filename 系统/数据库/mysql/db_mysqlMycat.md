#### 将某几张读写频繁的表分去另一台数据库

![](/assets/mycat01.png)

* /usr/local/mycat/conf/server.xml
* ```xml
  <user name="web">                                   <!-- php客户端 连接的用户     -->
      <property name="password">qweQWE123</property>  <!-- php客户端 连接的密码     -->
      <property name="schemas">web</property>         <!-- php客户端 连接的库名     -->
  <!--<property name="readOnly">true</property>-->
  </user>
  ```
* /usr/local/mycat/conf/schema.xml

```xml
<!-- 将 one 表和 two 表放入节点 dn1 中 -->
<schema name="mycat" checkSQLschema="false">
    <table name="one"  dataNode="dn1" />
    <table name="two"  dataNode="dn1" />
    <table name="test" dataNode="dn2" />
</schema>

<!-- 节点 dn1 使用 host1 主机，并使用它的 newbc 数据库 -->
<!-- 节点 dn2 使用 host2 主机，并使用它的 newbc 数据库 -->
<dataNode name="dn1" dataHost="host1" database="newbc" />
<dataNode name="dn2" dataHost="host2" database="newbc" />

<!-- 写入真实 mysql 主机的 用户名、密码 -->
<dataHost name="host1" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" url="192.168.1.51:3306" user="web" password="password"/>
</dataHost>

<dataHost name="host2" maxCon="1000" minCon="10" balance="0" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" url="192.168.1.52:3306" user="web" password="password"/>
</dataHost>
```



