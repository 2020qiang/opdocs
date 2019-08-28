##### 镜像操作

```docker
# 获取
docker pull centos
docker pull centos:6

# 上传
docker push docker.test.com/centos
docker push docker.test.com/centos:6

# 删除
docker rmi $id
docker image rm $id

# 强制删除
docker rmi -f $id
docker image rm -f $id
```

---

##### 容器操作

```docker
# 特权启动容器
docker run --privileged

# 查看运行的容器
docker ps

# 查看所有容器，包括停止
docker ps -a

# 进入容器
docker exec -it $id bash

# 启动容器
docker start $id

# 停止容器
docker stop $id

# 删除容器
docker rm $id

# 强制删除容器
docker rm -f $id

# 将容器改为镜像
docker commit $id test:v0.1
```

---

```docker
# 交互式进入容器，为了测试，退出容器将会自动删除
docker run --net=host -it --rm centos:6 bash

# 在后台运行容器
docker run -d nginx:v0.1
```


