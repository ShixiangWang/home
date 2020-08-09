---
title: 创建和使用shell函数
author: 王诗翔
date: 2017-11-26
categories: [shell]
tags: [linux, shell, note]
---

*来源： Linux命令行与shell脚本编程大全*

**内容**

>- 基本的脚本函数
>- 返回值
>- 在函数中使用变量
>- 数组变量和函数
>- 函数递归
>- 创建库
>- 在命令行上使用函数



我们可以将shell脚本代码放进函数中封装起来，这样就能在脚本中的任何地方多次使用它了。

下面我们来逐步了解如何创建自己的shell脚本函数并在应用中使用它们。

<!-- more -->

## 基本的脚本函数

函数是一个脚本代码块，我们可以为其命名并在代码中任何位置重用。要在脚本中使用该代码块，只要使用所起的函数名就行了。

### 创建函数

有两种格式可以创建函数。第一种格式是使用关键字`function`，后跟分配给该代码块的函数名。

```shell
funtion name{
	commands
}
```

`name`属性定义了赋予函数的唯一名称，`commands`是构成函数的一条或多条bash shell命令。

第二种格式更接近其他编程语言中定义函数的方式：

```shell
name() {
  commands
}
```

### 使用函数

要使用函数，只需要像其他shell命令一样，在行中指定函数名就行了。

```shell
wsx@wsx:~/tmp$ cat test1
#!/bin/bash
# using a function in a script

function func1 {
    echo "This is an example of a function"
}

count=1
while [ $count -le 5 ]
do
  func1
  count=$[ $count + 1 ]
done

echo "This is the end of the loop"
func1
echo "Now, this is the end of the script"

wsx@wsx:~/tmp$ ./test1
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is an example of a function
This is the end of the loop
This is an example of a function
Now, this is the end of the script
```

注意，定义函数名`func1`的后面一定要跟`{`有空格隔开，不然会报错。**函数要先定义再使用，接触过编程的想必不陌生吧**。

## 返回值

bash shell会把函数当做一个小型脚本，运行结束时会返回一个退出状态码，有3种不同的方法来为函数生成退出状态码。

### 默认退出状态码

默认函数的退出状态码是函数中最后一条命令返回的退出状态码。我们可以使用标准变量`$?`在函数执行结束后确定函数的状态码。

```shell
wsx@wsx:~/tmp$ cat test2
#!/bin/bash
# testing the exit status of a function

func1() {
	echo "trying to display a non-existent file"
	ls -l badfile
}

echo "testing the function"
func1
echo "The exit status is: $?"
wsx@wsx:~/tmp$ ./test2
testing the function
trying to display a non-existent file
ls: 无法访问'badfile': 没有那个文件或目录
The exit status is: 2
```

函数的退出状态码是2，说明函数的最后一条命令没有成功运行。但你无法知道函数中其他命令中是否成功运行，我们来看看下面一个例子。

```shell
wsx@wsx:~/tmp$ cat test3
#!/bin/bash
# testing the exit status of a function

func1(){
	ls -l badfile
	echo "This was a test of a bad command"
}

echo "testing the function:"
func1
echo "The exit status is: $?"
wsx@wsx:~/tmp$ ./test3
testing the function:
ls: 无法访问'badfile': 没有那个文件或目录
This was a test of a bad command
The exit status is: 0
```

这次函数的退出状态码是0，尽管其中有一条命令没有正常运行。可见使用函数的默认退出状态码是很危险的，幸运的是，我们有几种办法解决它。

### 使用return命令

`return`命令允许指定一个**整数值**来定义函数的退出状态码，从而提供了一种简单的途径来编码设定函数退出状态码。

```shell
wsx@wsx:~/tmp$ cat test4
#!/bin/bash
# using the return command in a function

function db1 {
	read -p "Enter a value: " value
	echo "doubling the value"
	return $[ $value * 2 ]
}

db1
echo "The new value is $?"
wsx@wsx:~/tmp$ ./test4
Enter a value: 4
doubling the value
The new value is 8
```

当使用这种方法时要小心，记住下面两条技巧来避免问题：

- 函数一结束就取返回值
- 退出状态码必须是0~255

如果在用`$?`变量提取函数的返回值之前使用了其他命令，函数的返回值就会丢失。任何大于255的整数值都会产生一个错误值。

