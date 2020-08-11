---
title: "《Mastering Go》第二章笔记"
author: "王诗翔"
date: "2020-08-09"
lastmod: "2020-08-09"
slug: ""
categories: [golang]
tags: [golang, internal]
---

### GO 编译器

Go 在编译的过程中做了大量的工作。

`go tool compile xx.go` 生成目标文件。

`go tool compile -pack xx.go` 生成存档文件

`go tool compile -race xx.go` 用于检测 race condition。

`go tool compile -S xx.go` 会生成大量难以理解的输出。

### 垃圾回收

垃圾回收是一个释放内存的过程。

Go 的标准库提供了一些函数还帮助我们理解该过程，下面是一个示例代码。

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func printStats(mem runtime.MemStats) {
	runtime.ReadMemStats(&mem)
	fmt.Println("mem.Alloc:", mem.Alloc)
	fmt.Println("mem.TotalAlloc:", mem.TotalAlloc)
	fmt.Println("mem.HeapAlloc:", mem.HeapAlloc)
	fmt.Println("mem.NumGC:", mem.NumGC)
	fmt.Println("-----")
}

func main() {
	var mem runtime.MemStats
	printStats(mem)

	for i := 0; i < 10; i++ {
		s := make([]byte, 50000000)
		if s == nil {
			fmt.Println("Operation failed!")
		}
	}

	printStats(mem)

	// does more memory allocations using Go slices
	for i := 0; i < 10; i++ {
		s := make([]byte, 100000000)
		if s == nil {
			fmt.Println("Operation failed!")
		}
		time.Sleep(5 * time.Second)
	}

	printStats(mem)
}
```

运行：

```sh
$ go run ./0013-gColl.go 
mem.Alloc: 125176
mem.TotalAlloc: 125176
mem.HeapAlloc: 125176
mem.NumGC: 0
-----
mem.Alloc: 50124320
mem.TotalAlloc: 500175112
mem.HeapAlloc: 50124320
mem.NumGC: 10
-----
mem.Alloc: 122440
mem.TotalAlloc: 1500257896
mem.HeapAlloc: 122440
mem.NumGC: 20
-----
```

在运行 go 文件之前添加 `GODEBUG=gctrace=1` 可以追踪「垃圾回收」。

```sh
GODEBUG=gctrace=1 go run ./0013-gColl.go 
gc 1 @0.080s 0%: 0.010+0.44+0.016 ms clock, 0.084+0.26/0.32/0.67+0.12 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 2 @0.148s 0%: 0.018+0.28+0.003 ms clock, 0.14+0.11/0.28/0.74+0.031 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 3 @0.205s 0%: 0.24+1.9+0.005 ms clock, 1.9+1.4/1.0/0.046+0.044 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 4 @0.257s 0%: 0.026+0.29+0.003 ms clock, 0.20+0/0.27/1.0+0.031 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 5 @0.272s 0%: 0.035+0.39+0.003 ms clock, 0.28+0/0.48/1.1+0.029 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 6 @0.285s 0%: 0.018+0.30+0.017 ms clock, 0.14+0/0.42/0.91+0.14 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
gc 7 @0.294s 0%: 0.022+0.47+0.003 ms clock, 0.17+0.26/0.63/1.8+0.026 ms cpu, 4->4->0 MB, 5 MB goal, 8 P
# command-line-arguments
gc 1 @0.001s 9%: 0.026+2.4+0.015 ms clock, 0.21+0.26/2.8/3.0+0.12 ms cpu, 4->7->6 MB, 5 MB goal, 8 P
gc 2 @0.017s 5%: 0.004+3.4+0.022 ms clock, 0.037+0/5.1/0.88+0.18 ms cpu, 10->10->9 MB, 12 MB goal, 8 P
gc 3 @0.066s 2%: 0.004+3.0+0.004 ms clock, 0.037+0.15/4.9/10+0.033 ms cpu, 17->17->16 MB, 19 MB goal, 8 P
gc 4 @0.134s 2%: 0.006+7.7+0.018 ms clock, 0.049+0.17/11/18+0.14 ms cpu, 29->32->27 MB, 32 MB goal, 8 P
mem.Alloc: 124808
mem.TotalAlloc: 124808
mem.HeapAlloc: 124808
mem.NumGC: 0
-----
gc 1 @0.001s 1%: 0.005+0.16+0.004 ms clock, 0.044+0.071/0.037/0.17+0.035 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 2 @0.027s 0%: 0.049+0.19+0.004 ms clock, 0.39+0.11/0.044/0.041+0.039 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 3 @0.031s 0%: 0.017+0.12+0.002 ms clock, 0.14+0.068/0.083/0.088+0.023 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 4 @0.033s 0%: 0.021+0.11+0.004 ms clock, 0.17+0.092/0.024/0.064+0.032 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 5 @0.038s 0%: 0.044+0.14+0.031 ms clock, 0.35+0.084/0.007/0.077+0.24 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 6 @0.042s 0%: 0.033+0.14+0.003 ms clock, 0.26+0.059/0.065/0.11+0.031 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 7 @0.044s 0%: 0.028+0.11+0.002 ms clock, 0.23+0.10/0.021/0.047+0.023 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 8 @0.046s 0%: 0.017+0.11+0.002 ms clock, 0.13+0.081/0.032/0.036+0.023 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 9 @0.051s 0%: 0.022+0.16+0.006 ms clock, 0.18+0.086/0.036/0.19+0.050 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
gc 10 @0.053s 0%: 0.019+0.15+0.003 ms clock, 0.15+0/0.11/0.12+0.029 ms cpu, 47->47->0 MB, 48 MB goal, 8 P
mem.Alloc: 122064
mem.TotalAlloc: 500176624
mem.HeapAlloc: 122064
mem.NumGC: 10
-----
gc 11 @0.055s 0%: 0.020+0.10+0.004 ms clock, 0.16+0.044/0.040/0.15+0.037 ms cpu, 95->95->0 MB, 96 MB goal, 8 P
gc 12 @5.103s 0%: 0.064+0.13+0.003 ms clock, 0.51+0/0.066/0.092+0.030 ms cpu, 95->95->0 MB, 96 MB goal, 8 P
...
```

以 `4->4->0 MB` 为例，第一个值是 gc 要运行时的堆大小，第二个值是 gc 结束操作时的堆大小，最后的值是活动的堆大小。

### Go 调用 C 代码

通过注释写入 C 代码，再加入导入 C 库，就可以调用 C 程序了。

```go
package main

