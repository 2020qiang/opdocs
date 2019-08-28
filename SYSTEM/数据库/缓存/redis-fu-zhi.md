#### 主从复制，异步进行![](/assets/redis-master-slave-async.png)PSYNC 同步命令![](/assets/redis-master-slave-psync-progress.png)实现原理![](/assets/redis-master-slave-psync.png)主从复制基本过程：

1. slave 启用同步
   1. 或者配置文件写入同步相关配置信息
   2. client 向 slave 发送命令启用同步：SLAVEOF &lt;master\_ip&gt; &lt;master\_port&gt;
2. slave 在本地登记对应\(配置文件写入同步信息\) master 的 ip、port
3. slave 与 master 建立连接
4. slave 向 master 发送命令 PING，判断连接状态是否良好，否则重新建立连接
5. slave 向 master 发送命令 AUTH，进行身份认证
6. slave 向 master 发送命令 REPLCONF listening-port &lt;port-num&gt;，告知 master ，当前 slave 所在监听的端口号
   1. master 接收到 slave 信息后，将slave 监听的端口号记录到 redisClient 的 slave\_listening\_port 属性
   2. 其唯一作用：master 执行 INFO replication 命令时，打印出 slave 的监听端口
7. 检查是否需要同步，master 会判断 slave 传来的 运行ID（master run id） 是否与自己的相同
   1. 相同则表示之间同步过数据，现在不需要同步
   2. 不相同则表示之间没有同步过数据，现在需要同步
   3. 需要同步则 slave 向 master 发送命令 PSYNC
8. 判断需要同步数据选择 全量/增量
   1. master 判断最后同步成功命令的复制偏移量（replication offset）在积压队列缓存中，则执行增量同步  
   2. master 判断最后同步成功命令的复制偏移量（replication offset）不在积压队缓存列中，则执行全量同步

#### 概念

* 全量同步
  * master 执行持久化操作（写入 RDB 文件到磁盘或者 TCP套接字）
  * master 并将持久化期间收到的指令数据缓存起来
  * master 会将 RDB 和缓存的指令数据一同发送至 slave，slave 将加载收到的 RDB 和缓存的指令数据  
* 增量同步
  * master 向 slave 进行命令传播  其中，master、slave 互为对方的客户端
  * master 能够向 slave 传播命令，本质：master 为 slave 的客户端  
* 积压队列缓存（in-memory backlog）
  * master 进行命令传播时，会将命令发送给所有 slave，同时写入积压队列缓存（内存缓冲区）
  * 相关配置：
    * 大小 MB：repl-backlog-size
    * 存活时间 S：repl-backlog-ttl    
* slave 复制断线重连
  * master/slave 根据条目 7~8，执行复制

#### 避免数据丢失

当启用 Redis 复制功能时，强烈建议打开主服务器的持久化功能。否则的话，由于延迟等问题，部署的服务应该要避免使用类似 Supervisor 的服务自动启动 Redis 服务

参考以下会导致主从服务器数据全部丢失的危险性例子：

* 假设节点A为主服务器，并且关闭了持久化。 并且节点B和节点C从节点A复制数据
* 节点A崩溃，然后由自动拉起服务重启了节点A. 由于节点A的持久化被关闭了，所以重启之后没有任何数据
* 节点B和节点C将从节点A复制数据，但是A的数据是空的， 于是就把自身保存的数据副本删除

在关闭主服务器上的持久化，并同时开启自动启动进程的情况下，即便使用 Sentinel 来实现 Redis 的高可用性，也是非常危险的。 因为主服务器可能启动得非常快，以至于 Sentinel 在配置的心跳时间间隔内没有检测到主服务器已被重启，然后还是会执行上面的数据丢失的流程。

无论何时，数据安全都是极其重要的，所以应该禁止主服务器关闭持久化的同时自动拉起。

#### 配置

```
####
#### 主从复制 ###
####

# 主ip port
slaveof 192.168.68.42 63790
# masterauth <master-password>

# yes 则slave仍然会回复client请求， 尽管数据可能会出现过期或者如果这是第一次同步，数据集可能为空
# no 则从机将回复错误“SYNC with master in progress”到所有类型的命令，除了 INFO和SLAVEOF 命令
slave-serve-stale-data no

# 只读从服务器
slave-read-only yes

# no 磁盘备份，Redis主设备创建一个将RDB文件写入磁盘的新进程。之后，文件被父进程传递给从服务器
# yes 无盘复制，Redis master创建一个新的进程，直接将RDB文件写入从套接字，而不用接触磁盘
repl-diskless-sync yes

# 启用无盘复制，可以配置服务器下一次复制等待的延迟时间 秒
repl-diskless-sync-delay 5

# 从机以时间间隔向服务器发送PING指令
repl-ping-slave-period 10

# 复制超时（SYNC期间批量传输I/O，master站data pings超时，master站REPLCONF ACK pings超时）
repl-timeout 60

# yes 使用较少数量的TCP数据包和较少的带宽向从站发送数据，会增加数据在slave端出现的延迟，导致数据不一致，linux kernel 默认最多可延迟 40ms
# no  slave端数据的延迟将会减少，但使用更多的带宽将被用于复制
repl-disable-tcp-nodelay no

# 复制缓冲区大小，用来保存最新复制的命令，只有在有slave连接的时候才分配内存
# slave断线重连时，如果可以执行部分同步，只需要把缓冲区的部分数据复制给slave，就能恢复正常复制状态
# 稍微大也没关系
repl-backlog-size 10mb

# slave断线之后缓冲区数据的存活时间秒，0表示永不释放
repl-backlog-ttl 3600

# master选举号码，数字最低的slave将成为master，0表示永远不能提升为master
slave-priority 10

# 至少需要多少个slave在线，mater就禁止写入，0为禁用
# 延迟小于min-slaves-max-lag秒的slave才认为是健康的slave
min-slaves-to-write 0
min-slaves-max-lag  0

# 端口转发或地址转换（NAT）网络环境中，需要向master申明自己的ip和端口
#slave-announce-ip 5.5.5.5
#slave-announce-port 1234
```

#### 检查

```
$ redis-cli -h 127.0.0.1 -p 63790 info Replication
$ redis-cli -h 127.0.0.1 -p 63791 info Replication
$ redis-cli -h 127.0.0.1 -p 63792 info Replication
```

```
# master
role:master
connected_slaves:2
slave0:ip=127.0.0.1,port=63791,state=online,offset=1611,lag=0
slave1:ip=127.0.0.1,port=63792,state=online,offset=1611,lag=1
master_repl_offset:1611
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:1610

# slave_1
role:slave
master_host:127.0.0.1
master_port:63790
master_link_status:up
master_last_io_seconds_ago:6
master_sync_in_progress:0
slave_repl_offset:1611
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# slave_2
role:slave
master_host:127.0.0.1
master_port:63790
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:1625
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

> 参见
>
> ```
> http://ningg.top/redis-lesson-8-redis-master-slave/
> http://redisdoc.com/topic/replication.html
> ```



