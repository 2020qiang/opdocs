#### systemd 日志管理工具

显示所有已存档和活动日志文件的磁盘使用量

```
[centos@localhost]$ journalctl --disk-usage
Archived and active journals take up 224.0M on disk.
```

清理方法

1. 限制日志总大小（K M G T）
2. 限制日志保留时间（s d y）

```
[centos@localhost]$ sudo journalctl --vacuum-size=200M --vacuum-time=20d
Vacuuming done, freed 0B of archived journals on disk.
Deleted archived journal /run/log/journal/b30d0f2110ac3807b210c19ede3ce88f/system@affd91fae13642f4883c9ffab5f34a7b-00000000006bee89-00057b92645bf5db.journal (88.0M).
Deleted archived journal /run/log/journal/b30d0f2110ac3807b210c19ede3ce88f/system@affd91fae13642f4883c9ffab5f34a7b-00000000006d6dd5-00057b9f3e5f89a6.journal (88.0M).
Deleted archived journal /run/log/journal/b30d0f2110ac3807b210c19ede3ce88f/system@affd91fae13642f4883c9ffab5f34a7b-00000000006eed1d-00057bac38d09d09.journal (88.0M).
Vacuuming done, freed 264.0M of archived journals on disk.
```

启用日志限制持久化配置

```
[centos@localhost]$ sudo vi /etc/systemd/journald.conf 
SystemMaxUse=200m
SystemMaxFileSize=100m
[centos@localhost]$ sudo systemctl restart systemd-journald.service
[centos@localhost]$ sudo journalctl --verify

```



