---
title: "dplyr 行式计算"
author: "王诗翔"
date: "2021-01-22"
lastmod: "2021-01-22"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["dplyr", "rowwise"]
---

原文来自：dplyr 文档

通常 dplyr 和 R 更适合对列进行操作，而对行操作则显得更麻烦。这篇文章，我们将学习围绕`rowwise()` 创建的 row-wise 数据框的 dplyr 操作方法。

本文将讨论 3 种常见的使用案例：

- 按行聚合（例如，计算 x, y, z 的均值）。
- 多次以不同的参数调用同一个函数。
- 处理列表列。

这些问题通常可以通过 for 循环简单地解决掉，但如果能够自然地将其流程化将是一个非常好的方案。

> Of course, someone has to write loops. It doesn’t have to be you. — Jenny Bryan

载入包

```R
library(dplyr, warn.conflicts = FALSE)
```

## 创建

行式操作需要一个特殊的分组类型，每一组简单地包含一个单一的行。你可以使用 `rowwise()` 创建它：

```R
df <- tibble(x = 1:2, y = 3:4, z = 5:6)
df %>% rowwise()
#> # A tibble: 2 x 3
#> # Rowwise: 
#>       x     y     z
#>   <int> <int> <int>
#> 1     1     3     5
#> 2     2     4     6
```

与 `group_by()` 类似， `rowwise()` 本身并不进行任何的操作，它仅改变其他动词操作如何工作。例如，比较下面 `mutate()` 的结果：

```R
df %>% mutate(m = mean(c(x, y, z)))
#> # A tibble: 2 x 4
#>       x     y     z     m
#>   <int> <int> <int> <dbl>
#> 1     1     3     5   3.5
#> 2     2     4     6   3.5
df %>% rowwise() %>% mutate(m = mean(c(x, y, z)))
#> # A tibble: 2 x 4
#> # Rowwise: 
#>       x     y     z     m
#>   <int> <int> <int> <dbl>
#> 1     1     3     5     3
#> 2     2     4     6     4
```

如果你使用 `mutate()` 操作一个常规的数据框，它计算所有行的 `x`, `y` 和 `z` 的均值。而如果你只应用到一个行式数据框，它计算每一行的均值。

你可以在 `rowwise()` 中提供“标识符”变量，这些变量将在你调用 `summarise()` 的时候保留，因此它的行为类似于将变量传入 `group_by()`：

```R
df <- tibble(name = c("Mara", "Hadley"), x = 1:2, y = 3:4, z = 5:6)

df %>% 
  rowwise() %>% 
  summarise(m = mean(c(x, y, z)))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 2 x 1
#>       m
#>   <dbl>
#> 1     3
#> 2     4

df %>% 
  rowwise(name) %>% 
  summarise(m = mean(c(x, y, z)))
#> `summarise()` regrouping output by 'name' (override with `.groups` argument)
#> # A tibble: 2 x 2
#> # Groups:   name [2]
#>   name       m
#>   <chr>  <dbl>
#> 1 Mara       3
#> 2 Hadley     4
```

`rowwise()` 仅是分组的一个特殊形式，因此如果你想要将其从数据框中移除，调用 `ungroup()` 即可。

## 按行汇总统计

`dplyr::summarise()` 让一列多行的统计汇总变得非常简单，当它与 `rowwise()` 结合时，它也可以简便地操作汇总一行多列。为了查看它是怎样工作的，我们从创建一个小的数据框开始：

```R
df <- tibble(id = 1:6, w = 10:15, x = 20:25, y = 30:35, z = 40:45)
df
#> # A tibble: 6 x 5
#>      id     w     x     y     z
#>   <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40
#> 2     2    11    21    31    41
#> 3     3    12    22    32    42
#> 4     4    13    23    33    43
#> # … with 2 more rows
```

假设我们想要计算每行 `w`, `x`, `y`, 和 `z` 的和，我们县创建一个行式数据框：

```R
rf <- df %>% rowwise(id)
```

我们然后使用 `mutate()` 添加一个新的列，或者使用 `summarise()` 仅返回一个汇总列：

```R
rf %>% mutate(total = sum(c(w, x, y, z)))
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> # … with 2 more rows
rf %>% summarise(total = sum(c(w, x, y, z)))
#> `summarise()` regrouping output by 'id' (override with `.groups` argument)
#> # A tibble: 6 x 2
#> # Groups:   id [6]
#>      id total
#>   <int> <int>
#> 1     1   100
#> 2     2   104
#> 3     3   108
#> 4     4   112
#> # … with 2 more rows
```

