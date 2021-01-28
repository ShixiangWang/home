---
title: "dplyr 列式计算"
author: "王诗翔"
date: "2021-01-22"
lastmod: "2021-01-22"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["dplyr", "colwise"]
---

> 在近期使用 **dplyr** 进行多列选择性操作，如 `mutate_at()` 时，发现文档提示一系列的 **dplyr** 函数变体已经过期，看来后续要退休了，使用 `across()` 是它们的统一替代品，所以最近抽时间针对性的学习和翻译下，希望给大家带来一些帮助。
>
> 本文是第一篇，介绍的是**列式计算**，后续还会有一篇介绍按行处理数据。
>
> 原文来自 [dplyr 文档]([Column-wise operations • dplyr (tidyverse.org)](https://dplyr.tidyverse.org/articles/colwise.html)) - 2021-01

同时对数据框的多列执行相同的函数操作经常有用，但是通过拷贝和粘贴的方式进行的话既枯燥就容易产生错误。

例如：

```R
df %>% 
  group_by(g1, g2) %>% 
  summarise(a = mean(a), b = mean(b), c = mean(c), d = mean(d))
```

（如果你想要计算每一行 `a, b, c, d` 的均值，请看行式计算一文）

本文将向你介绍 `across()` 函数，它可以帮助你以更加简洁的方式重写上述代码：

```R
df %>% 
  group_by(g1, g2) %>% 
  summarise(across(a:d, mean))
```

我们将从讨论 `across()` 的基本用法开始，特别是将其应用于 `summarise()` 中和展示如何联合多个函数使用它。然后我们将展示一些其他动词的使用。最后我们将简要介绍一下历史，说明为什么我们更喜欢 `across()` 而不是后一种方法（即 `_if()`, `_at()`, `_all()` 变体函数）以及如何将你的旧代码转换为新的语法实现。

载入包：

```R
library(dplyr, warn.conflicts = FALSE)
```

## 基本用法

`across()` 有两个主要的参数：

- 第一个参数是 `.cols` ，它用来选择你想要操作的列。它使用 tidy 选择语法（像 `select()` 那样），因此你可以按照位置、名字和类型来选择变量。
- 第二个参数是 `.fns`，它是应用到数据列上的一个函数或者是一个函数列表，它也可以是像 `~.x/2` 这样 **purrr** 风格的公式语法。

下面是联合 `across()` 和它最喜欢的动词函数 `summarise()`的一些例子。但你也可以联合 `across()` 和任意其他的 **dplyr** 动词函数，我们后面会提及。

```R
starwars %>% 
  summarise(across(where(is.character), ~ length(unique(.x))))
#> # A tibble: 1 x 8
#>    name hair_color skin_color eye_color   sex gender homeworld species
#>   <int>      <int>      <int>     <int> <int>  <int>     <int>   <int>
#> 1    87         13         31        15     5      3        49      38

starwars %>% 
  group_by(species) %>% 
  filter(n() > 1) %>% 
  summarise(across(c(sex, gender, homeworld), ~ length(unique(.x))))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 9 x 4
#>   species    sex gender homeworld
#>   <chr>    <int>  <int>     <int>
#> 1 Droid        1      2         3
#> 2 Gungan       1      1         1
#> 3 Human        2      2        16
#> 4 Kaminoan     2      2         1
#> # … with 5 more rows

starwars %>% 
  group_by(homeworld) %>% 
  filter(n() > 1) %>% 
  summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 10 x 4
#>   homeworld height  mass birth_year
#>   <chr>      <dbl> <dbl>      <dbl>
#> 1 Alderaan    176.  64         43  
#> 2 Corellia    175   78.5       25  
#> 3 Coruscant   174.  50         91  
#> 4 Kamino      208.  83.1       31.5
#> # … with 6 more rows
```

因为 `across()` 通过和 `summarise()` 以及 `mutate()` 结合使用，所以它不会选择分组变量以避免意外地修改它们。

```R
df <- data.frame(g = c(1, 1, 2), x = c(-1, 1, 3), y = c(-1, -4, -9))
df %>% 
  group_by(g) %>% 
  summarise(across(where(is.numeric), sum))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 2 x 3
#>       g     x     y
#>   <dbl> <dbl> <dbl>
#> 1     1     0    -5
#> 2     2     3    -9
```

### 多个函数

你可以通过对第二个参数传入一个函数（包括 lambda 函数）的命名列表来对每个变量同时执行多个函数操作。

```R
min_max <- list(
  min = ~min(.x, na.rm = TRUE), 
  max = ~max(.x, na.rm = TRUE)
)
starwars %>% summarise(across(where(is.numeric), min_max))
#> # A tibble: 1 x 6
#>   height_min height_max mass_min mass_max birth_year_min birth_year_max
#>        <int>      <int>    <dbl>    <dbl>          <dbl>          <dbl>
#> 1         66       264       15     1358              8            896
```

你可以通过 `.names` 参数使用 [glue](https://glue.tidyverse.org/) 规范来控制新建列名的名字：

```R
starwars %>% summarise(across(where(is.numeric), min_max, .names = "{.fn}.{.col}"))
#> # A tibble: 1 x 6
#>   min.height max.height min.mass max.mass min.birth_year max.birth_year
#>        <int>      <int>    <dbl>    <dbl>          <dbl>          <dbl>
#> 1         66        264       15     1358              8            896
```

如果你更喜欢将所有具有相同函数的摘要放到在一起（就是下面的 `min` 结果都在左侧，而 `max` 都在右侧），你必须自己进行扩展调用：

```R
starwars %>% summarise(
  across(where(is.numeric), ~min(.x, na.rm = TRUE), .names = "min_{.col}"),
  across(where(is.numeric), ~max(.x, na.rm = TRUE), .names = "max_{.col}")
)
#> # A tibble: 1 x 9
#>   min_height min_mass min_birth_year max_height max_mass max_birth_year
#>        <int>    <dbl>          <dbl>      <int>    <dbl>          <dbl>
#> 1         66       15              8        264     1358            896
#> # … with 3 more variables: max_min_height <int>, max_min_mass <dbl>,
#> #   max_min_birth_year <dbl>
```

（可能有一天这种操作会通过 `across()` 的一个参数进行支持，但目前我们还没找到解决方案）

### 当前列

如果需要，你可以通过调用 `cur_column()` 来获取当前列的名字。如果你想执行一些语境依赖的相关转换，这可能会很有用：

```R
df <- tibble(x = 1:3, y = 3:5, z = 5:7)
mult <- list(x = 1, y = 10, z = 100)

# df 每列乘以 mult 对应列的值
df %>% mutate(across(all_of(names(mult)), ~ .x * mult[[cur_column()]]))
#> # A tibble: 3 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1     1    30   500
#> 2     2    40   600
#> 3     3    50   700
```

### 陷阱

注意组合 `is.numeric()` 和数值汇总的使用：

```R
df <- data.frame(x = c(1, 2, 3), y = c(1, 4, 9))

df %>% 
  summarise(n = n(), across(where(is.numeric), sd))
#>    n x        y
#> 1 NA 1 4.041452
```

这里 `n` 变成 `NA` 是因为 `n` 是数值的，所以 `across()` 会计算它的标准差，3（常量） 的标准差是 `NA`，你可以最后计算 `n()` 来解决这个问题：

```R
df %>% 
  summarise(across(where(is.numeric), sd), n = n())
#>   x        y n
#> 1 1 4.041452 3
```

另外，你可以显式的将 `n` 排除掉来解决该问题：

```R
df %>% 
  summarise(n = n(), across(where(is.numeric) & !n, sd))
#>   n x        y
#> 1 3 1 4.041452
```

### 其他动词

到目前为止，我们聚焦于 `across()` 和 `summarise()` 的组合使用，但它也可以和其他 **dplyr** 动词函数一起工作：

- •重新缩放所有数值变量到范围 0-1：

  ```R
  rescale01 <- function(x) {
    rng <- range(x, na.rm = TRUE)
    (x - rng[1]) / (rng[2] - rng[1])
  }
  df <- tibble(x = 1:4, y = rnorm(4))
  df %>% mutate(across(where(is.numeric), rescale01))
  #> # A tibble: 4 x 2
  #>       x     y
  #>   <dbl> <dbl>
  #> 1 0     0.385
  #> 2 0.333 1    
  #> 3 0.667 0    
  #> 4 1     0.903
  ```

- 查找所有没有变量缺失值的行：

  ```R
  starwars %>% filter(across(everything(), ~ !is.na(.x)))
  #> # A tibble: 29 x 14
  #>   name  height  mass hair_color skin_color eye_color birth_year sex   gender
  #>   <chr>  <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr> <chr> 
  #> 1 Luke…    172    77 blond      fair       blue            19   male  mascu…
  #> 2 Dart…    202   136 none       white      yellow          41.9 male  mascu…
  #> 3 Leia…    150    49 brown      light      brown           19   fema… femin…
  #> 4 Owen…    178   120 brown, gr… light      blue            52   male  mascu…
  #> # … with 25 more rows, and 5 more variables: homeworld <chr>, species <chr>,
  #> #   films <list>, vehicles <list>, starships <list>
  ```

对一些像 `group_by()`、`count()` 和 `distinct()` 这样的动词，你可以省略汇总函数：

- 寻找所有的唯一值：

  ```R
  starwars %>% distinct(across(contains("color")))
  #> # A tibble: 67 x 3
  #>   hair_color skin_color  eye_color
  #>   <chr>      <chr>       <chr>    
  #> 1 blond      fair        blue     
  #> 2 <NA>       gold        yellow   
  #> 3 <NA>       white, blue red      
  #> 4 none       white       yellow   
  #> # … with 63 more rows
  ```

- 计算给定模式下所有变量的组合数目：

  ```R
  starwars %>% count(across(contains("color")), sort = TRUE)
  #> # A tibble: 67 x 4
  #>   hair_color skin_color eye_color     n
  #>   <chr>      <chr>      <chr>     <int>
  #> 1 brown      light      brown         6
  #> 2 brown      fair       blue          4
  #> 3 none       grey       black         4
  #> 4 black      dark       brown         3
  #> # … with 63 more rows
  ```

`across()` 不能与 `select()` 或者 `rename()` 一起工作，因为后面两个函数已经支持 tidy 选择语法。如果你想要通过函数转换列名，可以使用 `rename_with()`。

## `_if`, `_at`, `_all`

**dplyr** 以前的版本允许以不同的方式将函数应用到多个列：使用带有`_if`、`_at`和`_all`后缀的函数。这些功能解决了迫切的需求而被许多人使用，但现在被取代了。这意味着它们会一直存在，但不会获得任何新功能，只会修复关键的bug。

### 为什么我们喜欢 `across()`？

为什么我们决定从上面的函数迁移到 `across()`？理由如下：

1. `across()` 使它能够表达以前不可能表达的有用的汇总：

   ```R
   df %>%
     group_by(g1, g2) %>% 
     summarise(
       across(where(is.numeric), mean), 
       across(where(is.factor), nlevels),
       n = n(), 
     )
   ```

2. `across()` 减少 **dplyr** 需要提供的函数数量。这使 **dplyr** 更容易使用（因为需要记住的函数更少），也使我们更容易实现新的动词（因为我们只需要实现一个函数，而不是四个）。

3. `across()` 统一了 `_if` 和 `_at` 的语义让我们可以随心按照位置、名字和类型选择变量，甚至是随心所欲地组合它们，这在以前是不可能的。例如，你现在可以转换以 `x` 开头的数值列： `across(where(is.numeric) & starts_with("x"))`.

4. `across()` 不需要使用 `vars()`。`_at()` 函数是 **dplyr** 中唯一你需要手动引用变量名的地方，这让它们比较奇怪且难以记忆。

### 为什么过了这么久才发现 `across()`？

令人失望的是，我们没有早点发现 `across()`，而是经历了几个错误的尝试（首先没有意识到这是一个常见的问题，然后是使用`_each()`函数，最后是使用`_if()/_at()/_all()`函数）。但是 `across()` 的开发工作离不开以下三个最新发现：

- 你可以有一个数据框的列，它本身就是一个数据框。这是由 base R 提供的，但它并没有很好的文档，我们花了一段时间才发现它是有用的，而不仅仅是理论上的好奇。

- 我们可以使用数据框让汇总函数返回多列。
- 我们可以使用没有外部名称作为将数据框列解包为单独列的约定。

### 你如何转移已经存在的代码？

幸运的是，将已有的代码转换为使用 `across()` 实现通常是非常直观的：

- 去掉函数 `_if()`, `_at()` and `_all()` 后缀

- 调用 `across()`，第一个参数如下：

  1. 对于 `_if()`，原来的第二个参数包裹进 `where()`
  2. 对于 `_at()`，原来的参数，如果有 `vars()` 包裹则移除
  3. 对于 `_all()`，使用`everything()`

  后面如果还有参数，保持原样即可。

例如：

```R
df %>% mutate_if(is.numeric, mean, na.rm = TRUE)
# ->
df %>% mutate(across(where(is.numeric), mean, na.rm = TRUE))

df %>% mutate_at(vars(c(x, starts_with("y"))), mean)
# ->
df %>% mutate(across(c(x, starts_with("y")), mean, na.rm = TRUE))

df %>% mutate_all(mean)
# ->
df %>% mutate(across(everything(), mean))
```

这个规则有些意外情况：

- `rename_*()` 和 `select_*()` 遵循不同的模式。它们已经有选择语义，所以通常以与 `across()` 不同的方式使用，我们需要使用新的 `rename_with()` 代替。

- 先前 `filter()` 和 `all_vars()` 与 `any_vars()` 帮助函数配对使用。现在，`across()` 等价于 `all_vars()`，然而没有 `any_vars()` 的直接替代品，不过你可以自己创建一个：

  ```R
  df <- tibble(x = c("a", "b"), y = c(1, 1), z = c(-1, 1))
  
  # 找到满足每一个数值列都大于 0 的所有的行
  df %>% filter(across(where(is.numeric), ~ .x > 0))
  #> # A tibble: 1 x 3
  #>   x         y     z
  #>   <chr> <dbl> <dbl>
  #> 1 b         1     1
  
  # 找到满足任何一个数值列都大于 0 的所有的行
  rowAny <- function(x) rowSums(x) > 0
  df %>% filter(rowAny(across(where(is.numeric), ~ .x > 0)))
  #> # A tibble: 2 x 3
  #>   x         y     z
  #>   <chr> <dbl> <dbl>
  #> 1 a         1    -1
  #> 2 b         1     1
  ```

- 当在 `mutate()` 中使用时，所有 `across()` 执行的转换都一次性完成。这与 `mutate_if()`、`mutate_at()` 和 `mutate_all()` 不同，后者一次只完成一个转换。我们希望大家不会对这种新行为感到惊讶：

  ```R
  df <- tibble(x = 2, y = 4, z = 8)
  df %>% mutate_all(~ .x / y)
  #> # A tibble: 1 x 3
  #>       x     y     z
  #>   <dbl> <dbl> <dbl>
  #> 1   0.5     1     8
  
  df %>% mutate(across(everything(), ~ .x / y))
  #> # A tibble: 1 x 3
  #>       x     y     z
  #>   <dbl> <dbl> <dbl>
  #> 1   0.5     1     2
  ```



### 小结

**dplyr** 的开发者们通过 `across()` 简化了 **dplyr** 对于一些数据复杂操作的处理逻辑，提高了整体的学习和使用效率，让我们使用者更关注于逻辑而非实现上。点个赞！