## grub 安装至优盘，UEFI 和 BIOS 双支持启动

更改分区表为 gpt，数据会清空

```
sudo fdisk /dev/sda
命令(输入 m 获取帮助)： g
```

-   sda1：安装 MBR，为了兼容
-   sda2：安装 grub2 和 efi 文件
-   sda3：存放较多的 ISO 启动文件

分区类型一定要这样，fdisk 可用 t 指定类型

```
设备          起点      末尾     扇区   大小 类型
/dev/sda1    2048     2207      160   80K BIOS 启动
/dev/sda2    4096   167935   163840   20M EFI 系统
/dev/sda3  167936 30706654 30538719 14.9G Linux 文件系统

命令(输入 m 获取帮助)：w
分区表已调整。
```

格式化

```shell
sudo mkfs.fat /dev/sda2
sudo mkfs.ext2 /dev/sda3
```

挂载

```shell
sudo mkdir -vp /mnt/{boot,data}
sudo mount /dev/sda2 /mnt/boot
sudo mount /dev/sda3 /mnt/data
```

安装GRUB

```shell
sudo apt-get install -y grub-pc

sudo grub-install --target=i386-pc \
    --boot-directory=/mnt/usb/boot \
    /dev/sda

sudo grub-install --target=x86_64-efi \
    --efi-directory=/mnt/usb/boot

sudo touch /mnt/usb/boot/grub/grub.cfg
```

配置GRUB

```
insmod all_video

set default="0"
set timeout="30"

menuentry "wepe_x64_v1.2_win8.1.iso" {
    # https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz
    # ./bios/memdisk/memdisk
    set isofile="/iso/wepe_x64_v1.2_win8.1.iso"
    search --set=root --no-floppy --file /memdisk
    linux16 /boot/memdisk iso raw
    search --set=root --no-floppy --file ${isofile}
    initrd16 ${isofile}
}

menuentry "windows_10_x64_cn.iso" {
    set isofile="/iso/windows_10_cn_x64.iso"
    search --set=root --no-floppy --file /memdisk
    linux16 /boot/memdisk iso raw
    search --set=root --no-floppy --file ${isofile}
    initrd16 ${isofile}
}

menuentry "cn_windows_7_home_basic_with_sp1_x86_dvd_u_676500.iso" {
    set isofile="/iso/cn_windows_7_home_basic_with_sp1_x86_dvd_u_676500.iso"
    search --set=root --no-floppy --file /memdisk
    linux16 /boot/memdisk iso raw
    search --set=root --no-floppy --file ${isofile}
    initrd16 ${isofile}
}

menuentry "debian_live_full.iso" {
    set isofile="/debian_live_full.iso"
    search --set=root --no-floppy --file ${isofile}
    loopback loop ${isofile}
    linux (loop)/boot/vmlinuz       \
        archisolabel=ARCH_201305    \
        img_dev=/dev/sda$partition  \
        img_loop=$isofile           \
        earlymodules=loop
    linux /vmlinuz boot=live quiet nomodeset
    initrd (loop)/boot/initrd
}
```



## ISO Live 环境

创建自定义Debian Live环境（CD或USB）

这些是我在 **debian 4.9.0-8-amd64** 使用的步骤，用于构建 x86 Debian 9（Stretch）实时环境，可以从 CD 或 USB 启动

这些步骤可用于创建BIOS可引导（MBR），UEFI可引导（GPT）或UEFI和BIOS可引导组合的实时环境。本指南的独特之处在于不使用Syslinux / Isolinux。只有Grub引导装备。这样做是为了保持一致性并避免混合两者（单独的Syslinux / Isolinux无法完成本文所涵盖的所有内容，但Grub可以）。

