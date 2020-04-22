* master 管理端
* minions 被管理端
  * 启动时收集静态数据

#### 安装

```
curl -L https://bootstrap.saltstack.com -o install_salt.sh
master: sudo sh install_salt.sh -P -M -N
minion: sudo sh install_salt.sh -P
```

#### 目录结构

```
/etc/salt/
├── cloud
├── cloud.profiles
├── cloud.providers
├── master
├── minion
├── minion.d
├── minion_id ---------------------->被管理者的ID
├── pki
│   ├── master
│   │   ├── master.pem
│   │   ├── master.pub
│   │   ├── minions
│   │   ├── minions_autosign
│   │   ├── minions_denied
│   │   ├── minions_pre
│   │   └── minions_rejected
│   └── minion
│       ├── master.pem
│       └── master.pub
├── proxy
└── roster
```

#### 配置认证

使用密钥对认证

* minions 端操作
  * 在 minions 中指定 master 端
  * /etc/salt/minion
  * 在 16 行指定 master 端
  * 重启 minions 进程
* master 端操作
  * salt-key 查看认证状态
  * salt-key -a one.test 添加 minions 端

#### 远程执行

#### `salt '*' cmd.run 'df -h'`

* `salt`--------&gt; 使用 SaltStack 操作
* `'*'`---------&gt; 操作目标（通配符）
* `cmd`---------&gt; 模块
* `run`---------&gt; 方法
* `'df -h'`--&gt; 命令

输出：

```
one.test:
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda1       6.9G  959M  5.6G  15% /
    udev             10M     0   10M   0% /dev
    tmpfs           201M  4.4M  196M   3% /run
    tmpfs           501M   12K  501M   1% /dev/shm
    tmpfs           5.0M     0  5.0M   0% /run/lock
    tmpfs           501M     0  501M   0% /sys/fs/cgroup
two.test:
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda1       6.9G  959M  5.6G  15% /
    udev             10M     0   10M   0% /dev
    tmpfs           201M  4.4M  196M   3% /run
    tmpfs           501M   12K  501M   1% /dev/shm
    tmpfs           5.0M     0  5.0M   0% /run/lock
    tmpfs           501M     0  501M   0% /sys/fs/cgroup
```

以非特权用户身份运行 master/minions [参考官网](http://docs.saltstack.cn/ref/configuration/nonroot.html)

```
#chown -R [user] \
    /etc/salt \
    /var/cache/salt \
    /var/log/salt \
    /var/run/salt \
    /srv/salt/
```

#### 数据系统 Grains

* `salt '*' grains.ls`--------------------&gt; 输出默认 grains 的名称
* `salt '*' grains.items`---------------&gt; 输出默认 grains 的名称和值
* `salt 'one.test' grains.get os`--&gt; 输出grains 的名称为 os 的值

应用场景：minions 启动时收集静态数据

* 在 state 系统中使用，用于配置管理模块
* 在 starget 中使用，再匹配 minion，如 OS，使用 -G 选项
  * `salt -G os:debian cmd.run 'uptime'`--&gt; 在 OS 的值为 Debian 的机器上执行 uptime 指令
* 存放着 minions 搜集到的详细信息，可用于信息查询
* 在 minions 操作

定义 Grains

```
vi /etc/salt/grains
systemctl restart salt-minion.service
```

/etc/salt/grains 内容

```
cloud: openstatck
[or]
cloud: 
  - openstatck
```

例如打标签

```
vi /etc/salt/grains
group: nginx
systemctl restart salt-minion.service
```

验证这样这台机器被打上了 nginx 标签，直接操作 grains

```
salt -G group:nginx cmd.run 'uptime'
```

输出

```
one.test:
     20:32:33 up  1:42,  1 user,  load average: 0.00, 0.00, 0.00
```

可读取 group 的值

```
salt '*' grains.get group
```

输出

```
two.test:
one.test:
    nginx
```

#### 数据系统 Pillar（动态储存）

* **储存位置：**储存在 master 端，仅存放需要提供给 minion 的信息
* **应用场景：**储存（敏感信息）每个 minion 只能访问 master 分配给自己的
* 在 master 端操作

启用 pillar

```
vi /etc/salt/master
:705 [or] /pillar_roots
mkdir /srv/pillar
systemctl restart salt-master.service
```

配置 pillar

```
cd /srv/pillar
```

top.sls（指定哪一个节点可以访问 pillar 的值）

```
base:
  'one.test':
    - server
```

server.sls

```
group:
  - nginx
  - apache2
```

刷新 pillar 数据（类似 Grains 在 minions 中重启 minions 服务）

```
salt '*' saltutil.refresh_pillar
```

获取 pillar 数据

```
salt '*' pillar.item nginx_server
[or]
salt '*' pillar.get nginx_server
```

pillar 匹配运行

```
salt -I 'group:nginx' test.ping
```

输出

```
one.test:
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda1       6.9G  1.2G  5.3G  19% /
    udev             10M     0   10M   0% /dev
    tmpfs           201M  4.4M  196M   3% /run
    tmpfs           501M   12K  501M   1% /dev/shm
    tmpfs           5.0M     0  5.0M   0% /run/lock
    tmpfs           501M     0  501M   0% /sys/fs/cgroup
```

#### 数据系统对比

* Grains
  * 储存位置：minion 端定义
  * 数据类型：静态数据
  * 数据采集更新方式：minion 进程启动时收集，也可用 statutil.sync\_grains 刷新
  * 应用范围：用于匹配 minion，自身数据可用于资产管理等
* Pillar
  * 储存位置：master 端定义
  * 数据类型：动态数据
  * 数据采集更新方式：指定给对应的 minion，也可用 statutil.refresh\_pillar 刷新
  * 应用范围：储存只有指定 minion 才能读取的数据（敏感数据）



