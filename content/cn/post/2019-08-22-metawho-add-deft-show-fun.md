---
title: "可视化 deft 方法进行的 subgroup 分析结果"
author: "王诗翔"
date: "2019-08-22"
lastmod: "2019-08-22"
slug: ""
categories: [bioinformatics]
tags: ["r", "meta-analysis"]
---


在文章[《谁更能从治疗中获益？》](https://www.jianshu.com/p/54eb91473087)中我讲过 metawho 包的开发由来，但当时遗留了一个问题，就是如何可视化 deft 元分析方法的结果。

之前我提供了使用 metafor 包绘制结果的方法，但这种方法自定义度极高，绘图需要不断摸索调整。

![](https://upload-images.jianshu.io/upload_images/3884693-a8db64cad3567fbe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

刚花费了一天的时间解决这个问题，通过 forestmodel 包用ggplot2实现森林图支持构建了内置于 metawho 包的函数 `deft_show()`。

![](https://upload-images.jianshu.io/upload_images/3884693-dfc89a042090d9e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

完整的例子见[https://shixiangwang.github.io/metawho/articles/metawho.html](https://shixiangwang.github.io/metawho/articles/metawho.html)，我就不翻译了，写博文很费时间。

这个功能需要安装 GitHub 的最新版本，因为我修改了一些 `forestmodel` 包的代码，该包作者没有合并请求和更新到 CRAN，所以暂时我也不能 push 到CRAN上（如果更新，我会修改本文）。

```
remotes::install_github("ShixiangWang/metawho")
```

deft 方法的原理见文章：

```
Fisher, David J., et al. “Meta-analytical methods to identify who benefits most from treatments: daft, 
deluded, or deft approach?.” bmj 356 (2017): j573.
```
