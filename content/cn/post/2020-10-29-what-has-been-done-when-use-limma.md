---
title: "当使用limma时，它在比较什么"
author: "王诗翔"
date: "2018-9-16"
lastmod: "2020-10-29"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["bioinformatics"]
tags: ["r", "limma", "差异分析", "基因芯片"]
---


## 差异分析流程示例与资料

基因芯片的差异表达分析主要有 构建基因表达矩阵、构建实验设计矩阵、构建对比模型（对比矩阵）、线性模型拟合、贝叶斯检验和生成结果报表 六个关键步骤。

下面是模拟的一个示例：

```r
# Simulate gene expression data for 100 probes and 6 microarraexprSets
# MicroarraexprSet are in two groups
# First two probes are differentiallexprSet expressed in second group
# Std deviations varexprSet between genes with prior df=4

# 构建模拟的表达矩阵，实际处理时换成自己的表达矩阵即可
sd <- 0.3*sqrt(4/rchisq(100,df=4))
exprSet <- matrix(rnorm(100*6,sd=sd),100,6)
rownames(exprSet) <- paste("Gene",1:100)
colnames(exprSet) <- c(paste0("con-",1:3), paste0("G3-",1:3))
exprSet[1:2,4:6] <- exprSet[1:2,4:6] + 2

library(limma)
# 构建实验设计矩阵
group_list = c(rep("con",3), rep("G3",3))
# 这里根据实际的情况设置（表型）分组，对应表达矩阵的列：样本

design <- model.matrix(~0+factor(group_list))
design

colnames(design)=levels(factor(group_list))
rownames(design)=colnames(exprSet)
design
# 实验设计矩阵的每一行对应一个样品的编码，
# 每一列对应样品的一个特征。这里只考虑了一个因素两个水平，
# 如果是多因素和多水平的实验设计，会产生更多的特征，需要参考文档设计。

# 构建对比模型，比较两个实验条件下表达数据
contrast.matrix<-makeContrasts(G3-con,levels = design)
#contrast.matrix<-makeContrasts(paste0(unique(group_list),collapse = "-"),levels = design)
contrast.matrix ##这个矩阵声明，我们要把G3组跟con组进行差异分析比较


##### 差异分析
##step1 线性模型拟合
fit <- lmFit(exprSet,design)
##step2 根据对比模型进行差值计算 
fit2 <- contrasts.fit(fit, contrast.matrix) 
##step3 贝叶斯检验
fit2 <- eBayes(fit2) 
##step4 生成所有基因的检验结果报告
tempOutput = topTable(fit2, coef=1, n=Inf)
##step5 用P.Value进行筛选，得到全部差异表达基因
dif <- tempOutput[tempOutput[, "P.Value"]<0.01,]
# 显示一部分报告结果
head(dif)


```

参考：

