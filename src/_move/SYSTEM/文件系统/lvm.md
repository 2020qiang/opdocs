安装

```shell
sudo apt-get install lvm2 cryptsetup-bin
sudo systemctl enable lvm2
```



### cryptsetup

加密工具

*   `dm-crypt` 命令行工具
*   `dm-crypt` Linux内核版本2.6及更高版本中的透明磁盘加密子系统

打开LUKS容器

```shell
sudo cryptsetup open /dev/sda3 sda3_crypt --type luks
sudo systemd-nspawn -D /chroot -b
# sudo vgchange -an debian
# sudo cryptsetup close sda3_crypt
```

```shell
# chroot
ROOT="/chroot"
mount --types proc "/proc" "${ROOT}/proc"
mount --rbind "/sys" "${ROOT}/sys"
mount --rbind "/dev" "${ROOT}/dev"
mount --make-rslave "${ROOT}/sys"
mount --make-rslave "${ROOT}/dev"
chroot "${ROOT}" bash
```



概念

*   物理卷（PV）
    ```shell
    # 物理卷： 磁盘的物理分区，在这个分区中包含一个特殊区域，用于记载与LVM相关的管理参数
    pvcreate /dev/sdb         - 初始化磁盘或分区以供LVM使用
    pvmove /dev/sdb           - 数据移动到其他物理卷
    vgreduce Name /dev/sdb    - 将数据移出磁盘后，将其从卷组中删除
    pvremove /dev/sdb         - 删除物理卷
    pvdisplay                 - 验证PV配置
    ```

*   卷组（VG）
    ```shell
    # 卷组： 一个或者多个物理卷的组合，它将多个物理卷组合在一起，形成一个可管理的单元
    vgcreate Name /dev/sdb    - 创建物理卷的卷组
    vgextend Name /dev/sdb    - PV添加到已存在的VG
    vgremove                  - 删除卷组
    vgdisplay                 - 验证VG配置
    ```

*   逻辑卷（LV）
    ```shell
    # 逻辑卷: 在卷组中划分的一个逻辑区域，类似于分区
    lvcreate -n myLogicalVolume1 -L 10g myVirtualGroup1   - 在卷组中创建逻辑卷
    mkfs.ext4 /dev/myVirtualGroup1/myLogicalVolume1       - 将逻辑卷格式化为所需的文件系统
    lvremove myVirtualGroup1/myLogicalVolume1             - 删除逻辑卷
    lvdisplay                                             - 验证LV配置
    ```
