---
title: "关于 GLIBC 版本笔记"
author: "王诗翔"
date: "2020-09-28"
lastmod: "2020-09-28"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["config"]
tags: ["linux", "glibc"]
---

在服务器上测试代码时发现 glibc 版本不够，但我又没有 root 权限。。。。
好像常见的就是找不到 2.14 版本，centos 默认使用的 2.12，这可以通过以下方式检查：

```sh
$ ldd --version
ldd (GNU libc) 2.12
Copyright (C) 2010 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
Written by Roland McGrath and Ulrich Drepper.

$ strings /lib64/libc.so.6 | grep GLIBC_
GLIBC_2.2.5
GLIBC_2.2.6
GLIBC_2.3
GLIBC_2.3.2
GLIBC_2.3.3
GLIBC_2.3.4
GLIBC_2.4
GLIBC_2.5
GLIBC_2.6
GLIBC_2.7
GLIBC_2.8
GLIBC_2.9
GLIBC_2.10
GLIBC_2.11
GLIBC_2.12
GLIBC_PRIVATE
```

glibc 是非常底层的系统库，千万不要自己手动更新，网上有很多教训。

下面是一些有用的博文和讨论：

- <https://stackoverflow.com/questions/35616650/how-to-upgrade-glibc-from-version-2-12-to-2-14-on-centos>
- <https://www.geek-share.com/detail/2775638566.html>

我自己没有手动弄，想使用 conda 直接安装这个库，然后设定库目录 <https://anaconda.org/search?q=glibc>，奇怪的是安装后我看不到有新的版本，而且目前没有一些比较官方的通道 channel 提供这些版本。

突然发现管理员通过 module 提供了更新版本的 glibc，但一载入就报错，系统命令全挂了：

```sh
[wangshx@HPC-login ~]$ module load apps/glib/2.17
whoami: error while loading shared libraries: __vdso_time: invalid mode for dlopen(): Invalid argument
logger: error while loading shared libraries: __vdso_time: invalid mode for dlopen(): Invalid argument
[wangshx@HPC-login ~]$ ls
ls: error while loading shared libraries: __vdso_time: invalid mode for dlopen(): Invalid argument
whoami: error while loading shared libraries: __vdso_time: invalid mode for dlopen(): Invalid argument
logger: error while loading shared libraries: __vdso_time: invalid mode for dlopen(): Invalid argument
```

---

一些备用测试代码：

```sh
module load apps/R/3.6.1
module load apps/glib/2.14
```

```r
library(sigminer)
load(system.file('extdata', 'toy_copynumber_tally_M.RData', package = 'sigminer', mustWork = TRUE))
mat = cn_tally_M[['nmf_matrix']]
sigprofiler_extract(mat, '/tmp/test_sp_install', range = 3:4, nrun = 2L, use_conda = TRUE)
```
