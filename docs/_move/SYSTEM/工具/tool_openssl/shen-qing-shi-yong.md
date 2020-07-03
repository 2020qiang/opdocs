官网：[https://www.sslforfree.com](https://www.sslforfree.com)

直接输入域名，直接校验域名 txt 记录方便很多，而且证书是 Let's Encrypt 的

将会有三个文件：

* Certificate  -- 证书
* Private Key  -- 密钥
* CA Bundle    -- CA 证书

通常浏览器内建 CA 能识别出此证书，操作系统中默认没有，需要导入 CA 证书

linux 导入方式：

```
cat ca_bundle.crt >>/etc/pki/tls/certs/ca-bundle.crt
```



