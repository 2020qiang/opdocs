环境信息

```
CentOS Linux release 7.4.1708 (Core)
Linux localhost.localdomain 4.9.58-29.el7.x86_64 #1 SMP Mon Oct 23 17:24:36 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```

#### 安装 xen

```
# yum install -y centos-release-xen
# yum --enablerepo=centos-virt-xen -y update kernel
# yum --enablerepo=centos-virt-xen -y install xen
```

编辑 /etc/default/grub，虚拟机或实体机的内存一定要大于Domain0设置的内存

```
GRUB_CMDLINE_XEN_DEFAULT="dom0_mem=4096M,max:4096M cpuinfo com1=115200,8n1 .....
```

添加 xen 到默认 grub 中

```
# /bin/grub-bootxen.sh
```

**警告**：

> grub efi 无法使用，就算将启动项写入 /boot/efi/EFI/centos/grub.cfg，还是无法启动，提示缺少某些特性
>
> 解决：改为 mbr 启动，将 EFI 目录备份，运行 grub-install /dev/sda，改为

重启

```
# shutdown -r 0
```

查看 xen 的信息，检查是否安装成功

```
# xl info
```

#### 安装 管理工具

```
# yum install -y epel-release.noarch
# yum install -y libvirt libvirt-daemon-xen libvirt-daemon-kvm virt-install virt-viewer
# yum install -y virt-manager xauth wqy-microhei-fonts wqy-zenhei-fonts
# systemctl enable libvirtd.service
# systemctl start libvirtd.service
```

编辑 /etc/ssh/sshd\_config 开启 X 转发

```
X11Forwarding yes
```

> 参考
>
> ```
> https://unix.stackexchange.com/questions/108679/x-client-forwarded-over-ssh-cannot-open-display-localhost11-0/109322
> https://wiki.centos.org/zh/HowTos/Grub2
> https://www.linuxtechi.com/install-kvm-hypervisor-on-centos-7-and-rhel-7/
> https://wiki.centos.org/zh/HowTos/Xen/Xen4QuickStart
> ```

---

xen 默认分派 guest 内存很小，可调整

```
# xl info
...
total_memory           : 49070
free_memory            : 18738
...
```

调整命令

```
xl mem-set 0 5000
```

> [https://lists.xen.org/archives/html/xen-users/2014-07/msg00335.html](https://lists.xen.org/archives/html/xen-users/2014-07/msg00335.html)



