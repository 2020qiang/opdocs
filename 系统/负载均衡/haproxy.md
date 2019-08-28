### 调度器

`balance`：后端服务器组内的服务器调度算法（不能用在 frontend）

* **roundrobin**
  * 动态轮询算法，根据权重轮询，支持运行时调整权重，支持慢启动，受限于每个后端 4095 个活动服务器
  * 在一些大型集群，当服务器在很短的时间内关闭后，服务器上线时，有时可能需要几百个请求将其重新集成到服务器集群
* **static-rr**
  * 静态轮询算法，根据权重轮询，不支持运行时调整权重，不支持慢启动，后端主机数量无上限
  * 当服务器添加时，一旦重新计算完整，它总是立即重新引入到集群中。 它也使用略少的CPU运行（约-1％）
* **leastconn**
  * 根据权重循环在相同权重的服务集群中，支持运行时调整权重，支持慢启动
  * 类似 roundrobin，推荐使用在具有较长链接会话的场景中，例如 MySQL、LDAP 等
* **first**
  * 默认为自上而下进行调度，或最低 ID 至最高 ID，服务器达到其 maxconn 值，则使用下一台服务器，忽略了服务器权重
  * 目的是始终使用最小数量的服务器，以便在非密集型时间内关闭额外的服务器，且为长时间的会话带来了好处
    * 建议使用 http-check send-state 可以检查服务器上的连接健康状态
* **source**
  * 将源地址进行 hash 运算，指定一直连接某台服务器，权重总数发生变化（宕机/添加），可能会连接到此前不同的服务器
  * 常用于负载均衡无法使用 cookie 功能的基于 TCP 的协议；其默认为静态（static-rr），也可以使用 hash-type 修改
* uri
  * 对 URI 的左半部分（“?”标记之前的部分）或整个URI（如果“整数”参数存在）进行 hash 运算，由总权重相除后派发至服务器
  * 此算法常用于提高缓存的命中率，仅应用于 HTTP 后端服务器场景，默认为静态算法，也可以使用 hash-type 修改
  * 该算法支持两个可选参数，后跟一个正整数，当需要平衡仅基于 URI 开头的服务器时，这些选项可能会有所帮助
    * len：该算法考虑在 URI 多少个字符来计算 hash 值。注意，将 len 设置为 1 没意义，因为大多数 URI 以前 / 开头
    * depth：用于计算散列的最大目录深度。每个斜线为一个级别，如果指定了两个参数，当达到任一参数时，评估将停止
* url\_param
  * 在指定的 URL 中，在每个 HTTP GET 请求的字符串中查找，当使用 check\_post，GET 找不到时，将查找 POST 请求字符串
  * 此算法可以通过追踪请求中的用户标识，确保同一个用户的请求一直连接至特定的服务器，除非服务器的总权重发生了变化
    * 如果找到了指定的参数且为（name=value），此值 hash 运算并除以运行的服务器的总权重，再指定某台服务器请求
    * 如果（name=null）或（null），则使用轮询算法对相应请求进行调度，默认为静态的，也可以使用 hash-type 修改
* hdr\(&lt;name&gt;\)
  * 在每个 HTTP 请求中都会查找 HTTP 头 &lt;name&gt;（不区分大小写），并取出做 hash 运算，由总权重相除后连接至特定服务器
  * 其默认为静态（static-rr），也可以使用 hash-type 修改，如果不存在或者不包含任何值，则应用 roundrobin 算法
    * use\_domain\_only：参数可用于将 hash 算法减少到域部分，从而使用特定标题
    * 如，在主机值 wiki.liuq.org 中，仅考虑 liuq
* rdp-cookie / rdp-cookie\(&lt;name&gt;\)
  * 针对每个传入的 TCP 请求进行查找和 hash 运算，名称不区分大小写，它始终向相同的服务器发送相同的用户会话
  * 如果没有找到 cookie，则使用正常的 roundrobin 算法，默认为静态的，也可以使用 hash-type 修改


#### HTTP 健康检查

心跳语句超时时间，超过时间，分发器则断开连接，然后则恢复连接

`timeout check 600ms`

* option httpchk
* option httpchk &lt;uri&gt;
* option httpchk &lt;method&gt; &lt;uri&gt;
* option httpchk &lt;method&gt; &lt;uri&gt; &lt;version&gt;

