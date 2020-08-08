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





