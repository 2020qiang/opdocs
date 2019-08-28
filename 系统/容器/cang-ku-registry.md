##### 一、获得 registry 镜像

```
docker pull registry
```

##### 二、绑定域名、申请证书

绑定域名是为了 https 证书

感觉没必要申请证书

1. 因为如果默认操作系统不识别此证书（浏览器默认识别没用），则需要导入证书进系统
2. 而且 docker 仓库也不对外公开（开放至公网）

自签名证书：

```
sudo mkdir -p /opt/docker/keys
sudo openssl genrsa -out /opt/docker/keys/server.pem 4096
sudo openssl req -x509 -days 7300 -new -key /opt/docker/keys/server.pem -out /opt/docker/keys/server.crt -subj "/CN=docker.test.com/emailAddress=test@test"
sudo chmod 0555 /opt/docker/keys
sudo chmod 0444 /opt/docker/keys/*
```

##### 三、启动容器

对外开放端口、映射影像存放目录、映射证书

```
sudo mkdir /opt/docker/registry
sudo chmod 0700 /opt/docker/registry
docker run -d                                                   \
    -p 443:5000                                                 \
    --restart=always                                            \
    --name registry                                             \
    -v /opt/docker/keys:/keys                                   \
    -v /opt/docker/registry:/var/lib/registry/docker/registry   \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/keys/server.crt           \
    -e REGISTRY_HTTP_TLS_KEY=/keys/server.pem                   \
    registry
```

##### 四、检查服务

OS 导入自签名证书

```
cat /opt/docker/keys/server.crt >>/etc/pki/tls/certs/ca-bundle.crt
```

重启 docker 使它重载证书

```
sudo systemctl restart docker
```

##### 五、镜像信息

镜像列表

```
curl https://docker.test.com:443/v2/_catalog
```

镜像标签

```
curl https://docker.test.com:443/v2/image_name/tags/list
```

镜像 tag

```
curl https://docker.test.com:443/v2/nginx/tags/list
```

##### 六、上传镜像

必须首先更改 docker 镜像的 tag 才能上传

更改 tag，如：

```
shell> docker images
centos                   6                   70b5d81549ec        7 weeks ago         195MB

shell> docker tag centos:6 docker.test.com/centos:6

shell> docker images
docker.test.com/centos   6                   70b5d81549ec        7 weeks ago         195MB
```

上传，如：

```
shell> docker push docker.test.com/centos:6
The push refers to repository [docker.test.com/centos]
b797c4072d31: Layer already exists 
9a476fb89d63: Layer already exists 
22ed2d41a891: Layer already exists 
effe6b6a4b00: Layer already exists 
6ab69988f083: Layer already exists 
e0dec291ae94: Layer already exists 
0.5: digest: sha256:59c873f3536a7a6728064baaec3bd2032b9da16043a7bd26fe6943bb9aef805f size: 1574
```

##### 六、下载

```
docker push docker.test.com/centos:6
```



