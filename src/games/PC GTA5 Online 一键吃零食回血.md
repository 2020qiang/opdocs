## 一键吃零食回血

1.  安装工具 <https://www.autohotkey.com/download/ahk-install.exe>
2.  保存下面脚本到桌面，并执行
3.  进入游戏后，需要一键吃零食就按键盘 e 按键



## 脚本

```
;; 保存为ahk后缀文件
;; 双击执行

MsgBox, 4, GTA5 一键吃零食, 点击 “是” 之后，本脚本将后台运行
IfMsgBox NO
	Exit

onkey(v,roud=1)
{
    loop, %roud%
    {
		Send, {%v% down}
		sleep 10
		Send, {%v% up}
		sleep 10
    }
}

activ()
{
	onkey("m")
	onkey("Down",3)
	onkey("Enter")
	onkey("Down",2)
	onkey("Enter",2)
	onkey("m")
}


e::      ; e热键
activ()  ; 激活的功能
return   ; 结束热键
```

