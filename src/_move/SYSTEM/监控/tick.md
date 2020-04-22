TICK 是 influxdata 公司搞的一套开源监控软件栈 Telegraf, InfluxDB, Chronograf, Kapacitor 的缩写，分别与 Graphite 架构中的数据采集、存储、展示和告警模块对应，且与主流 Graphite 生态兼容。TICK 的核心在于 InfluxDB，一个高效且功能丰富的时间序列数据库；而 Chronnograf 与 Kapacitor 则相对没有那么惊艳；如果不考虑对 InfluxDB 的原生支持，Telegraf 也没有太突出的特点。



### influxdb

配置源

```shell
cat > /etc/yum.repos.d/influxdb.repo << EOF
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
```

安装InfluxDB并配置身份验证

```shell
yum install -y influxdb
```

启动控制台，创建新的管理用户 "admin"，密码 "qweQWE123"

```shell
# service influxdb start

# influx
> CREATE USER admin WITH PASSWORD 'qweQWE123' WITH ALL PRIVILEGES

# influx -host 127.0.0.1 -port 8086 -username 'admin' -password 'qweQWE123'
> show users
```

配置身份验证

```shell
vi /etc/influxdb/influxdb.conf

#[[udp]]
#    enabled = true
#    bind-address = "127.0.0.1:8089"
#    database = "fbc"

[http]
    enabled = true
    bind-address = ":8086"
    auth-enabled = true
    https-enabled = true
    https-certificate = "/keys/server.crt"
    https-private-key = "/keys/server.pem"
```

自启动

```shell
service influxdb restart
chkconfig influxdb on
```

sql语句

```sql
# 查看数据库
show databases

# 切换数据库
use dbname

# 查看表
SHOW MEASUREMENTS

# 查询数据
select * from mysql limit 2

# 删除数据
delete from mysql where host='aws-pingtai-db'

###
### 保留策略，旧数据会删除（Retention Policies）
###

# 查看
SHOW RETENTION POLICIES ON "dbname"

# 创建
CREATE RETENTION POLICY "rp_name" ON "dbname" DURATION 30d REPLICATION 1 DEFAULT
  1.rp_name：策略名
  2.db_name：具体的数据库名
  3.30d：保存最近30天，30天之前的数据将被删除
     它具有各种时间参数，比如：h（小时），w（星期）
  5.REPLICATION 1：副本个数，这里填1就可以了
  6.DEFAULT 设为默认的策略

# 删除
DROP RETENTION POLICY "rp_name" ON "dbname"
```



### telegraf

Telegraf 是一个开源代理，可以收集运行系统或其他服务的指标和数据。 Telegraf 然后将数据写入 InfluxDB 或其他输出

```
# yum install -y telegraf
```

编辑 Telegraf 配置文件，找到 \[outputs.influxdb\] 部分，根据需要修改 urls

```
# vi /etc/telegraf/telegraf.conf

[[outputs.influxdb]]
urls = ["http://localhost:8086"] # required
database = "telegraf" # required
timeout = "5s"
username = "admin"
password = "qweQWE123"
```

启动 telegraf

```
# chkconfig telegraf on
# service telegraf start
```

测试是否获取数据

```shell
telegraf -input-filter system -test
# [or]
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





### kapacitor

Kapacitor是一个数据处理引擎。它允许您插入自己的自定义逻辑，以使用动态阈值处理警报，匹配模式的度量或识别统计异常。我们将使用Kapacitor从InfluxDB读取数据，生成警报，并将这些警报发送到指定的电子邮件地址。

```
# yum install -y kapacitor
```

找到`[[influxdb]]`部分，并提供用于连接到`InfluxDB`数据库的用户名和密码

```
# cp /etc/kapacitor/kapacitor.conf /etc/kapacitor/kapacitor.conf.default
# vi /etc/kapacitor/kapacitor.conf

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

启动 kapacitor

```
# chkconfig kapacitor on
# service kapacitor start
```



### chronograf

Chronograf是一个图形和可视化应用程序，它提供了可视化监控数据和创建警报和自动化规则的工具。它包括对模板的支持，并且具有用于公共数据集的智能预配置仪表板库。我们将配置它连接到我们已经安装的其他组件

```
# yum install -y chronograf
```

启动 chronograf

```
# chkconfig chronograf on
# service chronograf start
```

现在，您可以通过在`Web`浏览器中访问`http://192.168.11.40:8888`访问Chronograf界面



>   官方文档 <https://docs.influxdata.com>
>
>   项目地址 <https://github.com/influxdata>