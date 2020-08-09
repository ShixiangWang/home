---
title: "dplyr编程"
author: "王诗翔"
date: "2019-07-08"
lastmod: "2019-07-08"
slug: ""
categories: [r]
tags: ["r", "dplyr", "meta-programming"]
---

> 本文首先发布于[简书](https://www.jianshu.com/p/5eca388205d4)，本人在对相关知识有进一步理解后对本文进行修改，以便于中文更好地理解。
> 来源：[vignettes/programming.Rmd](https://github.com/tidyverse/dplyr/blob/master/vignettes/programming.Rmd)

大多数 **dplyr** 函数使用非标准计算（NSE）。这是一个术语——意味着它们不遵循通常的计算规则。
相反，它们捕获你键入的表达式并以自定义的方式对其进行计算。这让 **dplyr** 代码有两个主要优点：

- 数据框的操作可以简洁地表达，因为你不需要重复输入数据框名称。例如你可以这样写`filter(df, x == 1, y == 2, z == 3)`来代替`df[df$x == 1 & df$y ==2 & df$z == 3, ]`.
- **dplyr** 可以选择以不同的方式计算结果与base R 相结合。

不幸的是，这些好处不是免费的。有两个主要缺点：

- 大多数dplyr参数不是**透明**。这意味着你不能用一个看似等价的对象代替一个在别处定义的值。换句话说，这个代码：

```
df <- tibble(x = 1:3, y = 3:1)
filter(df, x == 1)
## # A tibble: 1 x 2
##       x     y
##   <int> <int>
## 1     1     3
```

不等价下面这个代码：

```
my_var <- x
filter(df, my_var == 1)
# Error: object 'x' not found
```

或是这个代码：

```
    my_var <- "x"
    filter(df, my_var == 1)
## # A tibble: 0 x 2
## # ... with 2 variables: x <int>, y <int>
```

**这使得很难改变被 dplyr 动词计算的参数来创建函数**（这一点很重要，如果你使用 **dplyr** 进行数据框操作，会发现很好用，但是如果你用它创建函数，你会发现它总是以一种无法被理解的形式报错）。

- **dplyr**代码不明确，取决于在哪里定义了哪些变量, `filter(df, x == y)`可以等价于下面任意一个：

  ```
  df[df$x == df$y, ]
  df[df$x == y, ]
  df[x == df$y, ]
  df[x == y, ]
  ```

这在交互式工作时非常有用（因为它可以节省打字时间和减少打字量，快速发现问题），但使创建函数比你想要的更不可预测。

幸运的是，**dplyr** 提供了克服这些挑战的工具。他们需要多一点打字，但少量的前期工作是值得的，因为他们从长远来看可以帮助你节省时间。

这篇文章有两个目标：

- 演示如何使用dplyr的**pronouns**和**quasiquotation**编写可靠的函数，以减少数据分析代码中的重复。
- 教你基本理论，包括**quosures**——一个存储表达式和环境的数据结构，以及**tidyeval**——底层工具包。

我们先从热身开始，将这个问题与你更熟悉的东西联系起来，然后转向一些实用的工具，然后学习更深层次的理论。

## 热身

您可能没有意识到这一点，但您已经在解决另一个领域中的这类问题方面取得了成功：**字符串**。很明显，这个函数并没有做到你想要的：

```
greet <- function(name) {
  "How do you do, name?"
}
greet("Shixiang")
## [1] "How do you do, name?"
```

这是因为引号`"`对输入进行了捕获：它没有对你输入的东西进行计算，它仅仅将输入作为一个字符串进行存储。一种解决的办法是使用`paste()`函数将字符串粘连起来：

```
greet <- function(name) {
  paste0("How do you do, ", name, "?")
}
greet("Shixiang")
## [1] "How do you do, Shixiang?"
```

另一个方法是使用**glue**包：它允许你“unquote”一个字符串的组件（就是取消括起来），用R表达式的值替换字符串。这让我们可以优雅地实现我们的函数，因为`{name}`被替换为`name`参数的值。

```
greet <- function(name) {
  glue::glue("How do you do, {name}?")
}
greet("Shixiang")
## How do you do, Shixiang?
```

## 编程食谱

下面的食谱引导你了解 **tidyeval** 的基本知识，并以减少 **dplyr** 代码重复为目标。这里的例子有些不真实，因为我们已经将它们简化为非常简单的组件，以使它们更易于理解。它们非常简单，你可能会想知道为什么我们会不厌其烦地写一个函数。但简单地学习这些想法是个好主意。通过这个示例，你可以更好地将它们应用于您将在自己的代码中看到的更复杂的情况。

### 不同的数据集

你已经知道如何用 **dplyr** 动词的第一个参数`data`进行工作，这是因为 **dplyr** 没有对这个参数做任何特殊的处理，因此它是**透明**的。例如，如果你查看以下重复的代码：

```
mutate(df1, y = a + x)
mutate(df2, y = a + x)
mutate(df3, y = a + x)
mutate(df4, y = a + x)
```

你可能准备写一个解决重复的函数：

```
mutate_y <- function(df) {
  mutate(df, y = a + x)
}
```

不幸的是，这种简单的方法存在一个缺点：它可能会失败——如果其中一个变量不存在于数据框中，但存在于全局环境。

```
df1 <- tibble(x = 1:3)
a <- 10
mutate_y(df1)
## # A tibble: 3 x 2
##       x     y
##   <int> <dbl>
## 1     1   11.
## 2     2   12.
## 3     3   13.
```

我们可以通过使用`.data`代词（`pronoun`）进行更明确地指定以修正这种不确定性。如果变量不存在，这会抛出一个信息错误。

```
mutate_y <- function(df) {
  mutate(df, y = .data$a + .data$x)
}

mutate_y(df1)
## Error in mutate_impl(.data, dots): Evaluation error: Column `a`: not found in data.
```

如果这个函数在一个包里面，使用`.data`也会阻止`R CMD check`给出一个关于未定义全局变量的NOTE（假设你已经使用`@importFrom rlang .data`导入`rlang::.data`）。

### 不同的表达式

如果你想要函数的一个参数是变量名（像`x`）或者一个表达式（像`x + y`）是非常困难的，因此 **dplyr** 自动捕获输入（“quote”），即只捕获输入，而不是执行计算，因此它们都不是透明的。让我们从一个简单的情况开始：你想要创建一个变化的分组用于数据汇总。

```
df <- tibble(
  g1 = c(1, 1, 2, 2, 2),
  g2 = c(1, 2, 1, 2, 1),
  a = sample(5),
  b = sample(5)
)

df %>%
  group_by(g1) %>%
  summarise(a = mean(a))
## # A tibble: 2 x 2
##      g1     a
##   <dbl> <dbl>
## 1    1.  2.50
## 2    2.  3.33

df %>%
  group_by(g2) %>%
  summarise(a = mean(a))
## # A tibble: 2 x 2
##      g2     a
##   <dbl> <dbl>
## 1    1.  2.00
## 2    2.  4.50
```

你可能需要这样可以工作

```
my_summarise <- function(df, group_var) {
  df %>%
    group_by(group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)
## Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

**但是不行**。

也许提供字符串作为变量名可以解决？

```
my_summarise(df, "g2")
## Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

也不行。

如果你仔细地查看错误信息，你会发现这两种情况报错是一样的。`group_by()`函数像引号`"`一样工作：它不会计算（执行）它的输入，而是捕获输入。

想要函数工作，我们**需要做两件事情**。我们需要自己先捕获输入（因此`my_summarise()`像`group_by()`一样可以输入一个裸的变量名）；然后我们需要告诉`group_by()`计算已经捕获的输入。

我们要怎样才能捕获输入呢？我们不能使用`""`，因此它会给我们一个字符串。相反，我们需要一个函数它能够捕捉表达式以及它的环境。在base R中我们可以使用两种方式，函数`quote()`以及操作符`~`，但它们都不是我们真正想要的，因此我们需要一个新的函数：`quo()`。

`quo()`像`"`一样工作，它捕获输入而不是执行它。

```
quo(g1)
## <quosure>
##   expr: ^g1
##   env:  global
quo(a + b + c)
## <quosure>
##   expr: ^a + b + c
##   env:  global
quo("a")
## <quosure>
##   expr: ^"a"
##   env:  empty
```

`quo()` 返回一个**quosure**，它是一种特殊类型的公式。后面我们会深入讲解。

既然我们已经捕捉了这个表达式，我们怎么在`group_by`中使用它呢？如果直接使用这个函数的结果作为我们创建函数的输入不会起作用：

```
my_summarise(df, quo(g1))
## Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

我们会得到跟刚才一样的错误，因为我们还没有告诉`group_by()`我们已经处理过quote的问题了，用另一句说就是，我们需要告诉`group_by()`执行计算，因为我们已经提取处理过了。另一种方式说同样的事情就是我们想要**unquote**（去引用）`group_var`。

在 **dplyr**（和通用的 **tidyeval** ）中，你可以使用`!!`告诉动词函数你想要执行计算。联合上面操作，这就是我们想要的了，现在来试一试：

```
my_summarise <- function(df, group_var) {
  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, quo(g1))
## # A tibble: 2 x 2
##      g1     a
##   <dbl> <dbl>
## 1    1.  2.50
## 2    2.  3.33
```

啊哈！

还剩下一步：我们想要函数像`group_by()`一样使用:

```
my_summarise(df, g1)
```

因为没有对象`g1`的存在，所以这不会起作用。我们需要捕捉函数使用者键入的内容并将它捕获，你可以会尝试使用`quo()`：

```
my_summarise <- function(df, group_var) {
  quo_group_var <- quo(group_var)
  print(quo_group_var)

  df %>%
    group_by(!! quo_group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)
## <quosure>
##   expr: ^group_var
##   env:  000000001DF8CAC8
## Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

我使用了`print()`函数让错误的地方更显而易见，这里的问题是：`quo(group_var)`总是返回`~group_var`。而我们想要它替换为`~g1`。

类似字符串，我们不想要`""`，而是想要一些可以将参数变成字符串的函数。这正是`enquo()`的工作。`enquo()`使用一些黑魔法来看待这些参数，查看用户键入了什么，然后将该值返回为`quosure`（技术上来说，这是可以实现的，因为函数的参数都使用一种特殊的数据结构**promise**进行执行）。

```
my_summarise <- function(df, group_var) {
  group_var <- enquo(group_var)
  print(group_var)

  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1)
## <quosure>
##   expr: ^g1
##   env:  global
## # A tibble: 2 x 2
##      g1     a
##   <dbl> <dbl>
## 1    1.  2.50
## 2    2.  3.33
```

（如果你对base R中`quote()`和`substitute()`很熟悉的话，`quo()`等价于`quote()`而`enquo()`等价于`substitute()`。）

你可能在想，我们怎样将这个例子拓展为处理多个分组变量，后面我们会提到。

### 不同的输入变量

现在让我们来处理一些更复杂的问题。下面代码显示了重复的`summarise()`语句，计算三个汇总量，根据输入变量相应改变。

```
summarise(df, mean = mean(a), sum = sum(a), n = n())
## # A tibble: 1 x 3
##    mean   sum     n
##   <dbl> <int> <int>
## 1    3.    15     5
summarise(df, mean = mean(a * b), sum = sum(a * b), n = n())
## # A tibble: 1 x 3
##    mean   sum     n
##   <dbl> <int> <int>
## 1  9.60    48     5
```

为了将它转换为函数，我们首先检测最基本的交互式方法：我们`quo()`变量，然后使用`!!`unquo变量。注意，我们可以在复杂的表达式中使用`!!`。

```
my_var <- quo(a)
summarise(df, mean = mean(!! my_var), sum = sum(!! my_var), n = n())
## # A tibble: 1 x 3
##    mean   sum     n
##   <dbl> <int> <int>
## 1    3.    15     5
```

你可以用`quo()`将dplyr函数调用括起来，从 **dplyr** 的角度看下发生了什么。这是调试一个非常有用的工具。

```
quo(summarise(df,
  mean = mean(!! my_var),
  sum = sum(!! my_var),
  n = n()
))
## <quosure>
##   expr: ^summarise(df, mean = mean(^a), sum = sum(^a), n = n())
##   env:  global
```

现在我们可以将代码转换为一个函数（记得用`enquo()`替换`quo()`），检查是否工作：

```
my_summarise2 <- function(df, expr) {
  expr <- enquo(expr)

  summarise(df,
    mean = mean(!! expr),
    sum = sum(!! expr),
    n = n()
  )
}
my_summarise2(df, a)
## # A tibble: 1 x 3
##    mean   sum     n
##   <dbl> <int> <int>
## 1    3.    15     5
my_summarise2(df, a * b)
## # A tibble: 1 x 3
##    mean   sum     n
##   <dbl> <int> <int>
## 1  9.60    48     5
```

### 不同的输入和输出变量

下一个挑战是变化输出变量名字：

```
mutate(df, mean_a = mean(a), sum_a = sum(a))
## # A tibble: 5 x 6
##      g1    g2     a     b mean_a sum_a
##   <dbl> <dbl> <int> <int>  <dbl> <int>
## 1    1.    1.     1     3     3.    15
## 2    1.    2.     4     2     3.    15
## 3    2.    1.     2     1     3.    15
## 4    2.    2.     5     4     3.    15
## # ... with 1 more row
mutate(df, mean_b = mean(b), sum_b = sum(b))
## # A tibble: 5 x 6
##      g1    g2     a     b mean_b sum_b
##   <dbl> <dbl> <int> <int>  <dbl> <int>
## 1    1.    1.     1     3     3.    15
## 2    1.    2.     4     2     3.    15
## 3    2.    1.     2     1     3.    15
## 4    2.    2.     5     4     3.    15
## # ... with 1 more row
```

这个代码跟前面的例子相似，但是有两个新的问题：

- 我们通过将字符串粘连在一起创建新的变量名，因此我们需要`quo_name()`将输入表达式转换为字符串。
- `!! mean_name = mean(!! expr)` 不是合法的R代码，我们要使用由`rlang`提供的`:=`帮助函数。

```
my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))

  mutate(df,
    !! mean_name := mean(!! expr),
    !! sum_name := sum(!! expr)
  )
}

my_mutate(df, a)
## # A tibble: 5 x 6
##      g1    g2     a     b mean_a sum_a
##   <dbl> <dbl> <int> <int>  <dbl> <int>
## 1    1.    1.     1     3     3.    15
## 2    1.    2.     4     2     3.    15
## 3    2.    1.     2     1     3.    15
## 4    2.    2.     5     4     3.    15
## # ... with 1 more row
```

### 捕捉多个变量

要是能将`my_summarise()`扩展可以接收任何数目的分组变量就好了。我们需要3个改变：

- 在函数定义中使用`...`以便于我们的函数能够接收任意数目的参数。
- 使用`quos()`去捕获所有的`...`作为公式列表。
- 使用`!!!`替换`!!`将参数一个个切进`group_by()`。

```
my_summarise <- function(df, ...) {
  group_var <- quos(...)

  df %>%
    group_by(!!! group_var) %>%
    summarise(a = mean(a))
}

my_summarise(df, g1, g2)
## # A tibble: 4 x 3
## # Groups:   g1 [?]
##      g1    g2     a
##   <dbl> <dbl> <dbl>
## 1    1.    1.  1.00
## 2    1.    2.  4.00
## 3    2.    1.  2.50
## 4    2.    2.  5.00
```

`!!!`将元素列表作为参数并把它们切开放入当前的函数调用。

```
args <- list(na.rm = TRUE, trim = 0.25)
quo(mean(x, !!! args))
## <quosure>
##   expr: ^mean(x, na.rm = TRUE, trim = 0.25)
##   env:  global

args <- list(quo(x), na.rm = TRUE, trim = 0.25)
quo(mean(!!! args))
## <quosure>
##   expr: ^mean(^x, na.rm = TRUE, trim = 0.25)
##   env:  global
```

既然你已经通过实际例子学习了一些tidyeval的基础，我们现在深入理论海洋，泛化所学以应对新的情况。

## Quoting

`Quoting`是捕获表达式而不是执行（`evaluate`，直译为评估似乎不体贴）它的行为。所有基于表达式的函数quote它们的参数并将R代码作为表达式而不是执行代码的结果。如果你是一个R用户，你可能在标准的基础上`quote`过表达式。一个最重要的`quote`操作符是**formula**，它在统计模型中经常被使用。

```
disp ~ cyl + drat
## disp ~ cyl + drat
```

base R中另一个`quote`操作符是`quote()`，它返回一个原始表达式，而不是公式。

```
# 计算表达式的值
toupper(letters[1:5])
## [1] "A" "B" "C" "D" "E"

# 捕获表达式
quote(toupper(letters[1:5]))
## toupper(letters[1:5])
```

（注意尽管我们使用双引号`"`指代quote，但是`"`并不是`quote`操作符。在这个语境中，`"`指代一个生成的字符串而不是表达式）

在实践中，公式是两者中更好的选项，因为它捕获了代码以及它执行的**环境**。这是非常重要的——即使简单地表达式在不同的环境中生成的结果值可能不同。例如，下面两个表达式`x`指不同的值：

```
f <- function(x) {
  quo(x)
}

x1 <- f(10)
x2 <- f(100)
```

如果你将它们输出，表达式看起来是一样的。

```
x1
## <quosure>
##   expr: ^x
##   env:  00000000182E3490
x2
## <quosure>
##   expr: ^x
##   env:  000000001B6D2E90
```

但是如果你使用`rlang::get_env()`检查它们的环境——结果是不同的。

```
library(rlang)

get_env(x1)
## <environment: 0x00000000182e3490>
get_env(x2)
## <environment: 0x000000001b6d2e90>
```

进一步，当我们使用`rlang::eval_tidy()`执行那么公式时，我们可以看到它们会生成不同的值：

```
eval_tidy(x1)
## [1] 10
eval_tidy(x2)
## [1] 100
```

这是R一个关键的属性：一个名字能够指代不同环境中不同的数值。这对**dplyr**也同样重要，因为它允许你在函数调用中整合变量和对象。

```
user_var <- 1000
mtcars %>% summarise(cyl = mean(cyl) * user_var)
##    cyl
## 1 6188
```

当一个变量记录了一个环境，它被称为有了圈地（`enclosure`）。这正是R函数有时被称为`closures`的原因。

```
typeof(mean)
## [1] "closure"
```

基于这个原因，我们使用一个特殊的名字**quosures**来指代单边公式：单边公式时带有环境的`quotes`。

Quosures是标准的R对象，它们可以存储在变量中并被检查：

```
var <- ~toupper(letters[1:5])
var
## ~toupper(letters[1:5])

# 你可以抽取表达式
get_expr(var)
## toupper(letters[1:5])

# 或者检查它的enclosure
get_env(var)
## <environment: R_GlobalEnv>
```

## Quasiquotation

> 简而言之，Quasi-quotation使人们能够在给定实例中引入代表语言表达的符号，并将其用作不同实例中的语言表达。 — [Willard van Orman Quine](https://en.wikipedia.org/wiki/Quasi-quotation)

自动quote变量使得dplyr非常方便交互使用。但是如果你想用dplyr编程，你需要一些方法来间接引用变量 。此问题的解决方案是**quasiquotation**，它允许你直接在被quote的表达式内进行执行（evaluate）。

Quasiquotation是由Willard van Orman Quine在20世纪40年代创造的，并且是在20世纪70年代被LISP社区编程采用。所有tidyeval框架中基于表达式的函数都支持quasiquotation。执行quote会取消表达式部分的quotation。有三种类型的unquote：

- basic
- unquote splicing
- unquoting names

### Unquoting

第一个重要的操作是基本的`unquote()`，它以函数的形式`UQ()`，`!!`是其语法糖。

```
# 这里我们捕获letters[1:5]`作为表达式
quo(toupper(letters[1:5]))
## <quosure>
##   expr: ^toupper(letters[1:5])
##   env:  global

# 这里我们捕获`letters[1:5]`的值
quo(toupper(!! letters[1:5]))
## <quosure>
##   expr: ^toupper(<chr: "a", "b", "c", "d", "e">)
##   env:  global
quo(toupper(UQ(letters[1:5])))
## <quosure>
##   expr: ^toupper(<chr: "a", "b", "c", "d", "e">)
##   env:  global
```

`unquote`其他被`quote`的表达式也是可能的。`unquote`这样的符号对象提供了操作表达式的一种强大工具。

```
var1 <- quo(letters[1:5])
quo(toupper(!! var1))
## <quosure>
##   expr: ^toupper(^letters[1:5])
##   env:  global
```

你可以安全的unquote `quosures`，因为它们会记录它们自己的环境，而且 tidyeval 函数都知道如何执行它们。

```
my_mutate <- function(x) {
  mtcars %>%
    select(cyl) %>%
    slice(1:4) %>%
    mutate(cyl2 = cyl + (!! x))
}

f <- function(x) quo(x)
expr1 <- f(100)
expr2 <- f(10)

my_mutate(expr1)
## # A tibble: 4 x 2
##     cyl  cyl2
##   <dbl> <dbl>
## 1    6.  106.
## 2    6.  106.
## 3    4.  104.
## 4    6.  106.
my_mutate(expr2)
## # A tibble: 4 x 2
##     cyl  cyl2
##   <dbl> <dbl>
## 1    6.   16.
## 2    6.   16.
## 3    4.   14.
## 4    6.   16.
```

当引导符`!`出问题时，函数形式更加有用。

```
my_fun <- quo(fun)
quo(!! my_fun(x, y, z))
## Error in my_fun(x, y, z): 没有"my_fun"这个函数
quo(UQ(my_fun)(x, y, z))
## <quosure>
##   expr: ^^fun(x, y, z)
##   env:  global

my_var <- quo(x)
quo(filter(df, !! my_var == 1))
## <quosure>
##   expr: ^filter(df, (^x) == 1)
##   env:  global
quo(filter(df, UQ(my_var) == 1))
## <quosure>
##   expr: ^filter(df, (^x) == 1)
##   env:  global
```

`UQ()`生成了一个包含公式的quosure。这确保当quosure被执行时，它可以找到正确的环境。在一些特定的代码生成环境中，你可能仅仅想使用表达式而忽略环境，这是`UQE()`的工作。

```
quo(UQE(my_fun)(x, y, z))
## Warning: `UQE()` is deprecated. Please use `!! get_expr(x)`
## <quosure>
##   expr: ^fun(x, y, z)
##   env:  global
quo(filter(df, UQE(my_var) == 1))
## Warning: `UQE()` is deprecated. Please use `!! get_expr(x)`
## <quosure>
##   expr: ^filter(df, x == 1)
##   env:  global
```

### Unquote-splicing

第二种unquote操作符是unquote-splicing. 它的函数形式是`UQS()`，语法缩写是`!!!`。它以一个向量为输入，并将其中的每一个元素一个一个插入函数调用中去。

```
quo(list(!!! letters[1:5]))
## <quosure>
##   expr: ^list("a", "b", "c", "d", "e")
##   env:  global
```

这种方式的一个有用特点是向量名可以变成参数名：

```
x <- list(foo = 1L, bar = quo(baz))
quo(list(!!! x))
## <quosure>
##   expr: ^list(foo = 1L, bar = ^baz)
##   env:  global
```

这让使用 **dplyr** 动词进行编程非常简单：

```
args <- list(mean = quo(mean(cyl)), count = quo(n()))
mtcars %>%
  group_by(am) %>%
  summarise(!!! args)
## # A tibble: 2 x 3
##      am  mean count
##   <dbl> <dbl> <int>
## 1    0.  6.95    19
## 2    1.  5.08    13
```

### 设置参数名

最后的unquote操作符是设置参数名， `:=`。

> `:=` supports unquoting on both the LHS and the RHS.

LHS的规则有点不同：unquote的操作对象要是一个字符串或者符号。

```
mean_nm <- "mean"
count_nm <- "count"

mtcars %>%
  group_by(am) %>%
  summarise(
    !! mean_nm := mean(cyl),
    !! count_nm := n()
  )
## # A tibble: 2 x 3
##      am  mean count
##   <dbl> <dbl> <int>
## 1    0.  6.95    19
## 2    1.  5.08    13
```

