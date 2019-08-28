```
ntpd:
  service.running:
    - watch:
      - file: /etc/ntp.conf
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://ntp/files/ntp.conf
```

**watch**：检查 file 字典中的文件是否被更改，否则重新加载 ntp

---

```
django:
  pip.installed:
    - name: django >= 1.6, <= 1.7
    - require:
      - pkg: python-pip
```

**require**：检查 pkg 字典中的包是否安装，否则安装 python-pip

---

state的逻辑关系列表

```
watch： 在某个state变化时运行此模块
require： 依赖某个state，在运行此state前，先运行依赖的state，依赖可以有多个
match: 配模某个模块，比如 match: grain match: nodegroup
order： 优先级比require和watch低，有order指定的state比没有order指定的优先级高
```

> [http://www.361way.com/salt-states/5350.html](http://www.361way.com/salt-states/5350.html)



