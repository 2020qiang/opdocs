#### 使用状态模块，也可称为状态管理

状态：服务器上的用户、文件、文件内容、运行的程序

构建在**远程执行**之上的框架，祢补了 cmd.run 的不足，有很大的灵活及拓展性，可配置管理千上万的主机

| file\_roots | 设置状态文件位置 |
| :--- | :--- |
| env | Base 环境、开发环境、测试环境、预生产环境、生产环境 |
| sls | YAML格式、jinja、编写技巧 |
| state 模块 | [file](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.file.html)、[pkg](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.pkg.html)、[service](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.service.html)、[cmd](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.cmdmod.html) |
| state 关系 | require、require\_in、watch、unless、onlyif |
| 案例 | LAMP、LNMP、Zabbix、Haproxy+keepalived |
| 实战 | Openstack 自动化部署 |

#### 编写 sls 技巧

主要操作是编写状态描述文件 sls，sls 文件中描述了各种主要信息









