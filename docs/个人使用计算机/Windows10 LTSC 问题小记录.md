# Windows10 LTSC 问题小记录



### 下载原版镜像

* 我上传的镜像

```
https://download.liuq.org/microsoft.com/windows_10_cn_enterprise_ltsc_2019_x64_dvd_9c09ff24.iso
```

* 来自 msdn.itellyou.cn

```
ed2k://|file|cn_windows_10_enterprise_ltsc_2019_x64_dvd_9c09ff24.iso|4478906368|E7C526499308841A4A6D116C857DB669|/
```



---



### 激活

cmd 运行下面命令

```cmd
slmgr -ipk M7XTQ-FN8P6-TTKYV-9D4CC-J462D
slmgr -skms kms.03k.org
slmgr -ato
```



---



### 安装 Microsoft Store

1. 浏览器打开 <https://aka.ms/diag_apps10> 下载修复程序
2. 按照提示登陆微软帐号
3. 点击修复