以下是我的指南的一些替代方案，对于阅读本文的任何人来说可能是更好的解决方案：[live-build](https://manpages.debian.org/jessie/live-build/live-build.7.en.html)，[mkusb](https://help.ubuntu.com/community/mkusb)，[UNetbootin](https://unetbootin.github.io/)，[xixer](https://github.com/jnalley/xixer)，[rufus](https://rufus.akeo.ie/)，[YUMI](https://www.pendrivelinux.com/yumi-multiboot-usb-creator/)，[Simple-cdd](https://wiki.debian.org/Simple-CDD)。您还应该查看[Debian DebianCustomCD文档，](https://wiki.debian.org/DebianCustomCD)因为它将比本文更具信息性。

### 先前条件

##### 安装必须的工具

```shell
sudo apt-get install -y     \
    debootstrap             \
    squashfs-tools          \
    xorriso                 \
    grub-pc-bin             \
    grub-efi-amd64-bin      \
    mtools
```

##### 创建存储的目录

```shell
mkdir -vp $HOME/LIVE_BOOT
```

##### Bootstrap

debootstrap是一个将Debian基本系统安装到另一个已经安装的系统的子目录中的工具。

它不需要安装CD，只需访问Debian 存储库。它也可以从另一个操作系统安装和运行。

如果镜像离您更近，请更改此命令中的URL。

```shell
sudo debootstrap            \
     --arch=amd64           \
     --variant=minbase      \
     stretch                \
     $HOME/LIVE_BOOT/chroot \
     http://ftp.jp.debian.org/debian
```

##### 到我们刚刚创建的 debian 环境

```shell
sudo chroot $HOME/LIVE_BOOT/chroot
```

### chroot 环境操作

##### 设置自定义主机名

```shell
echo "livecd" >/etc/hostname
```

##### 安装必须环境

```sh
apt-get install -y linux-image-amd64 live-boot systemd-sysv
apt-get install -y sudo vim iputils-ping
useradd user
passwd user

# sudo
visudo
user ALL=(ALL) NOPASSWD:ALL
```

##### 退出基本chroot

```shell
exit
```

##### 启用高级chroot

```shell
sudo systemd-nspawn -D $HOME/LIVE_BOOT/chroot -b
```

##### 可选环境配置

```shell
# vimrc
cat > /usr/share/vim/vimrc << EOF
autocmd BufEnter * set mouse=
set expandtab
set tabstop=4
set hlsearch
set ignorecase
set smartcase
EOF

# DNS
cat > /etc/resolv.conf << EOF
nameserver 208.67.222.222
nameserver 8.8.8.8
nameserver 114.114.114.114
EOF

# sources
cat > /etc/apt/sources.list << EOF
deb http://ftp.jp.debian.org/debian/ stretch main non-free contrib
deb http://ftp.jp.debian.org/debian/ stretch-updates main contrib non-free
deb http://security.debian.org/debian-security stretch/updates main contrib non-free
EOF

# software
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
software_list='''
    locales ttf-wqy-microhei ttf-wqy-zenhei
    vim bash-completion htop wget curl tree axel xsel xterm apt-file unzip bc less
    xclip git-core iotop build-essential gparted iftop unrar redis-tools mariadb-client
    xpad leafpad lightdm terminator sshpass keepassx dia gpick feh exfat-fuse exfat-utils
    chromium chromium-l10n firefox-esr firefox-esr-l10n-zh-cn
    xfce4 xfce4-power-manager xfce4-power-manager-plugins xfce4-screenshooter
    xfwm4-theme-breeze xfwm4-themes
    redshift-gtk exfat-fuse exfat-utils p7zip p7zip-full p7zip-rar rdesktop
    ibus ibus-chewing im-config ibus-table-array30 ibus-qt4 ibus-gtk ibus-gtk3 ibus-sunpinyin
    network-manager-gnome
'''
echo "${software_list}" |xargs -n 99 apt-get install -y
unset software_list
apt-get --purge autoremove -y nano xfce4-notifyd
apt-get clean

vi /etc/NetworkManager/NetworkManager.conf
并将其添加到该[main]部分：
dns=none

# 开启tab按键补全
vi /etc/bash.bashrc
# enable bash completion in interactive shells

# 自动登陆
vi /etc/lightdm/lightdm.conf
autologin-user=user

# 语言
cat > /etc/default/locale << EOF
LC_ALL="zh_CN.UTF-8"
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN.UTF-8"
EOF
cat > ~/.bashrc << EOF
#/usr/bin/env bash
export LC_ALL=C
EOF
chmod +x ~/.bashrc
dpkg-reconfigure locales # en_US.UTF-8, zh_CN.UTF-8(default)

# user
cat > ~/.bashrc << EOF
#/usr/bin/env bash

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

alias ls="ls --color"
EOF
chmod +x .bashrc
```

### 打包为 squash 文件系统

```shell
mkdir -vp ${HOME}/LIVE_BOOT/{scratch,image/live}
sudo mksquashfs                              \
    ${HOME}/LIVE_BOOT/chroot                 \
    ${HOME}/LIVE_BOOT/image/live/os.squashfs \
    -e boot
```

#### 拷贝内核

```shell
cp -v ${HOME}/LIVE_BOOT/chroot/boot/vmlinuz-*     ${HOME}/LIVE_BOOT/image/vmlinuz
cp -v ${HOME}/LIVE_BOOT/chroot/boot/initrd.img-*  ${HOME}/LIVE_BOOT/image/initrd
```

#### 为 grub 创建菜单配置文件

此配置指示Grub使用该search命令来推断哪个设备包含我们的实时环境。

考虑到我们将现场环境编写为可启动媒体的各种方式，这似乎是最便携的解决方案。

```shell
vi ${HOME}/LIVE_BOOT/scratch/grub.cfg
```

```shell
insmod all_video

set default="0"
set timeout="0"

menuentry "Debian_9-x86_64_Live" {
    search --set=root --no-floppy --file /DEBIAN_CUSTOM
    linux  /vmlinuz boot=live quiet nomodeset
    initrd /initrd
}
```

在`image`named中创建一个特殊文件`DEBIAN_CUSTOM`。此文件将用于帮助`Grub`确定哪个设备包含我们的实时文件系统。

此文件名必须是唯一的，并且必须与我们的`grub.cfg`配置中的文件名匹配。

```shell
touch "${HOME}/LIVE_BOOT/image/DEBIAN_CUSTOM"
```

#### 检查目录及文件

LIVE\_BOOT 目录现在应该大致如下所示

```
LIVE_BOOT/chroot/*(tons of chroot files)*
LIVE_BOOT/scratch/grub.cfg
LIVE_BOOT/image/DEBIAN_CUSTOM
LIVE_BOOT/image/initrd
LIVE_BOOT/image/vmlinuz
LIVE_BOOT/image/live/os.squashfs
```

### 创建可启动 ISO

支持 UEFI+BIOS 启动方式

#### 创建一个 grub uefi 镜像

```shell
grub-mkstandalone                                  \
    --format=x86_64-efi                            \
    --output=${HOME}/LIVE_BOOT/scratch/bootx64.efi \
    --locales=""                                   \
    --fonts=""                                     \
    "boot/grub/grub.cfg=${HOME}/LIVE_BOOT/scratch/grub.cfg"
```

#### 创建包含EFI引导加载程序的FAT16 UEFI引导磁盘映像。

注意使用 mmd 和 mcopy 命令来复制我们命名的 UEFI 引导加载程序 bootx64.efi

```shell
cd ${HOME}/LIVE_BOOT/scratch
dd if=/dev/zero of=efiboot.img bs=1M count=10
sudo mkfs.vfat efiboot.img
mmd -i efiboot.img efi efi/boot
mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
```

#### 创建 grub bios 镜像

```shell
grub-mkstandalone                                                           \
    --format=i386-pc                                                        \
    --output=${HOME}/LIVE_BOOT/scratch/core.img                             \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search"                        \
    --locales=""                                                            \
    --fonts=""                                                              \
    "boot/grub/grub.cfg=${HOME}/LIVE_BOOT/scratch/grub.cfg"
```

#### 结合可引导文件到 cdboot.img

```shell
cat                                     \
    /usr/lib/grub/i386-pc/cdboot.img    \
    ${HOME}/LIVE_BOOT/scratch/core.img  \
    >${HOME}/LIVE_BOOT/scratch/bios.img
```

#### 生成ISO文件

```shell
xorriso                                                            \
    -as mkisofs                                                    \
    -iso-level 3                                                   \
    -full-iso9660-filenames                                        \
    -volid "DEBIAN_CUSTOM"                                         \
    -eltorito-boot                                                 \
        boot/grub/bios.img                                         \
        -no-emul-boot                                              \
        -boot-load-size 4                                          \
        -boot-info-table                                           \
        --eltorito-catalog boot/grub/boot.cat                      \
    --grub2-boot-info                                              \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img              \
    -eltorito-alt-boot                                             \
        -e EFI/efiboot.img                                         \
        -no-emul-boot                                              \
    -append_partition 2 0xef ${HOME}/LIVE_BOOT/scratch/efiboot.img \
    -output "${HOME}/LIVE_BOOT/debian-custom.iso"                  \
    -graft-points                                                  \
        "${HOME}/LIVE_BOOT/image"                                  \
        /boot/grub/bios.img=$HOME/LIVE_BOOT/scratch/bios.img       \
        /EFI/efiboot.img=$HOME/LIVE_BOOT/scratch/efiboot.img
```

> [Create a Custom Debian Live Environment (CD or USB)](https://willhaley.com/blog/custom-debian-live-environment/)



## 其他

自动登陆TTY

```shell
sudo vi $(systemctl cat getty@tty1 |head -n 1 |awk '{print $NF}')
"[Service]"
"ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM"
sudo systemctl daemon-reload
```

清空登陆成功提示信息

```shell
sudo cp -vf "/dev/null" "/etc/motd"
```

