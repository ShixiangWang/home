---
title: "浏览器 R 搜索插件"
author: "王诗翔"
date: "2020-09-09"
lastmod: "2020-09-09"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["r", "chrome", "extension", "stackoverflow", "wechat"]
---

`r-search-extension` 是一款浏览器插件，它支持搜索 R 文档/问题以及微信平台搜索。它的使用及其简单，在浏览器搜索栏输入 `r` 然后跟一个空格，接着输入你想要搜索的关键词即可。

## 安装

去版本[发布页面](https://github.com/ShixiangWang/r-search-extension/releases)下载 `extension.zip` 文件，然后手动安装到谷歌或微软 Edge 浏览器。

也可以通过坚果云下载：<https://www.jianguoyun.com/p/Dde3c80Q6uuVCBj4s7oD>

注意，读者需要打开浏览器的开发者模式，然后指定解压缩后的目录进行安装，记得不要删除解压后的目录，最好把它和你的其他软件根目录放到一起。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200908234352.png)

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200908234455.png)

## 使用

输入关键字 **r**，然后敲入一个空格，接着输入想要查询的文档或包，浏览器会自动跳转到搜索页面。

#### 可使用的命令

> 下面的 `<space>` 指代空格键。

- `r<space>keywords` 默认选项，会搜索 R 包/函数文档。
- `r<space>!keywords` 仅搜索 R 包。
- `r<space>?keywords` 搜索 Stack Overflow 上有 r 标签的问题和回答。
- `r<space>?all:keywords` 搜索 Stack Overflow 搜有的问题和回答。
- `r<space>/keyword` 搜索微信公众号文章。
- `r<space>:help` 展示可使用的命令。

### 例子

默认使用方式，基本上用这个就足够了。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200909123420.png)

搜索相关文档。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200908234841.png)

搜索相关包。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200908234652.png)

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200908234946.png)

搜索 R 相关问题。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200909123528.png)

搜索微信公众号。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200909123628.png)


## 致谢

- https://rdrr.io/
- [huhu](https://github.com/huhu/search-extension-core)


