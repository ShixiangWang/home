---
title: "读入 dbGap 的表型/注释信息"
author: "王诗翔"
date: "2019-08-23"
lastmod: "2019-08-23"
slug: ""
categories: [bioinformatics]
tags: [r, dbGap]
---


dbGaP 表型等信息零散地却有规律地分布在 `files/` 目录下，为了理解哪些文件存储了数据，我对下载的文件类型进行了查看，包括 xml, pdf 以及 gz 文件。大致有以下整理：

* pdf 文件存储的是各种文件的大致说明
* xml 文件存储一些文件的元信息和一些数据
* tar.gz 文件存储的是打包压缩的 xml 文件
* txt.gz 文件基本存储的是数据

xml 文件中的数据很难查看和导入，我也不懂 xml，放弃治疗。

tar.gz 文件存储的 xml 文件包含了 txt.gz 文件列名的描述，如果有这方面的疑问，推荐直接用文本模式看看它们，文件不大，还是比较好查看的。

带 MULTI 字符的 txt 文件虽然汇总了该研究所有的病人或样本信息，但很多信息没有存储！可惜了（如果读者发现自己下载的数据有存储最全面的信息，那还是推荐使用这个，减少麻烦）。

![](https://upload-images.jianshu.io/upload_images/3884693-d311c4cce527a31d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

实际包含详细信息的病人文件会带 Subject_Phenotypes 字符，而样本带 Sample_Attributes 字符。而它们还能相互补充，所以我要想办法导入 2 种数据，后面再进行合并处理。

![](https://upload-images.jianshu.io/upload_images/3884693-52d68d36bb542828.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

了解规律之后写函数处理：

```
read_dbGap = function(accession, destdir=getwd(), 
                      type = c("subject", "sample"), 
                      col_types = cols(.default = "c"),
                      pattern_subject_file = "Subject_Phenotypes", 
                      pattern_sample_file = "Sample_Attributes") {
    # col_types see ?readr::read_tsv
    # user can set it to dplyr::cols() if no error 'Too many conversion specifiers in format string' returned
    
    type = match.arg(type)
    # append / at the end if user not type it
    destdir = ifelse(endsWith(destdir, suffix = "/"), destdir, paste0(destdir, "/"))
    
    if (type == "subject") {
        fl = dir(destdir, paste0(accession, ".*", pattern_subject_file), full.names = TRUE)
    } else {
        fl = dir(destdir, paste0(accession, ".*", pattern_sample_file), full.names = TRUE)
    }
    
    if (length(fl) < 1) stop("Cannot find any file! Please check your input.")
    
    message("==> Finding out files with type ", type)
    print(fl)
    
    if (!require(tidyverse)) {
        message("Please install tidyverse package and re-run this function!")
    } else {
        purrr::map(fl, ~readr::read_tsv(., comment = "#", progress = TRUE, 
                                        col_types = col_types)) %>% 
            dplyr::bind_rows() %>% 
            unique()
    }
}
```

用户只要指定前 3 个参数，这里设定 `col_types = cols(.default = "c")` 是通过将所有列都读入为字符串以解决报错 `Too many conversion specifiers in format string`，你可以试试 `col_types = dplyr::cols()`，如果报错，再使用函数设定的默认参数。

因为我工作要处理的是多个 dbGap Study，所以我再创建一个函数来进行批量处理：

```
read_dbGapList = function(accession_list, destdir=getwd(),
                          col_types = cols(.default = "c"),
                          pattern_subject_file = "Subject_Phenotypes", 
                          pattern_sample_file = "Sample_Attributes") {
    if (!require(tidyverse)) {
        message("Please install tidyverse package and re-run this function!")
    } else {
        purrr::map(accession_list, function(x) {
            message("=> Processing accession ", x)
            type = c("subject", "sample")
            purrr::map(type, 
                       ~suppressWarnings(read_dbGap(x, destdir = destdir,type = .))) %>% 
                setNames(type)
        }) %>% 
            setNames(accession_list)
    }
}
```

效果如下：

```
> df_list = read_dbGapList(accession_list = paste0("phs00",
+                                                  c("0447", "0554", "0909", "0915", "1141")),
+                          destdir = "dbGap/phenotype/")
=> Processing accession phs000447
==> Finding out files with type subject
[1] "dbGap/phenotype//phs000447.v1.pht002581.v1.p1.c1.Prostate_CIP_Subject_Phenotypes.GRU.txt.gz"
[2] "dbGap/phenotype//phs000447.v1.pht002581.v1.p1.c2.Prostate_CIP_Subject_Phenotypes.CRO.txt.gz"
==> Finding out files with type sample
[1] "dbGap/phenotype//phs000447.v1.pht002582.v1.p1.c1.Prostate_CIP_Sample_Attributes.GRU.txt.gz"
[2] "dbGap/phenotype//phs000447.v1.pht002582.v1.p1.c2.Prostate_CIP_Sample_Attributes.CRO.txt.gz"
=> Processing accession phs000554
==> Finding out files with type subject
[1] "dbGap/phenotype//phs000554.v1.pht003196.v1.p1.c1.CRPC_Subject_Phenotypes.DS-CA-MDS.txt.gz"
==> Finding out files with type sample
[1] "dbGap/phenotype//phs000554.v1.pht003198.v1.p1.c1.CRPC_Sample_Attributes.DS-CA-MDS.txt.gz"
=> Processing accession phs000909
==> Finding out files with type subject
[1] "dbGap/phenotype//phs000909.v1.pht005250.v1.p1.c1.NEPC_Subject_Phenotypes.GRU.txt.gz"
==> Finding out files with type sample
[1] "dbGap/phenotype//phs000909.v1.pht004876.v1.p1.c1.NEPC_Sample_Attributes.GRU.txt.gz"
=> Processing accession phs000915
==> Finding out files with type subject
[1] "dbGap/phenotype//phs000915.v2.pht004946.v2.p2.c1.mCRPC_SU2C_Subject_Phenotypes.DS-PC-MDS.txt.gz"
[2] "dbGap/phenotype//phs000915.v2.pht004946.v2.p2.c2.mCRPC_SU2C_Subject_Phenotypes.DS-CA-MDS.txt.gz"
==> Finding out files with type sample
[1] "dbGap/phenotype//phs000915.v2.pht004947.v2.p2.c1.mCRPC_SU2C_Sample_Attributes.DS-PC-MDS.txt.gz"
[2] "dbGap/phenotype//phs000915.v2.pht004947.v2.p2.c2.mCRPC_SU2C_Sample_Attributes.DS-CA-MDS.txt.gz"
=> Processing accession phs001141
==> Finding out files with type subject
[1] "dbGap/phenotype//phs001141.v1.pht005601.v1.p1.c1.PROMOTE_Subject_Phenotypes.GRU.txt.gz"
==> Finding out files with type sample
[1] "dbGap/phenotype//phs001141.v1.pht005602.v1.p1.c1.PROMOTE_Sample_Attributes.GRU.txt.gz"
```

后续的合并就需要更多的 dirty work 了。。。

***

注：公布的函数是开源的，抄可以，但封装或修改时还是要有点开源精神，以GPL协议附上本人 copyright。如果是发表研究，应当适当引用。
