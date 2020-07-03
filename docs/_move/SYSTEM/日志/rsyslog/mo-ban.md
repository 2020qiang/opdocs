模板是rsyslog的一个关键特性。它们允许指定用户可能需要的任何格式

它们也用于生成动态文件名。rsyslog中的每个输出都使用模板 - 这适用于文件，用户消息等

模板由 template\(\) 语句指定。它们也可以通过 $template legacy 语句指定

模板语句的基本结构：

```
template(parameters) { list-descriptions }
```





