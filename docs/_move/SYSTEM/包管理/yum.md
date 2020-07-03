# yum



## epel源

```shell
yum install epel-release
```



## 常用命令

```shell
# 列出所有已安装的软件包
yum list installed

# 显示指定包的说明信息
yum info $(package_name)

# 搜索特定字符（包名称、包描述等）
yum search $(package_name)

# 搜索文件名
yum whatprovides 'libpcre.so*'

# 安装/卸载 指定包
yum install $(package_name)
yum install $(package_url)
yum remove  $(package_name)

# 安装指定包组
yum groupinstall $(package_group)

# 更新所有包，连旧的淘汰的包也升级
yum update
yum upgrade

# 清除暂存的文件
yum clean all

# 安装编译环境
yum groupinstall -y 'Development Tools' 'Server Platform Development'
```



## fpm 打包

为多个平台（deb、rpm 等）打包软件包，rpmbuild 是构建包，有所区别

* github：[https://github.com/jordansissel/fpm.git](https://github.com/jordansissel/fpm.git)
* 安装文档： [http://fpm.readthedocs.io/en/latest/installing.html](http://fpm.readthedocs.io/en/latest/installing.html)

安装

```shell
yum install -y ruby-devel gcc make rpm-build rubygems
gem install --no-ri --no-rdoc fpm
fpm --version
```

##### 常用参数

* `-s`：**指定源类型**

  * `dir`：将目录打包成所需要的类型，可以用于源码编译安装的软件包
  * `rpm`：对rpm进行转换
  * `gem`：对rubygem包进行转换
  * `python`：将python模块打包成相应的类型
* `-t`：**指定目标类型**，即想要制作为什么包
  * `rpm`：转换为rpm包
  * `deb`：转换为deb包
  * `solaris`：转换为solaris包
  * `puppet`：转换为puppet模块
* `-n`：**指定包的名字**
* `-v`：**指定包的版本号**
* `-d`：**指定依赖于哪些包**，安装此包前自动安装依赖
* `-f`：第二次打包时目录下如果有同名安装包存在，则覆盖它
* `-p`：要输出的包文件的路径
* ```
  --pre-install    软件包安装完成之前所要运行的脚本；同--before-install
  --post-install   软件包安装完成之后所要运行的脚本；同--after-install

  --pre-uninstall  软件包卸载完成之前所要运行的脚本；同--before-remove
  --post-uninstall 软件包卸载完成之后所要运行的脚本；同--after-remove
  ```

##### 打包实例

分别复制文件到包中的相应位置

```
[user@localhost redis-3.2.11]$ fpm -f -s dir -t rpm -n redis -v 3.2.11 \
>     --pre-install ./pre-install                                     \
>     --post-install ./post-install                                   \
>     --pre-uninstall ./pre-uninstall                                 \
>     --post-uninstall ./post-uninstall                               \
>     src/redis-benchmark=/usr/local/bin/                             \
>     src/redis-check-rdb=/usr/local/bin/                             \
>     src/redis-check-aof=/usr/local/bin/                             \
>     src/redis-server=/usr/local/bin/                                \
>     src/redis-sentinel=/usr/local/bin/                              \
>     src/redis-cli=/usr/local/bin/                                   \
>     redis.conf.default=/etc/redis/redis-server.conf.default         \
>     redis.conf=/etc/redis/redis-server.conf                         \
>     sentinel.conf.default=/etc/redis/redis-sentinel.conf.default    \
>     sentinel.conf=/etc/redis/redis-sentinel.conf                    \
>     init/redis-sentinel=/etc/init.d/                                \
>     init/redis-server=/etc/init.d/

Created package {:path=>"redis-3.2.11-1.x86_64.rpm"}
```

```
yum -y localinstall nginx-1.6.2-1.x86_64.rpm
这个命令会自动先安装rpm包的依赖，然后再安装rpm包。
```

> http://www.zyops.com/autodeploy-rpm

