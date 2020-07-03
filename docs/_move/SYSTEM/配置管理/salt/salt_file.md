salt.states.file

参考：[https://docs.saltstack.com/en/latest/ref/states/all/salt.states.file.html](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.file.html)

常用方法：

* salt.states.file: 管理文件及目录状态
  * file.managed --&gt; 确保文件存在并且为对应的状态
  * file.recurse --&gt; 确保目录存在并且为对应的状态
  * file.absent --&gt; 确保文件不存在，否则删除
* salt.states.pkg: 管理软件包状态
  * pkg.installed --&gt; 确保包已安装，并且它是正确的版本（如果指定）
  * pkg.latest --&gt; 确保包是最新版本，否则升级
  * pkg.remove --&gt; 卸载已安装的包
  * pkg.purge --&gt; 卸载并清除配置文件
* salt.states.service: 管理软件包状态
  * service.running --&gt; 确保服务处于运行状态（没运行则启动）
  * service.enabled --&gt; 确保服务开机自动启动
  * service.disabled --&gt; 确保服务开机不自动启动
  * service.dead --&gt; 确保服务当前没有运行（运行中则停止）

功能名称：requisites

功能：处理状态间的关系

常用方法：

* require --&gt; 依赖于某个状态
* require\_in --&gt; 被某个状态依赖
* watch --&gt; 关注于某个状态
* watch\_in --&gt; 被某个状态关注



