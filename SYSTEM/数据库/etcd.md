etcd是一个开源的分布式键值存储，为Container Linux集群提供共享配置和服务发现。etcd在集群中的每台机器上运行，并在网络分区和当前领导者的丢失期间优雅地处理领导者选举。

启动参数

```shell
--listen-peer-urls              监听对等同步流量的URL
--initial-advertise-peer-urls   告诉其他成员，此服务的对等流量的URL
--listen-client-urls            监听客户端流量的URL
--advertise-client-urls         告诉其他成员，此服务的客户端流量的URL
--initial-cluster-token         引导期间etcd集群的初始集群令牌。多个群集可以保护免受意外的跨群集操作。
--initial-cluster               第一次引导的静态初始集群配置
--initial-cluster-state         初始集群状态 ('new' or 'existing')（新、现有）
```

#### 初始启动集群

```shell
IP1="10.9.17.201"
IP2="10.9.17.202"
IP3="10.9.17.203"
IP4="10.9.17.204"

# Node_1
/opt/etcd/etcd --name infra1                                                                \
               --data-dir /opt/etcd/data                                                    \
               --listen-peer-urls http://0.0.0.0:2380                                       \
               --initial-advertise-peer-urls http://${IP1}:2380                             \
               --listen-client-urls http://0.0.0.0:2379                                     \
               --advertise-client-urls http://${IP1}:2379                                   \
               --initial-cluster-token etcd-test-1                                          \
               --initial-cluster infra0=http://${IP1}:2380,infra1=http://${IP2}:2380,infra2=http://${IP3}:2380               \
               --initial-cluster-state new

# Node_2
/opt/etcd/etcd --name infra2                                                                \
               --data-dir /opt/etcd/data                                                    \
               --listen-peer-urls http://0.0.0.0:2380                                       \
               --initial-advertise-peer-urls http://${IP2}:2380                             \
               --listen-client-urls http://0.0.0.0:2379                                     \
               --advertise-client-urls http://${IP2}:2379                                   \
               --initial-cluster-token etcd-test-1                                          \
               --initial-cluster infra0=http://${IP1}:2380,infra1=http://${IP2}:2380,infra2=http://${IP3}:2380               \
               --initial-cluster-state new

# Node_3
/opt/etcd/etcd --name infra3                                                                \
               --data-dir /opt/etcd/data                                                    \
               --listen-peer-urls http://0.0.0.0:2380                                       \
               --initial-advertise-peer-urls http://${IP3}:2380                             \
               --listen-client-urls http://0.0.0.0:2379                                     \
               --advertise-client-urls http://${IP3}:2379                                   \
               --initial-cluster-token etcd-test-1                                          \
               --initial-cluster infra0=http://${IP1}:2380,infra1=http://${IP2}:2380,infra2=http://${IP3}:2380               \
               --initial-cluster-state new
```

> --initial-cluster在随后的etcd运行中将忽略以命令行开头的命令行参数。在初始引导过程之后，随意删除环境变量或命令行标志。如果以后需要更改配置（例如，在集群中添加成员或从集群中删除成员），请参阅运行时配置指南。

#### member

* 初始启动节点数量最少 3 个
* 最少保留 3 个正常可用节点
* 节点数量最好单数，例如 3、5、7

```shell
[root@9191d2c194a7 /]# etcdctl member list
6d9bb9053d053fe8: name=infra1 peerURLs=http://10.9.17.201:2380 clientURLs=http://10.9.17.201:2379 isLeader=true
e93a78c1781ef4fa: name=infra2 peerURLs=http://10.9.17.202:2380 clientURLs=http://10.9.17.202:2379 isLeader=false
eedc0ad45df9a98e: name=infra3 peerURLs=http://10.9.17.203:2380 clientURLs=http://10.9.17.203:2379 isLeader=false
52a78ccf25a81b76: name=infra4 peerURLs=http://10.9.17.204:2380 clientURLs=http://10.9.17.204:2379 isLeader=false
```

移除节点，（该节点的 etcd 服务端将会停止）

```
[root@9191d2c194a7 /]# etcdctl member remove e93a78c1781ef4fa 
Removed member e93a78c1781ef4fa from cluster
```

添加节点，（该节点 data 文件需要先删除）

```
[root@9191d2c194a7 /]# etcdctl member add infra1 http://10.9.17.202:2380
Added member named infra1 with ID 760d2341423e83e4 to cluster

ETCD_NAME="infra2"
ETCD_INITIAL_CLUSTER="infra4=http://10.9.17.204:2380,infra1=http://10.9.17.201:2380,infra2=http://10.9.17.202:2380,infra3=http://10.9.17.203:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

```shell
添加上面的环境变量
IP="本机对外的IP"

/opt/etcd/etcd --name ${ETCD_NAME}                                            \
               --data-dir /opt/etcd/data                                      \
               --listen-client-urls http://0.0.0.0:2379                       \
               --advertise-client-urls http://${IP}:2379                      \
               --listen-peer-urls http://0.0.0.0:2380                         \
               --initial-advertise-peer-urls http://${IP}:2380                \ 
               --initial-cluster ${ETCD_INITIAL_CLUSTER}                      \
               --initial-cluster-state ${ETCD_INITIAL_CLUSTER_STATE}
```

#### Leader

移除了 Leader，集群会暂时没有 Leaer，无法工作，等待 Leader 选举成功，集群才能正常工作

选举流程

etcd Raft 使用心跳机制来触发 leader 选举。当服务器启动的时候，服务器成为 follower。只要 follower 从 leader 或者 candidate 收到有效的 RPCs 就会保持 follower 状态。如果 follower 在一段时间内（该段时间被称为 election timeout）没有收到消息，则它会假设当前没有可用的 leader，然后开启选举新leader的流程。流程如下：

1. follower 增加当前的 term，转变为 candidate
2. candidate 投票给自己，并发送 RequestVote RPC 给集群中的其他服务器
3. 收到 RequestVote 的服务器，在同一 term 中只会按照先到先得投票给至多一个 candidate。且只会投票给 log 至少和自身一样新的 candidate
4. candidate节点保持 2. 的状态，直到下面三种情况中的一种发生
   1. 该节点赢得选举。即收到大多数的节点的投票。则其转变为 leader 状态
   2. 另一个服务器成为了 leader。即收到了 leader 的合法心跳包（term 值等于或大于当前自身 term 值）。则其转变为 follower 状态
   3. 一段时间后依然没有胜者。该种情况下会开启新一轮的选举。 Raft 中使用随机选举超时时间来保证当票数相同无法确定 leader 的问题可以被快速的解决

> [Raft在etcd中的实现（三）选举流程](https://yuan1028.github.io/etcd-raft-3/)

---

### registrator 服务注册

此程序会将本机的服务注册到 etcd 分布式数据库中，其他组建则去 etcd 中取需要的数据

启动

```shell
-ip=${本机其他机器可以访问到的IP, 用于写入etcd，其他机器根据这个IP访问}
挂载的docker.sock，是为了使用docker的API，获取本地docker服务器的状态

docker pull gliderlabs/registrator:latest
docker rm -f registrator
docker run -d --name=registrator                         \
        -v /var/run/docker.sock:/tmp/docker.sock         \
        gliderlabs/registrator:latest                    \
                -ip=10.9.17.201                          \
                etcd://10.9.17.201:2379/registrator
```