```shell
wsx@wsx:~/tmp$ ./test4
Enter a value: 200
doubling the value
The new value is 144
```

### 使用函数输出

如同可以将命令的输出保存到shell变量一样，我们也可以对函数的输出采用同样的处理办法。

```shell
result=`db1`
```

这个命令会将`db1`函数的输出赋值给`$result`变量。下面是脚本的一个实例：

```shell
wsx@wsx:~/tmp$ cat test4b
#!/bin/bash
# using the echo to return a value

function db1 {
	read -p "Enter a value: " value
	echo $[ $value * 2 ]
}

result=$(db1)
echo "The new value is $result"
wsx@wsx:~/tmp$ ./test4b
Enter a value: 200
The new value is 400
```

函数会用`echo`语句来显示计算的结果，该脚本会查看`db1`函数的输出，而不是查看退出状态码。

> 通过这种技术，我们还可以返回浮点值和字符串值，这使它成为一种获取函数返回值的强大方法。



## 在函数中使用变量

在函数中使用变量时，我们需要注意它们的定义方式以及处理方法。这是shell脚本常见错误的根源。

### 向函数传递参数

函数可以使用标准的参数环境变量来表示命令行上传给函数的参数。例如，函数名会在`$0`变量中定义，函数命令行上的任何参数都会通过`$1`、`$2`定义。也可以用特殊变量`$#`来判断给函数的参数数目。

指定函数时，必须将参数和函数放在同一行：

```shell
func1 $value1 10
```

然后函数可以用参数环境变量来获得参数值。下面是一个例子：

```shell
wsx@wsx:~/tmp$ cat test5
#!/bin/bash
# passing parameters to a function

function addem {
	if [ $# -eq 0 ] || [ $# -gt 2 ]
	then
		echo -1
	elif [ $# -eq 1 ]
	then
		echo $[ $1 + $1 ]
	else
		echo $[ $1 + $2 ]
	fi
}

echo -n "Adding 10 and 15: "
value=$(addem 10 15)
echo $value
echo -n "Let's try adding just one number: "
value=$(addem 10)
echo $value
echo -n "Now trying adding no numbers: "
value=$(addem)
echo $value
echo -n "Finally, try add three numbers: "
value=$(addem 10 15 20)
echo $value
wsx@wsx:~/tmp$ ./test5
Adding 10 and 15: 25
Let's try adding just one number: 20
Now trying adding no numbers: -1
Finally, try add three numbers: -1

```

`addem`函数首先会检查脚本传给它的参数数目。如果没有任何参数，或者参数多于两个，`addem`会返回`-1`。如果只有一个参数，`addem`会将参数与自身相加。如果有两个参数，`addem`会将它们相加。

**由于函数使用特殊参数环境变量作为自己的参数值，因此它无法直接获取脚本在命令行中的参数值。**下面是个失败的例子：

```shell
wsx@wsx:~/tmp$ cat badtest1
#!/bin/bash
# trying to access script parameters inside a function

function badfunc1 {
	echo $[ $1 * $2 ]
}

if [ $# -eq 2 ]
then
	value=$(badfunc1)
	echo "The result is $value"
else
	echo "Usage: badtest1 a b"
fi

wsx@wsx:~/tmp$ ./badtest1 10 15
./badtest1: 行 5: *  : 语法错误: 需要操作数 (错误符号是 "*  ")
The result is

```

尽管函数也使用了`$1`与`$2`变量，但它们与主脚本中的变量不同，要使用它们必须在调用函数时手动传入。

```shell
wsx@wsx:~/tmp$ cat test6
#!/bin/bash
# trying to access script parameters inside a function

function func1 {
	echo $[ $1 * $2 ]
}

if [ $# -eq 2 ]
then
	value=$(func1 $1 $2)
	echo "The result is $value"
else
	echo "Usage: badtest1 a b"
fi

wsx@wsx:~/tmp$ ./test6
Usage: badtest1 a b
wsx@wsx:~/tmp$ ./test6 10 15
The result is 150

```

### 在函数中处理变量

**作用域**是变量可见的区域。对脚本的其他部分而言，函数定义的变量是隐藏的。这些概念其实是编程语言中通用的，想必学过一些其他编程的朋友早已有所理解了。

函数使用两种类型的变量：

