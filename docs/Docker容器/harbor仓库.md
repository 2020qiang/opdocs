# harbor

<https://goharbor.io/docs/>

提供丰富的容器镜像管理功能，通过web ui，可以方便地管理项目，成员和镜像的访问权限



## 要求

*   Docker, 17.06.0-ce +或更高版本
*   Compose, 1.18.0或更高版本
*   Docker客户端, 1.6.0或更高版本（可以使用centos epel 源的稳定版本）



## 安装

* 需要先 `docker v17.06.0-ce+` 和 `docker-compose v1.18.0+`

```shell
# docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker

# docker-compose
curl -sSL "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o "/usr/local/bin/docker-compose"
chmod +x "/usr/local/bin/docker-compose"
ln -s "/usr/local/bin/docker-compose" "/usr/bin/docker-compose"
```

* 安装 harbor
  1. 转到 <https://github.com/goharbor/harbor/releases> 下载安装包
  2. 在服务器上新建个目录 `${HOME}/.harbor`，<span style="color:red;">这个目录不能删</span>，原因
     1. 容器是有挂载上面下的包的配置文件
     2. `docker-compose` 也会在这里自动新建（执行 `install.sh` 后）
  3. 将下载的包拷贝解压到 `${HOME}/.harbor` 目录中（<span style="color:red;">这个目录不能删除，下载包最好也保留</span>）
  4. 按照 `harbor.yml.tmpl` 复制一份名为 `harbor.yml`，再修改 `harbor.yml` 这个配置文件
  5. 最后再执行 `./install.sh` 安装完毕了
* 启动/停止 harbor
  * 启动停止需要使用 `docker-compose`
  * 使用方法是在 `${HOME}/.harbor` 这个目录或子目录里找到 `docker-compose.yml`
  * `cd` 切换到 `docker-compose.yml` 文件的目录中
  * 再运行 `docker-compose start` 或 `docker-compose stop` 就行
  * 会按照启停顺序执行

```yaml
# harbor.yml 我个人测试机可以拿来参考

hostname: docker.example.com         # 域名，用于后台复制容器地址时拼接的
http:
  port: 8081                         # 因为会使用http代理，这样方便点
harbor_admin_password: Harbor12345   # 默认浏览器登陆admin用户的密码
database:
  password: root123
  max_idle_conns: 50
  max_open_conns: 10
data_volume: /data/.docker/harbor    # 数据卷挂载
jobservice:
  max_job_workers: 2
notification:
  webhook_job_max_retry: 10
log:
  level: warning
  local:
    rotate_count: 5
    rotate_size: 200M
    location: /var/log/harbor
_version: 2.2.0  # 这个不能改，也不能删除，只能按下载文件解压出的模板
```





## 小优化

因为默认安装后的容器名字，有些带 `harbor-` 前缀，有些没带这个前缀

例如

```
nginx
registry
redis
registryctl
harbor-jobservice
harbor-core
harbor-portal
harbor-db
harbor-log
```

更改需要先用 `docker-compose stop` 停止服务

再 `docker rename` 修改容器名，

最后修改 `docker-compose.yml`，

再 `docker-compose start` 启动就好了



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


