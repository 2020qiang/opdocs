[SED单行脚本快速参考](http://sed.sourceforge.net/sed1line_zh-CN.html)（[http://sed.sourceforge.net/sed1line\_zh-CN.html）](http://sed.sourceforge.net/sed1line_zh-CN.html）)

#### 命令行参数

```
-r         使用扩展的正则表达式
-i         直接修改源文件
-i.bak     直接修改源文件前备份源文件
-c         不改变源文件的文件描述符
```

#### 分隔符

通常使用 "\#" 和 "/"（除反斜杠或换行符之外的任何字符）

```
[2addr] s/BRE/replacement/flags

Substitute the replacement string for instances of the BRE in the pattern space. 
Any character other than backslash or newline can be used instead of a slash to 
delimit the BRE and the replacement. Within the BRE and the replacement, the BRE 
delimiter itself can be used as a literal character if it is preceded by a backslash."
```

---

##### 替换字符

```
cat > filename << EOF
1111
1111
3333
3333
EOF

sed "s/1111/2222/g" filename
sed "s#1111#2222#g" filename
sed "s/1111/2222/" filename
sed "s#1111#2222#" filename
sed -i.bak "s#1111#2222#" filename
```

* 在file-name中：
* -i 直接修改文件
* s 代表替换
* 把1111替换成2222
* g 代表替换所有匹配

### 插入

字符

```
sed -i '/1111/a\2222' filename
```

* 在file-name中：
* 把1111替换成2222
* a 表示插入

在指定行下面插入一行数据

```
line=10
sed -i "${line}i UseDNS no"
```

在指定行上面添加一行数据

```
line=10
sed -i "${line}a UseDNS no"
```

修改指定行行首插入 \# 字符串

```
line=10
sed -i "${line}s/^/#/"
```

修改指定行行尾添加 \# 字符串

```
line=10
sed -i "${i}s/$/#/"
```

匹配指定行范围

```
$ sed '1,19{s/old/new/g}'
```

---

### 删除

删除含指定字符串的行

```
sed '/abc/d;/efg/d' a.txt
```

删除文件开头总行的一半，并保留inode

```
sed -i -c "1,$(($(wc -l $file|awk '{print $1}')/2))d" file
```

删除含pattern的行。当然pattern

```
sed '/pattern/d'
```

---

查看本机指定接口的IP

```
ip addr show dev enp3s0 |grep 'inet ' |sed -r 's#.+ ([0-9\.]+).+#\1#g'
```