- 全局变量
- 局部变量

#### 全局变量

**全局变量**是在shell脚本中任何地方都有效的变量，如果你在函数内定义了一个全局变量，也可以在脚本的主体部分读取它的值。

默认情况下，我们在脚本中定义的任何变量都是全局变量。

```shell
wsx@wsx:~/tmp$ cat test7
#!/bin/bash
# using a global variable to pass a value

function db1 {
	value=$[ $value * 2 ]
}

read -p "Enter a value: " value
db1
echo "The new value is: $value"

wsx@wsx:~/tmp$ ./test7
Enter a value: 10
The new value is: 20

```

无论变量在函数内外定义，在脚本中引用该变量都有效。这样其实非常危险，尤其是如果你想在不同的shell脚本中使用函数的话。它要求你清清楚楚地知道函数中具体使用了哪些变量，包括那些用来计算非返回值的变量。下面是一个如何搞砸的例子：

```shell
wsx@wsx:~/tmp$ cat badtest2
#!/bin/bash
# demonstrating a bad use of variable

function func1 {
	temp=$[ $value + 5 ]
	result=$[ $temp * 2 ]
}

temp=4
value=6

func1
echo "The result is $result"
if [ $temp -gt $value ]
then
	echo "temp is larger"
else
	echo "temp is smaller"
fi
wsx@wsx:~/tmp$ ./badtest2
The result is 22
temp is larger

```

由于函数中用到了`$temp`变量，它的值在脚本中使用时受到了影响，产生了意想不到的后果。后面我们会学习如何处理这样的问题。

#### 局部变量

无需在函数中使用全局变量，函数内部使用的任何变量都可以被声明成局部变量。**我们只需要在变量声明前加上local关键字就可以了**。

```shell
local temp
```

也可以在变量赋值时使用local关键字：

```shell
local temp=$[ $value + 5 ]
```

`local`关键字保证了变量只局限于该函数中。我们再回看刚才的例子：

```shell
wsx@wsx:~/tmp$ cat test8
#!/bin/bash
# demonstrating the local keyword

function func1 {
	local temp=$[ $value + 5 ]
	result=$[ $temp * 2 ]
}

temp=4
value=6

func1
echo "The result is $result"
if [ $temp -gt $value ]
then
	echo "temp is larger"
else
	echo "temp is smaller"
fi

wsx@wsx:~/tmp$ ./test8
The result is 22
temp is smaller

```



## 数组变量和函数

在函数中使用数组变量值有点麻烦，还需要一些特殊考虑。下面我们使用一种方法来解决问题。

### 向函数传数组参数

这个方法有点不好理解，将数组变量当做单个参数传递的话不起作用，下面我们看一个bad例子：

```shell
wsx@wsx:~/tmp$ cat badtest3
#!/bin/bash
# trying to pass an array variable

function testit {
	echo "The parameters are: $@"
	thisarray=$1
	echo "The received array is ${thisarray[*]}"
}

myarray=(1 2 3 4 5)
echo "The original array is: ${myarray[*]}"
testit $myarray
wsx@wsx:~/tmp$ ./badtest3
The original array is: 1 2 3 4 5
The parameters are: 1
The received array is 1
```

可以看到，当我们将数组变量当做函数参数传递时，函数只会取数组变量的第一个值。

针对这个问题，我们的一个解决方案是将数组变量全部拆分为单个值，然后作为参数传入函数，在函数内部又重新对这些值进行组装。

```shell
wsx@wsx:~/tmp$ cat test9
#!/bin/bash
# array variable to function test

function testit {
	local newarray
	newarray=(`echo "$@"`)
	echo "The new array value is: ${newarray[*]}"
}

myarray=(1 2 3 4 5)
echo ${myarray[*]}
testit ${myarray[*]}

wsx@wsx:~/tmp$ ./test9
1 2 3 4 5
The new array value is: 1 2 3 4 5

```



### 从函数中返回数组

采用与上面类似的方法，函数用`echo`语句来按正确顺序输出单个数组值，然后脚本再将它们重新放进一个新的数组变量中。

