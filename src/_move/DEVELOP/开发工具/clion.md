### 远程 debug

一、添加代码同步

```
# 打开配置界面
Tool -> Deployment -> Configuration...

# 添加
Add (Insert) -> Name: sss, Type: SFTP

# 配置
Connection
    SFTP host: (服务器地址[ip/domain])
    Port:     （服务器 ssh 端口）
    Root path: (在服务端代码存放绝对路径)
    User name:（用户名）
    Auth type:（Password）
    Save password: true
    Password: （密码）
Mappings
    Local path:（本地代码绝对路径）
    Deployment:（/，将全部代码同步到服务器）
    Web path:  （/，默认）
Excluded Paths（排除）
    Add local path:     （本地代码绝对路径）
    Add deployment path:（远程代码绝对路径）

# 初始上传
Tool -> Deployment -> Upload to sss

# 自动同步更新代码到服务器
Tool -> Deployment -> Automatic Upload(always)

# 查看侧边栏
Tool -> Deployment -> Browse Remote Host
```

二、远程 debug



