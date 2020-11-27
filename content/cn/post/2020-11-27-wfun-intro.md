---
title: "使用 wfun 加速 GitHub 包安装和仓库克隆"
author: "王诗翔"
date: "2020-11-27"
lastmod: "2020-11-27"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["r", "github", "gitee"]
---

在国内下载 GitHub R 包或者克隆仓库经常失败，虽然在 Gitee 上设置镜像是一个不错的办法，但总是这么操作也挺麻烦了。今天分享一个解决的办法，就是使用我新写的 R 包啦！这个包使用了国人提供的 GitHub 镜像 [FastGit](https://doc.fastgit.org/zh-cn/guide.html) （在此致谢），所以下载就快很多了。

## 安装

使用下面命令从 Gitee 上安装该包：

``` r
remotes::install_git("https://gitee.com/ShixiangWang/wfun")
```

载入：

``` r
library(wfun)
```

## 例子

### 安装 GitHub/Gitee 仓库中的 R 包
``` r
install("ShixiangWang/ezcox")
install("ShixiangWang/tinyscholar", gitee = TRUE)
```

为了更通用，我加了一些其他安装包的封装，所以 `install()` 也可以用来安装普通的包。

``` r
install(c("ggplot2", "Biobase"))
```

### 克隆 GitHub/Gitee 仓库

需要注意，克隆到的本地目录事先不能存在，一般是设定一个同名目录。

``` r
x <- file.path(tempdir(), "ezcox")
if (dir.exists(x)) rm_paths(x)
clone("ShixiangWang/ezcox", x, reset_remote = TRUE)
#> Treat input as a GitHub repo.
#> cloning into '/var/folders/bj/nw1w4g1j37ddpgb6zmh3sfh80000gn/T//Rtmp0sCShM/ezcox'...
#> Receiving objects:   1% (9/814),   31 kb
#> Receiving objects:  11% (90/814),   31 kb
#> Receiving objects:  21% (171/814),   47 kb
#> Receiving objects:  31% (253/814),   63 kb
#> Receiving objects:  41% (334/814),   95 kb
#> Receiving objects:  51% (416/814),  143 kb
#> Receiving objects:  61% (497/814),  191 kb
#> Receiving objects:  71% (578/814), 1007 kb
#> Receiving objects:  81% (660/814), 1775 kb
#> Receiving objects:  91% (741/814), 3198 kb
#> Receiving objects: 100% (814/814), 3640 kb, done.
#> Reset remote url to https://github.com/ShixiangWang/ezcox

y <- file.path(tempdir(), "tinyscholar")
if (dir.exists(y)) rm_paths(y)
clone("ShixiangWang/tinyscholar", y, gitee = TRUE)
#> cloning into '/var/folders/bj/nw1w4g1j37ddpgb6zmh3sfh80000gn/T//Rtmp0sCShM/tinyscholar'...
#> Receiving objects:   1% (4/313),   19 kb
#> Receiving objects:  11% (35/313),   27 kb
#> Receiving objects:  21% (66/313),  147 kb
#> Receiving objects:  31% (98/313),  331 kb
#> Receiving objects:  41% (129/313),  411 kb
#> Receiving objects:  51% (160/313),  539 kb
#> Receiving objects:  61% (191/313),  595 kb
#> Receiving objects:  71% (223/313),  642 kb
#> Receiving objects:  81% (254/313),  650 kb
#> Receiving objects:  91% (285/313),  658 kb
#> Receiving objects: 100% (313/313),  719 kb, done.
```

### 下载 GitHub/Gitee 仓库的发布和存档文件

``` r
x <- tempdir()
download("ShixiangWang/tinyscholar", destdir = x)
#> Downloading repo archive...
dir(x)
#> [1] "ezcox"       "master.zip"  "tinyscholar"
```


> 如果该包对你有用，请点个 star <https://github.com/ShixiangWang/wfun>

