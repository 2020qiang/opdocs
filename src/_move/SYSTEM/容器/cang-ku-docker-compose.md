安装

```
sudo pip install --upgrade pip
sudo pip install docker-compose
```

打开官网：[https://github.com/vmware/harbor/releases\#download](https://github.com/vmware/harbor/releases#download)

```
wget -c https://storage.googleapis.com/harbor-releases/release-1.5.0/harbor-online-installer-v1.5.0.tgz
tar -xvf harbor-online-installer-v1.5.0.tgz
```

安装

```
cd harbor

修改 harbor.cfg
hostname        = 更改为远程连接的地址和端口
secretkey_path  = 密钥和证书存在的目录
ssl_cert        = 证书的绝对路径
ssl_cert_key    = 密钥的绝对路径

sudo ./install.sh
```



