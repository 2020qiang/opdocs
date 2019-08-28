#### 安装

官网：[https://docs.docker.com/install/linux/docker-ce/centos](https://docs.docker.com/install/linux/docker-ce/centos)

```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker

sudo yum install -y python2-pip
sudo pip install --upgrade pip
sudo pip install docker-compose
```


