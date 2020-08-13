---
title: "《Mastering Go》第三章笔记"
author: "王诗翔"
date: "2020-08-12"
lastmod: "2020-08-12"
slug: ""
categories: [golang]
tags: [golang, datatype]
---


### Go 循环

#### for 循环

```go
for i := 0; i < 100; i++ {

}
```

可以使用 `break` 和 `continue` 关键字控制循环。

#### while 循环

```go
for condition {

}
```

`do...while` 循环实现：

```go
for ok := true; ok; ok = anExpr {

}
```

#### range

`range` 关键字可以更简单地处理元素迭代。

#### 例子

```go
package main

import "fmt"

func main() {
	for i := 0; i < 100; i++ {
		if i%20 == 0 {
			continue
		}

		if i == 95 {
			break
		}

		fmt.Print(i, " ")
	}

	fmt.Println()
	i := 10
	for {
		if i < 0 {
			break
		}
		fmt.Print(i, " ")
		i--
	}
	fmt.Println()

	i = 0
	anExpression := true
	for ok := true; ok; ok = anExpression {
		if i > 10 {
			anExpression = false
		}

		fmt.Print(i, " ")
		i++
	}
	fmt.Println()

	anArray := [5]int{0, 1, -1, 2, -2}
	for i, value := range anArray {
		fmt.Println("index:", i, "value:", value)
	}
}
```

### Go 数组

声明：

```go
anArray := [4]int{1, 2, 4, -4}
// 多维数组
twoD := [2][3]int{{1, 2, 3}, {4, 5, 6}}
```

一般使用 `len` 提取数组长度用于遍历。

```go
package main

import "fmt"

func main() {
	a := [2][3]int{{1, 2, 3}, {4, 5, 6}}
	for i := 0; i < len(a); i++ {
		v := a[i]
		for j := 0; j < len(v); j++ {
			fmt.Println(v[j])
		}
	}

	for _, v := range a {
		for _, m := range v {
			fmt.Println(m)
		}
	}
}

```

go 的数组有很多缺点：

- 无法修改大小。
- 作为函数参数时传递拷贝，数组任何函数内部的修改在函数运行完后都会被丢弃。
- 如果数组很大，函数传递拷贝效率低。

go 数组虽然是一种基本的数据类型，但我们一般不使用它，它的用处也主要是为 go 其他常用数据类型提供底层实现基础，如切片。

### Go 切片

