#### SVN 与 Git 的最主要的区别

* **SVN** 是**集中式**版本控制系统，版本库集中在中央服务器，干活的时候，用自己的电脑，所以首先要从中央服务器哪里得到最新的版本，然后干活，干完后，需要把自己做完的活推送到中央服务器。集中式版本控制系统是必须联网才能工作，如果在局域网还可以，带宽够大，速度够快，如果在互联网下，如果网速慢的话，就纳闷了。
* **Git** 是**分布式**版本控制系统，它就没有中央服务器的，每个人的电脑就是一个完整的版本库，这样工作的时候就不需要联网了，每个人的电脑都有一个完整的版本库。在多个人协作上，比如说自己在电脑上改了版本库A，其他人也在他的电脑上改了版本库A，这时，你们两之间只需把各自修改的版本库推送给对方，就可以互相看到对方的修改内容了。

---

![](/assets/0df9740f9b41522ab12c14dbbf6bbad4_hd.jpg)

* **workspace** 就是工作在的目录，每当你在代码中进行了修改，workspace 的状态就改变了。
* **index** 是索引文件，它是连接 workspace 和 repository 的桥梁，当使用`git -add`命令来登记后，index 的内容就同步
* **repository** 是最后的阶段，只有 commit\(**提交**\) 了，代码才真正进入了 git 仓库。我们使用`git commit -m "xxx"`就是将 index 里的内容提交到本地仓库中（push **推送** 之后就到了远程仓库了）。

#### 服务端搭建

```
# useradd git -m -N -s /usr/bin/git-shell
# git init --bare /home/git/source.git
# mkdir /home/git/.ssh
# ssh-keygen -f /home/git/.ssh/git
# cat /home/git/.ssh/git.pub >>/home/git/.ssh/authorized_keys

分发客户端密钥 /home/git/.ssh/git
使用方式 git clone git@192.168.100.3:git
```

#### Git常用命令

用户信息

```
## 设置用户名
$ git config --global user.name [ 用户名 ]

## 设置电子邮件
$ git config --global user.email [ 电子邮件 ]
```

别名相关

```
## 添加远程git地址别名
git remote add [ 别名 ] [ git地址 ]

## 列出远程git地址别名，"-v" 为详细信息
$ git remote -v

## 删除远程git地址别名
$ git remote rm [ 别名 ]
```

比对信息

```
## 比对 workspace 与 index 的差别的
$ git diff

## 比对 index 与 local repositorty 的差别
$ git diff --cached

## 比对 workspace 和 local repository 的差别，（HEAD/master 指向的是 local repository 中最新提交的版本）
$ git diff [ master / HEAD ]
```

本地操作

```
## 保存更新，"." 为全部自动确认，"-i" 为逐个确认
$ git add [ . / -i ]

## 检查更新状态
$ git status

## 提交更新到本地仓库
$ git commit -m [ 更新说明 ]

## 重置 workspace 和 index 到指定提交的版本的状态
$ git reset --hard [ git log id ]
```

远端操作

```
## 克隆远程仓库到本地仓库
$ git clone [ git地址别名 / git地址 ]

## 抓取并合并,相当于 fetch(抓取)+merge(合并)
$ git pull [ git地址别名 / git地址  ] master

## 本地仓库推送到远程仓库
$ git push [ git地址别名 / git地址  ] master
```

分支相关

```
## 列出分支，"-r" 远端 ,"-a" 全部
$ git branch [ -r / -a ]

## 新建分支
$ git branch [ 分支名 ]

## 删除分支
$ git branch -d [ 分支名 ]

## 切换到分支
$ git checkout [ 分支名 ]

## 合并某分支到当前分支
$ git merge [ 分支名 ]
```

---

#### push

本地仓库推送到远程仓库

在执行 pull 之后，进行下一次 push 之前，如果其他人进行了推送内容到远程数据库的话，那么你的 push 将被拒绝。

![](/assets/capture_intro5_1_1.png)

