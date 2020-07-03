#!/usr/bin/env bash



# 为方便某些用户，这种非官方的 替代版本包括非免费固件，以便为某些笨拙的硬件提供额外支持
# 只包含核心Debian安装程序代码和一小组核心文本模式程序
# http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/archive/9.9.0+nonfree/amd64/iso-cd/firmware-9.9.0-amd64-netinst.iso

# 分区
# efi  = 100m
# boot = 250m
# swap = mem/2
# root+swap = disk/2

# 安装系统
# main                           -> Install
# Select a language              -> English
# Select youer location          -> Hong Kong
# Configure the keyboard         -> American English
# Configure the network          -> debian
# Configure the network          -> (null)
# Set up user and passwords      -> (root pass)
# Set up user and passwords      -> (root pass)
# Set up user and passwords      -> Elijah
# Set up user and passwords      -> liuq369
# Set up user and passwords      -> (user pass)
# Set up user and passwords      -> (user pass)
# Partition disks                -> Guided - use entire disk and set up encrypted LVM
# Partition disks                -> SCSI1 (0,0,0) (sda) -
# Partition disks                -> All files in one partition (recommended for new users)
# Partition disks                -> Yes
# Partition disks                -> (disk pass)
# Partition disks                -> (disk pass)
# Partition disks                -> Finish partitioning and write changes to disk
# Partition disks                -> Yes
# Configure the package manager  -> No
# Configure the package manager  -> Japan
# Configure the package manager  -> ftp.jp.debian.org
# Configure the package manager  -> (null)
# Configuring popularity-contest -> Yes
# Software selection             -> standard system utilities
# Finish the installation        -> Continue

