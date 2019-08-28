##### Glob（默认）

```
salt '*' test.ping
salt \* test.ping
```

---

##### Perl 语言兼容正则表达式（pcre）

* 短选项：`-E`
* 长选项：`--pcre`

```
salt -E '^[m|M]in.[e|o|u]n$' test.ping
```

---

##### List

* 短选项：`-S`
* 长选项：`--ipcidr`

```
salt -S 192.168.1.2 test.ping
salt -S 192.168.1.0/24 test.ping
```

---

##### Grain

* 短选项：`-G`
* 长选项：`--grain`

```
salt -G 'os:Debian' test.ping
salt -G 'ip_interfaces:eth0:192.168.1.2' test.ping
```

---

##### Grain Pcre（高效）

* 短选项：`null`
* 长选项：`--grain-pcre`

```
salt --grain-pcre 'os:red(hat|flag)' test.ping
```

---

##### Pillar

* 短选项：`-I`
* 长选项：`--pillar`

```
salt -I 'my_var:my_var' test.ping
```

---

##### Compound（混合）

* 短选项：`-C`
* 长选项：`--compound`

```
Shorthand    target
-------------------------
G            grain
E            pcre minion id
P            grain pcre
L            list
I            pillar
S            子网/IP
R            seco范围
```

```
salt -C 'P@os:red(hat|flag),S@192.168.1.0/24' test.ping
```

布尔中的 与（and）、或（or）、非（not）也可在 target 中使用

```
salt -C 'min* or *ion' test.ping
```

---

##### NodeGroup（结点组）

* 短选项：`-N`
* 长选项：`--nodegroup`

配置文件中定义：

```
nodegroups:
    webdev: 'P@os:red(hat|flag),S@192.168.1.0/24'
```

```
salt -N webdev test.ping
```

---

> [《精通 SaltStack》](https://www.amazon.cn/dp/B071S5VM95/ref=sr_1_3?s=digital-text&ie=UTF8&qid=1503833734&sr=1-3&keywords=saltstack)



