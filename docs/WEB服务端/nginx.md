



## 官方文档链接

* 内部变量 <https://nginx.org/en/docs/varindex.html>
* location <https://nginx.org/en/docs/http/ngx_http_core_module.html#location>
* 限速 <https://nginx.org/en/docs/http/ngx_http_limit_req_module.html>
* if 条件判断 <https://nginx.org/en/docs/http/ngx_http_rewrite_module.html#if>
* HSTS <https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security>





---





## 配置项





#### location 路由规则

根据请求URI配置 [转到](#官方文档链接)

```
Syntax:	location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }
Default:	—
Context:	server, location
```

```
=   精确匹配
^~  如果该符号后面的字符是最佳匹配，采用该规则，不再进行后续的查找
~   正则表达式，区分大小写
~*  正则表达式，不区分大小写
/   普通匹配
```

优先级

1. 精确匹配 `=`
2. 前缀匹配 `^~`（立刻停止后续的正则搜索）
3. 按文件中顺序的正则匹配 `~`或`~*`
4. 匹配不带任何修饰的前缀匹配





#### if 条件判断

匹配条件 [转到](#官方文档链接)

```
=  和 !=   比较变量 和 字符串
~  和 ~*   区分大小写匹配正则表达式 和 不区分大小写匹配正则表达式
!~ 和 !~*  反向匹配正则表达式（是否区分大小）
-f 和 !-f  检查文件是否存在
-d 和 !-d  检查目录是否存在
-e 和 !-e  检查文件，目录或符号链接的存在性
-x 和 !-x  运算符检查可执行文件
```

```nginx
server {
    listen 127.0.0.1:8080;
    location / {
        if ( $http_user_agent ~ MSIE) {
            return 404;
        }
    }
}
```





#### return 响应字符串

```nginx
server {
    listen 127.0.0.1:8080;
    location / {
        default_type text/html;
        return 500 "blocked\n";
    }
}
```





#### limit_req 限速

对于用一个客户端IP，平均每秒最多允许不超过40个请求，并且突发不超过60个请求 [转到](#官方文档链接)

```nginx
server {
    listen 127.0.0.1:8080;
    location / {
        limit_req_zone $binary_remote_addr zone=addr:10m rate=40r/s;
        limit_req zone=addr burst=60 nodelay;
    }
}
```

*   `limit_req_zone`
    1.  `$binary_remote_addr` 以客户端ip作为键值来进行限制
    2.  `zone=addr:10m` 生成一个大小为10M，名字为addr的存储区域，用来存储访问频率
    3.  `rate=5r/s` 限定客户端的访问频率为每秒5次
*   `limit_req`
    1.  `zone=addr` 使用存储区域addr来限制
    2.  `burst=50` 突发不允许超过60个请求
    3.  `nodelay` 超过的请求立即返回503





#### iptables 限流

每个客户端IP最大并发连接数为400

```shell
iptables -t filter -A INPUT -p tcp -m tcp -m multiport --dports 80,443 -m connlimit --connlimit-above 400 -j DROP
```







#### hsts 强制https

在一段时间内（下面配置一年），客户端强制默认使用https请求，http会407到https [转到](#官方文档链接)

```nginx
server {
    listen 127.0.0.1:8080;
    location / {
      add_header strict-transport-security "max-age=31536000; includeSubDomains; preload" always;
    }
}
```





#### allow 限制客户端IP网段

```nginx
server {
    listen 80;
    allow 192.168.0.0/16;
    allow 10.0.0.0/8;
    allow 127.0.0.1;
    deny all;
}
```





#### mobile 手机端子root

PC端使用一套前端，手机端使用另一套前端

```nginx
server {
    listen 80;
    root   /opt/www/html/pc;
    index  index.html;
    location / {
        if ($http_user_agent ~* "(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino") {
            root /opt/www/html/mobile;
        }
    }
}
```





#### server 反向代理到后端接口

前后端分离，后端接口的标准化

* 客户端发起请求`POST https://liuq.org/server/data?v=123`
  * nginx收到`POST /server/data?v=123`
* 反向代理到后端的是`POST /data?v=123`
  * 后端收到`POST /data?v=123`

```nginx
server {
    listen 80;
    server_name liuq.org;
    location ~ /server/(.*) {
        proxy_read_timeout 24h;
        proxy_send_timeout 24h;
        client_max_body_size 0;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080/$1?$query_string;
    }
}
```





#### 403 禁止特定接口

使用的是正则，不区分大小写

```nginx
server {
    listen 80;
    location ~* "^/server/code.+" { return 403; }
    location ~* "^/server/data"   { return 403; }
}
```





#### log 日志文件

1. 添加`$host`，请求的域名，记录日志
2. 添加`$request_body`，`POST`的内容记录到日志
3. 添加`buffer/flush`，写入日志文件的缓存

```nginx
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$host $request $request_body" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main buffer=32k flush=5s;
}
```





#### status 状态监控

```nginx
server {
    listen     127.0.0.1:81;
    access_log off;
    location = /nginx-status {
        stub_status on;
    }
    location = /phpfpm-status {
        include       fastcgi_params;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $fastcgi_script_name;
    }
}
```





#### redirect 强制重定向到https

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```





#### timeout 客户端/服务端

```nginx
http {
    client_header_timeout   4000s;
    client_body_timeout     4000s;
    keepalive_timeout       4000s;
    proxy_connect_timeout   4000s;
    proxy_read_timeout      4000s;
    proxy_send_timeout      4000s;
    fastcgi_connect_timeout 4000s;
    fastcgi_read_timeout    4000s;
    fastcgi_send_timeout    4000s;
}
```





#### x-forwarded-for 获取客户端IP

在有CDN的情况下，CDN默认会通过`x-forwarded-for`请求头转发客户端的IP到源

源只需要使用`set_real_ip_from`指定CDN的节点，就可获取客户端的IP

```nginx
http {
    set_real_ip_from 192.168.0.0/16;
    set_real_ip_from 10.0.0.0/8;
    set_real_ip_from 127.0.0.1;
    real_ip_header    X-Forwarded-For;
    real_ip_recursive on;
}
```





#### proxy 反向代理

1. 长超时表示超时由后端控制
2. 不限制请求体大小，表示由后端控制
3. 允许后端使用SNI多域名证书
4. 使用特定的主机名发起请求，一般设置`$host`
5. 通过`x-forwarded-for`转发客户端IP
6. 后端地址

```nginx
server {
    listen 80;
    location ~* "^/server/api1$" {
        proxy_read_timeout 24h;
        proxy_send_timeout 24h;
        client_max_body_size 0;
        proxy_ssl_server_name on;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass https://liuq.org:443;
    }
}
```





#### ssl_certificate 使用https

```shell
# 可选创建自签名证书
key="/opt/keys/null.key"
crt="/opt/keys/null.crt"
openssl genrsa -out ${key} 1024
openssl req -x509 -days 7300 -new -key ${key} -out ${crt} -subj '/CN=null'
```

```nginx
http {
    ssl_certificate     /opt/keys/null.crt;
    ssl_certificate_key /opt/keys/null.key;
}
```

```nginx
server {
    ssl_certificate     /opt/keys/null.crt;
    ssl_certificate_key /opt/keys/null.key;
}
```





#### header 自定义请求头获取

客户端请求

```shell
curl -s -v -o /dev/null http://127.0.0.1 -H 'x-data-test1: value'
```

服务端接收并记录到日志

```nginx
http {
    log_format  main  '$http_x_data_test1';
}
```





#### add_header 浏览器不缓存html

```nginx
location / {
    if ($request_filename ~* ".+\.html$") {
        add_header cache-control 'no-cache, no-store, must-revalidate';
    }
}
```





---





## 项目用的配置

1. 只允许执行指定php文件，防止被上传恶意代码执行（当然php解释器，不能有写项目代码文件的权限）
2. 真的404的话显示404，不会显示php的Not Found
3. 只公开少量的后端接口（前端全开放无所谓）

```nginx
###
### 允许本地所有路由
###
server {
    listen 127.0.0.1:8080;
    root   /opt/www/public;
    index  index.php;

    location / {
        if (!-e $request_filename) {
            rewrite ^(.*)$ /index.php?s=$1 last;
            break;
        }
    }
    location ~* \.php$ {
        if ($request_filename != "/opt/www/public/index.php") {
            return 403;
        }
        try_files $uri =404;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include       fastcgi_params;
    }
}

###
### 公开
###
server {
    listen 80;
    root   /opt/www/public;
    index  index.html;

    server_name liuq.org;
    server_name docs.liuq.org;

    location = / {
        proxy_read_timeout 24h;
        proxy_send_timeout 24h;
        client_max_body_size 0;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080;
    }
    location ~* "^/server/api1$" {
        proxy_read_timeout 24h;
        proxy_send_timeout 24h;
        client_max_body_size 0;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080;
    }
    location ~* "^/server/api2$" {
        proxy_read_timeout 24h;
        proxy_send_timeout 24h;
        client_max_body_size 0;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080;
    }
    location ~* "\.php$" { return 403; }
}
```





#### 自定义代理

1. 客户端发送自定义请求头`x-data-protocol,x-data-host`，表示代理的后端地址

```nginx
    server {
        listen 443 ssl default_server;

        ssl_certificate     /opt/keys/null.crt;
        ssl_certificate_key /opt/keys/null.key;

        location / {
            resolver 8.8.8.8 8.8.4.4;
            proxy_read_timeout 24h;
            proxy_send_timeout 24h;
            client_max_body_size 0;
            proxy_ssl_server_name on;
            proxy_set_header X-Data-Protocol "";
            proxy_set_header X-Data-Host "";
            proxy_set_header Host $http_x_data_host;
            proxy_pass $http_x_data_protocol://$http_x_data_host;
        }
    }

```

