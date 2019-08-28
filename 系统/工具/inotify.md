### inotify

文件系统状态事件触发

触发机制

```
access         文件或目录内容被读取
modify         文件或目录内容被写入
attrib         文件或目录属性已更改
close_write    文件或目录在可写入模式下打开后关闭
close_nowrite  文件或目录在以只读模式打开后关闭
close          文件或目录关闭，无论是读/写模式
open           文件或目录打开
moved_to       文件或目录移动到监视目录
moved_from     文件或目录从被监视的目录中移出
move           文件或目录移出或离开了目录
create         文件或目录中创建的目录
delete         在目录中删除的文件或目录
delete_self    文件或目录已被删除
unmount        包含文件或目录的文件系统卸载
```

常用选项

```
--exclude       排除匹配扩展正则表达式的所有事件
                --exclude '(/opt/www/Runtime|/opt/www/Uploads)' 可排除目录
-m, --monitor   不断地监听事件，如果没有这个选项，会在收到一个事件后退出
-r, --recursive 以递归方式监听事件目录
-e, --event     监听特定以上触发机制，如果省略，则监听所有事件
-q, --quiet     仅输出触发的事件
```

使用脚本

一直检查是否触发事件，触发事件之后，inotifywait 程序会退出，从而执行需要的命令

```
#!/usr/bin/env bash

while true; do
    inotifywait -r -e modify,attrib,move,create,delete --exclude '(/opt/www/Runtime|/opt/www/Uploads)' /opt/www
    rsync -acrvz --delete --exclude=Runtime --exclude=Uploads /opt/www www-sync@192.168.71.22:/opt
    rsync -acrvz --delete --exclude=Runtime --exclude=Uploads /opt/www www-sync@192.168.71.41:/opt
    rsync -acrvz --delete --exclude=Runtime --exclude=Uploads /opt/www www-sync@192.168.71.42:/opt
done
```

> 参考
>
> ```
> http://bartsimons.me/sync-folders-and-files-on-linux-with-rsync-and-inotify/
> ```