当然，如果你有大量的变量，键入每个变量名将非常无聊。因此，你可以使用 `c_across()` ，它支持 tidy 选择语法，因而你可以一次性选择许多变量：

```R
rf %>% mutate(total = sum(c_across(w:z)))
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> # … with 2 more rows
rf %>% mutate(total = sum(c_across(where(is.numeric))))
#> # A tibble: 6 x 6
#> # Rowwise:  id
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <int>
#> 1     1    10    20    30    40   100
#> 2     2    11    21    31    41   104
#> 3     3    12    22    32    42   108
#> 4     4    13    23    33    43   112
#> # … with 2 more rows
```

你可以结合列式操作（见前一篇文章）计算每一行的比例：

```R
rf %>% 
  mutate(total = sum(c_across(w:z))) %>% 
  ungroup() %>% 
  mutate(across(w:z, ~ . / total))
#> # A tibble: 6 x 6
#>      id     w     x     y     z total
#>   <int> <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1 0.1   0.2   0.3   0.4     100
#> 2     2 0.106 0.202 0.298 0.394   104
#> 3     3 0.111 0.204 0.296 0.389   108
#> 4     4 0.116 0.205 0.295 0.384   112
#> # … with 2 more rows
```

### 行式汇总函数

`rowwise()` 方法支持任何的汇总函数。但如果你要考虑计算的速度，寻找能够完成任务的内置的行式汇总函数非常值得。它们的效率更高，因为它们不会将数据切分为行，然后计算统计量，最后再把结果拼起来，它们将整个数据框作为一个整体进行操作。

```R
df %>% mutate(total = rowSums(across(where(is.numeric))))
#> # A tibble: 6 x 6
#>      id     w     x     y     z total
#>   <int> <int> <int> <int> <int> <dbl>
#> 1     1    10    20    30    40   101
#> 2     2    11    21    31    41   106
#> 3     3    12    22    32    42   111
#> 4     4    13    23    33    43   116
#> # … with 2 more rows
df %>% mutate(mean = rowMeans(across(where(is.numeric))))
#> # A tibble: 6 x 6
#>      id     w     x     y     z  mean
#>   <int> <int> <int> <int> <int> <dbl>
#> 1     1    10    20    30    40  20.2
#> 2     2    11    21    31    41  21.2
#> 3     3    12    22    32    42  22.2
#> 4     4    13    23    33    43  23.2
#> # … with 2 more rows
```

## 列表列

当您有列表列时，`rowwise()`操作是一种自然的配对。它们允许你避免显式的循环和/或使用 `apply()` 或 `purrr::map` 家族函数。

### 动机

想象你有下面这个数据框，你想要计算每个元素的长度：

```R
df <- tibble(
  x = list(1, 2:3, 4:6)
)
```

你可能会尝试 `length()`：

```R
df %>% mutate(l = length(x))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     3
#> 2 <int [2]>     3
#> 3 <int [3]>     3
```

但是返回的是列的长度，而不是单独值的长度。如果你是一个 R 文档迷，你可能知道有一个 base R 函数就是用来处理这种情况的：

```R
df %>% mutate(l = lengths(x))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
```

或者你是一个有经验的 R 编程者，你可能知道如何使用 `sapply()` 等函数将一个操作应用到每一个元素：

```R
df %>% mutate(l = sapply(x, length))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
df %>% mutate(l = purrr::map_int(x, length))
#> # A tibble: 3 x 2
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
```

但如果只写 `length(x)` dplyr 就能算出 `x`中 元素的长度不是很好吗？既然已经到了这里，你可能已经猜到了答案：这只是行模式的另一个应用。

```R
df %>% 
  rowwise() %>% 
  mutate(l = length(x))
#> # A tibble: 3 x 2
#> # Rowwise: 
#>   x             l
#>   <list>    <int>
#> 1 <dbl [1]>     1
#> 2 <int [2]>     2
#> 3 <int [3]>     3
```

### 取子集

在我们继续之前，我想简单地提一下让它起作用的魔法。这不是你通常需要考虑的事情（它会工作），但知道什么时候出错是很有用的。

分组数据框（每个组恰好有一行）和行数据框（每个组总是有一行）之间有一个重要的区别。以这两个数据框为例:

```R
df <- tibble(g = 1:2, y = list(1:3, "a"))
gf <- df %>% group_by(g)
rf <- df %>% rowwise(g)
```

如果我们计算 `y` 的一些属性，我们会发现结果有一些不同：