```shell
wsx@wsx:~/tmp$ cat test10
#!/bin/bash
# returning an array value

function arraydblr {
	local origarray
	local newarray
	local elements
	local i
	origarray=($(echo "$@"))
	newarray=($(echo "$@"))
	elements=$[ $# - 1 ]
	for (( i = 0; i <= $elements; i++ ))
	{
		newarray[$i]=$[ ${origarray[$i]} * 2]
	}
	echo ${newarray[*]}
}

myarray=(1 2 3 4 5)
echo "The orignal array is ${myarray[*]}"
arg1=$(echo ${myarray[*]})
result=($(arraydblr $arg1))
echo "The new array is: ${result[*]}"

wsx@wsx:~/tmp$ ./test10
The orignal array is 1 2 3 4 5
The new array is: 2 4 6 8 10

```

该脚本用`$arg1`变量将数组值传给`arraydblr`函数。该函数将数组重组到新的数组变量中，生成输出数组变量的一个副本，然后对数据元素进行遍历，将每个元素值翻倍，并将结果存入函数中该数组变量的副本。



## 函数递归

局部函数变量的一个特征是**自成体系**。这个特性使得函数可以递归地调用，也就是函数可以调用自己来得到结果。**通常递归函数都有一个最终可以迭代到的基准值。**

递归算法的经典例子是计算阶乘：一个数的阶乘是该数之前的所有数乘以该数的值。

比如5的阶乘：

```
5! = 1 * 2 * 3 * 4 * 5
```

方程可以简化为通用形式：

```
x! = x * (x-1)!
```

这可以用简单的递归脚本表达为：

```shell
function factorial {
  if [ $1 -eq 1 ]
  then
  	echo 1
  else
  	local temp=$[ $1 - 1 ]
  	local result=`factorial $temp`
  	echo $[ $result * $1 ]
  fi
}
```

下面用它来进行计算：

```shell
wsx@wsx:~/tmp$ cat test11
#!/bin/bash
# using recursion

function factorial {
	if [ $1 -eq 1 ]
	then
		echo 1
	else
		local temp=$[ $1 - 1]
		local result=`factorial $temp`
		echo $[ $result * $1 ]
	fi
}

read -p "Enter value: " value
result=$(factorial $value)
echo "The factorial of $value is: $result"

wsx@wsx:~/tmp$ ./test11
Enter value: 5
The factorial of 5 is: 120

```



## 创建库

如果你碰巧要在多个脚本中使用同一段代码呢？显然在每个脚本中都定义同样的函数太麻烦了，一种解决方法就是创建**库文件**，然后在脚本中引用它。

**第一步**是创建一个包含脚本中所需函数的公用库文件。下面是一个叫做myfuncs的库文件，定义了3个简单的函数。

```shell
wsx@wsx:~/tmp$ cat myfuncs
#!/bin/bash
# my script functions

function addem {
	echo $[ $1 + $2 ]
}

function multem {
	echo $[ $1 * $2 ]
}

function divem {
	if [ $2 -ne 0 ]
	then
		echo $[ $1 / $2 ]
	else
		echo -1
	fi
}
```

**下一步**是在用到这些函数的脚本文件中包含myfuncs库文件。

这里有点复杂，主要问题出在shell函数的作用域上。如果我们尝试像普通脚本一样运行库文件，函数不会出现在脚本中。

使用函数库的**关键**在于`source`命令。**`source`命令会在当前shell上下文中执行命令，而不是创建一个新的shell。**通过`source`命令就可以使用库中的函数了。

`source`命令有一个**快捷别名**，称为**点操作符**。要在shell脚本中运行myfuncs库文件，只需要使用下面这行：

```shell
. ./myfuncs
```

注意第一个点是点操作符，而第二个点指向当前目录（相对路径）。

下面这个例子假定myfuncs库文件与要使用它的脚本位于同一目录，不然需要使用相对应的路径进行访问。

```shell
wsx@wsx:~/tmp$ cat test12
#!/bin/bash
# using functions defined in a library file

. ./myfuncs

value1=10
value2=5
result1=$(addem $value1 $value2)
result2=$(multem $value1 $value2)
result3=$(divem $value1 $value2)
echo "The result of adding them is: $result1"
echo "The result of multiplying them is: $result2"
echo "The result of dividing them is: $result3"

```

运行：

```shell
wsx@wsx:~/tmp$ ./test12
The result of adding them is: 15
The result of multiplying them is: 50
The result of dividing them is: 2
```



## 在命令行上使用函数

