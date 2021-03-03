# HTTPS 证书免费申请



## Let’s Encrypt 多域名证书申请过程记录

Certbot作为Let’s Encrypt项目的一个官方客户端，可以完全自动化的获取、部署和更新证书



### 安装客户端

```shell
wget https://dl.eff.org/certbot-auto
chmod u+x certbot-auto
rm -vrf /etc/letsencrypt /var/log/letsencrypt
mv certbot-auto /usr/bin
```



### 申请证书

下面的方式 二选一



一、使用 http 请求验证，获取域名FQDN证书

```nginx
# 需要更改相应的记录到本机公网ip，nginx 开启 http 80 端口并做如下配置
server {
...
    location /.well-known/acme-challenge/ {
        default_type "text/plain";
        root /var/www/example;
    }
...
}
```

```shell
certbot certonly --webroot --email main@gmail.com -w /opt/www -d example.com -d www.example.com
```



二、使用 txt 解析验证，获取泛解析证书：

```shell
certbot certonly --manual --email main@gmail.com -d *.example.com -d example.com --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```

根据提示解析相应的 txt 记录，最好将ttl值设置为最少，然后等待几秒再回车

```
Please deploy a DNS TXT record under the name
_acme-challenge.example.com with the following value:

f5c0AHj2LYBzD9gC9GfDhxkSVMQP_xwWRNBZ0KO7QVE

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.example.com with the following value:

NdQXk_lyLaewc0lMjIZpsUMzQhxzwueGKPKixVNFMT0

Before continuing, verify the record is deployed.
```



### 成功

在成功获取证书之后会有类似下面的输出内容：

```
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem  [ 公钥 ]
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem    [ 私钥 ]
   Your cert will expire on 2018-12-15. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot-auto
   again. To non-interactively renew all of your certificates, run
   "certbot-auto renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```



### 续期

证书的有效期是3个月，可以在证书过期前的30天内，进行续期  

```shell
certbot renew
```

