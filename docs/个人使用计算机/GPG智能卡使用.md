## Nitrokey 硬件私钥 初始化

这些是必须的操作

1. 下载 [Nitrokey App](https://www.nitrokey.com/download)
2. 更改默认 PIN 码
   ![](GPG智能卡使用.img/Nitrokey-App-change-pin.png)



说明

* 默认 User PIN 是 **123456**
* 默认 Admin PIN 是 **12345678**
* User PIN 只有 **3** 次机会，否则需要使用 Admin PIN 来解锁
* Admin PIN 也只有 **3** 次机会，否则只能 [重置 key](https://www.nitrokey.com/documentation/frequently-asked-questions-faq#how-to-reset-a-nitrokey)





## Nitrokey 硬件私钥 存储密码

某些型号可以存储密码，条目在 10-30 条

![](GPG智能卡使用.img/Nitrokey-App-save-password.png)





---





#### 历史

1. PGP 是一个基于 RSA、AES 算法实现，PGP本身是商业应用程序
2. OpenPGP 是一项开放互联网标准，任何支持这一标准的程序也被允许称作 OpenPGP
3. GnuPG/GPG 是GNU 组织遵循 OpenPGP 技术标准设计，并与 OpenPGP 兼容



在 GPG 中，有主钥和子钥的概念，主钥和子钥都可以指定不同的用途

当使用默认参数生成一对密钥的时候，首先会生成一个主密钥，这个主密钥默认拥有 签名[S]和认证[C] 的用途

同时还会生成一个子密钥，这个子密钥默认用途只有加密[E]

当主密钥对子密钥认证[C]之后，这个子密钥就和主密钥”绑定”在了一起

因此日常的加密和签名操作是更推荐使用子密钥来进行，而主密钥一般情况下不使用





#### 功能

| 简写 | 能力（Capability）/用途（Usage） | 说明                                                 |
| :--: | -------------------------------- | ---------------------------------------------------- |
| [C]  | Certificating                    | 认证其他密钥/给其他证书签名，就像SSL/TLS的根证书一样 |
| [S]  | Signing                          | 签名，比如给文件添加数字签名，给邮件签名，给git签名  |
| [A]  | Authenticating                   | 身份验证/鉴权，比如SSH登陆                           |
| [E]  | Encrypting                       | 加密，比如加密文件、消息                             |





---





## GnuPG 常用命令

* 必用程序 `apt-get -y install gnupg2 scdaemon pcscd dirmngr`
* 如果 `~/.gnupg/` 清空过，则需要运行 `gpgconf --kill gpg-agent`



##### 查看智能卡内容

```text
user@test:~$ gpg --card-status

Reader ...........: Key Name (000000000000000000000000) 00 00
Application ID ...: 00000000000000000000000000000000
Version ..........: 0
Manufacturer .....: Name
Serial number ....: 00000000
Name of cardholder: [not set]
Language prefs ...: en
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 0 0 0
PIN retry counter : 0 0 0
Signature counter : 0
Signature key ....: 0000 0000 0000 0000 0000  0000 0000 0000 0000 0000
      created ....: 2020-00-00 00:00:00
Encryption key....: 0000 0000 0000 0000 0000  0000 0000 0000 0000 0000
      created ....: 2020-00-00 00:00:00
Authentication key: 0000 0000 0000 0000 0000  0000 0000 0000 0000 0000
      created ....: 2020-00-00 00:00:00
General key info..: pub  rsa4096/0000000000000000 2020-00-00 RealName (Comment) <EmailAddress>
sec>  rsa4096/0000000000000000  created: 2020-00-00  expires: never     
                                card-no: 0000 00000000
ssb>  rsa4096/0000000000000000  created: 2020-00-00  expires: never     
                                card-no: 0000 00000000
ssb>  rsa4096/0000000000000000  created: 2020-00-00  expires: never     
                                card-no: 0000 00000000
```



##### 删除智能卡所有数据

```text
user@test:~$ gpg --card-edit

gpg/card> admin
Admin commands are allowed

gpg/card> factory-reset
gpg: OpenPGP card no. D0000000000000000000000000000000 detected

gpg: Note: This command destroys all keys stored on the card!

Continue? (y/N) y
Really do a factory reset? (enter "yes") yes
```



##### 在智能卡上生成私钥

```text
user@test:~$ gpg --card-edit

gpg/card> admin
Admin commands are allowed

gpg/card> generate
Make off-card backup of encryption key? (Y/n) n  ## 这里选择是不备份私钥到计算机 ##
        ┌──────────────────────────────────────────────┐
        │ Please enter the PIN                         │
        │                                              │
        │ PIN ********________________________________ │
        │                                              │
        │      <OK>                        <Cancel>    │
        └──────────────────────────────────────────────┘
What keysize do you want for the Signature key? (4096) 4096       ## 推荐使用这个长度 ##
What keysize do you want for the Encryption key? (4096) 4096      ## 推荐使用这个长度 ##
What keysize do you want for the Authentication key? (4096) 4096  ## 推荐使用这个长度 ##
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0  ## 私钥永不过期 ##
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: ## 推荐填写名字 ##
Email address:  ## 推荐填写邮箱 ##
Comment:  ## 推荐填写备注 ##
You selected this USER-ID:
    "Real name (Comment) <Email address>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
        ┌────────────────────────────────────────────────────┐
        │ Please enter the Admin PIN                         │
        │                                                    │
        │ Admin PIN **********______________________________ │
        │                                                    │
        │       <OK>                            <Cancel>     │
        └────────────────────────────────────────────────────┘
gpg: /home/user/.gnupg/trustdb.gpg: trustdb created
gpg: key 1000000000000000 marked as ultimately trusted
gpg: directory '/home/user/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/user/.gnupg/openpgp-revocs.d/4000000000000000000000000000000000000000.rev'
public and secret key created and signed.
```



##### 导出智能卡公钥

```
gpg --armor --export <pub id>
```



##### 上传gpg公钥到github

1. 登陆 [github.com](https://github.com)
2. 进入 Settings -> SSH and GPG keys -> New GPG key
3. 粘贴gpg公钥字符串并提交
4. 公钥地址就是 `https://github.com/<用户名>.gpg`



##### 智能卡指定公钥url

```text
user@test:~$ gpg --card-edit

gpg/card> admin
Admin commands are allowed

gpg/card> url
URL to retrieve public key: <http://>

```



##### 从github上恢复公钥

```
user@test:~$ gpg --card-edit

gpg/card> fetch
gpg: requesting key from 'https://'
gpg: key 0000000000000000: "Real name (Comment) <Email address>" changed
gpg: Total number processed: 1
gpg:              unchanged: 1
```