```R
gf %>% mutate(type = typeof(y), length = length(y))
#> # A tibble: 2 x 4
#> # Groups:   g [2]
#>       g y         type  length
#>   <int> <list>    <chr>  <int>
#> 1     1 <int [3]> list       1
#> 2     2 <chr [1]> list       1
rf %>% mutate(type = typeof(y), length = length(y))
#> # A tibble: 2 x 4
#> # Rowwise:  g
#>       g y         type      length
#>   <int> <list>    <chr>      <int>
#> 1     1 <int [3]> integer        3
#> 2     2 <chr [1]> character      1
```

关键的区别在于 `mutate()` 将列切分然后传入 `length(y)` 的时候，分组 mutate 使用 `[` 操作，而行式 mutate 使用 `[[`。下面代码通过 for 循环展示这一区别：

```R
# grouped
out1 <- integer(2)
for (i in 1:2) {
  out1[[i]] <- length(df$y[i])
}
out1
#> [1] 1 1

# rowwise
out2 <- integer(2)
for (i in 1:2) {
  out2[[i]] <- length(df$y[[i]])
}
out2
#> [1] 3 1
```

注意，这种魔力只适用于引用现有列时，而不适用于创建新行。这可能会让人感到困惑，但我们确信这是最差的解决方案，特别是在错误消息中给出了提示。

```R
gf %>% mutate(y2 = y)
#> # A tibble: 2 x 3
#> # Groups:   g [2]
#>       g y         y2       
#>   <int> <list>    <list>   
#> 1     1 <int [3]> <int [3]>
#> 2     2 <chr [1]> <chr [1]>
rf %>% mutate(y2 = y)
#> Error: Problem with `mutate()` input `y2`.
#> x Input `y2` can't be recycled to size 1.
#> ℹ Input `y2` is `y`.
#> ℹ Input `y2` must be size 1, not 3.
#> ℹ Did you mean: `y2 = list(y)` ?
#> ℹ The error occurred in row 1.
rf %>% mutate(y2 = list(y))
#> # A tibble: 2 x 3
#> # Rowwise:  g
#>       g y         y2       
#>   <int> <list>    <list>   
#> 1     1 <int [3]> <int [3]>
#> 2     2 <chr [1]> <chr [1]>
```

> 译者注：第二个例子中的操作 `y` 已经被解开列表了，所以需要重新被包裹起来。

### 建模

`rowwise()` 数据框允许我们以一种特别优雅的方式解决很多的建模问题。让我们从创建一个嵌套数据框开始：

```R
by_cyl <- mtcars %>% nest_by(cyl)
#> `summarise()` ungrouping output (override with `.groups` argument)
by_cyl
#> # A tibble: 3 x 2
#> # Rowwise:  cyl
#>     cyl data              
#>   <dbl> <list>            
#> 1     4 <tibble [11 × 12]>
#> 2     6 <tibble [7 × 12]> 
#> 3     8 <tibble [14 × 12]>
```

这与通常的 `group_by()` 输出有一点不同:我们明显地改变了数据的结构。现在我们有了三行（每个组一行），还有一个列表列 data，用于存储该组的数据。还要注意输出是 `rowwwise()`;这一点很重要，因为它将使处理数据框列表变得更加容易。

一旦我们每一行有一个数据框，对每行创建一个模型非常直观：

```R
mods <- by_cyl %>% mutate(mod = list(lm(mpg ~ wt, data = data)))
mods
#> # A tibble: 3 x 3
#> # Rowwise:  cyl
#>     cyl data               mod   
#>   <dbl> <list>             <list>
#> 1     4 <tibble [11 × 12]> <lm>  
#> 2     6 <tibble [7 × 12]>  <lm>  
#> 3     8 <tibble [14 × 12]> <lm>
```

用每行一组预测值来补充：

```R
mods <- mods %>% mutate(pred = list(predict(mod, data)))
mods
#> # A tibble: 3 x 4
#> # Rowwise:  cyl
#>     cyl data               mod    pred      
#>   <dbl> <list>             <list> <list>    
#> 1     4 <tibble [11 × 12]> <lm>   <dbl [11]>
#> 2     6 <tibble [7 × 12]>  <lm>   <dbl [7]> 
#> 3     8 <tibble [14 × 12]> <lm>   <dbl [14]>
```

然后你可以用多种方式总结这个模型：

