## GlusterFS

是一个大尺度分布式文件系统，它是各种不同的存储服务器之上的组合

*   分布式算法 <https://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/>

*   命令列表 <https://docs.gluster.org/en/latest/CLI-Reference/cli-main/>





## 安装

*   官方源 <https://wiki.centos.org/SpecialInterestGroup/Storage/gluster-Quickstart>

```shell
   sudo yum install centos-release-gluster \
&& sudo yum install glusterfs-server glusterfs glusterfs-fuse \
&& sudo systemctl enable glusterd glusterfsd \
&& sudo systemctl start  glusterd glusterfsd
```





## 配置

```shell
# [server]
mkdir /opt/www-image
gluster peer probe 192.168.69.51
gluster peer probe 192.168.69.23
gluster peer probe 192.168.69.24
#gluster peer status
#gluster peer detach

gluster volume create www-images replica 3 192.168.69.51:/opt/www-image 192.168.69.23:/opt/www-image 192.168.69.24:/opt/www-image force
#gluster volume delete www-images
gluster volume start www-images
gluster volume info

# [client]
mount -t glusterfs 192.168.69.51:www-image /opt/www/Uploads
```

自动挂载

```shell
# [client]
vi /etc/fstab
#192.168.69.51:www-image /opt/www/Uploads  glusterfs  defaults 0 0
mount -a
```





## 故障处理

*   删除所有GlusterFS相关的卷和主机，但是这些主机是离线状态

第一步：在卷中移除指定的主机

创建时

```
gluster volume create       www-images replica 2 192.168.69.51:/opt/www-image 192.168.69.24:/opt/www-image force
```

现在移除 192.168.69.51

```
gluster volume remove-brick www-images replica 1                              192.168.69.24:/opt/www-image force
```

第二步：移除池中的主机

```
rm -vrf /var/lib/glusterd/peers/*
systemctl  stop  glusterd glusterfsd
systemctl  start glusterd glusterfsd
systemctl status glusterd glusterfsd
```

第三步：移除卷

```
gluster volume delete www-images
```

