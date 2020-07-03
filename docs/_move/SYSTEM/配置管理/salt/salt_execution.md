#### 远程执行

```
salt 'one.test' cmd.run 'w'
     \__匹配__/
```

cmd.run 权限太高，不推荐使用，为了安全则禁用，在 /etc/salt/master:340 中配置，[参考官网](https://docs.saltstack.com/en/latest/ref/configuration/master.html#publisher-acl-blacklist)

配置黑名单为 publisher\_acl\_blacklist

```
publisher_acl_blacklist:
  modules:
    - cmd.*
```

白名单为 publisher\_acl

```
publisher_acl:
  users:
    - root
```

```
client_acl_verify: True
publisher_acl_blacklist:
  users:
    - root
    - '^(?!sudo_).*$'
  modules:
    - cmd
```

* 目标（Targeting）
  * 匹配
    * 与 Minion ID 相关
      * 通配符（Globbing）
        * _\*_ -------&gt;  表示 0 或多个任意字符
        * ? -------&gt; 表示 1 个任意字符
        * \[1-3\] --&gt; 表示 1~3
        * \[!1\] ----&gt; 表示不是 1
      * 列表（List）
        * 使用 -L 指定匹配值为列表
          * `salt -L 'one.test,two.test' test.ping`
      * 正则表达式（Regex）
        * 使用 -E 指定匹配值为正则
          * `salt -E '(one|two).test' test.ping`
    * 与 Minion ID 无关
      * IP 地址/子网
        * 使用 -S 指定匹配值为 IP 或网段
          * `salt -S 192.168.1.202 test.ping`
          * `salt -S 192.168.1.200/24 test.ping`
      * Grains 参考以上 \[数据系统 Grains\]
      * Pillar    参考以上 \[数据系统 Pillar\]
      * 复合匹配（混合匹配）（Compound matchers）
        * 使用 -S 指定匹配值为复合匹配
          | Letter | 含义 | 例子 |
          | :--- | :--- | :--- |
          | G | Grains glob 匹配 | G@os:debian |
          | E | PCRE Minion ID 匹配 | E@web\d+.\(dev\|proc\).loc |
          | P | Grains PCRE 匹配 | P@os:\(debian\|gentoo\) |
          | L | minions 列表 | L@one.test,two,test |
          | I | Pillar glob 匹配 | l@group:nginx |
          | S | IP/子网或网段匹配 | S@1.1.1.1 \[or\] S@1.1.1.0/12 |
          | R | Range cluster 匹配 | R@%foo.bar |
          | D | Ｍinion Data 匹配 | D@Key:Value |
      * 节点组（Node groups）
        * 在 /etc/salt/master:1016 中定义
      * 批处理执行（Batching execution）
        * 使用 -b \[数字\] 指定匹配值为复合匹配
          * 同一时刻仅仅执行 2 台机器
            * `salt '*' -b 2 test.ping`
* 模块（Module） [官网](https://docs.saltstack.com/en/latest/ref/modules/all/)
  * 常用模块
    * network 网络模块
    * service 服务模块
    * state 状态模块
* 返回（Returnners）
  * 可将返回值写入 SQL 中
  * [http://edu.51cto.com/lesson/id-44038.html](http://edu.51cto.com/lesson/id-44038.html)

Minion ID：是 minion 主机的唯一标识符

默认是没在 /etc/salt/minion:103 中配置，因此它是使用  minion FQDN\(Fully Qualified Domain Name\)，因为 salt-key 是使用 Minion ID 来认证，且对应 Minion Host 的公钥存在 /etc/salt/pki/master/minions 目录中，公钥的名称就是 Minion ID，所以 Minion ID 最好不要变动。如果需要变动 Minion ID，则要重新使用 salt-key 认证新 minions 的公钥

