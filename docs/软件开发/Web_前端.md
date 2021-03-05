# Web 前端

* 非专业记录





### 安装 typescript

1. 安装 nodejs
   1. 打开 nodejs 的官网 [nodejs.org](https://nodejs.org)
   2. 下载二进制文件 `node-v***-linux-x64.tar.xz`
   3. 解压到 `/opt/nodejs`
   4. 加入到环境变量 `export PATH="${PATH}:/opt/nodejs/bin"`
   5. 查看是否安装成功 `node -v && npm -v`
2. 安装 typescript
   1. 执行 `npm install -g typescript`
   2. 安装目录 `/opt/nodejs/lib/node_modules`
   3. 执行程序 `/opt/nodejs/bin/tsc`



### CSS 样式

```css
/* 横屏 */
@media screen and (orientation: landscape) {
    body { background-color: gray; }
}

/* 竖屏 */
@media screen and (orientation: portrait) {
    body { background-color: gray; }
}

/* 竖屏+小屏 */
@media screen and (orientation: landscape) and (max-width: 500px) {
    body { background-color: gray; }
}
```



### html 标签

```html
<!-- iframe 全屏 -->
<iframe id="ifr"
        src="https://sogou.com"
        style="position:fixed; top:0; left:0; bottom:0; right:0; width:100%; height:100%; border:none; margin:0; padding:0; overflow:hidden; z-index:999999;"
></iframe>
```



### 元素选择器

```js
/* 父iframe获取子iframe元素 */
let ifr = document.getElementById("iframe").contentWindow;
ifr.document.getElementsByTagName("h1");

/* 子iframe获取父iframe元素 */
window.parent.document.getElementById("main");
```



### 页面滚动

```js
/* 在父iframe滚动到子iframe某个元素 */
let ifr = document.getElementById("aaa");
ifr.onload = ifr.contentWindow.scrollTo(0, 100);
```

