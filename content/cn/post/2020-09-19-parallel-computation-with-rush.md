---
title: "使用 rush 进行命令并行处理"
author: "王诗翔"
date: "2020-09-19"
lastmod: "2020-09-19"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["linux"]
tags: ["linux", "rush", "parallel", "shell", "bioinformatics", "golang"]
---


rush 是一个类似于 GNU-parallel 的工具，提供了并行化命令的处理方案。
官方地址是：<https://github.com/shenwei356/rush>，该工具由人称爪哥的生信同行用 Golang 编写而成（强！）。
他开发的其他几个工具也比较有名，如 [seqkit](https://github.com/shenwei356/seqkit)、[csvtk](https://github.com/shenwei356/csvtk)。感兴趣的朋友可以访问他的[博客](https://bioinf.shenwei.me/)。

rush 提供的功能特性非常多，作为技术介绍文，这里我只会简单介绍它的基础核心功能。其他功能读者可以通过 GitHub 官网阅读和学习。

## 下载和安装

- Linux - <http://app.shenwei.me/data/rush/rush_linux_amd64.tar.gz>
- MacOS - <http://app.shenwei.me/data/rush/rush_darwin_amd64.tar.gz>
- Windows - <http://app.shenwei.me/data/rush/rush_windows_amd64.exe.tar.gz> 然后拷贝 rush.exe 到 `C:\WINDOWS\system32`
- Golang - `go get -u github.com/shenwei356/rush/`

对于 Linux 和 MacOS，下载后记得将文件放到 `PATH` 变量支持的目录下或者添加新的 PATH 路径。

## 简单使用

### 简单运行

```sh
$ seq 1 3 | rush echo {}
1
2
3
```

使用 `-k` 保证输出顺序不变，对比下下面两个结果：

```sh
seq 1 10 | rush echo {}
8
1
2
4
7
3
6
5
10
9
                                                                                                         
$ seq 1 10 | rush -k echo {}
1
2
3
4
5
6
7
8
9
10
```

要并行的命令是可以包裹在引号中的，即 `seq 1 10 | rush -k "echo {}"`。

### 通过 `-i` 从文件中读取数据


```sh
$ seq 1 3 > data1.txt
$ seq 4 6 > data2.txt
$ rush echo {} -i data1.txt -i data2.txt
4
6
3
1
2
5
```

这里比较强大在于 `-i` 可以多次使用。

### `-r` 设定重试次数

这个在处理一些涉及联网的操作时应该相当有用。

```sh
seq 1 | rush 'python unexisted_script.py' -r 1
python: can't open file 'unexisted_script.py': [Errno 2] No such file or directory
[WARN] wait cmd #1: python unexisted_script.py: exit status 2
python: can't open file 'unexisted_script.py': [Errno 2] No such file or directory
[ERRO] wait cmd #1: python unexisted_script.py: exit status 2
```

### 一些有用的占位符

- 目录名 `{/}`
- 文件名 `{%}`
- 移除后缀 `{^suffix}`

```sh
$ echo dir/file_1.txt.gz | rush 'echo {/} {%} {^_1.txt.gz}'
dir file_1.txt.gz dir/file
```

- 移除文件名最后的拓展名 `{%.}`
- 移除文件名所有拓展名 `{%:}`

```sh
$ echo dir.d/file.txt.gz | rush 'echo {%.} {%:}'        
file.txt file
```

分别使用 `{.}` 和 `{:}` 会保留目录：

```sh
$ echo dir.d/file.txt.gz | rush 'echo {.} {:}'  
dir.d/file.txt dir.d/file
```

- job id `{#}`
- 域索引 `{N}`

```sh
echo 12 file.txt dir/s_1.fq.gz | rush 'echo job {#}: {2} {2.} {3%:^_1}'
job 1: file.txt file s
```

- 使用正则表达式提取子串 `{@regexp}`

```sh
$ echo read_1.fq.gz | rush 'echo {@(.+)_\d}'
read
```

### `-d` 自定义域分隔符

```sh
$ echo a=b=c | rush 'echo {1} {2} {3}' -d =
a b c
```

### `-D` 自定义记录分隔符

```sh
$ echo a b c d | rush -D " " -k 'echo {}'
a
b
c
d
```

> **记录**理解为数据的行，**域**理解为数据的列。

### `-n` 传递多行数据到命令

```sh
seq 5 | rush -n 2 -k 'echo "{}"; echo'
1
2

3
4

5

```

### `-t` 设定超时

这个功能我自己认为用处不是很大，但对于处理那种长时间生信数据处理来说有时候可能会有发挥的地方。

```sh
$ time seq 1 | rush 'sleep 2; echo {}' -t 1
[ERRO] run cmd #1: sleep 2; echo 1: time out
seq 1  0.00s user 0.00s system 66% cpu 0.005 total
rush 'sleep 2; echo {}' -t 1  0.01s user 0.01s system 2% cpu 1.022 total
```



