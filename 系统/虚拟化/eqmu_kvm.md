KVM关键启动参数

```shell
#!/bin/bash

echo '1' >/proc/sys/net/ipv4/ip_forward
tunctl -t tap0
ip link set tap0 up
ip addr add 192.168.190.1/24 dev tap0
iptables -t nat -A POSTROUTING -j MASQUERADE
mount --bind /home/liuq369/.liuq369/ /srv/ftp/admin/
service vsftpd restart
service vsftpd start

qemu-system-x86_64 \
    -enable-kvm \
    -smp cpus=2 \
    -m 2000 \
    -drive file=/home/liuq369/virtio/seven.raw,if=virtio,format=raw \
    -drive file=/home/liuq369/virtio/seven.qcow2,if=virtio \
    -net nic,model=virtio \
    -net tap,ifname=tap0,script=no \
    -rtc base=localtime \
    -vnc 192.168.1.222:1 \
    -cdrom /home/liuq369/virtio/asp.net.iso


echo '0' >/proc/sys/net/ipv4/ip_forward
ip link set tap0 down
tunctl -d tap0
iptables -F -t nat
umount /srv/ftp/admin/
service vsftpd stop
```

iptables

```shell
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -I FORWARD 1 -i tap0 -j ACCEPT
sudo iptables -I FORWARD 1 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```



