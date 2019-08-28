## 判断

#### 数值比较

|         比较          | 详细描述    |
| :-------------------: | :---------- |
| `[[ "n1" -eq "n2" ]]` | n1 == n2    |
| `[[ "n1" -ge "n2" ]]` | n1 &gt;= n2 |
| `[[ "n1" -gt "n2" ]]` | n1 &gt; n2  |
| `[[ "n1" -le "n2" ]]` | n1 &lt;= n2 |
| `[[ "n1" -lt "n2" ]]` | n1 &lt; n2  |
| `[[ "n1" -ne "n2" ]]` | n1 != n2    |

#### 字符串比较

|           比较           | 详细描述              |
| :----------------------: | :-------------------- |
| `[[ "str1" == "str2" ]]` | str1 是否与 str2 相同 |
| `[[ "str1" != "str2" ]]` | str1 是否与 str2 不同 |
|    `[[ -z "str1" ]]`     | str1 的长度是否为 0   |
|    `[[ -n "str1" ]]`     | str1 的长度是否非 0   |

#### 文件比较

|            比较             | 详细描述                                   |
| :-------------------------: | :----------------------------------------- |
|      `[[ -e "file" ]]`      | 检查 file 是否存在                         |
|      `[[ -d "file" ]]`      | 检查 file 是否存在并是一个目录             |
|      `[[ -f "file" ]]`      | 检查 file 是否存在并是一个文件             |
|      `[[ -s "file" ]]`      | 检查 file 是否存在并非空                   |
|      `[[ -r "file" ]]`      | 检查 file 是否存在并可读                   |
|      `[[ -w "file" ]]`      | 检查 file 是否存在并可写                   |
|      `[[ -x "file" ]]`      | 检查 file 是否存在并可执行                 |
|      `[[ -L "file" ]]`      | 检查 file 是否符号链接                     |
|      `[[ -O "file" ]]`      | 检查 file 是否存在并属当前用户所有         |
|      `[[ -G "file" ]]`      | 检查 file 是否存在并且默认组与当前用户相同 |


#### 复合条件测试

###### 是 shell 中的 bool 运算方式

-   `[[ condition1 ]] && [[ condition2 ]]`：等于 AND
-   `[[ condition1 ]] || [[ condition2 ]]`：等于 OR

#### 高级特性

-   用于数学表达式的双括号
-   用于高级字符串的双方括号

##### 双括号

|  符号   | 详细描述 |
| :-----: | :------- |
| `var++` | 后增     |
| `var--` | 后减     |
| `++var` | 先增     |
| `--var` | 先减     |
|  `！`   | 逻辑求反 |
|   `~`   | 位求反   |
|  `**`   | 幂运算   |
|  `<<`   | 左位移   |
|  `>>`   | 右位移   |
|   `&`   | 位比尔和 |
|  `︳`   | 位布尔或 |
|  `&&`   | 逻辑和   |
| `︳︳`  | 逻辑或   |

>   《Linux命令行与shell脚本编程大全 第3版\(图灵设计从书\)》



## 后台/继承

*   `ttt` 后台运行的函数
*   `text` 后台函数需要的变量
*   `export` 导出子进程需要的环境
*   `()$` 使用子进程执行

```shell
#!/usr/bin/env bash

ttt ()
{
    echo "${T}"
}
T="text"

export T
export -f ttt

(
    sleep 1s
    ttt
)&
```





## 加减乘除

#### 基本算数操作

###### 不支持小数、不支持负数

```shell
#!/usr/bin/env bash

var0=2
let var=var0+10
echo ${var}

# 自增/自减
let var++
let var--
```

#### 完整算数操作

###### 加减乘除, 四舍五入, 保留两位小数, awk

```shell
#!/usr/bin/env bash

var1="100"
var2="99"

var="$(echo "${var1} ${var2}" |awk '{
a1 = $1
a2 = $2
a3 = ( a1 - a2 )
a4 = ( a3 - 1 )
printf( "%.2f\n", a4 + 0.005 )
}')"

echo "${var}"
```

###### 五舍六入, 保留两位小数, bc

```shell
#!/usr/bin/env bash

var1="0"
var2="1"

# 保留两位小数
var0="$( bc << EOF
scale = 2
a1 = ( ${var1} + ${var2} )
out = ( a1 + 0.55699 )

if ( length(out)==scale(out) ) {
    print 0
}
print out
EOF
)"

# 五舍六入
var="$(printf "%.2f" "$(echo ${var0})")"
```



#### 进制转换

```shell
$ echo " obase=2; 254 " |bc
11111110

echo " obase=10; ibase=2; 11111110 " |bc
254
```

#### 平方 / 平方根

```shell
$ echo " 2^4 " |bc
16

echo " sqrt(16) " |bc
4
```



## 特殊环境变量

| `$$` | 当前shell的PID                                       |
| :--: | ---------------------------------------------------- |
| `$!` | 上一个后台进程或上一个后台函数的PID                  |
| `$?` | 最后一条命令的退出状态,0表示执行成功,非0表示执行失败 |
| `$0` | 脚本自己名称                                         |
| `$n` | n为数字，代表传给脚本的第n个参数                     |
| `$@` | 参数数组列表                                         |
| `$#` | 传给脚本的参数个数                                   |



## 读取用户输入

```shell
#!/usr/bin/env bash

read -p "Username: " user
printf "My Username is %s !\\n" ${user}

# 隐藏输入内容
read -s -p "Password: " pass
printf "My Password is %s !\\n" ${pass}
```



## 启用跟踪调试脚本

```shell
#!/usr/bin/env bash

set -x
set -v
```



## 表明使用的是systemd还是init

```shell
cat /proc/1/comm
```



## 文件描述符重定向

是进程对其所打开文件的索引，形式上是个非负整数

| 描述符 | 名称         | 缩写   | 默认值 |
| :----- | :----------- | :----- | :----- |
| 0      | 标准输入     | stdin  | 键盘   |
| 1      | 标准输出     | stdout | 屏幕   |
| 2      | 标准错误输出 | stderr | 屏幕   |

简单重定向

```shell
# 不要任何输出
echo 123 >dev/null 2>&1

# 所有输出新建并存储为文件
echo 123 >/log 2>&1

# 输出并存储内容为文件
echo 123 |tee /log
```

>   [`tee`](http://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html) 命令的作用是在不影响原本`I/O`的情况下，将 `stdout` 复制一份到档案去


