## **Apache Guacamole**

##### 是基于 html 5 的无客户端远程桌面网关，它支持标准协议，如 VNC、RDP、SSH

#### 组件

* **guacd**：守护进程，由 guacamole 的服务源构建，支持 VNC、RDP、SSH、telnet
* **guacamole**：web 应用程序，在 jdk tomcat8 中运行的，并支持 websocket

---

#### jar 环境

```
https://www.java.com/zh_CN/download/linux_manual.jsp
```

环境变量

```
# vi /etc/profile
export JAVA_HOME=/opt/jar
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
# source /etc/profile
```

验证

```
# java -version
java version "1.8.0_151"
Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)
```

---

#### tomcat 环境

```
http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz
```

环境变量

```
# vi /etc/profile
export CATALINA_HOME=/opt/tomcat
# source /etc/profile
```

基础配置

```
# vi $CATALINA_HOME/bin/catalina.sh
# 找到 OS specific support，然后在这行下面添加以下配置
CATALINA_HOME=/opt/tomcat
JAVA_HOME=/opt/jdk
```

##### 配置 HTTP2 TLS\(pem 格式\)

```
# yum install -y gcc apr-devel openssl-devel
$ tar -xvf $CATALINA_HOME/bin/tomcat-native.tar.gz
$ cd tomcat-native-1.2.14-src/native/
$ ./configure --prefix=$CATALINA_HOME --with-java-home=$JAVA_HOME --with-ssl=yes
$ make
# make install
```

```
# vi $CATALINA_HOME/bin/setenv.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib
# chmod u+x $CATALINA_HOME/bin/setenv.sh
```

```
# vi /opt/tomcat/conf/server.xml
<Connector
        port="24"
        secure="true"
        protocol="org.apache.coyote.http11.Http11AprProtocol"
        SSLEnabled="true">
        <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol"/>
        <SSLHostConfig>
                <Certificate
                        certificateKeyFile="conf/server.key"
                        certificateFile="conf/server.crt" />
        </SSLHostConfig>
</Connector>
```

配置服务

```
# cp $CATALINA_HOME/bin/catalina.sh /etc/init.d/tomcat
# chmod u+x /etc/init.d/tomcat
# chkconfig tomcat on
```

> ```
> http://tomcat.apache.org/native-doc/
> https://zhuanlan.zhihu.com/p/21349186
> https://stackoverflow.com/questions/30855281/tomcat-support-for-http-2-0
> https://tomcat.apache.org/tomcat-8.5-doc/config/http.html#SSL_Support_-_SSLHostConfig
> ```

---

#### 部署 guacamole.client

guacamole clent 含有 guacamole（所有 java 和 JavaScript 组件）。这些组件最终构成将为连接到服务器的用户提供 HTML5 g uacamole 客户端的 Web 应用程序。这个 Web 应用程序将然后连接到 guacd 的一部分，鳄梨服务器代表连接的用户，以满足他们，他们有权访问的任何远程桌面。

```
# service tomcat stop
$ wget -c https://sourceforge.net/projects/guacamole/files/current/binary/guacamole-0.9.13-incubating.war
# rm -rf /opt/tomcat/webapps/*
# mkdir /opt/tomcat/webapps/ROOT
# unzip guacamole-0.9.13-incubating.war -d /opt/tomcat/webapps/ROOT
# service tomcat start
```

```
# vi /etc/profile
export GUACAMOLE_HOME=/opt/guacamole
# source /etc/profile
```

```
# mkdir $GUACAMOLE_HOME
# vi $GUACAMOLE_HOME/guacamole.properties
available-languages:    en, de
guacd-hostname:         127.0.0.1
guacd-port:             4822
user-mapping: /opt/guacamole/user-mapping.xml
```

```
# vi $GUACAMOLE_HOME/user-mapping.xml
<user-mapping>

        <!-- password= password -->
        <authorize
        username="user"
        password="password">
                <protocol>rdp</protocol>
                <param name="hostname">192.168.122.100</param>
                <param name="port">3389</param>
                <param name="username">admin</param>
                <param name="password">admin</param>
        </authorize>

        <!-- password= password -->
        <authorize
        username="user"
        password="76A2173BE6393254E72FFA4D6DF1030A"
        encoding="md5">

                <!-- one connection -->
                <connection name="localhost">
                        <protocol>rdp</protocol>
                        <param name="hostname">192.168.122.100</param>
                        <param name="port">3389</param>
                </connection>

                <!-- one connection -->
                <connection name="localhost2">
                        <protocol>rdp</protocol>
                        <param name="hostname">192.168.122.100</param>
                        <param name="port">3389</param>
                </connection>
        </authorize>

</user-mapping>
```

---

#### 部署 guacamole.server

```
# yum install -y cairo-devel libjpeg-turbo-devel libjpeg-devel libpng-devel uuid-devel freerdp-devel openssl-devel libvorbis-devel libwebp-devel
$ links https://guacamole.incubator.apache.org/releases/0.9.13-incubating/
$ tar -xvf guacamole-server-0.9.13-incubating.tar.gz
$ cd guacamole-server-0.9.13-incubating
$ ./configure --with-init-dir=/etc/init.d
$ make
$ make install
# ldconfig
# /etc/init.d/guacd start
# vi /etc/init.d/tomcat
添加
# chkconfig:   2345 20 80
# chkconfig guacd on
```

