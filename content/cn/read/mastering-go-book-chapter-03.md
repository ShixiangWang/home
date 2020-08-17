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

一般情况下我们使用 Go 切片，少量情况，如我们存储一个固定长度的数据时，才使用数组。

切片传递地址，所以非常高效。

基本使用：

```go
package main

import "fmt"

func main() {
	s1 := make([]int, 5)
	reSlice := s1[1:3]
	fmt.Println(s1)
	fmt.Println(reSlice)

	reSlice[0] = -100
	reSlice[1] = 123456
	fmt.Println(s1)
	fmt.Println(reSlice)
}
```

运行：

```sh
$ go run ./0023-reslice.go 
[0 0 0 0 0]
[0 0]
[0 -100 123456 0 0]
[-100 123456]
```

`len()` 函数获取切片长度，`cap()` 函数获取容量。

示例：

```go
package main

import "fmt"

func printSlice(x []int) {
	for _, number := range x {
		fmt.Print(number, " ")
	}
	fmt.Println()
}

func main() {
	aSlice := []int{-1, 0, 4}
	fmt.Printf("aSlice: ")
	printSlice(aSlice)

	fmt.Printf("Cap: %d, Length: %d\n", cap(aSlice), len(aSlice))
	aSlice = append(aSlice, -100)
	fmt.Printf("aSlice: ")
	printSlice(aSlice)
	fmt.Printf("Cap: %d, Length: %d\n", cap(aSlice), len(aSlice))

	aSlice = append(aSlice, -2)
	aSlice = append(aSlice, -3)
	aSlice = append(aSlice, -4)
	printSlice(aSlice)
	fmt.Printf("Cap: %d, Length: %d\n", cap(aSlice), len(aSlice))
}

```

运行：

```sh
$ go run ./0024-lenCap.go 
aSlice: -1 0 4 
Cap: 3, Length: 3
aSlice: -1 0 4 -100 
Cap: 6, Length: 4
-1 0 4 -100 -2 -3 -4 
Cap: 12, Length: 7
```

字节切片常用于文件输入输出操作。

`copy()` 函数用于创建一个切片副本。

> You should be very careful when using the copy() function on slices because the built-in copy(dst, src) copies the minimum of the len(dst) and len(src) elements.

几种情况：

```go
package main

import "fmt"

func main() {

	// Part1: a6 比 a4 大
	// a4 拷贝到 a6 还有元素保留
	a6 := []int{-10, 1, 2, 3, 4, 5}
	a4 := []int{-1, -2, -3, -4}
	fmt.Println("a6:", a6)
	fmt.Println("a4:", a4)
	copy(a6, a4)
	fmt.Println("a6:", a6)
	fmt.Println("a4:", a4)
	fmt.Println()

	// Part2: a4 比 a6 小
	// a6 拷贝到 a4 有元素拷贝不过去
	a6 = []int{-10, 1, 2, 3, 4, 5}
	a4 = []int{-1, -2, -3, -4}
	fmt.Println("a6:", a6)
	fmt.Println("a4:", a4)
	copy(a4, a6)
	fmt.Println("a6:", a6)
	fmt.Println("a4:", a4)
	fmt.Println()

	// Part3：拷贝有 4 个元素的数组到有 6 个元素的切片
	// [0:] 将数组转化为切片，不然无法使用 copy
	array4 := [4]int{4, -4, 4, -4}
	s6 := []int{1, 1, -1, -1, 5, -5}
	copy(s6, array4[0:])
	fmt.Println("array4:", array4[0:])
	fmt.Println("s6:", s6)
	fmt.Println()

	// Part4: 拷贝切片到数组
	array5 := [5]int{5, -5, 5, -5, 5}
	s7 := []int{7, 7, -7, -7, 7, -7, 7}
	copy(array5[0:], s7)
	fmt.Println("array5:", array5)
	fmt.Println("s7:", s7)
}
```

运行：

```sh
$ go run ./0025-copySlice.go 
a6: [-10 1 2 3 4 5]
a4: [-1 -2 -3 -4]
a6: [-1 -2 -3 -4 4 5]
a4: [-1 -2 -3 -4]

a6: [-10 1 2 3 4 5]
a4: [-1 -2 -3 -4]
a6: [-10 1 2 3 4 5]
a4: [-10 1 2 3]

array4: [4 -4 4 -4]
s6: [4 -4 4 -4 5 -5]

array5: [7 7 -7 -7 7]
s7: [7 7 -7 -7 7 -7 7]
```