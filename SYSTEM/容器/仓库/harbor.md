# harbor

<https://goharbor.io/docs/>

提供丰富的容器镜像管理功能，通过web ui，可以方便地管理项目，成员和镜像的访问权限



## 要求

*   Docker, 17.06.0-ce +或更高版本
*   Compose, 1.18.0或更高版本
*   Docker客户端, 1.6.0或更高版本（可以使用centos epel 源的稳定版本）



## 安装

目标主机需要docker，并且要安装docker compose

```shell
# docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker

# compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

```shell
# harbor
wget -c $(https://github.com/goharbor/harbor/releases)
tar -xvf harbor-offline-installer-v1.8.1.tgz
cd harbor/

# https
sudo mkdir -vp /opt/harbor/{keys,data}
cd /opt/harbor/keys
sudo openssl genrsa -out "./null.key" 1024
sudo openssl req -x509 -days 7300 -new -key "./null.key" -out "./null.cert" -subj '/CN=null'

# config
#  1. 使用域名 
#  1. 安装数据目录 = /opt/harbor/data
#  2. https路径   = /opt/harbor/keys/*
vi harbor.yml
$(https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md)

# install
#   with-clair
#     集成漏洞扫描
#   with-notary
#     目的是为了增加开发者对于所使用镜像的安全性，保证所使用的镜像与当初内容提供者是相同
#     用于发布和管理受信任内容的集合工具，发布者签名，消费者验证内容的完整性和发布者
sudo ./install.sh --with-clair
```



## 使用

浏览器打开 <https://domain>

默认用户名密码 admin/Harbor12345

```shell
# login
$ sudo docker login docker.domain.com
Username: admin
Password: 
Login Succeeded

$ sudo docker run hello-world
#$ sudo docker tag hello-world docker.domain.com/test/hello-world:latest
$ sudo docker tag hello-world $(domain)/$(project)/$(image):latest
$ sudo docker push docker.domain.com/test/hello-world
```



## 机器人帐户

是由项目管理员创建的帐户，用于自动化操作

1.  机器人账户无法登录港口门户
2.  机器人账户只能使用令牌执行`docker push`/ `docker pull`操作
3.  可以配置有效期限制



## 注意

*   不要想着本机harbor监听其他 web 127.0.0.1端口，前面加反向代理，会变成下面这样
  *   ```shell
    [centos@test ~]$ sudo docker login docker.domain.com
    Username: admin
    Password: 
    Error response from daemon: Get https://docker.domain.com/v2/: Get http://docker.domain.com:127.0.0.1:8080/service/token?account=admin&client_id=docker&offline_token=true&service=harbor-registry: invalid URL port "127.0.0.1:8080"
    ```

*   需要https，第一次安装就要准备好证书

*   第一次安装Harbor后，mysql的数据会存储在/data/database文件夹下。如果你想修改mysql root密码的话（不管你有没有重装），都要先把/data/database删掉，否则UI容器会一直报“Access denied”的错误，即便是重下镜像也无法解决

*   禁止注册：登陆后，`系统管理 -> 配置管理 -> 认证模式 -> 允许自注册(取消)`

*   http post body 大小：如果有多个nginx反向代理，最好更改 client_max_body_size 0; 为不限制，否则报错 413

*   如果要复制Docker Hub的官方映像，则必须添加`library/hello-world`匹配官方的hello-world镜像，并复制到本`library`项目中

    *   ```
        系统管理 -> 同步管理 -> 新建规则 -> 源资源过滤器 -> 名称
        ```



## 管理

1.  `harbor-offline-installer-v1.8.2.tgz` 解压出来的目录及文件一个都不要删除
    1.  `docker-compose.yml` 需要使用环境变量文件及容器配置文件
2.  容器里面使用是 `127.0.0.11` 内置dns（`docker-compose.yml`）
    1.  域名为 `services:[@]`，解析IP是解析到指定 `services`，容器内部使用 `services` 连接就好



## notary

服务端启用

```
项目 -> $(project) -> 配置管理 -> 部署安全 -> 内容信任 -> enable
```

客户端启用

```shell
# user = root

# 创建一个委托密钥对。这些密钥可以使本地生成
docker trust key generate key_name

export DOCKER_CONTENT_TRUST="1"
export DOCKER_CONTENT_TRUST_SERVER="https://$(key_server):443"
docker push $(domain)/$(project)/$(image):latest
```

### 注意

*  签名的镜像无法轻易删除

    *  只能删除整个镜像，多个tag会同时删除

    *  必须签名者使用私钥移除镜像签名，再在 web ui 删除项目

    *  ```shell
        # 使用 notary cli 删除镜像的签名
        wget -c $(https://github.com/theupdateframework/notary/releases)
        alias notary="./notary -s https://$(key_server):443 -d ~/.docker/trust"
        notary remove $(domain)/$(project)/$(image) $(tag) -p
        # 接着数据管理员帐号密码
        ```


