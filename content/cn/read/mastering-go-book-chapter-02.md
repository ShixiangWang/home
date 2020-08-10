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

代码见 [这里](./go)。

```sh
$ gcc -c callClib/*.c
$ ar rs callC.a *.o  # 生成静态链接文件
$ go build ./0015-callC.go
```