---
title: "CentOS 安装和管理 Shiny Server"
author: "王诗翔"
date: "2020-11-24"
lastmod: "2020-11-24"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["r", "shiny", "server"]
---


## 安装

```sh
sudo yum install R
sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

wget -c https://download3.rstudio.org/centos6.3/x86_64/shiny-server-1.5.15.953-x86_64.rpm
sudo yum install --nogpgcheck shiny-server-1.5.15.953-x86_64.rpm
```

## 管理

文档是 <https://docs.rstudio.com/shiny-server/>，有经验再写。

后续参考下：https://www.jianshu.com/p/0d077bfa413b 

