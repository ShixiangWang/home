---
title: "使用 youtube-dl 下载视频"
author: "王诗翔"
date: "2020-12-23"
lastmod: "2020-12-23"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["config"]
tags: ["youtube", "learning", "download"]
---

使用的工具项目地址：<https://github.com/ytdl-org/youtube-dl>

安装：

```sh
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
```

简单下载就是命令后加链接：

```
youtube-dl <url>
```

下载播放列表可以使用：

```
youtube-dl -cit <youtube-playlist-url>
```

- `-c` 持续下载
- `-i` 忽略错误
- `-t` 带标题

查询下载视频格式（质量）

```
youtube-dl <url>
```

会出现类似下面这样的表格信息：

```
[youtube] zv3cVJHCqXA: Downloading webpage
[info] Available formats for zv3cVJHCqXA:
format code  extension  resolution note
249          webm       audio only tiny   51k , opus @ 50k (48000Hz), 1.56MiB
250          webm       audio only tiny   68k , opus @ 70k (48000Hz), 1.97MiB
251          webm       audio only tiny  122k , opus @160k (48000Hz), 3.51MiB
140          m4a        audio only tiny  130k , m4a_dash container, mp4a.40.2@128k (44100Hz), 4.15MiB
160          mp4        256x144    144p   89k , avc1.4d400c, 30fps, video only, 1.13MiB
278          webm       256x144    144p   99k , webm container, vp9, 30fps, video only, 1.13MiB
242          webm       426x240    240p  194k , vp9, 30fps, video only, 1.82MiB
133          mp4        426x240    240p  214k , avc1.4d4015, 30fps, video only, 2.37MiB
243          webm       640x360    360p  278k , vp9, 30fps, video only, 3.07MiB
244          webm       854x480    480p  450k , vp9, 30fps, video only, 4.60MiB
134          mp4        640x360    360p  471k , avc1.4d401e, 30fps, video only, 4.28MiB
247          webm       1280x720   720p  853k , vp9, 30fps, video only, 7.92MiB
135          mp4        854x480    480p  880k , avc1.4d401f, 30fps, video only, 6.87MiB
248          webm       1920x1080  1080p 1263k , vp9, 30fps, video only, 10.46MiB
136          mp4        1280x720   720p 1760k , avc1.4d401f, 30fps, video only, 12.14MiB
137          mp4        1920x1080  1080p 3703k , avc1.640028, 30fps, video only, 19.56MiB
18           mp4        640x360    360p  324k , avc1.42001E, 30fps, mp4a.40.2@ 96k (44100Hz), 10.39MiB
22           mp4        1280x720   720p  507k , avc1.64001F, 30fps, mp4a.40.2@192k (44100Hz) (best)
```

然后下载时通过 `-f` 进行指定，例如下载 `1080P`：

```
youtube-dl -f 137 <url>
```

还可以指定 `cookie` 和 代理：

```
youtube-dl --cookies ck.txt --proxy socks5://127.0.0.1:7891 --verbose -f 22 -cit https://www.youtube.com/watch\?v\=0SgvSPyYEHo\&list\=PLeB-Dlq-v6tY3QLdQBA7rwb4a7fK9mLpv
```

参考：

<https://sachithmuhandiram.medium.com/youtube-dl-cheatsheet-bcc0782e7124>
