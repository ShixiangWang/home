---
title: "PicGo + Gitee 构建免费云图床"
author: "王诗翔"
date: "2020-08-10"
lastmod: "2020-08-10"
slug: ""
categories: ["config"]
tags: ["PicGo", "Gitee", "云图床", "figure"]
---


![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810112027062.png "PicGo")

PicGo 下载链接：<https://github.com/Molunerfinn/PicGo/releases/>

> 开源开发不易，不妨对仓库点个 Star，致谢下作者们。

根据自己的系统版本进行下载。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810105244021.png "下载页面")

下载后傻瓜式安装，完成后打开软件面板，进入插件设置。这里我安装 gitee 插件：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810105735451.png)

PicGo 支持很多云图床，默认就包括七牛云、GitHub 等等。国内使用不推荐 GitHub，因为访问慢，所以使用了其替代品 Gitee。更多插件可以在 <https://github.com/PicGo/Awesome-PicGo> 找到。

然后我们根据自己需要修改一些设置，比如上传快捷键设定，默认的跟 VS Code 命令快捷键冲突了：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810105853490.png)

接着设置是否开机自启动、文件重命名等等。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110048074.png)

用不到的图床建议取消勾选，不显示它们，这样不会看着费事。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110015373.png)

登录 Gitee，然后新建一个仓库，**记得勾选「使用Readme文件初始化这个仓库」**：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110215066.png)

在个人设置中生成一个私人令牌，把值记录下来：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110300560.png)

打开图床设置，填入上面获取的信息，设置为默认图床并保存：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110556978.png)

> 这里 path 根据自己的喜好设置，这里我设置为 `png`，那么上传的图片全部都在 仓库`png` 目录下。

然后我们就可以在上传区域上传图片了：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110651962.png)

上传成功后我们可以在相册中看到，进行编辑、拷贝链接和删除。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810110727576.png)


点击第一个图标，我们就可以拷贝为 Markdown 链接，CTRL+V 即可粘贴使用了。

```
![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/20200810110623.png)
```

另外我们可以在上传小区域中使用 CTRL+C 快捷键进行复制：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810111824392.png)



完成上面这些内容后，我们就能够使用免费云图床对图片进行快乐地玩耍了。

如果你还使用 typora，那么可以在设置的图像里选择 PicGo 自动进行上传：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810123619017.png)

如果你选择了插入图片时上传图片，那么图片在插入时就会进行上传。但这种设置会应用到你所有的文档中去，如果你想要根据需要进行单篇设置，建议选择将图片复制到一个文件夹中去。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810123807327.png)

然后在 typora 菜单栏图像中选择当插入图片时上传图片。

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810123921460.png)

这样 typora 会自动插入 YAML 元信息：

![](https://gitee.com/ShixiangWang/ImageCollection/raw/master/png/image-20200810124023556.png)

当然，你也可以手动进行这样的设置。

