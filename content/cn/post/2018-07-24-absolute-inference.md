---
title:  ABSOLUTE 推断框架
author: 王诗翔
date:  2018-07-24
categories:
- 学术
tags:
- 论文
- 推导
---



* 样本混合物中Cancer细胞比例：$\alpha$  (假设单染色体组monogenomic，即有同源SCNAs)

* 样本混合物中Normal细胞比例：$1-\alpha$  （染色体倍性为2）

* 基因组某位点：$x$

* Cancer细胞中该位点（整型）拷贝数表示为：$q(x)$

* Cancer细胞平均倍性为：$\tau$，定义为整个基因组上$q(x)$的平均值


样本混合物中位点$x$的平均绝对拷贝数为：

$$
\alpha q(x) + 2(1-\alpha)    \rightarrow Cancer细胞比例*位点拷贝数+正常细胞比例*位点拷贝数2
$$

样本混合物中平均倍性$D$为：

$$
\alpha \tau + 2(1-\alpha) \rightarrow Cancer细胞比例 * Cancer倍性 + 正常细胞比例 * 正常细胞倍性2
$$

> 上述两个值以单倍体基因组为单位

因此，位点$x$的相对拷贝数$R$为：

$$
R(x) = (\alpha q(x) + 2(1-\alpha)) / D = (\alpha / D) q(x) + (2(1-\alpha) / D)
$$

$$
\rightarrow 平均绝对拷贝数 / 平均倍性
$$

因为$q(x)$取整数值，因此$R(x)$必然是离散值。最小值为$(2(1-\alpha)/D)$，发生在**纯合性缺失**位点，对应正常细胞的DNA比例。

**Notably, if a cancer sample is not strictly clonal, copy-number alteration occurring in substantial subclonal fraction will appear as outliers from this pattern.**

