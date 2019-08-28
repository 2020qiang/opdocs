#### Gluster是一个大尺度分布式文件系统，它是各种不同的存储服务器之上的组合

分布式算法：[http://docs.gluster.org/en/latest/Administrator Guide/Setting Up Volumes/](http://docs.gluster.org/en/latest/Administrator Guide/Setting Up Volumes/)

命令列表：[https://docs.gluster.org/en/latest/CLI-Reference/cli-main/](https://docs.gluster.org/en/latest/CLI-Reference/cli-main/)

环境

```
# [server]
#
# CentOS7 192.168.100.126/24
# CentOS7 192.168.100.125/24

# [client]
#
# CentOS7 192.168.100.127/24
```

安装

```
# [server]
#
# yum install -y centos-release-gluster37
# yum install -y glusterfs-server

# [client]
#
# yum install -y centos-release-gluster37
# yum install -y glusterfs glusterfs-fuse
```

启动

```
# [server]
#
# chkconfig glusterd on
# chkconfig glusterfsd on
# service glusterd start
# service glusterfsd start
```

配置

```
# [server]
#
# mkdir /opt/www-image
# gluster peer probe 192.168.69.51
# gluster peer probe 192.168.69.23
# gluster peer probe 192.168.69.24
# gluster volume create www-image replica 3 192.168.69.51:/opt/www-image 192.168.69.23:/opt/www-image 192.168.69.24:/opt/www-image force
# gluster volume start www-image
# gluster volume info

# [client]
#
# mount -t glusterfs 192.168.69.51:www-image /opt/www/Uploads
```

测试

```
# [client]
#
# touch /shareDate/test
# md5sum /shareDate/test

# [server]
#
# md5sum /shareDate/test
```

自动挂载

```
# [client]
#
# vi /etc/fstab
# 192.168.69.51:www-image /opt/www/Uploads  glusterfs  defaults 0 0
#
# mount -a
```


