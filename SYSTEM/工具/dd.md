#### 创建大文件

```shell
dd if=/dev/zero of=test bs=1M count="$(read -p 'size(M): ' m; echo $m)"
```

