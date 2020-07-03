### 工作模式

```
1 rsync [OPTION]... SRC [SRC]... DEST                                 # 同步本地文件至本地文件
2 rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST                     # 同步本地文件至远程文件，使用远程 shell
3 rsync [OPTION]... SRC [SRC]... [USER@]HOST::DEST                    # 同步本地文件至远程文件，使用远程 rsync
4 rsync [OPTION]... SRC [SRC]... rsync://[USER@]HOST[:PORT]/DEST      # 可忽略
5 rsync [OPTION]... [USER@]HOST:SRC [DEST]                            # 同步远程文件至本地文件，使用远程 shell
6 rsync [OPTION]... [USER@]HOST::SRC [DEST]                           # 同步远程文件至本地文件，使用远程 rsync
7 rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]             # 可忽略
```

#### 使用第 2 种模式

目的：本地同步网页文件至线上

一、差异同步

```
rsync \
    --[quiet/verbose] \         # [安静模式/详细输出模式]
    -c, --checksum \                # 校验
    -r, --recursive \               # 递归
    -z, --compress \                # 压缩
        --delete \                  # 本地没有的文件，远程的删除
    -a, --archive \                 # 保持所有文件属性
        --backup \                  # 使用备份目标修改前的文件（同步过去前先备份之前的文件）
    /home/liuq369/.Me/ \        # 本地目录
    root@192.168.6.4:/web       # 远程目录

    -e 'ssh -p 22'              # 可以指定 ssh 端口
    --backup-dir=''             # 指定备份目录（远程机器上）
    --exclude=''                # 排除指定目录

$ rsync -acrvz --delete --exclude=Runtime --exclude=Uploads /opt/www www-sync@192.168.100.68:/opt
```

> [https://einverne.github.io/post/2017/07/rsync-introduction.html](https://einverne.github.io/post/2017/07/rsync-introduction.html)


