---
title: "安装 Rmpi 包"
author: "王诗翔"
date: "2020-11-23"
lastmod: "2020-11-23"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["config"]
tags: ["r", "MPI", "并行计算"]
---

### 下载包

```sh
wget -c https://cran.r-project.org/src/contrib/Rmpi_0.6-9.tar.gz
```

> 此处可以换不同的源，最新版本也可能不同。

### CentOS 下安装

```sh
# 先安装依赖库
sudo yum install openmpi-devel
# 安装
# ld -lmpi --verbose
R CMD INSTALL Rmpi_0.6-9.tar.gz --configure-args="--with-Rmpi-include=/usr/include/openmpi-x86_64/  --with-Rmpi-libpath=/usr/lib64/openmpi/lib --with-Rmpi-type=OPENMPI"
```

如果存在编译问题，查看 <http://fisher.stats.uwo.ca/faculty/yu/Rmpi/> 文档看看有什么解决方案。
我在安装的过程中主要是碰到找不到动态库和头文件两个问题。

如果需要本地调用 openmpi 可以增加下面两个环境变量到 `~/.bashrc`：

```sh
export PATH=$PATH:/usr/lib64/openmpi/bin
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:${LD_LIBRARY_PATH}
```

### MacOS 下安装

基本安装官方文档 <http://fisher.stats.uwo.ca/faculty/yu/Rmpi/mac_os_x.htm> 就应该没啥问题。

简单分为下面几个步骤：

1. 安装 `gcc`：`brew install gcc`
2. 安装 `openmpi`：`brew install open-mpi`
3. 配置一下：`brew link --overwrite open-mpi`
4. R 里面安装包 `install.packages("Rmpi", type="source")`，如果命令行中安装，使用 `R CMD INSTALL Rmpi_0.6-9.tar.gz --configure-args=--with-mpi=/usr/local/Cellar/open-mpi/4.0.5/`。

我自己安装时碰到默认 R 编译使用的 MacOS 平台的 clang++，如果有问题，需要简单配置下。

1. 在 RStudio 中运行 `file.edit("~/.R/makevars")` 打开 `~/.R/makevars` 文件。
2. 输入 `CC=gcc` （如果已经存在 `CC=xx`，则进行修改）。
3. 保存文件重新安装即可。

如果在测试使用时出现下面错误：

```
Error in mpi.comm.spawn(slave = rscript, slavearg = args, nslaves = count,  : 
  MPI_ERR_SPAWN: could not spawn processes
```

参考这篇帖子解决：<https://stackoverflow.com/questions/46541301/new-install-dompi-throwing-mpi-err-spawn-error>。

### 最后

Windows 安装见 <http://fisher.stats.uwo.ca/faculty/yu/Rmpi/windows.htm>。

本来想利用这个包支持 HPC 跨节点计算，测试发现安装和运行效率没有我详细中的好和高，弃疗。