```R
mods %>% summarise(rmse = sqrt(mean((pred - data$mpg) ^ 2)))
#> `summarise()` regrouping output by 'cyl' (override with `.groups` argument)
#> # A tibble: 3 x 2
#> # Groups:   cyl [3]
#>     cyl  rmse
#>   <dbl> <dbl>
#> 1     4 3.01 
#> 2     6 0.985
#> 3     8 1.87
mods %>% summarise(rsq = summary(mod)$r.squared)
#> `summarise()` regrouping output by 'cyl' (override with `.groups` argument)
#> # A tibble: 3 x 2
#> # Groups:   cyl [3]
#>     cyl   rsq
#>   <dbl> <dbl>
#> 1     4 0.509
#> 2     6 0.465
#> 3     8 0.423
mods %>% summarise(broom::glance(mod))
#> `summarise()` regrouping output by 'cyl' (override with `.groups` argument)
#> # A tibble: 3 x 13
#> # Groups:   cyl [3]
#>     cyl r.squared adj.r.squared sigma statistic p.value    df logLik   AIC   BIC
#>   <dbl>     <dbl>         <dbl> <dbl>     <dbl>   <dbl> <dbl>  <dbl> <dbl> <dbl>
#> 1     4     0.509         0.454  3.33      9.32  0.0137     1 -27.7   61.5  62.7
#> 2     6     0.465         0.357  1.17      4.34  0.0918     1  -9.83  25.7  25.5
#> 3     8     0.423         0.375  2.02      8.80  0.0118     1 -28.7   63.3  65.2
#> # … with 3 more variables: deviance <dbl>, df.residual <int>, nobs <int>
```

或轻松访问各模型的参数：

```R
mods %>% summarise(broom::tidy(mod))
#> `summarise()` regrouping output by 'cyl' (override with `.groups` argument)
#> # A tibble: 6 x 6
#> # Groups:   cyl [3]
#>     cyl term        estimate std.error statistic    p.value
#>   <dbl> <chr>          <dbl>     <dbl>     <dbl>      <dbl>
#> 1     4 (Intercept)    39.6       4.35      9.10 0.00000777
#> 2     4 wt             -5.65      1.85     -3.05 0.0137    
#> 3     6 (Intercept)    28.4       4.18      6.79 0.00105   
#> 4     6 wt             -2.78      1.33     -2.08 0.0918    
#> # … with 2 more rows
```

## 重复的函数调用

`rowwise()`不仅适用于返回长度为1的向量的函数（又名总结函数）；如果结果是列表，它可以与任何函数一起工作。这意味着`rowwise()`和`mutate()`提供了一种优雅的方式，可以使用不同的参数多次调用函数，并将输出与输入一起存储。

### 模拟

我认为这是执行模拟的一种特别优雅的方式，因为它允许您存储模拟值以及生成它们的参数。例如，假设你有以下数据框，描述了 3 个均匀分布样本的属性:

```R
df <- tribble(
  ~ n, ~ min, ~ max,
    1,     0,     1,
    2,    10,   100,
    3,   100,  1000,
)
```

你可以使用 `rowwise()`和`mutate()`将这些参数提供给`runif()`：

```R
df %>% 
  rowwise() %>% 
  mutate(data = list(runif(n, min, max)))
#> # A tibble: 3 x 4
#> # Rowwise: 
#>       n   min   max data     
#>   <dbl> <dbl> <dbl> <list>   
#> 1     1     0     1 <dbl [1]>
#> 2     2    10   100 <dbl [2]>
#> 3     3   100  1000 <dbl [3]>
```

注意这里使用了`list()`——`runif()`返回多个值，而`mutate()`表达式必须返回长度为1的值。`list()`意味着我们将得到一个列表列，其中每一行都是一个包含多个值的列表。如果你忘记使用`list()`， dplyr 会给你提示：

```R
df %>% 
  rowwise() %>% 
  mutate(data = runif(n, min, max))
#> Error: Problem with `mutate()` input `data`.
#> x Input `data` can't be recycled to size 1.
#> ℹ Input `data` is `runif(n, min, max)`.
#> ℹ Input `data` must be size 1, not 2.
#> ℹ Did you mean: `data = list(runif(n, min, max))` ?
#> ℹ The error occurred in row 2.
```

### 重复组合

如果您想为每个输入组合调用一个函数，该怎么办？你可以使用 `expand.grid()`或者`tidyr::expand_grid()`来生成数据帧，然后重复上面的模式：

```R
df <- expand.grid(mean = c(-1, 0, 1), sd = c(1, 10, 100))

df %>% 
  rowwise() %>% 
  mutate(data = list(rnorm(10, mean, sd)))
#> # A tibble: 9 x 3
#> # Rowwise: 
#>    mean    sd data      
#>   <dbl> <dbl> <list>    
#> 1    -1     1 <dbl [10]>
#> 2     0     1 <dbl [10]>
#> 3     1     1 <dbl [10]>
#> 4    -1    10 <dbl [10]>
#> # … with 5 more rows
```

