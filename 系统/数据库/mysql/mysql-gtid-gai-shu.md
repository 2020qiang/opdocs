## GTID - 全局事务标识符

使用这个功能，每次事务提交都会在 binlog 里生成一个唯一标识符，它由 server\_UUID 加上 事务ID 组成：

* server\_UUID
  * 服务器身份ID，第一次启动会生成一个 server\_uuid 并写入 auto.conf 文件中
  * ```
    [root@localhost ~]# cat /var/lib/mysql/auto.cnf 
    [auto]
    server-uuid=b1c95464-eae8-11e7-a876-525400900450
    ```
* 事务ID
  * 首次提交的 事务ID 为 1，第二次为 2，第三次为 3，以此类推