有时候有必要在命令行界面的提示符下直接使用这些函数。这是个灰常不错的功能，在shell中定义的函数可以在整个系统中使用它，无需担心脚本是不是在PATH环境变量中。

**重点在于让shell能够识别这些函数**。以下有几种方法可以实现。

### 在命令行上创建函数

shell会解释用户输入的命令，所以可以在命令行上直接定义一个函数。

有两种方法。

**一种是采用单行方式定义函数。**

```shell
wsx@wsx:~/tmp$ function divem { echo $[ $1 / $2 ]; }
wsx@wsx:~/tmp$ divem 100 5
20
```

当在命令行上定义函数时，你**必须**记得在每个命令后面加个分号，这样shell能识别命令的起始。

**另一种是采用多行方式来定义函数。**在定义时bash shell会使用次提示符来提示输入更多命令。这种方法不必在命令末尾加分号，只要按回车键就可。

```shell
wsx@wsx:~/tmp$ function multem {
> echo $[ $1 * $2 ]
> }
wsx@wsx:~/tmp$ multem 2 5
10
```

**注意**：在命令行上创建函数不要跟内建命令重名，函数会覆盖原来的命令。

### 在.bashrc文件中定义函数

在bash shell每次启动时都会在主目录下查找`.bashrc`文件，不管是交互式shell还是shell中启动的新shell。所以我们可以将函数写入该文件，或者在脚本中写入命令读取函数文件。操作前面都讲过，不再赘述，**只要把该文件当做脚本对待就可以了**。理解这一点这部分就会了。



## 实例

**在开源的世界里，共享代码才是关键，而这一点同样适用于脚本函数。**我们可以下载大量各式各样的函数然后用于自己的应用程序。

这一节介绍**如何下载、安装和使用GNU shtool shell脚本函数库**。shtool库提供了一些简单的shell脚本函数，可以用来完成日常的shell功能。

### 下载和安装

shtool软件包下载地址：

```shell
http://mirrors.ustc.edu.cn/gnu/shtool/shtool-2.0.8.tar.gz # China
```

可以浏览器或者命令行下载：

```shell
wsx@wsx:~/tmp$ wget http://mirrors.ustc.edu.cn/gnu/shtool/shtool-2.0.8.tar.gz
--2017-11-24 00:34:32--  http://mirrors.ustc.edu.cn/gnu/shtool/shtool-2.0.8.tar.gz
正在解析主机 mirrors.ustc.edu.cn (mirrors.ustc.edu.cn)... 202.141.176.110, 218.104.71.170, 2001:da8:d800:95::110
正在连接 mirrors.ustc.edu.cn (mirrors.ustc.edu.cn)|202.141.176.110|:80... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度： 97033 (95K) [application/gzip]
正在保存至: “shtool-2.0.8.tar.gz”

shtool-2.0.8.tar.gz 100%[===================>]  94.76K  --.-KB/s    用时 0.1s

2017-11-24 00:34:32 (783 KB/s) - 已保存 “shtool-2.0.8.tar.gz” [97033/97033])
```

复制到主目录，然后用`tar`命令提取文件：

```shell
wsx@wsx:~$ tar -zxvf shtool-2.0.8.tar.gz
shtool-2.0.8/AUTHORS
shtool-2.0.8/COPYING
shtool-2.0.8/ChangeLog
shtool-2.0.8/INSTALL
shtool-2.0.8/Makefile.in
shtool-2.0.8/NEWS
shtool-2.0.8/RATIONAL
shtool-2.0.8/README
shtool-2.0.8/THANKS
shtool-2.0.8/VERSION
shtool-2.0.8/configure
shtool-2.0.8/configure.ac
shtool-2.0.8/sh.arx
shtool-2.0.8/sh.common
shtool-2.0.8/sh.echo
shtool-2.0.8/sh.fixperm
shtool-2.0.8/sh.install
shtool-2.0.8/sh.mdate
shtool-2.0.8/sh.mkdir
shtool-2.0.8/sh.mkln
shtool-2.0.8/sh.mkshadow
shtool-2.0.8/sh.move
shtool-2.0.8/sh.path
shtool-2.0.8/sh.platform
shtool-2.0.8/sh.prop
shtool-2.0.8/sh.rotate
shtool-2.0.8/sh.scpp
shtool-2.0.8/sh.slo
shtool-2.0.8/sh.subst
shtool-2.0.8/sh.table
shtool-2.0.8/sh.tarball
shtool-2.0.8/sh.version
shtool-2.0.8/shtool.m4
shtool-2.0.8/shtool.pod
shtool-2.0.8/shtool.spec
shtool-2.0.8/shtoolize.in
shtool-2.0.8/shtoolize.pod
shtool-2.0.8/test.db
shtool-2.0.8/test.sh

```

