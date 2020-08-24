---
title: "《Mastering Go》第三章笔记"
author: "王诗翔"
date: "2020-08-12"
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

另一个例子：

```go
package main

import "fmt"

func main() {
	aSlice := []int{1, 2, 3, 4, 5}
	fmt.Println(aSlice)
	integer := make([]int, 2)
	fmt.Println(integer)
	integer = nil
	fmt.Println(integer)

	// Create a reference to an existing array
	anArray := [5]int{-1, -2, -3, -4, -5}
	refAnArray := anArray[:]

	fmt.Println(anArray)
	fmt.Println(refAnArray)
	anArray[4] = -100
	fmt.Println(refAnArray)

	// Define 1D and 2D slice
	s := make([]byte, 5)
	fmt.Println(s)
	twoD := make([][]int, 3)
	fmt.Println(twoD)
	fmt.Println()

	// Init 2D slice
	for i := 0; i < len(twoD); i++ {
		for j := 0; j < 2; j++ {
			twoD[i] = append(twoD[i], i*j)
		}
	}

	// Use range to visit and print
	// all elements
	for _, x := range twoD {
		for i, y := range x {
			fmt.Println("i:", i, "value:", y)
		}
		fmt.Println()
	}

}

```

运行：

```sh
$ o run ./0026-slices.go 
[1 2 3 4 5]
[0 0]
[]
[-1 -2 -3 -4 -5]
[-1 -2 -3 -4 -5]
[-1 -2 -3 -4 -100]
[0 0 0 0 0]
[[] [] []]

i: 0 value: 0
i: 1 value: 0

i: 0 value: 0
i: 1 value: 1

i: 0 value: 0
i: 1 value: 2
```

对切片排序：

```go
package main

import (
	"fmt"
	"sort"
)

type aStructure struct {
	person string
	height int
	weight int
}

func main() {
	mySlice := make([]aStructure, 0)
	mySlice = append(mySlice, aStructure{"Mihalis", 180, 90})
	mySlice = append(mySlice, aStructure{"Bill", 134, 45})
	mySlice = append(mySlice, aStructure{"Marietta", 155, 45})
	mySlice = append(mySlice, aStructure{"Epifanios", 144, 50})
	mySlice = append(mySlice, aStructure{"Athina", 134, 40})

	fmt.Println("0:", mySlice)

	sort.Slice(mySlice, func(i, j int) bool {
		return mySlice[i].height < mySlice[j].height
	})
	fmt.Println("<:", mySlice)

	sort.Slice(mySlice, func(i, j int) bool {
		return mySlice[i].height > mySlice[j].height
	})
	fmt.Println(">:", mySlice)
}
```

运行：

```sh
$ go run ./0027-sortSlice.go 
0: [{Mihalis 180 90} {Bill 134 45} {Marietta 155 45} {Epifanios 144 50} {Athina 134 40}]
<: [{Bill 134 45} {Athina 134 40} {Epifanios 144 50} {Marietta 155 45} {Mihalis 180 90}]
>: [{Mihalis 180 90} {Marietta 155 45} {Epifanios 144 50} {Bill 134 45} {Athina 134 40}]
```

### Go Map（映射/字典）

在很多编程语言中也常被成为哈希表，它使用任意固定的数据类型作为值的索引。在 Go 中，Map 的 Key 必须可以比较，即支持 `==` 操作符。

创建：

```go
iMap = make(map[string]int)
```

创建并初始化数据：

```go
aMap := map[string]int {
	"k1": 12
	"k2": 13
}
```

使用 `delete(aMap, "k1")` 可以删除索引内容。

迭代方式：

```go
for key, value := range aMap {
	fmt.Println(key, value)
}
```

下面是一个详细的示例：

```go
package main

import (
	"fmt"
)

func main() {
	iMap := make(map[string]int)
	iMap["k1"] = 12
	iMap["k2"] = 13
	fmt.Println("iMap:", iMap)

	anotherMap := map[string]int{
		"k1": 12,
		"k2": 13,
	}

	fmt.Println("anotherMap:", anotherMap)
	delete(anotherMap, "k1")
	fmt.Println("anotherMap:", anotherMap)

	_, ok := iMap["doesItExist"]
	if ok {
		fmt.Println("Exists!")
	} else {
		fmt.Println("Does NOT exist")
	}

	for key, value := range iMap {
		fmt.Println(key, value)
	}
}

```

运行：

```sh
$ go run ./0028-usingMaps.go
iMap: map[k1:12 k2:13]
anotherMap: map[k1:12 k2:13]
anotherMap: map[k2:13]
Does NOT exist
k1 12
k2 13
```

### Go 常量

使用 `const` 关键字。

```go
const HEIGHT = 180
```

多个常量：

```go
const (
	C1 = "C1C1"
	C2 = "C2C2"
	C3 = "C3C3"
)
```

