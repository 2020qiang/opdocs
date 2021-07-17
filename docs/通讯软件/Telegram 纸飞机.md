## 机器人

作用：可以用它模拟少部分人类的操作



#### 创建机器人

* 纸飞机 @botFather
* 发送消息：`/start`
* 点击链接 `/newbot`



#### 机器人向群发消息

1. 拉机器人进群
2. 进群后有人发送消息
3. 打开 `https://api.telegram.org/bot<key>:<auth>/getUpdates`
4. 在响应数据中 `result[*].message.chat.title` 找到群名字，并记录ID





---





# 客户端



#### 问题：IBus无法输入中文



1. 使用下面命令获取Telegram的启动配置文件

```shell
find $HOME -type f |grep -i -E 'telegram(.*)desktop$'
```

2. 编辑启动配置文件

```ini
# 旧
Exec=/opt/Telegram/Telegram ...

# 新
Exec=env QT_IM_MODULE=IBus /opt/Telegram/Telegram ...
```

