---
title: "「翻译」在生物信息学中使用 GNU-Parallel"
author: "王诗翔"
date: "2020-09-18"
lastmod: "2020-09-18"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["linux"]
tags: ["linux", "parallel", "bioinformatics"]
---

原文出处：<https://www.danielecook.com/using-gnu-parallel-for-bioinformatics/>

[GNU Parallel](https://www.gnu.org/software/parallel/) 是一个用于加速生信分析不可或缺的一个工具。它允许你非常简单地对命令并行化处理。下面我将介绍一些如何使用它以及如何将它应用于生信。

很多高性能计算平台节点已经预先安装了它。你可以从 [homebrew](https://www.danielecook.com/using-gnu-parallel-for-bioinformatics/brew.sh) 或其他包管理器找到和安装它。

# 基本用法

让我们从一个简单的例子开始：

```bash
seq 1 5 | parallel -j 4 echo
```

这里我们 (1) 打印了数字 1 到 5，且 (2) 将该序列数据通过管道传进了 `parallel` 命令。我们提供了一个命令 `echo` ，它将通过 `-j=4` 的选项指定进行并行化。我们可以通过添加 `--dry-run` 打印将要运行的命令。

```bash
seq 1 5 | parallel --dry-run -j 4 echo
echo 3
echo 4
echo 5
echo 2
echo 1
```

结果是乱序的！这是并行化的本质：不是所有的任务都会花费相同的时间，所以有的结束的早，有的结束的晚，因此输出顺序并不一致。我们可以使用 `-k` 选项强制程序执行“先入先出”准则。让我们看一下下面的结果：

```bash
seq 1 5 | parallel -j 4 -k echo
1
2
3
4
5
```

像其他任何命令一样，我们可以将输出保存到文件中：

```bash
seq 1 5 | parallel -j 4 -k echo > out.txt
```

## `-j`

为了让 GNU Parllel 工作，你需要一个多核 CPU。指定超过所拥有的核心数会让性能变得糟糕。因此，调节 `-j` 选项以便于命令更好地工作是非常重要的。

幸运地是，`parallel` 运行你通过 `-j` 指定计算占有的 CPU 比例或相对数量。

```bash
parallel -j 100% # 使用 100% 的核心数
parallel -j -1 # 使用比所有核心数少 1 个的核心数
parallel -j +1 # 使用比所有核心数多 1 个的核心数
```

## 使用 `:::` 传递参数

使用 `:::` 指定并行指定的命令参数（列表来源）。

```bash
parallel -j 4 -k echo ::: `seq 1 5`
```

**注意**，上面这种情况能够传递的参数数量是有限的，通过管道传递参数或像下面一样通过文件传递参数可能更好：

```bash
seq 1 5 | parallel -j 4 -k echo
```

## 使用 `::::` 传递文件内的参数

如果参数列表很大，你可以通过文件指定，文件每一行对应要并行的一个参数：

```bash
parallel -j 4 -k echo :::: my_args.txt
```

## 使用 `

默认 `parallel` 假定参数放在输入命令的结尾，但是你可以通过 `{}` 显式地指定： 

```bash
parallel --dry-run -j 4 -k echo \"{} "<-- a number"\" ::: `seq 1 5`
echo "1 <-- a number"
echo "2 <-- a number"
echo "3 <-- a number"
echo "4 <-- a number"
echo "5 <-- a number"
```

注意上面我们使用转移符号输出了双引号。

## 组合

你可以组合 `:::` 和 `:::` 来添加额外的参数，然后它们会生成所有可能的组合。这对测试有不同参数组合的命令非常有用： 

```bash
parallel --dry-run -k -j 4 Rscript run_analysis.R {1} {2} ::: `seq 1 2` ::: A B C
Rscript run_analysis.R 1 A
Rscript run_analysis.R 1 B
Rscript run_analysis.R 1 C
Rscript run_analysis.R 2 A
Rscript run_analysis.R 2 B
Rscript run_analysis.R 2 C
```

## 并行化函数

在一些情况下，你想要执行一系列的命令。例如，下面的代码计算了输入DNA序列互补配对的碱基计数：

```bash
echo "ATTA" |  tr ATCG TAGC | \
    python -c "import sys; o=sys.stdin.read().strip(); print(o, o.count('T'), o.count('G'), o.count('C'), o.count('A'))"
```

这个命令有 2 个操作。但我们可以将它整合为 'one-liner'：创建一个 bash 函数，导出它，然后使用它作为输入：

```shell
function count_nts {
    # $1 is the first argument passed to the function
    echo $1 | tr ATCG TAGC | \
    python -c "import sys; o=sys.stdin.read().strip(); print(o, o.count('T'), o.count('G'), o.count('C'), o.count('A'))"
}

# Use the `-f` flag to export functions
export -f count_nts

parallel -j 4 count_nts ::: TAAT TTT AAAAT GCGCAT | tr ' ' '\t'
```

有了上面的基础，让我们看看如何使用它加速生信分析。

# 使用 GNU Parallel 进行 Variant Calling

当处理 BAMs 或 VCFs 时，你可以并行处理所有的染色体。大多数变异检测软件或注释工具允许你通过指定区间一次处理一个染色体。这允许我们使用**拆分-应用-组合**策略到该分析中。 

## 从 BAM 中分割染色体

```bash
chrom_list=`samtools idxstats in.bam | cut -f 1 | grep -v '*'`

# For c. elegans you can would see the following 7
# I
# II
# III
# IV
# V
# X
# MtDNA
```

我们可以创建一个 bash 函数：

```bash
function bam_chromosomes {
    samtools idxstats $1 | cut -f 1 | grep -v '*'
}
```

## 应用操作到每一条染色体

下面是处理代码：

```bash
#!/bin/bash

genome=path/to/genome.fa
export genome # This is critical!

function parallel_call {
    bcftools mpileup \
        --fasta-ref ${genome} \
        --regions $2 \
        --output-type u \
        $1 | \
    bcftools call --multiallelic-caller \
                  --variants-only \
                  --output-type u - > ${1/.bam/}.$2.bcf
}

export -f parallel_call

chrom_set=`bam_chromosomes test.bam`
parallel --verbose -j 4 parallel_call sample_A.bam ::: ${chrom_set}
```

一些重要的注意事项：

- 你必须导出 `export` 所有并行化函数中使用到的变量，例如上面的 `genome`。
- `--output-type=u` 是出于效率考虑。

- Finally, I use a variable substitution to remove the extension from the bam and to generate a `<sample>.<chromsome>.bcf` filename: `${1/.bam/}.$2.bcf` → `sample_A.I.bam`, `sample_A.II.bam`, etc. This prevents filename collisions if we are calling many samples simultaneously.

## 组合变异检测结果

一旦我们完成工作，接着我们使用 bash 数组和组合所有结合并将其廉洁为单个文件。

```bash
# Generate an array of the resulting files
# to be concatenated.
sample_name="sample_A"
set -- `echo $chrom_set | tr "\n" " "`
set -- "${@/#/${sample_name}.}" && set -- "${@/%/.bcf}"
# This will generate a list of the output files:
# sample_A.I.bcf sample_B.II.bcf etc.

set -- "${@/#/test.}" && set -- "${@/%/.bcf}"

# Output compressed result
bcftools concat $@ --output-type b > $sample_name.bcf

# Remove intermediate files
rm $@
```

为了确保所有中间文件被删除，这里使用了[bash trap](http://redsymbol.net/articles/bash-exit-traps/)。

# 总结

GNU Parallel 可以极大提高简单并行场景任务处理效率。虽然需要编写额外的代码用于处理拆分和组合两步，但这可以得到极大的效率提升。