# 配置桌面（设置管理器）
# 窗口管理器
#   样式
#     主题：   Default-4.6
#     标题文字：文泉驿等宽正黑，Regular, 9
#     标题对齐：中
#     按钮布局：标题、最小化、最大化、关闭
#   键盘
#     动作：全部清除
#     保留：
#       上： 上
#       下： 下
#       左： 左
#       右： 右
#       取消： 退出
#       循环： Alt+制表
#       切换同一应用程序的窗口： Ctrl+制表
#       关闭窗口： Super+Q
#       最大化窗口： Super+A
#       隐藏窗口： Super+Z
#       调整窗口大小： Super+X
#   焦点
#     点击聚焦
#     聚焦新窗口：自动聚焦新创建的窗口
#     聚焦时提升：窗口接收焦点时自动提升，短
#     点击时提升：在应用程序窗口内点击时提升窗口
#   高级
#     全部取消
#     双击动作：最大化窗口
# 窗口管理器微调
#   循环：全部取消
#   焦点
#     遵守标准的 ICCCM 焦点提示
#     窗口提升自己时：窗口放在当前工作区
#   辅助功能
#     全部取消
#     用来捕获和移动窗口按键：Super
#     按下任意鼠标按钮时提升窗口
#   工作区
#     全部取消
#   放置
#     触发智能放置的窗口最小大小：1/3
#     窗口默认放置在：在鼠标光标下
#   合成器
#     全部取消
# 工作区
#   一般
#     工作区数量：1
#     边缘：空
# 面板（只有一个）
#   显示
#     一般
#       模式：水平
#       锁定面板
#       自动隐藏面板：聪明地
#     尺寸
#       行大小（像素）：22
#       行数：1
#       长度（%）：24
#       自动增加长度
#   外观
#     背景
#       样式：无（使用系统样式）
#   项目
#     应用程序菜单
#       全部取消
#       在菜单中显示图标
#       显示按钮标题
#       按钮标题：应用程序
#       菜单文件：使用默认菜单文件
#     通知区域
#       全部取消
#       最大图标大小（像素）：22
#     时钟
#       时间设置：时区：空
#       外观
#         布局：数字式
#         工具提示格式：自定义格式：空
#       时钟选项
#         格式：自定义格式：%Y/%m/%d %H:%M:%S
#     PulseAudio Plugin
#     启动器
# 首选应用程序
#   互联网
#     网络浏览器：chromium
#     邮件阅读器：空
#   实用程序
#     文件管理器：thunar
#     终端模拟器：terminator
# 外观
#   样式：Xfce-4.4
#   图标：Tango
#   字体
#     默认字体
#       文泉驿等宽正黑, Regular, 10
#     渲染
#       启用抗锯齿
#         提示：中度
#         次像素次序：RGB
#     DPI
#       自定义 DPI 设置：96
#   设置
#     工具栏样式：图标
#     菜单和按钮
#       全部取消
#       在菜单中显示图片
#     事件声音：全部取消
# 文件管理器
#   显示
#     默认视图
#       查看新文件夹用：详细列表视图
#       显示缩略图：只显示本地文件
#       文件夹排列在文件前
#       以二进制格式显示文件大小
#     图标视图：全部取消
#     日期：年-月-日 时:分:秒
#   侧边栏
#     快捷方式栏
#       图标大小：较小
#       显示图标徽标
#     树形栏
#       图标大小：非常小
#       显示图标徽标
#   行为
#     导航：双击激活项目
#     单击鼠标中键：在新窗口中打开文件夹
#   高级
#     文件夹权限：每次都询问
#     卷管理：全部关闭
# 桌面
#   背景
#     目录：liuq369
#     样式：缩放
#     颜色：水平渐变
#     应用到所有工作区
#     不自动修改背景
#   菜单
#     全部取消
#   图标
#     外观
#       图标类型：最小化应用程序的图标
#       图标大小：36
#       使用自定义的字体大小：10
#       不显示图标提示
#       不显示缩略图
#       不显示桌面的隐藏文件
#       单击激活项目
#     默认图标
#       全部取消
# 电源管理器
#   一般
#     按钮
#       按下电源按钮时：什么都不做
#       按下睡眠按钮时：什么都不做
#       按下休眠按钮时：什么都不做
#     外观
#       不显示通知
#       不显示系统托盘图标
#   系统
#     系统节电
#       系统睡眠模式：挂起
#       在闲置时：从不
#   显示
#     显示电源管理器设置
#       显示器电源管理
#         在之后空白：从不
#         在之后转入休眠：从不
#         在之后关不：5分钟
#   安全性
#     Light Locker
#       自动锁定会话：当屏保被激活
#       在屏保之后延迟锁定：1秒
#       当系统即将休眠时锁定屏幕
# 键盘
#   行为
#     一般
#       启动时恢复数字键状态
#     输入设置
#       启用按键重复
#         重复延时：500
#         重复速度：20
#     光标
#       启用显示闪烁
#       闪烁延时：1200
#   应用程序快捷键
#     /usr/bin/chromium：                     Super+W
#     /usr/bin/chromium-tmp：                 Super+V
#     /usr/bin/leafpad：                      Ctrl+Space
#     /usr/bin/terminator：                   Super+T
#     /usr/bin/thunar：                       Super+E
#     /usr/bin/xfce4-screenshooter -c -r：    Super+打印
#     /usr/bin/xkill：                        Super+K
#     /usr/bin/xfce4-appfinder：              Super+F
#     /usr/bin/xfce4-popup-applicationsmenu： Super+C
#     /usr/bin/xflock4：                      Super+L
#   布局
#     使用系统默认
# 可移动驱动器和介质
#   全部取消
# 鼠标和触摸板
#   主题：Adwaita
# 显示
#   不，连接时配置新显示
# 辅助功能
#   辅助技术
#     不启用辅助技术
#   键盘
#     全部取消
#   鼠标
#     全部取消
# 会话和启动
#   一般
#     全部取消
#     注销时提示
#   启动画面
#     Mice
#   应用程序自启动
#     anydesk
#     anydesk --tray
#     redshift-gtk
#     dropbox
#     skype
#     keepassx-setup
#       while true; do
#           /usr/bin/keepassx /home/liuq369/.sa/sa.kdbx
#           sleep 1s
#       done
#   高级
#     全部取消
#     睡眠前锁屏