下面变量声明是等价的：

```go
s1 := "My string"
var s2 = "My string"
var s3 string = "My string"
```

针对常量：

```go
const s1 = "My String"
const s2 string = "My String"
```

两种方式有所不同，第一种 Go 可能会自适应类型。

下面是一个例子：

```go
package main

import "fmt"

func main() {
	const s1 = 123
	const s2 float64 = 123

	var v1 float32 = s1 * 12
	var v2 float32 = s2 * 12

	fmt.Println(v1)
	fmt.Println(v2)
}
```

运行：

```sh
$ go run ./0030-a.go 
# command-line-arguments
./0030-a.go:10:6: cannot use s2 * 12 (type float64) as type float32 in assignment
```

上面例子中由于第二种声明方式限定了常量的类型，所以后面的运算会报错。

### 常量生成器 iota

```go
package main

import "fmt"

type Digit int
type Power2 int

const PI = 3.1415926

const (
	C1 = "C1C1"
	C2 = "C2C2"
	C3 = "C3C3"
)

func main() {
	const s1 = 123
	var v1 float32 = s1 * 12
	fmt.Println(v1)
	fmt.Println(PI)

	const (
		Zero Digit = iota
		One
		Two
		Three
		Four
	)
	fmt.Println(One)
	fmt.Println(Two)

	const (
		p2_0 Power2 = 1 << iota
		_
		p2_2
		_
		p2_4
		_
		p2_6
	)

	fmt.Println("2^0:", p2_0)
	fmt.Println("2^2:", p2_2)
	fmt.Println("2^4:", p2_4)
	fmt.Println("2^6:", p2_6)
}

```

运行：

```sh
$ go run ./0031-constants.go 
1476
3.1415926
1
2
2^0: 1
2^2: 4
2^4: 16
2^6: 64
```

### Go 指针

- `*` 获取指针指向的值。
- `&` 获取指针指向值的内存地址。

指针可以作为参数和返回值。

```go
package main

import "fmt"

func getPointer(n *int) {
	*n = *n * *n
}

func returnPointer(n int) *int {
	v := n * n
	return &v
}

func main() {
	i := -10
	j := 25

	pI := &i
	pJ := &j

	fmt.Println("pI memory:", pI)
	fmt.Println("pJ memory:", pJ)
	fmt.Println("pI value:", *pI)
	fmt.Println("pJ value:", *pJ)

	*pI = 123456
	*pI--
	fmt.Println("i:", i)

	getPointer(pJ)
	fmt.Println("j:", j)
	k := returnPointer(12)
	fmt.Println(*k)
	fmt.Println(k)
}

```

运行：

```sh
$ go run ./0032-pointer.go 
pI memory: 0xc0000140d0
pJ memory: 0xc0000140d8
pI value: -10
pJ value: 25
i: 123455
j: 625
144
0xc000014110
```

### 处理时间和日期

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("Epoch time:", time.Now().Unix())
	t := time.Now()
	fmt.Println(t, t.Format(time.RFC3339))
	fmt.Println(t.Weekday(), t.Day(), t.Month(), t.Year())

	time.Sleep(time.Second)
	t1 := time.Now()
	fmt.Println("Time difference:", t1.Sub(t))

	formatT := t.Format("01 January 2006")
	fmt.Println(formatT)

	loc, _ := time.LoadLocation("Europe/Paris")
	londonTime := t.In(loc)
	fmt.Println("Paris:", londonTime)
}
```

运行：

```sh
$ go run ./0033-usingTime.go 
Epoch time: 1598284256
2020-08-24 23:50:56.714301 +0800 CST m=+0.000107613 2020-08-24T23:50:56+08:00
Monday 24 August 2020
Time difference: 1.004741226s
08 August 2020
Paris: 2020-08-24 17:50:56.714301 +0200 CEST
```

### 解析时间

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"time"
)

func main() {
	var myTime string
	if len(os.Args) != 2 {
		fmt.Printf("usage: %s string\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	myTime = os.Args[1]

	d, err := time.Parse("15:04", myTime)
	if err == nil {
		fmt.Println("Full:", d)
		fmt.Println("Time:", d.Hour(), d.Minute())
	} else {
		fmt.Println(err)
	}
}

```

运行：

```sh
$ go run ./0034-parseTime.go 11:55
Full: 0000-01-01 11:55:00 +0000 UTC
Time: 11 55
```

### 解析日期

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"time"
)

func main() {
	var myDate string
	if len(os.Args) != 2 {
		fmt.Printf("usage: %s string\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	myDate = os.Args[1]

	d, err := time.Parse("02 January 2006", myDate)
	if err == nil {
		fmt.Println("Full:", d)
		fmt.Println("Time:", d.Day(), d.Month(), d.Year())
	} else {
		fmt.Println(err)
	}
}

```