接下来可以构建shell脚本库文件了。

### 构建库

shtool文件必须针对特定的Linux环境进行配置。**配置工作必须使用标准的configure和make命令**：

```shell
wsx@wsx:~$ cd shtool-2.0.8/
wsx@wsx:~/shtool-2.0.8$ ./configure
Configuring GNU shtool (Portable Shell Tool), version 2.0.8 (18-Jul-2008)
Copyright (c) 1994-2008 Ralf S. Engelschall <rse@engelschall.com>
checking whether make sets $(MAKE)... yes
checking for perl interpreter... /usr/bin/perl
checking for pod2man conversion tool... /usr/bin/pod2man
configure: creating ./config.status
config.status: creating Makefile
config.status: creating shtoolize
config.status: executing adjustment commands
wsx@wsx:~/shtool-2.0.8$ make
building program shtool
./shtoolize -o shtool all
Use of assignment to $[ is deprecated at ./shtoolize line 60.
Generating shtool...(echo 11808/12742 bytes)...(mdate 3695/4690 bytes)...(table 1818/2753 bytes)...(prop 1109/2038 bytes)...(move 2685/3614 bytes)...(install 4567/5495 bytes)...(mkdir 2904/3821 bytes)...(mkln 4429/5361 bytes)...(mkshadow 3260/4193 bytes)...(fixperm 1471/2403 bytes)...(rotate 13425/14331 bytes)...(tarball 5297/6214 bytes)...(subst 5255/6180 bytes)...(platform 21739/22662 bytes)...(arx 2401/3312 bytes)...(slo 4139/5066 bytes)...(scpp 6295/7206 bytes)...(version 10234/11160 bytes)...(path 4041/4952 bytes)
building manpage shtoolize.1
building manpage shtool.1
building manpage shtool-echo.1
building manpage shtool-mdate.1
shtool-mdate.tmp around line 222: You forgot a '=back' before '=head1'
POD document had syntax errors at /usr/bin/pod2man line 71.
building manpage shtool-table.1
building manpage shtool-prop.1
building manpage shtool-move.1
building manpage shtool-install.1
building manpage shtool-mkdir.1
shtool-mkdir.tmp around line 186: You forgot a '=back' before '=head1'
POD document had syntax errors at /usr/bin/pod2man line 71.
building manpage shtool-mkln.1
building manpage shtool-mkshadow.1
shtool-mkshadow.tmp around line 191: You forgot a '=back' before '=head1'
POD document had syntax errors at /usr/bin/pod2man line 71.
building manpage shtool-fixperm.1
building manpage shtool-rotate.1
building manpage shtool-tarball.1
building manpage shtool-subst.1
building manpage shtool-platform.1
building manpage shtool-arx.1
building manpage shtool-slo.1
building manpage shtool-scpp.1
building manpage shtool-version.1
building manpage shtool-path.1

```

`configure`命令会检查构建shtool库文件所必需的软件。一旦发现所需工具，它会使用工具路径修改配置文件。

`make`命令负责构建shtool库文件。最终的结果（shtool）是一个完整的库软件包。

我们可以测试下这个库文件：