# 输入法
#   常规
#     快捷键
#       下一个输入法：<Super>space
#     字体和风格
#       候选词排列方向：竖直
#       显示属性栏：不再提示
#       打开在系统托盘上显示图标
#       打开在应用程序窗口中启用内嵌套编辑模式
#       不使用自定义字体
#   输入法
#     汉语
#     英语
#   高级
#     使用系统键盘布局
#     在所有应用程序中共享同一个输入法


# DNS
F="/etc/resolv.conf"
cat > ${F} << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
chattr +i ${F}


# 软件源
cat > /etc/apt/sources.list << EOF
deb http://ftp.jp.debian.org/debian/ stretch main non-free contrib
deb http://ftp.jp.debian.org/debian/ stretch-updates main contrib non-free
deb http://security.debian.org/debian-security stretch/updates main contrib non-free
EOF

# 安装软件
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
software_list='''
    locales ttf-wqy-microhei ttf-wqy-zenhei sudo
    vim bash-completion htop wget curl tree axel xsel xterm apt-file unzip bc
    xclip git-core iotop build-essential gparted iftop unrar redis-tools mariadb-client
    xpad leafpad lightdm terminator sshpass keepassx dia gpick feh exfat-fuse exfat-utils meld
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

exit



# 语言
cat > /etc/default/locale << EOF
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN.UTF-8"
EOF
cat > /root/.bashrc << EOF
export LC_ALL=C
EOF
chmod +x /root/.bashrc

# vi
cat > /usr/share/vim/vimrc << EOF
autocmd BufEnter * set mouse=
set expandtab
set tabstop=4
set hlsearch
set ignorecase
set smartcase
EOF

# 终端
F="/home/$(ls /home)/.config/terminator/config"
mkdir -vp "$(dirname $F)"
wget "https://raw.githubusercontent.com/liuq369/tools/master/config/terminator.txt" -O "${F}"

# 快速开机
F="/etc/default/grub"
sed -i '/^GRUB_TIMEOUT/d' ${F}
lent="$(grep -E '^GRUB_DEFAULT=.+' ${F} |head -n 1 |awk -F ':' '{print $1}')"
sed -i "${lent} a GRUB_TIMEOUT=0" ${F}
unset lent
update-grub
update-grub2





exit


# 开启tab按键补全
vi /etc/bash.bashrc
# enable bash completion in interactive shells


# 自动登陆
vi /etc/lightdm/lightdm.conf
autologin-user=liuq369



# xpad
Preferences
  View
    全部取消
    打开两个 Hide all
  Staerup
    全部取消
    钩上 Start Xpad automatically after login
  Tray
    全部取消
  Other
    全部取消
    钩上 删除标签确定
    

rm -rf /home/liuq369/*


wget -c https://go.skype.com/skypeforlinux-64.deb
dpkg -i skypeforlinux-64.deb
apt-get install -f -y
rm -f skypeforlinux-64.deb


# liuq369
ibus-setup
cat > .bashrc << EOF
#/usr/bin/env bash

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

alias ls="ls --color"
export PATH="$PATH:/opt/user/go/bin"
EOF
chmod +x .bashrc


wget -c https://download.virtualbox.org/virtualbox/5.1.38/virtualbox-5.1_5.1.38-122592~Debian~stretch_amd64.deb
wget -c https://download.virtualbox.org/virtualbox/5.1.38/Oracle_VM_VirtualBox_Extension_Pack-5.1.38.vbox-extpack
dpkg -i virtualbox-5.1_5.1.38-122592~Debian~stretch_amd64.deb
apt-get install -f -y
rm -f virtualbox-5.1_5.1.38-122592~Debian~stretch_amd64.deb
usermod -a -G vboxusers liuq369
apt-get install -y linux-headers-amd64
/sbin/vboxconfig
virtualbox
rm -f Oracle_VM_VirtualBox_Extension_Pack-5.1.38.vbox-extpack


wget -c https://download.anydesk.com/linux/anydesk_4.0.0-1_amd64.deb
dpkg -i anydesk_4.0.0-1_amd64.deb
apt-get install -f -y
rm -f anydesk_4.0.0-1_amd64.deb

cat > /usr/bin/keepassx-setup << EOF
while true; do
    /usr/bin/keepassx /home/liuq369/.sa/sa.kdbx
    sleep 1s
done
EOF
chmod 0555 /usr/bin/keepassx-setup


cat > .ssh/config << EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ServerAliveInterval 10
EOF







wget -c https://download-cf.jetbrains.com/cpp/CLion-2018.2.4.tar.gz

mv Downloads/resources_cn_GoLand_2018.1_r2.jar /opt/user/GoLand-2018.2.3/lib/
mv Downloads/resources_cn_CLion_2018.1_r1.jar /opt/user/clion-2018.2.4/lib/

https://gist.github.com/bangnguyen47/96af3784c9d61d54280e0aadeb5576eb
CATF44LT7C-eyJsaWNlbnNlSWQiOiJDQVRGNDRMVDdDIiwibGljZW5zZWVOYW1lIjoiVmxhZGlzbGF2IEtvdmFsZW5rbyIsImFzc2lnbmVlTmFtZSI6IiIsImFzc2lnbmVlRW1haWwiOiIiLCJsaWNlbnNlUmVzdHJpY3Rpb24iOiJGb3IgZWR1Y2F0aW9uYWwgdXNlIG9ubHkiLCJjaGVja0NvbmN1cnJlbnRVc2UiOmZhbHNlLCJwcm9kdWN0cyI6W3siY29kZSI6IklJIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In0seyJjb2RlIjoiQUMiLCJwYWlkVXBUbyI6IjIwMjAtMDEtMDgifSx7ImNvZGUiOiJEUE4iLCJwYWlkVXBUbyI6IjIwMjAtMDEtMDgifSx7ImNvZGUiOiJQUyIsInBhaWRVcFRvIjoiMjAyMC0wMS0wOCJ9LHsiY29kZSI6IkdPIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In0seyJjb2RlIjoiRE0iLCJwYWlkVXBUbyI6IjIwMjAtMDEtMDgifSx7ImNvZGUiOiJDTCIsInBhaWRVcFRvIjoiMjAyMC0wMS0wOCJ9LHsiY29kZSI6IlJTMCIsInBhaWRVcFRvIjoiMjAyMC0wMS0wOCJ9LHsiY29kZSI6IlJDIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In0seyJjb2RlIjoiUkQiLCJwYWlkVXBUbyI6IjIwMjAtMDEtMDgifSx7ImNvZGUiOiJQQyIsInBhaWRVcFRvIjoiMjAyMC0wMS0wOCJ9LHsiY29kZSI6IlJNIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In0seyJjb2RlIjoiV1MiLCJwYWlkVXBUbyI6IjIwMjAtMDEtMDgifSx7ImNvZGUiOiJEQiIsInBhaWRVcFRvIjoiMjAyMC0wMS0wOCJ9LHsiY29kZSI6IkRDIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In0seyJjb2RlIjoiUlNVIiwicGFpZFVwVG8iOiIyMDIwLTAxLTA4In1dLCJoYXNoIjoiMTE1MzA4ODUvMCIsImdyYWNlUGVyaW9kRGF5cyI6MCwiYXV0b1Byb2xvbmdhdGVkIjpmYWxzZSwiaXNBdXRvUHJvbG9uZ2F0ZWQiOmZhbHNlfQ==-BZLL+H88k449OQC56NsqU0fwb6wMAX1Di+CK5HS46DuOD1E68HPiTqREdn8DzrLVAoMkJReaH30RaIDLwUI8GEFifDcCYE5RbpE5ApNJ8mcUJr8oA1nrjY9IzZCgrSBFr4GAOLqSfXH+1UJ3K8UPqGh8nThomnKW9Jvv9pA7HIH/KrNm2RLV/aNMHWO8Q44A8ToXm7g5FS2lW903URPQ0KFgxT11w/KL81UkHm6yUXC7/LTAygIBArI8j+XUk3rlz4rpi2wrJclYXukrKQqH/V6CTbnVV3d6XAdtCqjryQ2Ga7bP/XTLjwAGwPEB3Q1W7LHNQ7CsyvZG/oTSOgD2YQ==-MIIElTCCAn2gAwIBAgIBCTANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1KZXRQcm9maWxlIENBMB4XDTE4MTEwMTEyMjk0NloXDTIwMTEwMjEyMjk0NlowaDELMAkGA1UEBhMCQ1oxDjAMBgNVBAgMBU51c2xlMQ8wDQYDVQQHDAZQcmFndWUxGTAXBgNVBAoMEEpldEJyYWlucyBzLnIuby4xHTAbBgNVBAMMFHByb2QzeS1mcm9tLTIwMTgxMTAxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxcQkq+zdxlR2mmRYBPzGbUNdMN6OaXiXzxIWtMEkrJMO/5oUfQJbLLuMSMK0QHFmaI37WShyxZcfRCidwXjot4zmNBKnlyHodDij/78TmVqFl8nOeD5+07B8VEaIu7c3E1N+e1doC6wht4I4+IEmtsPAdoaj5WCQVQbrI8KeT8M9VcBIWX7fD0fhexfg3ZRt0xqwMcXGNp3DdJHiO0rCdU+Itv7EmtnSVq9jBG1usMSFvMowR25mju2JcPFp1+I4ZI+FqgR8gyG8oiNDyNEoAbsR3lOpI7grUYSvkB/xVy/VoklPCK2h0f0GJxFjnye8NT1PAywoyl7RmiAVRE/EKwIDAQABo4GZMIGWMAkGA1UdEwQCMAAwHQYDVR0OBBYEFGEpG9oZGcfLMGNBkY7SgHiMGgTcMEgGA1UdIwRBMD+AFKOetkhnQhI2Qb1t4Lm0oFKLl/GzoRykGjAYMRYwFAYDVQQDDA1KZXRQcm9maWxlIENBggkA0myxg7KDeeEwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCwYDVR0PBAQDAgWgMA0GCSqGSIb3DQEBCwUAA4ICAQAF8uc+YJOHHwOFcPzmbjcxNDuGoOUIP+2h1R75Lecswb7ru2LWWSUMtXVKQzChLNPn/72W0k+oI056tgiwuG7M49LXp4zQVlQnFmWU1wwGvVhq5R63Rpjx1zjGUhcXgayu7+9zMUW596Lbomsg8qVve6euqsrFicYkIIuUu4zYPndJwfe0YkS5nY72SHnNdbPhEnN8wcB2Kz+OIG0lih3yz5EqFhld03bGp222ZQCIghCTVL6QBNadGsiN/lWLl4JdR3lJkZzlpFdiHijoVRdWeSWqM4y0t23c92HXKrgppoSV18XMxrWVdoSM3nuMHwxGhFyde05OdDtLpCv+jlWf5REAHHA201pAU6bJSZINyHDUTB+Beo28rRXSwSh3OUIvYwKNVeoBY+KwOJ7WnuTCUq1meE6GkKc4D/cXmgpOyW/1SmBz3XjVIi/zprZ0zf3qH5mkphtg6ksjKgKjmx1cXfZAAX6wcDBNaCL+Ortep1Dh8xDUbqbBVNBL4jbiL3i3xsfNiyJgaZ5sX7i8tmStEpLbPwvHcByuf59qJhV/bZOl8KqJBETCDJcY6O2aqhTUy+9x93ThKs1GKrRPePrWPluud7ttlgtRveit/pcBrnQcXOl1rHq7ByB8CFAxNotRUYL9IF5n3wJOgkPojMy6jetQA5Ogc8Sm7RG6vg1yow==
