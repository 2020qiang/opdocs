### 获取用户IP

```php
<?php
/* 获取客户端IP */
function getIP() {
    if (@$_SERVER["HTTP_X_FORWARDED_FOR"])$ip = $_SERVER["HTTP_X_FORWARDED_FOR"];
    else if (@$_SERVER["HTTP_CLIENT_IP"]) $ip = $_SERVER["HTTP_CLIENT_IP"];
    else if (@$_SERVER["REMOTE_ADDR"]) $ip = $_SERVER["REMOTE_ADDR"];
    else if (@getenv("HTTP_X_FORWARDED_FOR")) $ip = getenv("HTTP_X_FORWARDED_FOR");
    else if (@getenv("HTTP_CLIENT_IP")) $ip = getenv("HTTP_CLIENT_IP");
    else if (@getenv("REMOTE_ADDR")) $ip = getenv("REMOTE_ADDR");
    else $ip = "Unknown";
    return $ip;
}
$ip = getIP();
echo $ip;
?>
```



### 检查模块的函数是否存在

```shell
php -r "var_dump(function_exists('imagecreatefromjpeg'));"
```

