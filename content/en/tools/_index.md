---
title: Software and Tool
author: "王诗翔"
date: '2019-01-01'
---

This page lists all softwares and tools I developed.

## R packages

### DoAbsolute

**Homepage**: <https://github.com/ShixiangWang/DoAbsolute>

The goal of **DoAbsolute** is to automate ABSOLUTE calling for multiple
samples in parallel way.

[ABSOLUTE](https://www.nature.com/articles/nbt.2203) is a famous
software developed by Broad Institute, however, the **RunAbsolute**
function is designed for computing one sample each time and set no
default values. **DoAbsolute** helps user set default parameters
according to [ABSOLUTE
documentation](http://software.broadinstitute.org/cancer/software/genepattern/modules/docs/ABSOLUTE),
provides a uniform interface to input data easily and runs **RunAbsolute**
parallelly.

### metawho

**Homepage**: <https://github.com/ShixiangWang/metawho>

The goal of **metawho** is to provide simple R implementation of
"Meta-analytical method to Identify Who Benefits Most from Treatments".

**metawho** is powered by R package **metafor** and does not support
dataset contains individuals for now. Please use Stata package
**ipdmetan** if you are more familiar with Stata code.

### sigminer

**Homepage**: <https://github.com/ShixiangWang/sigminer>

The goal of **sigminer** is to provide a uniform interface for genomic variation signature analysis and visualization.

### UCSCXenaTools

**Homepage**: <https://github.com/ShixiangWang/UCSCXenaTools>

**UCSCXenaTools** is an R package for downloading and exploring data
from [**UCSC Xena data hubs**](https://xenabrowser.net/datapages/),
which are a collection of UCSC-hosted public databases such as TCGA,
ICGC, TARGET, GTEx, CCLE, and others. Databases are normalized so they
can be combined, linked, filtered, explored and downloaded.

### UCSCXenaShiny

**Homepage**: <https://github.com/openbiox/XenaShiny>

**UCSCXenaShiny** is Shiny app for [UCSC Xena](https://xenabrowser.net/), this package is built on the
top of **Shiny** and **UCSCXenaTools** etc..

## Linux tools

### sync-deploy

**Homepage**: <https://github.com/ShixiangWang/sync-deploy>

**sync-deploy** is a shell toolkit for deploying script/command task on a remote host, including up/download files, run script and more.

### Variants2Neoanitgen

**Homepage**: <https://github.com/ShixiangWang/Variants2Neoantigen>

**Variants2Neoanitgen** is a neoantigen calling pipeline begins from variants record file (MAF).

> Of note, VCF file as input is not supported