* [用limma对芯片数据做差异分析](https://www.plob.org/article/9963.html)
* [Bioconductor分析基因芯片数据](https://www.shixiangwang.top/post/2017-10-09-microarray-data-analysis/#%E5%9F%BA%E5%9B%A0%E8%8A%AF%E7%89%87%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90)
* `limFit`函数文档 `?limFit()`

更新资料：

* [差异分析是否需要比较矩阵](https://github.com/bioconductor-china/basic/blob/master/makeContrasts.md)
* [入门GEO表达芯片数据分析该读一读的一些文章](https://www.jianshu.com/p/e4daa6b4f93e)

相关问题请下面留言讨论。

## 差异分析比较的是什么

在使用limma时，我一直对对比的事物存有疑惑，特别是当你可能看到下面这种分析结果相同时：

\#1:

```r
library(CLL)
data(sCLLex)
library(limma)
design=model.matrix(~factor(sCLLex$Disease))
fit=lmFit(sCLLex,design)
fit=eBayes(fit)
options(digits = 4)
#topTable(fit,coef=2,adjust='BH') 
> topTable(fit,coef=2,adjust='BH')
           logFC AveExpr      t   P.Value adj.P.Val     B
39400_at  1.0285   5.621  5.836 8.341e-06   0.03344 3.234
36131_at -0.9888   9.954 -5.772 9.668e-06   0.03344 3.117
33791_at -1.8302   6.951 -5.736 1.049e-05   0.03344 3.052
1303_at   1.3836   4.463  5.732 1.060e-05   0.03344 3.044
36122_at -0.7801   7.260 -5.141 4.206e-05   0.10619 1.935
36939_at -2.5472   6.915 -5.038 5.362e-05   0.11283 1.737
41398_at  0.5187   7.602  4.879 7.824e-05   0.11520 1.428
32599_at  0.8544   5.746  4.859 8.207e-05   0.11520 1.389
36129_at  0.9161   8.209  4.859 8.212e-05   0.11520 1.389
37636_at -1.6868   5.697 -4.804 9.355e-05   0.11811 1.282

```

\#2:

```R
library(CLL)
data(sCLLex)
library(limma)
design=model.matrix(~0+factor(sCLLex$Disease))
colnames(design)=c('progres','stable')
fit=lmFit(sCLLex,design)
cont.matrix=makeContrasts('progres-stable',levels = design)
fit2=contrasts.fit(fit,cont.matrix)
fit2=eBayes(fit2)
options(digits = 4)
topTable(fit2,adjust='BH')
 
           logFC AveExpr      t   P.Value adj.P.Val     B
39400_at -1.0285   5.621 -5.836 8.341e-06   0.03344 3.234
36131_at  0.9888   9.954  5.772 9.668e-06   0.03344 3.117
33791_at  1.8302   6.951  5.736 1.049e-05   0.03344 3.052
1303_at  -1.3836   4.463 -5.732 1.060e-05   0.03344 3.044
36122_at  0.7801   7.260  5.141 4.206e-05   0.10619 1.935
36939_at  2.5472   6.915  5.038 5.362e-05   0.11283 1.737
41398_at -0.5187   7.602 -4.879 7.824e-05   0.11520 1.428
32599_at -0.8544   5.746 -4.859 8.207e-05   0.11520 1.389
36129_at -0.9161   8.209 -4.859 8.212e-05   0.11520 1.389
37636_at  1.6868   5.697  4.804 9.355e-05   0.11811 1.282
```

> 上述代码资料来自jimmy

为什么第一种方式没有做对比矩阵，结果一致！

> 大家运行一下这些代码就知道，两者结果是一模一样的。
>而差异比较矩阵的需要与否，主要看分组矩阵如何制作的！
>```
>design=model.matrix(~factor(sCLLex$Disease))
>design=model.matrix(~0+factor(sCLLex$Disease))
>```
>有本质的区别！！！
>前面那种方法已经把需要比较的组做出到了一列，需要比较多次，就有多少列，第一列是截距不需要考虑，第二列开始往后用coef这个参数可以把差异分析结果一个个提取出来。
>而后面那种方法，仅仅是分组而已，组之间需要如何比较，需要自己再制作差异比较矩阵，通过makeContrasts函数来控制如何比较！
> --- jimmy

另一个问题：这两种方法哪一种更可取呢？

在我没有实际操作之前，我觉得简单的更清爽，适用，但适用后我的结论是第二种各种可取。在前几天的一次分析中，我将差异比较的两个水平分为：`High`和`Low`，结果分析的差异基因fold change反了！在没有显式指定的情况下，我们难以真正确定我们比对的结果是`High-Low`还是`Low-High`。另外，后一种方法更利于将差异的比较过程程序化。

最后，再强调一下流程：

**基因芯片的差异表达分析主要有 构建基因表达矩阵、构建实验设计矩阵、构建对比模型（对比矩阵）、线性模型拟合、贝叶斯检验和生成结果报表 六个关键步骤。**

其他相关资料：

- [基因芯片（Affymetrix）分析1：芯片质量分析](http://blog.csdn.net/u014801157/article/details/24494009)
- [基因芯片（Affymetrix）分析2：芯片数据预处理](http://blog.csdn.net/u014801157/article/details/24372381)
- [基因芯片（Affymetrix）分析3：获取差异表达基因](http://blog.csdn.net/u014801157/article/details/24372385)
- [基因芯片（Affymetrix）分析4：GO和KEGG分析](http://blog.csdn.net/u014801157/article/details/24372393)
- [基因芯片（Affymetrix）分析5：聚类分析](http://blog.csdn.net/u014801157/article/details/24372399)
- [使用oligo软件包处理芯片数据](http://blog.csdn.net/u014801157/article/details/66974577)
- [如何使用GEOquery和limma完成芯片数据的差异表达分析](https://www.jianshu.com/p/1537efae5be9)

![](https://upload-images.jianshu.io/upload_images/3884693-964fabc2c1b17b23.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