```shell
wsx@wsx:~/shtool-2.0.8$ make test
Running test suite:
echo..........FAILED
+---Test------------------------------
| test ".`../shtool echo foo bar quux`" = ".foo bar quux" || exit 1
| bytes=`../shtool echo -n foo | wc -c | awk '{ printf("%s", $1); }'` || exit 1
| test ".$bytes" = .3 || exit 1
| bytes=`../shtool echo '\1' | wc -c | awk '{ printf("%s", $1); }'` || exit 1
| test ".$bytes" = .3 || exit 1
| exit 0
+---Trace-----------------------------
| + ../shtool echo foo bar quux
| + test .foo bar quux = .foo bar quux
| + ../shtool echo -n foo
| + wc -c
| + awk { printf("%s", $1); }
| + bytes=3
| + test .3 = .3
| + ../shtool echo \1
| + wc -c
| + awk { printf("%s", $1); }
| + bytes=2
| + test .2 = .3
| + exit 1
+-------------------------------------
mdate.........ok
table.........ok
prop..........ok
move..........ok
install.......ok
mkdir.........ok
mkln..........ok
mkshadow......ok
fixperm.......ok
rotate........ok
tarball.......ok
subst.........ok
platform......ok
arx...........ok
slo...........ok
scpp..........ok
version.......ok
path..........ok
FAILED: passed: 18/19, failed: 1/19

```

（有一个没通过～）

如果全部通过测试，就可以将库安装到系统中，这样所有脚本都能使用这个库了。

要完成安装，需要使用`make`命令的`install`选项。需要使用root权限。

```shell
wsx@wsx:~/shtool-2.0.8$ make install
./shtool mkdir -f -p -m 755 /usr/local
./shtool mkdir -f -p -m 755 /usr/local/bin
./shtool mkdir -f -p -m 755 /usr/local/share/man/man1
mkdir: cannot create directory '/usr/local/share/man/man1': Permission denied
chmod: cannot access '/usr/local/share/man/man1': No such file or directory
Makefile:94: recipe for target 'install' failed
make: *** [install] Error 1
wsx@wsx:~/shtool-2.0.8$ sudo make install
[sudo] wsx 的密码：
./shtool mkdir -f -p -m 755 /usr/local
./shtool mkdir -f -p -m 755 /usr/local/bin
./shtool mkdir -f -p -m 755 /usr/local/share/man/man1
./shtool mkdir -f -p -m 755 /usr/local/share/aclocal
./shtool mkdir -f -p -m 755 /usr/local/share/shtool
./shtool install -c -m 755 shtool /usr/local/bin/shtool
./shtool install -c -m 755 shtoolize /usr/local/bin/shtoolize
./shtool install -c -m 644 shtoolize.1 /usr/local/share/man/man1/shtoolize.1
./shtool install -c -m 644 shtool.1 /usr/local/share/man/man1/shtool.1
./shtool install -c -m 644 shtool-echo.1 /usr/local/share/man/man1/shtool-echo.1
./shtool install -c -m 644 shtool-mdate.1 /usr/local/share/man/man1/shtool-mdate.1
./shtool install -c -m 644 shtool-table.1 /usr/local/share/man/man1/shtool-table.1
./shtool install -c -m 644 shtool-prop.1 /usr/local/share/man/man1/shtool-prop.1
./shtool install -c -m 644 shtool-move.1 /usr/local/share/man/man1/shtool-move.1
./shtool install -c -m 644 shtool-install.1 /usr/local/share/man/man1/shtool-install.1
./shtool install -c -m 644 shtool-mkdir.1 /usr/local/share/man/man1/shtool-mkdir.1
./shtool install -c -m 644 shtool-mkln.1 /usr/local/share/man/man1/shtool-mkln.1
./shtool install -c -m 644 shtool-mkshadow.1 /usr/local/share/man/man1/shtool-mkshadow.1
./shtool install -c -m 644 shtool-fixperm.1 /usr/local/share/man/man1/shtool-fixperm.1
./shtool install -c -m 644 shtool-rotate.1 /usr/local/share/man/man1/shtool-rotate.1
./shtool install -c -m 644 shtool-tarball.1 /usr/local/share/man/man1/shtool-tarball.1
./shtool install -c -m 644 shtool-subst.1 /usr/local/share/man/man1/shtool-subst.1
./shtool install -c -m 644 shtool-platform.1 /usr/local/share/man/man1/shtool-platform.1
./shtool install -c -m 644 shtool-arx.1 /usr/local/share/man/man1/shtool-arx.1
./shtool install -c -m 644 shtool-slo.1 /usr/local/share/man/man1/shtool-slo.1
./shtool install -c -m 644 shtool-scpp.1 /usr/local/share/man/man1/shtool-scpp.1
./shtool install -c -m 644 shtool-version.1 /usr/local/share/man/man1/shtool-version.1
./shtool install -c -m 644 shtool-path.1 /usr/local/share/man/man1/shtool-path.1
./shtool install -c -m 644 shtool.m4 /usr/local/share/aclocal/shtool.m4
./shtool install -c -m 644 sh.common /usr/local/share/shtool/sh.common
./shtool install -c -m 644 sh.echo /usr/local/share/shtool/sh.echo
./shtool install -c -m 644 sh.mdate /usr/local/share/shtool/sh.mdate
./shtool install -c -m 644 sh.table /usr/local/share/shtool/sh.table
./shtool install -c -m 644 sh.prop /usr/local/share/shtool/sh.prop
./shtool install -c -m 644 sh.move /usr/local/share/shtool/sh.move
./shtool install -c -m 644 sh.install /usr/local/share/shtool/sh.install
./shtool install -c -m 644 sh.mkdir /usr/local/share/shtool/sh.mkdir
./shtool install -c -m 644 sh.mkln /usr/local/share/shtool/sh.mkln
./shtool install -c -m 644 sh.mkshadow /usr/local/share/shtool/sh.mkshadow
./shtool install -c -m 644 sh.fixperm /usr/local/share/shtool/sh.fixperm
./shtool install -c -m 644 sh.rotate /usr/local/share/shtool/sh.rotate
./shtool install -c -m 644 sh.tarball /usr/local/share/shtool/sh.tarball
./shtool install -c -m 644 sh.subst /usr/local/share/shtool/sh.subst
./shtool install -c -m 644 sh.platform /usr/local/share/shtool/sh.platform
./shtool install -c -m 644 sh.arx /usr/local/share/shtool/sh.arx
./shtool install -c -m 644 sh.slo /usr/local/share/shtool/sh.slo
./shtool install -c -m 644 sh.scpp /usr/local/share/shtool/sh.scpp
./shtool install -c -m 644 sh.version /usr/local/share/shtool/sh.version
./shtool install -c -m 644 sh.path /usr/local/share/shtool/sh.path

```

