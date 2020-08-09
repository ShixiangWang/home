---
title: "使用 Docker run 覆盖 ENTRYPOINT"
author: "王诗翔"
date: "2020-08-06"
lastmod: "2020-08-06"
slug: ""
categories: [docker]
tags: [docker, entrypoint]
---

原文：<https://phoenixnap.com/kb/docker-run-override-entrypoint>

> 分享此文的原因在于当在 Docker 文件中使用 Entrypoint 后，无法直接运行 `docker run -it container` 进入交互式终端。

为了演示如何覆盖 entrypoint 命令，我们将运行一个结合了 CMD 和 entrypoint 的 hello world 容器。

下面是 Dockerfile 的内容，`ENTRYPOINT` 命令定义了可执行文件，而 `CMD` 设置了默认参数。

```docker
FROM ubuntu
MAINTAINER sofija
RUN apt-get update
ENTRYPOINT [“echo”, “Hello”]
CMD [“World”]
```

如果构建一个镜像并生成一个容器运行，得到：

![Docker ENTRYPOINT vs CMD instructions combined.](https://phoenixnap.com/kb/wp-content/uploads/2020/02/run-docker-container-with-entrypoint-and-cmd-instructions.png)

你可以非常简单地通过设置参数来覆盖掉默认 CMD 指定的参数，格式如下：

```sh
sudo docker run [container_name] [new_parameter]
```

一个示例：

![Adding parameters to a docker run command to run a container with ENTRYPOINT and CMD instructions.](https://phoenixnap.com/kb/wp-content/uploads/2020/02/running-a-docker-container-with-additional-parameters.png)

**然而**，你可能想要覆盖掉默认的可执行文件，例如在一个容器中运行 Shell。这个时候，我们需要显式地指定 `--entrypoint` 标志，语法如下：

```sh
sudo docker run --entrypoint [new_command] [docker_image] [optional:value]
```

例如，我们要覆盖掉上面的 `echo` 命令，执行 shell：

```sh
sudo docker run -it --entrypoint /bin/bash [docker_image]
```

输出告诉了我们已经身处容器之中：

![Run Docker container by overriding entrypoint command and opening container shell.](https://phoenixnap.com/kb/wp-content/uploads/2020/03/override-entrypoint-with-docker-run-command.png)

> 小结一下，不难理解，当不指定 `--entrypoint` 时，默认的 entrypoint 就是 shell，所以如果我们在 dockerfile 中指定了 entry point，那么我们想要运行其他可执行文件时，就必须显式地指定可执行文件了。
