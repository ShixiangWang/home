---
title: "使用 Git 存储大文件"
author: "王诗翔"
date: "2020-12-07"
lastmod: "2020-12-07"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["config"]
tags: ["git-lfs", "gitter"]
---

如果你是一个 gitter，你可能会遇到我今天遇到的问题。

### git push 文件太大报警告

当在 Git 仓库中存储大的二进制文件时（>50MB），比如 R 里面的 RData 或 RDS 文件，默认的 git 提交方式无法获取二进制文件的修改，会让仓库越来越大。在这种情况下，将仓库 push 到远程会出现警告。

```
$ git push
Counting objects: 15, done.
Delta compression using up to 24 threads.
Compressing objects: 100% (15/15), done.
Writing objects: 100% (15/15), 58.66 MiB | 1.46 MiB/s, done.
Total 15 (delta 6), reused 0 (delta 0)
remote: Resolving deltas: 100% (6/6), completed with 4 local objects.
remote: warning: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
remote: warning: See http://git.io/iEPt8g for more information.
remote: warning: File xx.rds is 54.69 MB; this is larger than GitHub's recommended maximum file size of 50.00 MB
To https://github.com/ShixiangWang/XX.git
   9a93595..fff62d7  master -> master
```


### 我之前的解决办法

既然文件很大，那就不要将它存储在 Git 仓库中了，提前将文件名写入 `.gitignore` 可以将其忽略掉。但有时候没这么简单，我们也没那么细心，如果已经将大文件添加到 git 仓库中了怎么办呢？

可以使用下面的命令将文件 `var/log/system.log` 从 git 仓库中移除：

```
git filter-branch --index-filter 'git rm --cached --ignore-unmatch var/log/system.log' --tag-name-filter cat -- --all
```

### 如果想存储文件怎么办

根据前面出现的警告我们知道有个 git-lfs 的工具可以解决这个问题。

> Large files detected. You may want to try Git Large File Storage - <https://git-lfs.github.com>

那么 git-lfs 是什么呢？

> Git 大文件存储（Large File Storage，简称LFS）目的是更好地把大型二进制文件，比如音频文件、数据集、图像和视频等集成到 Git 的工作流中。我们知道，Git 存储二进制效率不高，因为它会压缩并存储二进制文件的所有完整版本，随着版本的不断增长以及二进制文件越来越多，这种存储方案并不是最优方案。而 LFS 处理大型二进制文件的方式是用文本指针替换它们，这些文本指针实际上是包含二进制文件信息的文本文件。文本指针存储在 Git 中，而大文件本身通过HTTPS托管在Git LFS服务器上。

一个更清晰的简介如下：

> 对于包涵大文件（尤其是经常被修改的大文件）的项目，初始克隆需要大量时间，因为客户端会下载每个文件的每个版本。Git LFS（Large File Storage）是由 Atlassian, GitHub 以及其他开源贡献者开发的 Git 扩展，它通过延迟地（lazily）下载大文件的相关版本来减少大文件在仓库中的影响，具体来说，大文件是在 checkout 的过程中下载的，而不是 clone 或 fetch 过程中下载的（这意味着你在后台定时 fetch 远端仓库内容到本地时，并不会下载大文件内容，而是在你 checkout 到工作区的时候才会真正去下载大文件的内容）。

![](https://pic3.zhimg.com/80/v2-ba2b7ea48f0a48396fe656657ee19682_1440w.jpg)

![](https://pic3.zhimg.com/80/v2-546c2213c530bb6b1e61c377d5225a16_1440w.jpg)

![](https://pic3.zhimg.com/80/v2-805341628b82fdd7a68876d9e953aa46_1440w.jpg)

### 如何使用 git-lfs

#### 安装

安装很简单，我们可以上 <https://github.com/git-lfs/git-lfs> 查看不同系统怎么安装。像 linux 操作系统可以直接通过包管理器安装，例如 CentOS 上是 `yum install git-lfs`。

#### 使用

> 假设你目前位于 git 仓库中。

命令形如 `git lfs track "*.rds"`，它就可以标记和追踪所有 rds 后缀名文件，并将其通过 lfs 技术进行存储和传输。

使用上面命令后，在通过下面的命令提交修改。

```
$ git add .gitattributes
$ git commit -m "track *.rds file using Git LFS"
```

后面就可以常规使用 `git add` 和 `git commit` 了，例如

```
$ git add xx.rds
$ git commit -m "add xx.rds"
$ git push
```

#### 迁移

如果你想将仓库里已经存储的文件修改存储方式为 LFS，那么使用下面的命令进行迁移：

```
git lfs migrate import --include="*.rds" --everything
migrate: Sorting commits: ..., done.                                                                                    
migrate: Rewriting commits: 100% (12/12), done.                                                                         
  master	fff62d77ddfa2a58e87bb88a77857e7d73ca1f6d -> 3f71d46858f3140fbe70a5d9804a3c43fd2e6dbf
migrate: Updating refs: ..., done.                                                                                      
migrate: checkout: ..., done.      
```

如果你想要查看哪些文件格式占据的空间比较大，使用下面的命令：

```
$ git lfs migrate info
migrate: Fetching remote refs: ..., done.                                                                               
migrate: Sorting commits: ..., done.                                                                                    
migrate: Examining commits: 100% (12/12), done.                                                                         
*.xena	12 MB 	  1/1 files(s)	100%
*.gz  	11 MB 	  3/3 files(s)	100%
*.xlsx	9.4 MB	  7/7 files(s)	100%
*.csv 	4.7 MB	  7/7 files(s)	100%
*.css 	2.1 MB	21/21 files(s)	100%
```

####  git pull 碰到拒绝合并无关历史

当使用 git push 后，再拉取更新可能会出现拒绝合并无关历史的情况，可以使用下面的命令解决：

```
git pull origin master --allow-unrelated-histories 
```

如果发现仓库中的文件大小不对，使用 `git lfs install` 初始化，然后拉取 `git lfs pull`。


#### 取消文件最终

```
git lfs untrack '<file-type>'
git rm --cached '<file-type>'
git add '<file-type>'
git commit -m "restore '<file-type>' to git from lfs"
```

可以进一步使用 `git lfs prune` 清除本地缓存文件。


参考：

- <https://jakciehoo.github.io/2017/03/18/2017-03-18-Git-LFS/>
- <https://zhuanlan.zhihu.com/p/146683392>
- <https://blog.csdn.net/aixiaoyang168/article/details/76012094>
- <https://stackoverflow.com/questions/22227851/error-while-pushing-to-github-repo>
- <https://stackoverflow.com/questions/35011366/move-git-lfs-tracked-files-under-regular-git>
