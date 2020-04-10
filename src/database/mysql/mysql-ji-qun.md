[https://dev.mysql.com/doc/refman/5.7/en/mysql-innodb-cluster-introduction.html](https://dev.mysql.com/doc/refman/5.7/en/mysql-innodb-cluster-introduction.html)

InnoDB集群简介
MySQL InnoDB集群为MySQL提供了一个完整的高可用性解决方案。
MySQL Shell包含AdminAPI，它使您可以轻松配置和管理一组至少三个MySQL服务器实例，以充当InnoDB集群。
每个MySQL服务器实例都运行MySQL组复制，它提供了在InnoDB集群中复制数据的机制，并具有内置的故障转移功能。
AdminAPI不需要直接使用InnoDB集群中的组复制，但是有关更多信息，请参阅 第17章，组解释详细信息的组复制。
MySQL路由器可以根据您部署的集群自动配置自身，将客户端应用程序透明地连接到服务器实例。
如果服务器实例发生意外故障，群集将自动重新配置。在默认的单主模式下，InnoDB集群有一个读写服务器实例 - 主服务器实例。
多个辅助服务器实例是主要的副本。如果主服务器失败，则辅助服务器会自动提升为主服务器的角色。
MySQL路由器检测到这一点并将客户端应用程序转发到新的主要应用程序 高级用户还可以将群集配置为具有多个初选。
![](https://dev.mysql.com/doc/refman/5.7/en/images/innodb_cluster_overview.png)

