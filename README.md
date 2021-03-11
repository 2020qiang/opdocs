# 个人文档





1. 使用 [docs-web项目](https://github.com/2020qiang/docs-web) 构建
   * 纯粹的前端项目
   * 后端数据都是从 github api 获取
2. 使用 [netlify](https://www.netlify.com/) 源站
   * 添加域名绑定白名单
   * 对公网开放 https 443 端口
   * 是自签名证书
3. 使用 [cloudflare](https://www.cloudflare.com/zh-cn/) dns+cdn
   * 开启 dnssec
   * https 响应开启 hsts
   * 公网开放 http+https 的标准端口
   * http 带参数重定向到 https
   * https 经过cloudflare 的cdn 反向代理到源站
   * https 或者 cloudflare 返回边缘节点的缓存



1. 使用 [github](https://github.com/) 托管markdown源码
2. 使用 [typora](https://typora.io/) 文档编辑器


