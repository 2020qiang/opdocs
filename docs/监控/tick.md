## 说明

*   官方文档 <https://docs.influxdata.com>

*   项目地址 <https://github.com/influxdata>

*   TICK 是 influxdata 公司搞的一套开源监控软件栈 Telegraf, InfluxDB, Chronograf, Kapacitor 的缩写，

*   分别与 Graphite 架构中的数据采集、存储、展示和告警模块对应，且与主流 Graphite 生态兼容。

*   TICK 的核心在于 InfluxDB，一个高效且功能丰富的时间序列数据库；

*   而 Chronnograf 与 Kapacitor 则相对没有那么惊艳；

*   如果不考虑对 InfluxDB 的原生支持，Telegraf 也没有太突出的特点。

### 安装源

```ini
# /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
```



## influxdb

*   数据库

安装

```shell
yum install influxdb
```

远程身份验证

```ini
# /etc/influxdb/influxdb.conf
[[udp]]
    enabled = true
    bind-address = "127.0.0.1:8089"
    database = "dbname"
[http]
    enabled = true
    bind-address = ":8086"
    auth-enabled = true
    https-enabled = true
    https-certificate = "/keys/null.cert"
    https-private-key = "/keys/null.key"
```

启动

```shell
service influxdb start
```

创建用户

```shell
# 新的管理用户 "admin"，密码 "password"
shell> influx
sql> CREATE USER "admin" WITH PASSWORD "password" WITH ALL PRIVILEGES;
sql> show users;
shell> influx -host 127.0.0.1 -port 8086 -username "admin" -password "password";
```

sql语句

```shell
# 查看数据库
show databases;

# 切换数据库
use dbname;

# 查看表
SHOW MEASUREMENTS;

# 查询数据
select * from mysql limit 2;

# 删除数据
delete from mysql where host='aws-hostname';

###
### 保留策略，旧数据会删除（Retention Policies）
###

# 查看
SHOW RETENTION POLICIES ON "dbname";

# 创建
CREATE RETENTION POLICY "rp_name" ON "dbname" DURATION 30d REPLICATION 1 DEFAULT;
  1.rp_name：策略名
  2.db_name：具体的数据库名
  3.30d：保存最近30天，30天之前的数据将被删除
     它具有各种时间参数，比如：h（小时），w（星期）
  5.REPLICATION 1：副本个数，这里填1就可以了
  6.DEFAULT 设为默认的策略

# 删除
DROP RETENTION POLICY "rp_name" ON "dbname";
```





## telegraf

*   客户端
*   收集运行系统或其他服务的指标和数据，然后将数据写入 InfluxDB 或其他输出

安装

```shell
yum install telegraf
```

配置文件

```shell
# /etc/telegraf/telegraf.conf
[[outputs.influxdb]]
    urls = ["http://server.local:8086"] # required
    database = "dbname" # required
    timeout = "5s"
    username = "admin"
    password = "passwoed"
```

启动

```shell
service telegraf start
```

测试 是否获取到数据

```shell
telegraf -input-filter system -test
# and
telegraf -config /etc/telegraf/telegraf.conf -input-filter system -test
```

自定义监控数据

```shell
#  https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
[[inputs.exec]]
  commands = ["/etc/telegraf/defunct.sh"]
  timeout = "5s"
  name_suffix = "_defunct" # 指标名
  data_format = "" # 常用 value/json
  data_type = ""   # 常用 integer/float
```





## kapacitor

*   告警服务端
*   从InfluxDB读取数据，插入自己的自定义动态阈值处理警报，将这些警报执行 为电子邮件或执行本地程序(数据是标准输入)

安装

```shell
yum install kapacitor
```

配置

```shell
# /etc/kapacitor/kapacitor.conf

[http]
  bind-address = "127.0.0.1:9092"
  log-enabled = false

[logging]
  level = "OFF"

[[influxdb]]
  enabled = true
  default = true
  name = "localhost"
  urls = ["http://127.0.0.1:8086"]
  username = "admin"
  password = "qweQWE123"
```

启动

```shell
service kapacitor start
```

排除某个机器的告警

1.  浏览器打开 chronograf
2.  点击左侧 Alerting 子栏 Manage Tasks
3.  在 TICKscripts 选择需要排除告警，以进入编辑脚本模式
4.  大约在第9行 `lambda: TRUE` 更改为 `lambda: ("host" != "aws-hostname")`





## chronograf

*   web图形化展示

安装

```shell
yum install chronograf
```

配置

```shell
vi /etc/init.d/chronograf
```

启动 

```shell
service chronograf start
```

现在，您可以通过在`Web`浏览器中访问 <http://server.local:8888> 访问Chronograf界面


