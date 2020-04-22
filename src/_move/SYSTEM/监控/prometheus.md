#### Prometheus 是 Apache v2.0 开源协议发布的 监控告警解决方案

是一个独立的开源项目，并且独立于任何公司，[https://github.com/prometheus/prometheus](https://github.com/prometheus/prometheus)

大多数Prometheus组件都是用Go编写的，因此它们很容易构建和部署为静态二进制文件

* 数据是基于时序的 float64 的值
* 数据将不会长久存储
* 采用 http 协议，简单易懂
* 使用 pull 模式，拉取数据
* 可以采用服务发现的方式
* 多种统计数据模型，图形化友好
* 灵活的查询语句（PromQL）

#### 架构图：

![](/assets/architecture.svg)

