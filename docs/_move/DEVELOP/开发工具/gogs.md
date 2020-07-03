#### 服务端钩子

1. pre-receive** **处理来自客户端的推送操作时最先被调用。
2. update** **它会为每一个准备更新的分支各运行一次。
3. **post-receive  **在整个过程完结以后运行，可以用来更新其他系统服务或者通知用户。

```
[root@test-200-7 ying]# ls
branches  config  description  HEAD  hooks  info  objects  refs
[root@test-200-7 ying]# cd hooks/
[root@test-200-7 hooks]# ls
applypatch-msg.sample  commit-msg.sample  post-commit.sample  post-receive  post-receive.sample  post-update.sample  pre-applypatch.sample  pre-commit.sample  prepare-commit-msg.sample  pre-rebase.sample  update.sample
[root@test-200-7 hooks]# cat post-receive
#!/usr/bin/env bash
touch /root/123-git
```

---

#### gogs 钩子配置

* 钩子文件路径在：**/data/git/gogs-repositories/&lt;用户名&gt;/&lt;仓库名&gt;.git/hooks/post-receive**

  * ```
    #!/usr/bin/env bash
    /usr/bin/sshpass -p U2gLc73B4ewewsPZe7E7kpUN /usr/bin/ssh www@18.136.105.49 'cd /opt/www/newcode && git pull'
    ```

* 钩子文件**允许执行权限**
* 钩子文件内容**命令使用绝对路径**
* 远程执行ssh需要添加如下内容到 **/home/git/.ssh/config**

```
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile    /dev/null
```


