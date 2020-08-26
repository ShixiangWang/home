---
title: "《Mastering Go》第四章笔记"
author: "王诗翔"
date: "2020-08-26"
slug: ""
categories: [golang]
tags: [golang, datatype]
---

### Go 结构体

构建结构体：

```go
package main

import "fmt"

func main() {
	type XYZ struct {
		X int
		Y int
		Z int
	}

	var s1 XYZ
	fmt.Println(s1.Y, s1.Z)

	p1 := XYZ{23, 12, -2}
	p2 := XYZ{Z: 12, Y: 13}
	fmt.Println(p1)
	fmt.Println(p2)

	pSlice := [4]XYZ{}
	pSlice[2] = p1
	pSlice[0] = p2
	fmt.Println(pSlice)
	p2 = XYZ{1, 2, 3}
	fmt.Println(pSlice)

}
```

运行：

```sh
$ go run ./0036-structures.go 
0 0
{23 12 -2}
{0 13 12}
[{0 13 12} {0 0 0} {23 12 -2} {0 0 0}]
[{0 13 12} {0 0 0} {23 12 -2} {0 0 0}]
```

### 结构体指针

```go
package main

import "fmt"

type myStructure struct {
	Name    string
	Surname string
	Height  int32
}

func createStruct(n, s string, h int32) *myStructure {
	if h > 300 {
		h = 0
	}

	return &myStructure{n, s, h}
}

func retStructure(n, s string, h int32) myStructure {
	if h > 300 {
		h = 0
	}
	return myStructure{n, s, h}
}

func main() {
	s1 := createStruct("Mihalis", "Tsoukalos", 123)
	s2 := retStructure("Mihalis", "Tsoukalos", 123)
	fmt.Println((*s1).Name)
	fmt.Println(s2.Name)
	fmt.Println(s1)
	fmt.Println(s2)
}
```

运行：

```sh
$ go run ./0037-pointerStructure.go
Mihalis
Mihalis
&{Mihalis Tsoukalos 123}
{Mihalis Tsoukalos 123}
```


### new 关键字

```go
sP := new([]aStructure)
```

> `new` 和 `make` 的区别在于 `make` 创建的变量已经进行了适当的初始化，仅能应用于 maps、channels 和 slices，它不会返回地址（即指针）。

### 元组

Go 没有支持元组类型，但有隐形的元组实现。

```go
min, _ := strconv.ParseFloat(arguments[1], 64)
```

下面是一个例子：

```go
package main

import "fmt"

func retThree(x int) (int, int, int) {
	return 2 * x, x * x, -x
}

func main() {
	fmt.Println(retThree(10))
	n1, n2, n3 := retThree(20)
	fmt.Println(n1, n2, n3)

	n1, n2 = n2, n1
	fmt.Println(n1, n2, n3)

	x1, x2, x3 := n1*2, n1*n1, -n1
	fmt.Println(x1, x2, x3)
}

```

运行：

```sh
$ go run ./0038-tuples.go 
20 100 -10
40 400 -20
400 40 -20
800 160000 -400
```

### 正则表达式和模式匹配

