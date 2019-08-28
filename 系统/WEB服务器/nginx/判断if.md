[http://nginx.org/en/docs/http/ngx\_http\_rewrite\_module.html\#if](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#if)

---

在 location 区块里 if 指令下唯一 100% 安全的指令应该只有

> return …; rewrite … last

#### 匹配条件

```
=  和 !=   比较变量 和 字符串
~  和 ~*   区分大小写匹配正则表达式 和 不区分大小写匹配正则表达式
!~ 和 !~*  反向匹配正则表达式（是否区分大小）
-f 和 !-f  检查文件是否存在
-d 和 !-d  检查目录是否存在
-e 和 !-e  检查文件，目录或符号链接的存在性
-x 和 !-x  运算符检查可执行文件
```

例如：

```
if ( $http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /msie/$1 break;
}

if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
    set $id $1;
}

if ($request_method = POST) {
    return 405;
}

if ($slow) {
    limit_rate 10k;
}

if ($invalid_referer) {
    return 403;
}
```



