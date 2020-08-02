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

