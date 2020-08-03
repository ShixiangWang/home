---
title: "《Mastering Go》第一章笔记"
author: "王诗翔"
date: "2020-08-03"
lastmod: "2020-08-03"
slug: ""
categories: go
tags:
- go
- os
---

### godoc 使用

```bash
go doc fmt.Printf
go doc fmt
# Open a Go doc server
godoc -http=:8001
```

### 运行和编译 go 代码

```go
package main

import "fmt"

func main() {
	fmt.Println("This is a sample Go program!")
}
```

使用 `go run filename` 运行代码文件；使用 `go buils filename` 编译 go 代码形成可执行文件。

### 下载 go 包

```bash
go get -v 包URL地址
```

删除下载安装生成的中间文件

```bash
go clean -i -v -x 包URL地址
```

### stdin, stdout, stderr

对应 `os.Stdin`, `os.Stdout`, `os.Stderr`.

### 打印 output

```go
package main

import "fmt"

func main() {
	v1 := "123"
	v2 := 123
	v3 := "Have a nice day\n"
	v4 := "abc"

	fmt.Print(v1, v2, v3, v4)
	fmt.Println()
	fmt.Println(v1, v2, v3, v4)
	fmt.Print(v1, " ", v2, " ", v3, " ", v4, "\n")
	fmt.Printf("%s%d %s %s\n", v1, v2, v3, v4)
}
```

S 家族函数，如 `Sprint()` 用于创建字符串；F 家族函数用于使用 `io.Writer` 将内容写入文件。

### 使用标准输出

`io` 包提供函数，`os` 包提供设备：

```go
package main

import (
	"io"
	"os"
)

func main() {
	myString := ""
	arguments := os.Args
	if len(arguments) == 1 {
		myString = "Please give me one argument!"
	} else {
		myString = arguments[1]
	}

	io.WriteString(os.Stdout, myString)
	io.WriteString(os.Stdout, "\n")
}
```

### 从标准输入读入

`bufio` 包用来批处理数据（文件）。

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	var f *os.File
	f = os.Stdin
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		fmt.Println(">", scanner.Text())
	}
}
```

下面 `CTRL + D` 以告诉终端停止输入。

```sh
$ go run ./0005-stdin.go 
hello world!
```

### 处理命令行参数

下面是一个找到最小值、最大值的命令行程序。

```go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	if len(os.Args) == 1 {
		fmt.Println("Please give one or two floats.")
		os.Exit(1)
	}

	arguments := os.Args
	min, _ := strconv.ParseFloat(arguments[1], 64)
	max := min

	for i := 2; i < len(arguments); i++ {
		n, _ := strconv.ParseFloat(arguments[i], 64)
		if n < min {
			min = n
		}
		if n > max {
			max = n
		}
	}

	fmt.Println("Min:", min)
	fmt.Println("Max:", max)
}

```

运行：

```sh
$ go run ./0006-cla.go 1.2 0.9 3
Min: 0.9
Max: 3
```
