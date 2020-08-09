---
title: "tidyverse 新操作符{{}}——更好的非标准计算"
author: "王诗翔"
date: "2019-08-04"
lastmod: "2019-08-04"
slug: ""
categories: [r]
tags: [r, rlang, tidyeval, tidyverse]
---

> 本文整理自 <https://www.tidyverse.org/articles/2019/06/rlang-0-4-0/>，有删改

`rlang v0.4.0`引入了新的非标准计算操作符 `{{`。这大大方便了`dplyr`重编程。

```r
library(dplyr)

starwars %>%
  group_by(gender) %>%
  summarise(mass_maximum = max(mass, na.rm = TRUE))
#> # A tibble: 5 x 2
#>   gender        mass_maximum
#>   <chr>                <dbl>
#> 1 <NA>                    75
#> 2 female                  75
#> 3 hermaphrodite         1358
#> 4 male                   159
#> 5 none                   140
```

将需要执行非标准计算的变量名使用`{{}}`括起来即可，不再需要`enquo()`和`!!`操作符。

```r
max_by <- function(data, var, by) {
  data %>%
    group_by({{ by }}) %>%
    summarise(maximum = max({{ var }}, na.rm = TRUE))
}

starwars %>% max_by(height)
#> # A tibble: 1 x 1
#>   maximum
#>     <int>
#> 1     264

starwars %>% max_by(height, by = gender)
#> # A tibble: 5 x 2
#>   gender        maximum
#>   <chr>           <int>
#> 1 <NA>              167
#> 2 female            213
#> 3 hermaphrodite     175
#> 4 male              264
#> 5 none              200
```

注意这个语法和 glue 包是有区别的：

```r
var <- sample(c("woof", "meow", "mooh"), size = 1)
glue::glue("Did you just say {var}?")
#> Did you just say mooh?
```

如果需要传递多个变量，还是使用`...`：

```r
  summarise_by <- function(data, ..., by) {
    data %>%
      group_by({{ by }}) %>%
      summarise(...)
  }
  
  starwars %>%
    summarise_by(
      average = mean(height, na.rm = TRUE),
      maximum = max(height, na.rm = TRUE),
      by = gender
    )
  #> # A tibble: 5 x 3
  #>   gender        average maximum
  #>   <chr>           <dbl>   <int>
  #> 1 <NA>             120      167
  #> 2 female           165.     213
  #> 3 hermaphrodite    175      175
  #> 4 male             179.     264
  #> 5 none             200      200
```

现在`enquos()`和`!!!`只有在需要修改输入或者名字时才需要用到。

- 如果有字符串输入，使用 `.data` 代词：

```r
  max_by <- function(data, var, by) {
    data %>%
      group_by(.data[[by]]) %>%
      summarise(maximum = max(.data[[var]], na.rm = TRUE))
  }
  
  starwars %>% max_by("height", by = "gender")
  #> # A tibble: 5 x 2
  #>   gender        maximum
  #>   <chr>           <int>
  #> 1 <NA>              167
  #> 2 female            213
  #> 3 hermaphrodite     175
  #> 4 male              264
  #> 5 none              200
```

这里magrittr 提供的 `.` 代词并不适用，因为它代表整个数据框，但是`.data`这里代表的是当前的子数据集。

更多阅读：

*  [new programming vignette in ggplot2](https://ggplot2.tidyverse.org/dev/articles/ggplot2-in-packages.html#using-aes-and-vars-in-a-package-function)


