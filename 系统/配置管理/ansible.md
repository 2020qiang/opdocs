检查是否在线

```
ansible all -m ping
ansible 127.0.0.1 -m ping
```

---

执行命令

```
ansible calhost -m shell -a 'id'
ansible calhost -m shell -a 'df -h'
```

---

多线程执行

```
ansible calhost -m ping -f 2
```

---

上传文件

```
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

下载文件

```
ansible all -m copy -a "dest=/root/hosts src=/etc/hosts"
```

---

修改文件的属主和权限

```
ansible webservers -m file -a "dest=/srv/foo/a.txt mode=600"
ansible webservers -m file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
```

创建目录,与执行 mkdir -p

```
ansible webservers -m file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
```

删除目录\(递归的删除\)和删除文件

```
ansible webservers -m file -a "dest=/path/to/c state=absent"
```

---

确认一个软件包已经安装,但不去升级它:

```
$ ansible webservers -m yum -a 
"name=acme state=present"
```

确认一个软件包的安装版本:

```
$ ansible webservers -m yum -a 
"name=acme-1.5 state=present"
```

确认一个软件包还没有安装:

```
$ ansible webservers -m yum -a 
"name=acme state=absent"
```

---

使用 ‘user’ 模块可以方便的创建账户,删除账户,或是管理现有的账户:

```
$ ansible all -m user -a "name=foo password=<crypted password here>"
$ ansible all -m user -a "name=foo state=absent"
```

---

确认某个服务在所有的webservers上都已经启动:

```
$ ansible webservers -m service -a 
"name=httpd state=started"
```

或是在所有的webservers上重启某个服务\(译者注:可能是确认已重启的状态?\):

```
$ ansible webservers -m service -a 
"name=httpd state=restarted"
```

确认某个服务已经停止:

```
$ ansible webservers -m service -a 
"name=httpd state=stopped"
```

---

确认某个服务在所有的webservers上都已经启动:

```
$ ansible webservers -m service -a 
"name=httpd state=started"
```

或是在所有的webservers上重启某个服务\(译者注:可能是确认已重启的状态?\):

```
$ ansible webservers -m service -a 
"name=httpd state=restarted"
```

确认某个服务已经停止:

```
$ ansible webservers -m service -a 
"name=httpd state=stopped"
```

  
