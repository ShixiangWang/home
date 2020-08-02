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
