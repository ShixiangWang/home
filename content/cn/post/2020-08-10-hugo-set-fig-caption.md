---
title: "Hugo 设置 markdown 图片的标题"
author: "王诗翔"
date: "2020-08-10"
lastmod: "2020-08-10"
slug: ""
categories: ["config"]
tags: ["hugo", "image"]
---

添加文件 `layouts/_default/_markup/render-image.html`，hugo 会在这里寻找模板。

写入下面模板代码：

```html
{{ if .Title }}
  <figure>
    <img src="{{ .Destination | safeURL }}" alt="{{ .Text }}">
    <figcaption>{{ .Title }}</figcaption>
  </figure>
{{ else }}
  <img src="{{ .Destination | safeURL }}" alt="{{ .Text }}">
{{ end }}
```

Markdown 中的图片引用格式如下：

```
![Alt text here](/images/image.jpg "Title here")
```

上面的代码会将 `Title here` 转化为相应图片的标题。

参考：<https://sebastiandedeyne.com/captioned-images-with-markdown-render-hooks-in-hugo/>