现在我们能在自己的shell脚本中使用这些函数咯。

### shtool库函数

| 函数       | 描述               |
| -------- | ---------------- |
| Arx      | 创建归档文件（包含一些扩展功能） |
| Echo     | 显示字符串，并提供了一些扩展构件 |
| fixperm  | 改变目录树的文件权限       |
| install  | 安装脚本或文件          |
| mdate    | 显示文件或目录修改时间      |
| mkdir    | 创建一个或更多目录        |
| Mkln     | 使用相对路径创建链接       |
| mkshadow | 创建一棵阴影树          |
| move     | 带有替换功能的文件移动      |
| Path     | 处理程序路径           |
| platform | 显示平台标识           |
| Prop     | 显示一个带有动画效果的进度条   |
| rotate   | 转置日志文件           |
| Scpp     | 共享的C预处理器         |
| Slo      | 根据库的类别，分离链接器选项   |
| Subst    | 使用sed的替换操作       |
| Table    | 以表格的形式显示由字段分隔的数据 |
| tarball  | 从文件和目录中创建tar文件   |
| version  | 创建版本信息文件         |

每个shtool函数都包含大量的选项和参数。下面是使用格式：

```shell
shtool [option] [function [option] [args]]
```



### 使用库

我们能直接在命令行或者在自己构建的脚本中使用shtool的函数。

下面是在脚本中使用的简单例子：

```shell
wsx@wsx:~/tmp$ cat test13
#!/bin/bash
shtool platform
wsx@wsx:~/tmp$ ./test13
Ubuntu 17.10 (AMD64)

```

`platform`函数会返回Linux发行版以及系统使用的CPU硬件相关信息。

`prop`函数可以使用`\`,`|`,`/`和`-`字符创建一个旋转的进度条。它可以告诉shell脚本用户目前正在处理一些后台处理工作。

```shell
wsx@wsx:~/tmp$ ls -al /usr/bin | shtool prop -p "waiting..."
waiting...
```



在脚本学习中涉及到诸多的符号，在运行时我们可能会感觉到顺利，但自己写的时候往往会用不太对，推荐阅读一下常用的一些符号区分，像小括号、中括号、花括号等等。觉的不懂的可以看看[Linux_Bash脚本_单引号’双引号“”反引号`小括号()中括号[]大括号{}](http://blog.csdn.net/yangtalent1206/article/details/12996797)以及相关的百度资料。
