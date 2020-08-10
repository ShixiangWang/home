---
title: "通过公钥无法免密登录远程服务器"
author: "王诗翔"
date: "2020-08-10"
lastmod: "2020-08-10"
slug: ""
categories: ["linux"]
tags: ["ssh", "公钥"]
---

如果我们已经在服务器上配置好了公钥，那么这种问题基本上是服务器目录权限导致的。

ssh 为了保证通讯安全，设置了非常严格的目录权限。

```sh
chmod 755 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

上面有一个不满足都无法通过免密登录。