可选的HTTP版本字符串，某些可能 HTTP 1.0 中会出现错误，将其转换为 HTTP/1.1 有时会有所帮助

注意：在 HTTP/1.1 中，主机字段是强制性的，作为一个技巧，可以在版本字符串后的  r n 之后传递它

* 示例：
  * ```
    # 将 HTTPS 流量中继到 Apache 实例并检查服务可用性
    # 在端口 80 上使用 HTTP 请求 OPTIONS * HTTP/1.1
    backend https_relay
        mode tcp
        option httpchk OPTIONS * HTTP/1.1\r\nHost:\ www
        server apache1 192.168.1.1:443 check port 80
    ```
* `http-check expect [!] <match> <pattern>`
  * 在 backend 只支持一个 http-check 。 如果服务器无法响应或超时，显然将失败
  * 全局 tune.chksize 选项定义的一定大小，默认为 16384 字节，非常大的响应会浪费些 CPU，特别是使用正则表达式时
  * `<match>`：是一个关键字，! 来否定匹配，感叹号和关键字之间允许有空格
    * `status <string>`：字符串与 HTTP 状态代码匹配
    * `rstatus <regex>`：正则表达式与 HTTP 状态代码匹配
    * `string <string>`：精确字符串在正文中的匹配
    * `rstring <regex>`：body 在 HTTP 响应上的正则表达式
  * `<pattern>`：可以是一个字符串或正则表达式，如果模式包含空格，则必须使用通常的反斜杠 `\` 进行转义

#### TCP 健康检查

* `option mysql-check [ user <username> [ post-41 ] ]`：**通过 MySQL 握手包或测试完整的客户端身份验证测试**

  * 仅仅支持 tcp 运行模式
  * 没有 user 选项：仅仅执行 MySQL 握手检查
  * 用户 &lt;username&gt; \(可选\):用于执行客户端身份验证检查这需要使用 MySQL 服务器中进行更新，如下所示：
  * ```
    USE mysql;
    INSERT INTO user (Host,User) values ('<ip_of_haproxy>','<username>');
    FLUSH PRIVILEGES;
    ```

* `option redis-check`：**redis运行状况检查进行服务器测试**

  * 等同于：

  * ```
    option tcp-check
    tcp-check send PING\r\n
    tcp-check expect +PONG
    ```

* 示例：

* ```
    # 只接受状态 200 为有效
    option httpchk GET /
    http-check expect status 200

    # 将 SQL 错误视为错误
    http-check expect ! string SQL\ Error

    # 考虑状态 5xx 仅作为错误
    http-check expect ! rstatus ^5

    # 检查我们在 /html 中是否有正确的十六进制标签
    http-check expect rstring <!--tag:[0-9a-f]*</html>
  ```
* `mode { tcp|http|health }`：设置运行的模式或协议
  * tcp：以纯 TCP 模式工作，将在客户端和服务器之间建立全双工连接，不执行第7层检查。这是默认模式。用于 SSL，SSH 等
  * http：该实例将在 HTTP 模式下工作，在连接到任何服务器之前，将深入分析客户端请求。任何不符合 RFC 的请求都将被拒绝，可以进行第7层过滤，处理和切换，这是HAProxy最具价值的模式。

```
# yum install -y haproxy
```

```
global
        daemon
#       log 127.0.0.1 local0                    # 全局 syslog 服务器，最多 2 台
        chroot /var/lib/haproxy
#       cpu-map all                             # 每一个进程绑定一个 cpu core，默认一个进程（在Linux 2.6及更高版本上）
        pidfile /var/run/haproxy.pid
        user haproxy
#       maxconnrate 4000                        # 每个 haproxy 进程可接受的最大并发连接数，默认 2000

defaults
#       log global
        mode http
#       option httplog                          # 启用HTTP请求记录，会话状态和计时器
#       option dontlognull                      # 启用日志记录的空连接
        option redispatch                       # 当serverId对应的服务器挂掉后，强制定向到其他健康的服务器
        timeout connect 10s
        timeout client 1m
        timeout server 1m
        option redispatch                       # 在连接失败的情况下，会话重新分配

frontend frontend
        bind 192.168.6.4:80
        stats enable
        stats uri /haproxy_status               # 启用统计信息，定义的 url
        stats auth root:passwd                  # 密码验证
        default_backend backend                 # 定义一个名为my_webserver后端部分

