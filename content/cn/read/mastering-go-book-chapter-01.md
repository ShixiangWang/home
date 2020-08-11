---
title: "《Mastering Go》第一章笔记"
author: "王诗翔"
date: "2020-08-03"
lastmod: "2020-08-03"
slug: ""
categories: [golang]
tags: [golang, os]
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

### 关于错误输出

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

	io.WriteString(os.Stdout, "This is Standard output\n")
	io.WriteString(os.Stderr, myString)
	io.WriteString(os.Stderr, "\n")
}
```

运行：

```sh
$ go run ./0007-stderr.go error                
This is Standard output
error
```

### 输出到日志文件

`log` 包提供了与 `fmt` 包一致的输出函数将输出打印到日志设备/文件中。

日志水平有 `debug, info, notice, warning, err, crit, alert, emerg`。

日志设备有 `auth, authpriv, cron` 等，一般定义在 `/etc/syslog.conf` 或 `/etc/rsyslog.conf` 中。

日志服务器，在 MacOS 上的进程是 `syslogd(8)`，Linux 上是 `rsyslogd(8)`。

一个程序：

```go
package main

import (
	"fmt"
	"log"
	"log/syslog"
	"os"
	"path/filepath"
)

func main() {
	programName := filepath.Base(os.Args[0])
	sysLog, err := syslog.New(syslog.LOG_INFO|syslog.LOG_LOCAL7, programName)

	if err != nil {
		log.Fatal(err)
	} else {
		// Set logging output device
		log.SetOutput(sysLog)
	}

	log.Println("LOG_INFO + LOG_LOCAL7: Logging in Go!")

	sysLog, err = syslog.New(syslog.LOG_MAIL, "Some program!")
	if err != nil {
		log.Fatal(err)
	} else {
		log.SetOutput(sysLog)
	}

	log.Println("LOG_MAIL: Logging in Go!")
	fmt.Println("Will you see this?")
}
```

### 关于 `log.Fatal()`

Fatal 状态用于代码有问题，你想要退出程序。

```go
package main

import (
	"fmt"
	"log"
	"log/syslog"
)

func main() {
	sysLog, err := syslog.New(syslog.LOG_ALERT|syslog.LOG_MAIL, "Some program!")
	if err != nil {
		log.Fatal(err)
	} else {
		log.SetOutput(sysLog)
	}

	log.Fatal(sysLog)
	fmt.Println("Will you see this?")
}
```

运行：

```sh
$ go run ./0009-logfatal.go 
exit status 1
$ grep "Some program" /var/log/mail.log
Aug  9 00:28:38 ShixiangWangdeMacBook-Pro Some program![6898]: 2020/08/09 00:28:38 &{17 Some program! ShixiangWangdeMacBook-Pro.local   {0 0} 0xc00000e200}
```

### 关于 `log.Panic()`

有时候程序出于一些目的停止，而你想要获取失败尽可能多的信息，此时使用 Panic 状态函数。

程序：

```go
package main

import (
	"fmt"
	"log"
	"log/syslog"
)

func main() {
	sysLog, err := syslog.New(syslog.LOG_ALERT|syslog.LOG_MAIL, "Some program!")
	if err != nil {
		log.Fatal(err)
	} else {
		log.SetOutput(sysLog)
	}

	log.Panic(sysLog)
	fmt.Println("Will you see this?")
}
```

运行：

```sh
$ go run ./0010-logpanic.go            
panic: &{17 Some program! ShixiangWangdeMacBook-Pro.local   {0 0} 0xc00000e200}

goroutine 1 [running]:
log.Panic(0xc000123f68, 0x1, 0x1)
        /usr/local/Cellar/go/1.14.5/libexec/src/log/log.go:351 +0xac
main.main()
        /Users/wsx/go/src/github.com/ShixiangWang/home/go/0010-logpanic.go:17 +0xe3
exit status 2
```

### Go 的错误处理

Go 有专门的错误类型 `error`。需要注意，程序中有些错误需要我们立即停止程序，而有些错误则需要我们发出警告，这依赖开发者。


#### 错误类型

下面代码演示如何创建一个错误类型。

```go
package main

import (
	"errors"
	"fmt"
)

func returnError(a, b int) error {
	if a == b {
		err := errors.New("Error in returnError() function!")
		return err
	} else {
		return nil
	}
}

func main() {
	err := returnError(1, 2)
	if err == nil {
		fmt.Println("returnError() ended normally!")
	} else {
		fmt.Println(err)
	}

	err = returnError(10, 10)
	if err == nil {
		fmt.Println("returnError() ended normally!")
	} else {
		fmt.Println(err)
	}
}
```

运行：

```sh
$ go run ./0011-newError.go 
returnError() ended normally!
Error in returnError() function!
```

> 使用 `err.Error()` 方法可以从错误类型中生成 string 类型错误信息。

#### 错误处理

一般测试 `err` 是否与 `nil` 相等，如果不是，则使用 `fmt`、`log`包或通过 `panic()` 函数生成错误，使用 `os.Exit()` 退出程序。

下面是一个示例代码：

```go
package main

import (
	"errors"
	"fmt"
	"os"
	"strconv"
)

func main() {
	if len(os.Args) == 1 {
		fmt.Println("Please give one or more floats.")
		os.Exit(1)
	}

	arguments := os.Args
	var err error = errors.New("An error")
	k := 1
	var n float64

	for err != nil {
		if k >= len(arguments) {
			fmt.Println("None of the arguments is a float!")
			return
		}
		n, err = strconv.ParseFloat(arguments[k], 64)
		k++
	}

	min, max := n, n

	for i := 2; i < len(arguments); i++ {
		n, err := strconv.ParseFloat(arguments[i], 64)
		if err == nil {
			if n < min {
				min = n
			}
			if n > max {
				max = n
			}
		}
	}

	fmt.Println("Min:", min)
	fmt.Println("Max:", max)
}
```

测试：

```sh
$ go run ./0012-error.go a b c
None of the arguments is a float!
$ go run ./0012-error.go b c 1 2 3 c -1 100 -200 s
Min: -200
Max: 100
```
