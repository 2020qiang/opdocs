## 安装

*   官网 <https://docs.docker.com/install/linux/docker-ce/centos>

```shell
# docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker

# docker-compose
sudo yum install -y python2-pip
sudo pip install --upgrade pip
sudo pip install docker-compose
```





## docker-compose

1.  用于定义和运行多容器 Docker 应用程序的工具
2.  可以使用 YML 文件来配置应用程序需要的所有服务
3.  使用一个命令，就可以从 YML 文件配置中创建并启动所有服务






## 常用命令

镜像操作

```
获取镜像  docker pull centos:7
上传镜像  docker push docker.test.com/centos:7
删除镜像  docker rmi ${id}
```

容器操作

```docker
 特权模式  docker run --privileged
 查看容器  docker ps -a
 进入容器  docker exec -it ${id} bash
 启动容器  docker start ${id}
 停止容器  docker stop ${id}
 删除容器  docker rm ${id}
镜像化容器  docker commit $id test:v0.1
```

示例

```docker
# 交互式进入容器，为了测试，退出容器将会自动删除
docker run --net=host -it --rm centos:6 bash

# 在后台运行容器
docker run -d nginx:v0.1
```





## 构建

```shell
sudo docker pull centos:6
sudo docker build -t test:v0.1
```

Dockerfile

```dockerfile
FROM centos:6

# 时区
RUN    cp -f /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime  \
    && echo 'ZONE="Asia/Hong_Kong"' >/etc/sysconfig/clock

# 更新
RUN    yum install -y epel-release yum-utils   \
    && yum makecache                           \
    && yum update -y                           \
    && yum upgrade -y

# 安装
RUN    yum install -y nginx php-fpm    \
    && yum clean all

# 配置
RUN    echo \
    && echo '/etc/init.d/nginx    start'               >/start.sh \
    && echo '/etc/init.d/php-fpm  start'              >>/start.sh \
    && echo 'tail -f /dev/null'                       >>/start.sh

# 运行
CMD    ["/bin/bash", "/start.sh"]
```