backend backend
        balance static-rr
        option httpchk GET /                   # 获取 URL / 数据
        http-check expect status 200 OK        # 接受 HTTP 状态 200 为有效
        server localhost01 192.168.6.4:8080 check port 8080 weight 6
        server localhost02 192.168.6.5:8080 check port 8080 weight 10
        server localhost03 192.168.6.6:8080 check port 8080 weight 10
```

推荐配置

```
global
    daemon
#   log         127.0.0.1 local0            # 全局 syslog 服务器，最多 2 台
    pidfile     /var/run/haproxy.pid
    user        haproxy
    maxconn     10000                       # 每个 haproxy 进程可接受的最大并发连接数，默认 2000
    maxconnrate 10000                       # 单haproxy进程每秒接受的连接数

defaults
#   log         global
#   option      httplog           # 启用HTTP请求记录，会话状态和计时器
#   option      dontlognull       # 启用日志记录的空连接
    mode        http
    option      http-server-close
    timeout     connect 5s
    timeout     client  10s
    timeout     server  10s

frontend frontend
    bind *:80

    # 敏感地址仅仅允许内部网络访问
    stats        enable
    stats uri    /haproxy_status
    acl localnet src  127.0.0.1 192.168.68.0/24
    acl locapat1 path_beg /haproxy_status
    acl locapat2 path /nginx_status /phpfpm_status /phpfpm_ping
    redirect location / if locapat1 !localnet
    redirect location / if locapat2 !localnet
    use_backend backendwebsite if locapat1 localnet
    use_backend backendwebsite if locapat2 localnet

    # 仅仅允许域名访问本站
    option forwardfor
    acl domain hdr_beg(host) -i newbc.015157.com newmain.015157.com newag.015157.com newadmin.015157.com
    use_backend backendwebsite if domain

backend backendwebsite
    balance source
#   option httpchk GET http://127.0.0.1/login?f=                        # 获取 URL / 数据
#   http-check expect status 200 OK                                     # 仅仅接受 HTTP 状态 200 为有效
    option httpchk GET http://127.0.0.1/phpfpm_ping                     # 获取 URL / 数据
    http-check expect string F98EA8FE223C713B
    server BACKUP_JF_201801_NGINX_1 192.168.68.21:80 check
    server BACKUP_JF_201801_NGINX_2 192.168.68.22:80 check
#   server BACKUP_JF_201801_NGINX_2 192.168.68.22:80 check backup
```

---

TCP 流量存活转发，适用于 memcached redis mysqld

```
global
        daemon
#       log 127.0.0.1 local0            # 全局 syslog 服务器，最多 2 台
#       chroot /var/lib/haproxy
#       cpu-map all                     # 每一个进程绑定一个 cpu core，默认一个进程（在Linux 2.6及更高版
        pidfile /var/run/haproxy.pid
        user haproxy
        maxconnrate 4000                # 每个 haproxy 进程可接受的最大并发连接数，默认 2000

defaults
#       log global
        mode tcp
#       option httplog          # 启用HTTP请求记录，会话状态和计时器
#       option dontlognull      # 启用日志记录的空连接
        option redispatch       # 在连接失败的情况下，会话重新分配
        timeout connect 10s
        timeout client 1m
        timeout server 1m

frontend frontend
        bind 192.168.68.13:6379
        default_backend backend # 定义一个名为my_webserver后端部分

backend backend
        balance static-rr
        server BACKUP_JF_201801_REDIS_1 192.168.68.41:6379 check
        server BACKUP_JF_201801_REDIS_2 192.168.68.42:6379 check
```

查看 WEB 统计信息

* [http://192.168.6.4/haproxy](http://192.168.6.4/haproxy)
* username: root
* password: passwd

> [HAproxy\_v1.5 官网文档](http://cbonte.github.io/haproxy-dconv/1.5/configuration.html)  
> [https://linux.cn/article-4765-2.html](https://linux.cn/article-4765-2.html)  
> [http://7424593.blog.51cto.com/7414593/1764640](http://7424593.blog.51cto.com/7414593/1764640)  
> [http://liaoph.com/haproxy-tutorial/](http://liaoph.com/haproxy-tutorial/)  
> [http://maxiecloud.com/2017/07/01/haproxy/](http://maxiecloud.com/2017/07/01/haproxy/)  
> [https://serverfault.com/questions/757662/haproxy-check-does-not-check-content-on-iis](https://serverfault.com/questions/757662/haproxy-check-does-not-check-content-on-iis)