### 不同的函数

在更复杂的问题中，你可能还希望改变被调用的函数。因为输入`tibble`中的列没有那么规则，所以这种方法更不适合这种方法。但这仍然是可能的，而且在这里使用`do.call()`是很自然的：

```R
df <- tribble(
   ~rng,     ~params,
   "runif",  list(n = 10), 
   "rnorm",  list(n = 20),
   "rpois",  list(n = 10, lambda = 5),
) %>%
  rowwise()

df %>% 
  mutate(data = list(do.call(rng, params)))
#> # A tibble: 3 x 3
#> # Rowwise: 
#>   rng   params           data      
#>   <chr> <list>           <list>    
#> 1 runif <named list [1]> <dbl [10]>
#> 2 rnorm <named list [1]> <dbl [20]>
#> 3 rpois <named list [2]> <int [10]>
```

## 以前

### `rowwise()`

`rowwise()` 也被质疑了很长一段时间，部分原因是我不明白有多少人需要通过本地能力来计算每一行的多个变量的摘要。作为替代方案，我们建议使用 purrr 的 `map()` 函数执行逐行操作。但是，这很有挑战性，因为您需要根据变化的参数数量和结果类型来选择映射函数，这需要相当多的 purrr 函数知识。

我也曾抗拒 `rowwwise()`，因为我觉得自动在`[`到`[[`之间切换太神奇了，就像自动`list()`-ing结果使`do()`太神奇一样。我现在已经说服自己，行式魔法是好的魔法，部分原因是大多数人发现`[`和`[[`神秘化和`rowwise()`之间的区别意味着你不需要考虑它。

由于 `rowwise()` 显然是有用的，它不再被质疑，我们希望它能够长期存在。

### `do()`

我们对 `do()`的必要性已经质疑了很长一段时间，因为它与其他 dplyr 动词并不太相似。它有两种主要的运作模式:

- 没有参数名：你可以调用函数来输入和输出数据框。引用“当前”组。例如，下面的代码获取每个组的第一行：

  ```R
  mtcars %>% 
    group_by(cyl) %>% 
    do(head(., 1))
  #> # A tibble: 3 x 13
  #> # Groups:   cyl [3]
  #>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb  cyl2  cyl4
  #>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
  #> 1  22.8     4   108    93  3.85  2.32  18.6     1     1     4     1     8    16
  #> 2  21       6   160   110  3.9   2.62  16.5     0     1     4     4    12    24
  #> 3  18.7     8   360   175  3.15  3.44  17.0     0     0     3     2    16    32
  ```

  这已经被 `cur_data()` 和更宽松的 `summarise()` 所取代，后者现在可以创建多列和多行。

  ```R
  mtcars %>% 
    group_by(cyl) %>% 
    summarise(head(cur_data(), 1))
  #> `summarise()` ungrouping output (override with `.groups` argument)
  #> # A tibble: 3 x 13
  #>     cyl   mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb  cyl2  cyl4
  #>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
  #> 1     4  22.8   108    93  3.85  2.32  18.6     1     1     4     1     8    16
  #> 2     6  21     160   110  3.9   2.62  16.5     0     1     4     4    12    24
  #> 3     8  18.7   360   175  3.15  3.44  17.0     0     0     3     2    16    32
  ```

- •带参数：它的工作方式类似于 `mutate()` 但会自动将每个元素包裹为列表：

  ```R
  mtcars %>% 
    group_by(cyl) %>% 
    do(nrows = nrow(.))
  #> # A tibble: 3 x 2
  #> # Rowwise: 
  #>     cyl nrows    
  #>   <dbl> <list>   
  #> 1     4 <int [1]>
  #> 2     6 <int [1]>
  #> 3     8 <int [1]>
  ```

  我现在觉得这个行为既太神奇又不是很有用，它可以被`summarise()`和`cur_data()`取代。

  ```R
  mtcars %>% 
    group_by(cyl) %>% 
    summarise(nrows = nrow(cur_data()))
  #> `summarise()` ungrouping output (override with `.groups` argument)
  #> # A tibble: 3 x 2
  #>     cyl nrows
  #>   <dbl> <int>
  #> 1     4    11
  #> 2     6     7
  #> 3     8    14
  ```

  如果需要（不像这里），你可以自己将结果包装在一个列表中。
  

`cur_data()`/`across()` 的添加和 `summarise()` 应用范围的增加意味着不再需要 `do()`，所以它现在被废弃了。