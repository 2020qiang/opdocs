#### KVM

硬件辅助的全虚拟化解决方案，无需修改 Guest OS

可以选择性的添加 KVM 功能到 linux kernel

需要 cpu 支持虚拟化，使用`grep --color -E "vmx|svm" /proc/cpuinfo`查看

```
[*] Virtualization  --->
    <*>   Kernel-based Virtual Machine (KVM) support
    <M>   KVM for Intel processors support
    <*>   KVM for AMD processors support
    <*>   Host kernel accelerator for virtio net
Device Drivers  --->
    [*] Network device support  --->
        [*]   Network core driver support
        <*>   Universal TUN/TAP device driver support
[*] Networking support  --->
        Networking options  --->
            <M> The IPv6 protocol
            <*> 802.1d Ethernet Bridging
```

KVM 是内核组建，那么它的用户空间组建包括在 qemu 中

---

#### 体系结构

* KVM
  * 初始化CPU硬件
  * 控制CPU、内存、中断、控制器、时钟
* QEMU
  * 模拟网卡、显卡、储存控制器、硬盘
* libvirt
  * 提供统一的 API、守护进程、默认的virsh管理工具 

![](/assets/截图 - 2017年05月19日 - 21时17分19秒.png)

> 参考
>
> [Gentoo wiki 关于 QEMU](https://wiki.gentoo.org/wiki/QEMU)



