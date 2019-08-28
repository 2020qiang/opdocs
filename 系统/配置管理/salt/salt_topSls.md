在 /etc/salt/master:545\(file\_roots\) 中指定

目录结构

```
├── name.sls
└── top.sls
```

top.sls 使用正则表达式 和 使用 grain

```
base:
  '(one|two).test':
    - match: pcre
    - name
  'os:debian:
    - match: grain
    - apache2
```

name.sls

```
apche-service:
  pkg.installed:
    - names:
      - apache2
      - apache2-dev
      - nginx
  service.rinning:
    - name: nginx
    - enable: True
```



