* 目的： Windows10 数据安全
* 要求：
  * Windows10 要有 BitLocker 功能
  * YubiKey 有 PIV(smart card) 功能





## 第一次配置 YubiKey

操作：

* [YubiKey Manager](<https://www.yubico.com/products/services-software/download/yubikey-manager/>) 到官网下载管理程序并安装
* 可选： 点击 Interfaces 菜单，只开启 USB PIV
* 更改默认密码： Applications  ->  PIV  ->  PIN Management

说明：

- PIN： 只能错误3次，之后只能用 PUK 解锁
- PUK： 只能错误3次，之后只能 Reset
- Management Key： 管理操作都需要这个密钥
- Reset： 不需要任何密码验证
- 官网： [PIN and Management Key](<https://developers.yubico.com/yubikey-piv-manager/PIN_and_Management_Key.html>)





## 加密数据盘

解密方式：

* 开机自动解密： 系统盘要开启 BitLocker，BitLocker 配置自动解密
* 手动密钥PIN解密



一、YubiKey 生成自签名证书

操作：

* 启动 YubiKey Manager 程序
* 进入  Applications  ->  PIV  ->  Certificates
* 在 Authentication 插槽里， 生成 RSA 自签名证书

说明：

* BitLocker 只支持 RSA 证书
* 默认有效期只有1年，记得调整
* 插槽说明 [Certificate slots](<https://developers.yubico.com/PIV/Introduction/Certificate_slots.html>)



二、Windows10允许自签名证书

* 保存为 `.reg` 文件并执行

```
Windows Registry Editor Version 5.00
 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FVE]
"SelfSignedCertificates"=dword:00000001
```



三、启用 BitLocker + smart card

* 右键磁盘  ->  启用 BitLocker  ->  使用智能卡





## 加密系统盘

* 加密 C 盘

* 允许使用 PIN
  * 运行 gpedit.msc 组策略
  * 计算机配置  ->  管理模板  ->  Windows组件  ->  BitLocker加密  ->  操作系统驱动器
  * 启动时需要附加身份验证
  * 有 TPM 时允许 PIN
* 设置 PIN
  * 控制面板搜索 BitLocker
  * 进入 管理 BitLocker  ->  更改在启动时解锁驱动器的方式  ->  输入 PIN
  * 最长20位数字
* YubiKey 设置 PIN
  * Applications  ->  OTP  ->  Configure  ->  Static Password





> 参考：
>
> [BitLocker 智能卡自签名证书 – Extrawdw](https://blog.extrawdw.net/computer/windows/bitlocker-smartcard-self-signed-certificates/)
>
> [Using Smart Cards with BitLocker | Microsoft Docs](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-7/dd875530(v=ws.10))