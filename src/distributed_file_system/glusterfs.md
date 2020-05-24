## GlusterFS

是一个大尺度分布式文件系统，它是各种不同的存储服务器之上的组合

*   分布式算法 <https://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/>

*   命令列表 <https://docs.gluster.org/en/latest/CLI-Reference/cli-main/>





## 安装

*   官方源 <https://wiki.centos.org/SpecialInterestGroup/Storage/gluster-Quickstart>

```shell
   sudo yum install -y centos-release-gluster \
&& sudo yum install -y glusterfs-server glusterfs glusterfs-fuse \
&& sudo systemctl enable glusterd glusterfsd \
&& sudo systemctl start  glusterd glusterfsd \
&& sudo systemctl status glusterd glusterfsd
```





## 配置

```shell
sudo mkdir -vp "/opt/.www-images/data"
sudo gluster peer probe 192.168.68.10
sudo gluster peer probe 192.168.68.11
sudo gluster peer probe 192.168.68.12
#sudo gluster peer status
#sudo gluster peer detach

sudo gluster volume create www-images replica 3 \
    192.168.68.10:/opt/.www-images/data \
    192.168.68.11:/opt/.www-images/data \
    192.168.68.12:/opt/.www-images/data \
    force
#sudo gluster volume delete www-images
sudo gluster volume start www-images
sudo gluster volume info
```

挂载

```shell
# [client]
vi /etc/fstab
#192.168.68.12:www-images /opt/www  glusterfs  defaults 0 0
mount -a

# or

mount -t glusterfs 192.168.56.101:www-images /opt/www/images
```





## 磁盘配额

<https://docs.gluster.org/en/latest/Administrator%20Guide/Directory%20Quota/>>

*   默认mount后最大是50G

修改为500G

```shell
sudo gluster volume quota www-images enable
sudo gluster volume quota www-images limit-usage / 500GB
sudo gluster volume quota www-images list
```





## 故障处理

*   删除所有GlusterFS相关的卷和主机，但是这些主机是离线状态

第一步：在卷中移除指定的主机

```shell
# 创建时
sudo gluster volume create       www-images replica 2 192.168.69.51:/opt/www-image 192.168.69.24:/opt/www-image force

# 现在移除 192.168.69.51
sudo gluster volume remove-brick www-images replica 1                              192.168.69.24:/opt/www-image force
```

第二步：移除池中的主机

```shell
sudo rm -vrf /var/lib/glusterd/peers/*
sudo systemctl  stop  glusterd glusterfsd
sudo systemctl  start glusterd glusterfsd
sudo systemctl status glusterd glusterfsd
```

第三步：移除卷

```shell
sudo gluster volume delete www-images
```

