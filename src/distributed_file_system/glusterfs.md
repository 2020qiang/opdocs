## GlusterFS

是一个大尺度分布式文件系统，它是各种不同的存储服务器之上的组合

分布式算法 <https://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/>

命令列表 <https://docs.gluster.org/en/latest/CLI-Reference/cli-main/>



### 安装

<https://wiki.centos.org/SpecialInterestGroup/Storage/gluster-Quickstart>

```shell
   sudo yum install centos-release-gluster \
&& sudo yum install glusterfs-server glusterfs glusterfs-fuse \
&& sudo systemctl enable glusterd glusterfsd \
&& sudo systemctl start glusterd glusterfsd
```



环境

```
# [server]
CentOS7 192.168.100.126/24
CentOS7 192.168.100.125/24

# [client]
CentOS7 192.168.100.127/24
```

安装

```shell
# [server]
yum install -y centos-release-gluster7
yum install -y glusterfs-server

# [client]
yum install -y centos-release-gluster7
yum install -y glusterfs glusterfs-fuse
```

启动

```shell
# [server]
systemctl enable glusterd
systemctl enable glusterfsd
systemctl start glusterd
systemctl start glusterfsd
```

配置

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

测试

```shell
# [client]
touch /shareDate/test
md5sum /shareDate/test

# [server]
md5sum /shareDate/test
```

自动挂载

```shell
# [client]
vi /etc/fstab
#192.168.69.51:www-image /opt/www/Uploads  glusterfs  defaults 0 0
mount -a
```