//#include <stdio.h>
//void callC() {
// printf("Calling C code!\n");
//}
import "C"
import "fmt"

func main() {
	fmt.Println("A Go Statement!")
	C.callC()
	fmt.Println("Another Go statement!")
}
```

> `import "C"` 前面不能存在空行。

示例：

```sh
go run ./0014-cGo.go
A Go Statement!
Calling C code!
Another Go statement!
```

### Go 调用独立 C 代码文件

代码见[这里](https://github.com/ShixiangWang/home/tree/master/go)。

```sh
$ gcc -c callClib/*.c
$ #ar rs callC.a *.o  # 生成静态链接文件
$ #使用 ar 命令会出问题 https://gowa.club/macOS/%E5%9C%A8macOS-Mojave%E4%B8%8A%E7%BC%96%E8%AF%91Lua%E5%A4%B1%E8%B4%A5%E7%9A%84%E7%BB%8F%E5%8E%86.html
$ libtool -static -o callC.a callC.o
$ go build ./0015-callC.go
$ ./0015-callC 
Going to call a C function!
Hello from C!
Going to call another C function!
Go send me This is Mihalis!
All perfectly done!
(base) 
```

### C 代码调用 Go 函数

Go 代码文件内容：

```go
package main

import "C"

//export PrintMessage
func PrintMessage() {
	fmt.Println("A Go function!")
}

//export Multiply
func Multiply(a, b int) int {
	return a * b
}

func main() {
	
}
```

生成 C 共享库：

```sh
$ go build -o usedByC.o -buildmode=c-shared ./0016-usedByC.go
$ file usedByC.o
usedByC.o: Mach-O 64-bit dynamically linked shared library x86_64
```

不要修改生成的 `.h` 和 `.o` 文件。

C 代码：

```c
#include <stdio.h>
#include "usedByC.h"

int main(int argc, char **argv) {
  GoInt x = 12;
  GoInt y = 23;

  printf("About to call a Go function!\n");
  PrintMessage();

  GoInt p = Multiply(x, y);
  printf("Product: %d\n", (int)p);
  printf("It worked!\n");
  return 0;
}
```

编译和运行 C 代码：

```sh
$ gcc -o willUseGo willUseGo.c ./usedByC.o 
$ ./willUseGo 
About to call a Go function!
A Go function!
Product: 276
It worked!
```

### defer 关键字

`defer` 可以指定函数退出时执行的语句，遵循先进后出原则。

示例代码：

```go
package main

import "fmt"

func d1() {
	for i := 3; i > 0; i-- {
		defer fmt.Print(i, " ")
	}
}

func d2() {
	for i := 3; i > 0; i-- {
    // 函数退出时才调用，所以是 0、0、0
		defer func() {
			fmt.Print(i, " ")
		}()
	}
	fmt.Println()
}

func d3() {
	for i := 3; i > 0; i-- {
		defer func(n int) {
			fmt.Print(n, " ")
		}(i)
	}
}

func main() {
	d1()
	d2()
	fmt.Println()
	d3()
	fmt.Println()
}
```

运行：

```sh
$ go run ./0017-defer.go 
1 2 3 
0 0 0 
1 2 3 
```

### Panic 和 Recover

示例代码：

```go
package main

import "fmt"

func a() {
	fmt.Println("Inside a()")
	defer func() {
		if c := recover(); c != nil {
			fmt.Println("Recover inside a()!")
		}
	}()
	fmt.Println("About to call b()")
	b()
	fmt.Println("b() exited!")
	fmt.Println("Exiting a()")
}

func b() {
	fmt.Println("Inside b()")
	panic("Panic in b()!")
	fmt.Println("Exiting b()")
}

func main() {
	a()
	fmt.Println("main() ended!")
}
```

运行：

```sh
$ go run ./0018-panicRecover.go 
Inside a()
About to call b()
Inside b()
Recover inside a()!
main() ended!
```

### 单独使用 panic 函数

前面提到过，这个可以用来显示比较详细的报错信息。

测试代码：

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) == 1 {
		panic("Not enough arguments!")
	}

	fmt.Println("Thanks for the argument(s)!")
}
```


```sh
$ go run ./0019-justPanic.go 
panic: Not enough arguments!

goroutine 1 [running]:
main.main()
        /Users/wsx/go/src/github.com/ShixiangWang/home/go/0019-justPanic.go:10 +0xa9
exit status 2
```

### 查看系统信号

strace(1) 和 dtrace(1) 工具。

### Go 环境

代码：

```go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Print("You are using ", runtime.Compiler, " ")
	fmt.Println("on a", runtime.GOARCH, "machine")
	fmt.Println("Using Go version", runtime.Version())
	fmt.Println("Number of CPUs:", runtime.NumCPU())
	fmt.Println("Number of Goroutines:", runtime.NumGoroutine())
}
```

运行：

```sh
go run ./0020-goEnv.go 
You are using gc on a amd64 machine
Using Go version go1.14.5
Number of CPUs: 8
Number of Goroutines: 1
```

