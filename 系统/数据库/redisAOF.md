数据持久化比较

* **RDB**：\(默认开启\) 以指定的时间间隔执行数据集的快照
  * 优点：完美的备份解决方案
  * 缺点：故障发生后，在两个时间间隔中的某些数据会丢失
* **AOF**：记录服务器接收的每个写入操作
  * 优点：准实时持久化，最大可能减少数据丢失的风险
  * 缺点：占用空间较大，恢复速度较慢

#### 开启 AOF

添加关键配置

```
1: appendonly                  yes
2: appendfilename              redis.aof
3: appendfsync                 everysec
4: auto-AOF-rewrite-percentage 100
5: auto-AOF-rewrite-min-size   64mb
6: aof-load-truncated          yes
```

1. 开启 AOF
2. 备份文件名 \(redis.conf 中的 dir 配置指定\)
3. 同步选择方式：
   1. **always**：每个事件循环都要将 aof\_buf 缓冲区所有内容同步到 AOF 文件
      1. 优点：最安全，即使出现故障停机， AOF 持久化也只会丢失一个事件循环中的数据
      2. 缺点：效率慢，由于每次都会调用 fsync，所以其性能也会受到影响
   2. **everysec**：每隔超过 1s 就要在子线程中对 AOF 文件进行一次同步
      1. 优点：较安全，即使出现故障停机， AOF 持久化也只会丢失 1s 前的数据
      2. 缺点：在最坏的情况下，2s 会进行一次 fsync 操作（调用时长超过1s，会采取延迟的策略，再等 1s）
   3. **no**：每个事件循环都要将 aof\_buf 缓冲区中的所有内容写入到 OS 缓冲区
      1. 优点：效率高，仅仅同步至 OS 缓冲区，由 OS 决定何时同步至 AOF 文件
      2. 缺点：安全差，在系统缓存中积累一段时间的数据才同步至 AOF 文件，默认 30s，异常关机重启会丢失缓冲区数据
4. AOF 文件大小超过上一次重写时的大小的百分之几
   1. 刚启动 redis 时，此策略有严重缺陷的，例如：
      1. 文件的尺寸可以由 1K 变为 2K，1M 变为 2M，但是没有必要重写，所以需要引入另一个参数作为补充
5. 限制允许重写最小 AOF 文件大小，避免多次重复写入
6. AOF 持久化文件同步过程中断电宕机，导致文件损坏，这里 yes 表示继续回复，并写入日志

##### 测试

```
[TEST].~ > redis-cli 
127.0.0.1:6379> set fg 212
OK
127.0.0.1:6379> get fg 
"212"
[TEST].~ > sudo service redis restart
Stopping redis-server:                                     [  OK  ]
Starting redis-server:                                     [  OK  ]
[TEST].~ > redis-cli 
127.0.0.1:6379> get fg
"212"
```

> [http://blog.qiusuo.im/blog/2015/02/05/why-not-use-redis-as-db/](http://blog.qiusuo.im/blog/2015/02/05/why-not-use-redis-as-db/)  
> [https://redis.io/topics/persistence](https://redis.io/topics/persistence)  
> [http://redisbook.com/preview/aof/aof\_implement.html](http://redisbook.com/preview/aof/aof_implement.html)