在读取别人 push 的变更并进行合并操作之前，你的push都将被拒绝。

这是因为，如果不进行合并就试图覆盖已有的变更记录的话，其他人push的变更（图中的提交C）就会丢失。

![](/assets/capture_intro5_1_2.png)

![](/assets/截图_2017-11-26_12-58-39.png)

---

#### pull

取得远程git版本数据库

执行前首先确认更新的本地版本数据库没有任何的更改

![](/assets/capture_stepup3_1_1.png)

这时只执行合并

![](/assets/capture_stepup3_1_2.png)

如果本地数据库的 master 分支有新的历史记录，就需要合并双方的修改

![](/assets/capture_stepup3_1_3.png)

执行 pull，如果没有冲突的修改，就可以自动进行合并提交。如果发生冲突的话，要手动解决冲突，再手动提交。

![](/assets/capture_stepup3_1_4.png)

![](/assets/截图_2017-11-26_13-00-53.png)

---

##### 手动解决冲突

如果远程数据库和本地数据库的同一个地方都发生了修改的情况下，因为无法自动判断要选用哪一个修改，所以就会发生冲突。

![](/assets/capture_intro5_1_3.png)

![](/assets/截图_2017-11-26_12-52-42.png)

如下图所示，修正所有冲突的地方之后，执行提交。

![](/assets/capture_intro5_1_4.png)

---

#### 工具使用

* Git
  * 下载：[https://git-scm.com/download/win](https://git-scm.com/download/win)
  * 命令行工具
* TortoiseGit
  * 下载：[https://tortoisegit.org/download](https://tortoisegit.org/download)
  * GUI 工具，依赖 git 命令行

初始化配置，表明自己是谁

![](/assets/254654322532.png)

![](/assets/324143141.png)

首先右键获取远程仓库到本地，成为本地仓库

![](/assets/1231331121.png)

输入远程仓库 URL 获取到本地目录

![](/assets/131241431414.png)

操作成功

![](/assets/52242424234242132.png)

代码修改好了，就要提交到仓库中

![](/assets/1231312414.png)

提交到仓库中，master 表示最主要的一个分支的最新版本 ![](/assets/124135346424.png)

1. 填写提交信息（必须）
2. 提交（提交到本地仓库）、推送（推送到远程仓库）

![](/assets/2525242341.png)

操作成功

![](/assets/12424132.png)

#### 当有多个人协同处理时

在这里有两个一样的版本库，表示有两个工作人员，两台办公计算机![](/assets/214234141.png)在这里他们同时都在最新的版本中修改了文件![](/assets/23525324.png)这时只能由一个先提交推送，另一个后提交推送

第一个提交推送者操作成功，第二个提交推送者报错，这是正常的，如果提交成功，会覆盖上一个提交的文件

![](/assets/21324241431.png)

需要在第二个操作者上 pull 远程库获取合并，再推送

![](/assets/12142341431.png)

获取远程库成功，在 test.html 文件中自动合并失败

![](/assets/41325124.png)

需要手动合并

![](/assets/342432534.png)

看需要该怎么合并，这里修改为：

![](/assets/142341412.png)

保存，然后提交，再推送

![](/assets/23142352.png)

因为已经手动解决了合并的冲突，就直接忽略警告

![](/assets/32534253535.png)

提交并推送到远程库成功

![](/assets/25354625352.png)

注意：多人使用时需要沟通，谁什么时候有没有 push（推送到远程版本库）过，如果有人 push 过，其他人就需要 pull（拉取远程版本库）的最新版本，再编辑文件，需要时才能再 push，否则就需要手动处理合并冲突的文件

#### 回退到指定状态

首先根据提交日志，找到指定状态

![](/assets/242314242.png)

确认回退到这个状态

![](/assets/235342413.png)

会根据由 sha1 计算过的 ID 回退到指定状态

![](/assets/35234132.png)

操作成功

![](/assets/32525224.png)

