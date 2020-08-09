---
title:  Shell脚本之处理用户输入
author: 王诗翔
date: 2017-08-19
categories: ["shell"]
tags: ["linux", "shell", "note"]

summary: "学习如何处理shell的用户输入..."
---



> 内容：
>
> - 传递参数
> - 跟踪参数
> - 移动变量
> - 处理选项
> - 将选项标准化
> - 获得用户输入



经过前面的介绍，我们已经可以掌握一些流程化的脚本编程了。但有时候，我们需要编写的脚本能够跟使用者进行交互。它可以是静态的，输入相应的参数让它运行到底；也可以是动态的，脚本根据输入参数反馈不同的信息，使用者又能根据信息调整下一步的处理，实时与程序互动。

bash shell提供了一些不同的方法来从**用户处获得数据，包括命令行参数、命令行选项以及直接从键盘读取输入**的能力。下面将一一介绍实现。

<!-- more -->



## 命令行参数

使用命令行参数是向脚本传递数据的最基本方法，在运行脚本的同时可以在命令行添加数据。

比如：

```shell
./addem 10 30
```

运行当前目录下名为`addem`脚本的同时向内部传递2个参数（10和30）。而脚本会通过特殊的变量来处理命令行参数。

下面介绍如何使用它们。



### 读入参数

bash shell会将称为**位置参数**的特殊变量分配给输入到命令行的所有参数：`$0`是程序名，`$1`是第一个参数，`$2`是第二个参数，以此类推。书上介绍直到第九个参数`$9`，但这个应该不是受限的。[Shell最多可以输入多少个参数？](http://www.cnblogs.com/ivictor/p/4022382.html)一文探索了参数的个数限制，有兴趣的朋友不妨看看和试试。

下面是单个参数的例子：

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test1.sh
#!/bin/bash

# using one command line parameter
#
factorial=1
for (( number = 1; number <= $1; number++ ))
do
	factorial=$[ $factorial * $number ]
done
echo The factorial of $1 is $factorial
wsx@wsx-ubuntu:~/script_learn$ ./test1.sh 5
The factorial of 5 is 120
```

我们可以像使用其他变量一样使用`$1`变量。shell脚本会自动分配，不需要我们做任何处理。可以看得出来这样非常方便，不过如果输入参数过多，很容易让人混淆。

如果需要输入更多的参数，只需要用空格分隔即可。

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test2.sh
#!/bin/bash

# using two command line parameters

total=$[ $1 * $2 ]
echo The first parameter is $1.
echo The second parameter is $2.
echo The total value is $total.

wsx@wsx-ubuntu:~/script_learn$ ./test2.sh 2 5
The first parameter is 2.
The second parameter is 5.
The total value is 10.
```

字符参数也是一样的。如果我没记错，在脚本中的数字默认都是做字符处理的，进行数学运算时会自动调整。不过当我们想要输入的一个参数是带空格的字符串时，需要在两边加上引号以保证shell能够正确识别。不然会被当做多个参数处理的。

下面取个例子：

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test3.sh
#!/bin/bash

echo Hello $1, glad to meet you.
wsx@wsx-ubuntu:~/script_learn$ ./test3.sh shixiang wang
Hello shixiang, glad to meet you.
wsx@wsx-ubuntu:~/script_learn$ ./test3.sh 'shixiang wang'
Hello shixiang wang, glad to meet you.
wsx@wsx-ubuntu:~/script_learn$ ./test3.sh "shixiang wang"
Hello shixiang wang, glad to meet you.
```

看来使用时要注意正确使用引号喔。

> 说明：在文本字符串作为参数传递时，引号并非数据的一部分。它们只是表明数据的起止位置。

如果需要输入的命令行参数不止9个，写脚本需要修改一下变量名（第9个之后）。比如`${10}`表示输入的第十个变量（原来如此啊）。

这样我们就可以向脚本添加任意多的参数啦～

前面也说了，`$0`参数可以获取脚本名，这样在编程的时候很方便。但是这里存在一个潜在的问题：如果使用另一个命令来运行shell脚本，命令会和脚本名混在一起，出现在`$0`中。

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test4.sh
#!/bin/bash
# Testing the $0 parameter

echo The zero parameter is set to: $0
wsx@wsx-ubuntu:~/script_learn$ ./test4.sh
The zero parameter is set to: ./test4.sh

wsx@wsx-ubuntu:~/script_learn$ bash test4.sh
The zero parameter is set to: test4.sh

wsx@wsx-ubuntu:~/script_learn$ bash ~/script_learn/test4.sh
The zero parameter is set to: /home/wsx/script_learn/test4.sh
```

而且，你发现没有，当指明脚本路径时，这个路径也会带入其中。

如果我们要编写一个根据脚本名来执行不同功能的脚本，就得把脚本的运行路径剥离掉。还要删除与脚本名混在一起的命令。幸好有一个方便的小命令`basename`可以帮助我们返回不包含路径的脚本名。

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test5.sh
#!/bin/bash
# Using basename with the $0 parameter

name=$(basename $0)
echo
echo The script name is: $name

wsx@wsx-ubuntu:~/script_learn$ bash ~/script_learn/test5.sh

The script name is: test5.sh
wsx@wsx-ubuntu:~/script_learn$ ./test5.sh

The script name is: test5.sh
```

下面编写基于脚本名执行不同功能的脚本。挺有意思的，我们看看吧：

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test6.sh
#!/bin/bash
# Testing a Multi-function script
#
name=$(basename $0)
#
if [ $name = "addem" ]
then
	total=$[ $1 + $2 ]
elif [ $name = "multem" ]
then
	total=$[ $1 * $2 ]
fi
#
echo
echo The calculated value is $total.
wsx@wsx-ubuntu:~/script_learn$ cp test6.sh addem
wsx@wsx-ubuntu:~/script_learn$ chmod u+x addem
wsx@wsx-ubuntu:~/script_learn$ ln -s test6.sh multem
wsx@wsx-ubuntu:~/script_learn$ ll *em
-rwxrw-r-- 1 wsx wsx 216 8月  18 16:47 addem*
lrwxrwxrwx 1 wsx wsx   8 8月  18 16:47 multem -> test6.sh*
wsx@wsx-ubuntu:~/script_learn$ ./addem 2 5

The calculated value is 7.
wsx@wsx-ubuntu:~/script_learn$ ./multem 2 5

The calculated value is 10.

```

这个脚本中创建了两个不同的文件名：一个通过复制创建；另一个通过链接。在两种情况下都会先获得脚本的基本名称，然后根据该值执行相应的功能。



### 测试参数

如果在脚本中使用了参数，但是运行脚本时没用参数，这会导致错误发生，需要小心。因此我们在使用参数前应该测试。

好比下面这个例子：

```shell
wsx@wsx-ubuntu:~/script_learn$ cat test7.sh
#!/bin/bash
# testing parameters before use
#
if [ -n "$1" ] # -n 选项检查字符是否非空
then
	echo Hello $1, glad to meet you.
else
	echo "Sorry, you did not identify yourself."
fi

wsx@wsx-ubuntu:~/script_learn$ ./test7.sh shixiang
Hello shixiang, glad to meet you.
wsx@wsx-ubuntu:~/script_learn$ ./test7.sh
Sorry, you did not identify yourself.
```



## 特殊参数变量

bash shell中有些特殊变量，它们会记录命令行参数。



### 参数统计

bash shell提供了一个特殊的变量`$#`来统计命令行中输入了多少个参数。我们可以像使用普通变量一样使用它。

现在能在使用参数前测试参数的总数了。

```shell
wangsx@SC-201708020022:~/tmp$ cat test9.sh
#!/bin/bash
# Testing parameters
#
if [ $# -ne 2 ]
then
    echo
    echo Usage: test9.sh a b
    echo
else
    total=$[ $1 + $2 ]
    echo
    echo The total is $total
    echo
fi

wangsx@SC-201708020022:~/tmp$ bash test9.sh

Usage: test9.sh a b

wangsx@SC-201708020022:~/tmp$ bash test9.sh 10

Usage: test9.sh a b

wangsx@SC-201708020022:~/tmp$ bash test9.sh 2 5

The total is 7
```

例子中，`if-then`语句用`-ne`测试命令行参数数量。如果参数数量不对，会显示一条错误信息告诉脚本的正确用法。

这个变量还提供了一个简便方法来获取命令行最后一个参数，完全不需要知道实际上有多少个参数。不过要实现它需要花些功夫。


也许，我们会有这样的想法，既然`$#`变量含有参数的总数，那么变量`{% raw %}${$#}{% endraw %}`就代表了最后一个命令行参数变量。试试看呗：


```shell
wangsx@SC-201708020022:~/tmp$ cat test10.sh
#!/bin/bash

# testing grabbing last parameter
#
echo The last parameter was ${$#}

wangsx@SC-201708020022:~/tmp$ ./test10.sh 10
The last parameter was 65

```

我擦，明显不对。这说明`{% raw %}${$#}{% endraw %}`的用法错误。实际上，花括号能不能使用美元符，必须把它换成感叹号。虽然有点奇怪，但的确有用。


```shell
wangsx@SC-201708020022:~/tmp$ cat test10.sh
#!/bin/bash

# testing grabbing last parameter
#
echo The last parameter was ${!#}

wangsx@SC-201708020022:~/tmp$ ./test10.sh 10
The last parameter was 10
wangsx@SC-201708020022:~/tmp$ ./test10.sh 1 2 3 4 5
The last parameter was 5
```



### 抓取所有的数据

`$*`与`$@`变量可以用来轻松访问所有的参数。它们都能够在单个变量中存储所有的命令行参数。

`$*`变量会将命令行提供的所有参数当作一个单词保存。这个单词包含了命令行中出现的每一个参数值。基本上`$*`变量会将这些参数视为一个整体，而不是多个个体。

`$@`则将所有参数当作同一字符串中的多个独立的单词。这样能够遍历所有的参数值，得到每个参数。这通常交给`for`命令完成。

弄个例子吧，理解两者的区别。

```shell
wangsx@SC-201708020022:~/tmp$ cat test11.sh
#!/bin/bash
# testing $* and $@
#
echo
echo "Using then \$* method: $*"
echo
echo "Using the \$@ method: $@"
wangsx@SC-201708020022:~/tmp$ ./test11.sh rich barbara katie jessica

Using then $* method: rich barbara katie jessica

Using the $@ method: rich barbara katie jessica

# 下面给出两者差异
wangsx@SC-201708020022:~/tmp$ cat test12.sh
#!/bin/bash
echo
count=1
#
for param in "$*"
do
    echo "\$* Parameter #$count = $param"
    count=$[ $count + 1 ]
done
#
echo
count=1
#

for param in "$@"
do
    echo "\$@ Parameter #$count = $param"
    count=$[ $count + 1 ]
done
wangsx@SC-201708020022:~/tmp$ ./test12.sh rich barbara katie jessica

$* Parameter #1 = rich barbara katie jessica

$@ Parameter #1 = rich
$@ Parameter #2 = barbara
$@ Parameter #3 = katie
$@ Parameter #4 = jessica
```



## 移动变量

bash shell的`shift`命令能够用来操作命令行参数。默认情况下它会将每个参数变量向左移动一个位置。So, 变量`$3`的值会移到`$2`，`$2`移到`$1`，而`$1`的值会被删除（`$0`的值，也就是脚本名，是不会变的）。

这是遍历命令行参数的另一个好方法，不需要知道参数的个数，我们只需要操作第一个参数，然后移动参数，继续操作第一个参数。

下面解释它怎么工作的：

```shell
wangsx@SC-201708020022:~/tmp$ cat test13.sh
#!/bin/bash
# demonstrating the shift command
#
echo
count=1
while [ -n "$1" ]
do
    echo "Parameter #$count = $1"
    count=$[ $count + 1 ]
    shift
done

wangsx@SC-201708020022:~/tmp$ ./test13.sh rich barbara katie jessica

Parameter #1 = rich
Parameter #2 = barbara
Parameter #3 = katie
Parameter #4 = jessica
```

> 使用shift命令时需要注意，一旦参数被移除，它的值就被丢弃了 ，无法再恢复。

`shift n`中`n`可以指定移动多个位置。



## 处理选项

熟悉Linux的朋友必然见过不少同时提供参数和选项的bash命令。选项是跟在但破折线后面的单个字母，它能改变命令的行为。下面介绍3中再脚本中处理选项的方法。



### 查找选项

只要我们愿意，我们可以像处理命令行参数一样处理命令行选项。



#### 处理简单选项

前面一节最后我们用`shift`命令来依次处理脚本携带的命令行参数。我们也可以用同样的方法来处理命令行选项。

在提取每个单独参数时，用`case`语句来判断某个参数是否为选项。

```shell
wangsx@SC-201708020022:~/tmp$ cat test15.sh
#!/bin/bash
# extracting command line option as parameter
#
echo
while [ -n "$1" ]
do
    case "$1" in
        -a) echo "Found the -a option";;
        -b) echo "Found the -b option";;
        -c) echo "Found the -c option";;
        *)  echo "$1 is not an option";;
    esac
    shift
done

wangsx@SC-201708020022:~/tmp$ ./test15.sh -a -b -c -d

Found the -a option
Found the -b option
Found the -c option
-d is not an option
```

`case`语句在命令行参数中找到一个选项，就处理一个选项。如果命令行上还提供了其他参数，你可以在`case`语句的通用情况处理部分中处理。



#### 分离参数与选项

shell脚本通常使用选项和参数，Linux中处理这个问题的标准方法是用**特殊字符**来将二者分开，该字符会告诉脚本何时选项结束以及普通参数何时开始。

这个所谓的特殊字符就是`--`双破折号。

要检查双破折号，在`case`语句中加一项就行了。

```shell
wangsx@SC-201708020022:~/tmp$ cat test16.sh
#!/bin/bash
# extracting options and paramters
echo
while [ -n "$1" ]
do
    case "$1" in
        -a) echo "Found the -a option";;
        -b) echo "Found the -b option";;
        -c) echo "Found the -c option";;
        --) shift
            break ;;
        *) echo "$1 is not an option";;
    esac
    shift
done
#
count=1
for param in $@
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
```

当遇到双破折号时，先把它移除掉，然后跳出循环，这样shell就会把后面的参数当参数而不是选项处理了。

先用一组普通的选项和参数来运行测试脚本：

```shell
wangsx@SC-201708020022:~/tmp$ ./test16.sh -c -a -b test1 test2 test3

Found the -c option
Found the -a option
Found the -b option
test1 is not an option
test2 is not an option
test3 is not an option
```

现在加上双破折号，进行测试：

```shell
wangsx@SC-201708020022:~/tmp$ ./test16.sh -c -a -b -- test1 test2 test3

Found the -c option
Found the -a option
Found the -b option
Parameter #1: test1
Parameter #2: test2
Parameter #3: test3
```

可以看到，当脚本遇到双破折号时，它会停止处理选项，并将剩下的参数都当做命令处理。

这样如果顺序填写选项和参数的话，显然没什么问题。但是如果乱序写呢？很显然选项和参数对应不起来。如何解决？



#### 处理带值的选项

有些选项会带上一个额外的参数值，类似下面：

```shell
./testing.sh -a test1 -b -c -d test2
```

下面看看怎么正确处理。

```shell
wangsx@SC-201708020022:~/tmp$ cat test17.sh
#!/bin/bash
# extracting command line options and values
echo
while [ -n "$1" ]
do
    case "$1" in
        -a) echo "Found the -a option";;
        -b) param="$2"
            echo "Found the -b option, with parameter value $param"
            shift;;
        -c) echo "Found the -c option";;
        --) shift
            break;;
        *) echo "$1 is not an option";;
    esac
    shift
done
#
count=1
for param in "$@"
do
    echo "Paramter #$count: $param"
    count=$[ $count + 1 ]
done
wangsx@SC-201708020022:~/tmp$ ./test17.sh -a -b test1 -d

Found the -a option
Found the -b option, with parameter value test1
-d is not an option
```

本例中，定义了3个要处理的选项，`-b`还带一个额外参数。因为处理的选项是`$1`，所以额外参数位于`$2`，另外因为加了额外参数，所以找到后应该用`shift`把它移除（这个选项占了两个位置，需要多移动一个）。

这样，我们可以根据需求进行类似的设定了。不管什么顺序放置选项都可以正常工作。

```shell
wangsx@SC-201708020022:~/tmp$ ./test17.sh  -b test1 -a -d

Found the -b option, with parameter value test1
Found the -a option
-d is not an option
```

不过，这里还有一些限制。如果我们想把多个选项放在一起，这样就行不通啦~

```shell
wangsx@SC-201708020022:~/tmp$ ./test17.sh  -ac

-ac is not an option
```

而这种功能是Linux常见的喔。那究竟怎么合并选项呢？幸好还有一种处理方法可以帮忙。



### 使用getopt命令

`getopt`命令是一个处理命令行选项和参数时非常方便的工具。它能够识别命令行参数，从而更方便地进行解析。

**命令的格式**

```shell
getopt optstring parameters
```

`optstring`是这个过程的关键所在。它定义了命令行有效的选项字母，还定义了哪些字母需要带参数。

**首先，在`optstring`中列出你要在脚本中用到的每个命令行选项字母。然后，在每个需要参数值的选项字母后加一个冒号。**

> `getopt`的高级版本叫`getoptions`。需要注意区分

下面看看`getopt`如何工作的：

```shell
wangsx@SC-201708020022:~/tmp$ getopt ab:cd -a -b test1 -cd test2 test3
 -a -b test1 -c -d -- test2 test3
```

运行完后看到结果感觉自己晕乎乎的，让我们一起来看看解释：

`optstring`定义了四个有效选项字母：a,b,c,d。（嗯，对的，这个没问题）。冒号被放在字母b后面，说明b选项需要一个参数。（这样啊）。当`getopt`命令运行时，它会检查参数列表（就时getopt命令后面跟的），并基于提供的`optstring`进行解析。值得注意，它会自动把`-cd`选项分成两个独立的选项，并插入双破折号来分隔行中的额外参数。

如果指定的选项不在`optstring`中，会报错。`-q`选项可以忽略掉它（注意放在`optstring`之前，因为是命令本身的选项嘛）。

```shell
wangsx@SC-201708020022:~/tmp$ getopt ab:cd -a -b test1 -cde test2 test3
getopt：无效选项 -- e
 -a -b test1 -c -d -- test2 test3
wangsx@SC-201708020022:~/tmp$ getopt -q ab:cd -a -b test1 -cde test2 test3
 -a -b 'test1' -c -d -- 'test2' 'test3'
```



**在脚本中用getopt**

用法稍微有点复杂，方法是用`getopt`命令生成的格式化后的版本替换已有的命令行选项和参数。用`set`可以做到。

```shell
set -- $(getopt -q ab:cd "$@)
```

`set`命令的选项之一是`--`，它会将命令行参数替换成`set`命令的命令行值。

该方法会将原始脚本的命令行参数传给`getopt`命令，之后将`getopt`命令的输出传给`set`命令，用`getopt`格式化的命令行参数来替换原始的命令行参数。

现在写下处理命令行参数的脚本吧：

```shell
wangsx@SC-201708020022:~/tmp$ cat test18.sh
#!/bin/bash
# Extract command line options & values with getopt
#
set -- $(getopt -q ab:cd "$@")
#
echo
while [ -n "$1" ]
do
    case "$1" in
        -a) echo "Found the -a option";;
        -b) param="$2"
            echo "Found the -b option, with parameter value $param"
            shift ;;
        -c) echo "Found the -c option";;
        --) shift
            break ;;
        *) echo "$1 is not an option"
    esac
    shift
done
#
count=1
for param in "$@"
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
#
```

可以看到它跟`test17.sh`不同的地方是加入了`getopt`命令来帮助格式化命令行参数。

下面测试发现新加的功能实现了，之前的也没问题。

```shell
wangsx@SC-201708020022:~/tmp$ ./test18.sh -ac

Found the -a option
Found the -c option
wangsx@SC-201708020022:~/tmp$ ./test18.sh -a -b test1 -cd  test2 test3 test4

Found the -a option
Found the -b option, with parameter value 'test1'
Found the -c option
-d is not an option
Parameter #1: 'test2'
Parameter #2: 'test3'
Parameter #3: 'test4'
```

相当不错啦。不过`getopt`命令隐藏一个问题。

```shell
wangsx@SC-201708020022:~/tmp$ ./test18.sh -a -b test1 -cd  "test2 test3" test4

Found the -a option
Found the -b option, with parameter value 'test1'
Found the -c option
-d is not an option
Parameter #1: 'test2
Parameter #2: test3'
Parameter #3: 'test4'
```

`getopt`命令并不擅长处理带空格和引号的参数值。它会将空格当作参数分隔符，而不是根据双引号将两者当作一个参数。

幸而还有办法能够解决这个问题。



### 使用更高级的getopts

`getopts`命令内建于bash shell。它比`getopt`多一些扩展功能。

`getopts`命令格式如下：

```shell
getopts optstring variable
```

`optstring`值类似于`getopt`命令中的那个。要去掉错误信息的话，可以在`optstring`之前加一个冒号。`getopts`命令将当前参数保存在命令行中定义的`variable`中。

**该命令会用到两个环境变量。如果选项需要跟一个参数值，`OPTARG`环境变量就会保存这个值。`OPTIND`环境变量保存了参数列表中`getopts`正在处理的参数位置。这样你就能在处理选项之后继续处理其他命令行参数了。**

空说无益，还是来练练。

```shell
wangsx@SC-201708020022:~/tmp$ cat test19.sh
#!/bin/bash
# Simple demonstration of the getopts command
#
echo
while getopts :ab:c opt
do
    case "$opt" in
       a) echo "Found the -a option" ;;
       b) echo "Found the -b option, with value $OPTARG";;
       c) echo "Found the -c option";;
       *) echo "Unknown option: $opt";;
   esac
done
wangsx@SC-201708020022:~/tmp$ ./test19.sh -ab test1 -c

Found the -a option
Found the -b option, with value test1
Found the -c option
```

`while`语句定义了`getopts`命令，指明了要查找哪些命令行选项，以及每次迭代中存储它们的变量名（`opt`）。

`getopts`运行时，它一次只处理命令行上检测到的一个参数。处理完所有参数后，它会退出并返回一个大于0的退出状态码。这让它非常适合用于解析命令行所有的参数的循环中。

这里我们可以已经注意到了例子中的`case`用法和之前不同。`getopts`命令解析命令行选项时会移除开头的单破折号，所以在`case`定义中不用单破折号了。

上一小节末尾我们遇到的问题可以很好的解决了：

```shell
wangsx@SC-201708020022:~/tmp$ ./test19.sh -ab "test1 test2" -c

Found the -a option
Found the -b option, with value test1 test2
Found the -c option
```

另一个好用的功能是能够将选项字母和参数值放在一起，而且不用加空格。

```shell
wangsx@SC-201708020022:~/tmp$ ./test19.sh -abtest1

Found the -a option
Found the -b option, with value test1
```

除此之外，`getopts`还能够将命令行上找到的所有未定义的选项统一输出成问号。

```shell
wangsx@SC-201708020022:~/tmp$ ./test19.sh -d

Unknown option: ?
wangsx@SC-201708020022:~/tmp$ ./test19.sh -acde

Found the -a option
Found the -c option
Unknown option: ?
Unknown option: ?
```

`getopts`命令知道何时停止处理选项，并将参数留给你处理。在`getopts`处理每一个选项时，它会将`OPTIND`环境变量值增一。在`getopts`完成处理后，你可以使用`shift`命令和`OPTIND`值来移动参数。

```shell
wangsx@SC-201708020022:~/tmp$ cat test20.sh
#!/bin/bash
# Processing options & parameters with getopts
#
echo
while getopts :ab:cd opt
do
    case "$opt" in
        a) echo "Found the -a option" ;;
        b) echo "Found the -a option, with value $OPTARG" ;;
        c) echo "Found the -c option" ;;
        d) echo "Found the -d option" ;;
        *) echo "Unknown option: $opt" ;;
    esac
done
#
shift $[ $OPTIND -1 ]
#
echo
count=1
for param in  "$@"
do
    echo "Parameter $count: $param"
    count=$[ $count + 1 ]
done

wangsx@SC-201708020022:~/tmp$ ./test20.sh -a -b test1 -d test2 test3 test4

Found the -a option
Found the -a option, with value test1
Found the -d option

Parameter 1: test2
Parameter 2: test3
Parameter 3: test4
```

这里`shift $[ $OPTIND -1 ]`需要解释以下：前面提到`OPTIND`在`getopts`每次处理掉一个参数后会加1。比如`./test20.sh -a -b test1 -d test2 test3 test4`前面键入了4个参数，选项处理完成后`OPTIND`的值为5。它会指向`$5`，即第5个参数，后面为了值剩下命令行参数，所以去掉所有的选项（及带的参数），所以用`shift $[ $OPTIND - 1]`命令。



## 将选项标准化

有些字母在Linux世界里已经拥有了某种程度的标准含义。如果我们能在shellji奥本中支持这些选项，脚本看起来会更加友好。

下面表格列出一些命令行选项的常用含义

|  选项  |        描述        |
| :--: | :--------------: |
|  -a  |      显示所有对象      |
|  -c  |      生成一个计数      |
|  -d  |      指定一个目录      |
|  -e  |      扩展一个对象      |
|  -f  |    指定读入数据的文件     |
|  -h  |    显示命令的帮助信息     |
|  -i  |     忽略文本大小写      |
|  -l  |    产生输出的长格式版本    |
|  -n  |   使用非交互模式（批处理）   |
|  -o  | 将所有输出重定向到指定的输出文件 |
|  -q  |     以安静模式运行      |
|  -r  |    递归地处理目录和文件    |
|  -s  |     以安静模式运行      |
|  -v  |      生成详细输出      |
|  -x  |      排除某个对象      |
|  -y  |    对所有问题答yes     |



## 获得用户输入

有时脚本地交互性还需要更强一些。比如你想要在脚本运行时问个问题，并等待运行脚本地人来回答。bash shell为此提供了read命令。



### 基本的读入

`read`命令从标准输入（键盘）或另一个文件描述符中接受输入。在收到输入后，`read`命令会将数据放进一个变量。

简单用法如下：

```shell
wangsx@SC-201708020022:~/tmp$ cat test21.sh
#!/bin/bash
# testing the read -p option
#
read -p "Please enter your age: " age
#
days=$[ $age * 365 ]
echo "That makes you over $days days old!"
#
wangsx@SC-201708020022:~/tmp$ ./test21.sh
Please enter your age: 23
That makes you over 8395 days old!
```

`read`命令会将提示符后输入的所有数据分配给单个变量，要么我们需要指定多个变量。当变量数量不够时，剩下的数据就全部分配给最后一个变量。

```shell
wangsx@SC-201708020022:~/tmp$ cat test22.sh
#!/bin/bash
# entering multiple variable
#
read -p "Enter your name: " first last
echo "Checking data for $last, $first..."

wangsx@SC-201708020022:~/tmp$ ./test22.sh
Enter your name: shixiang wang
Checking data for wang, shixiang...
wangsx@SC-201708020022:~/tmp$ ./test22.sh
Enter your name: shixiang wang hhhhh
Checking data for wang hhhhh, shixiang...
```

也可以在`read`命令行中不指定变量。如果这样的话，`read`命令会将它收到的任何数据都放进特殊环境变量`REPLY`中。我们直接可以使用它。



### 超时

脚本很可能一直苦苦等待脚本用户的输入。如果不管数据是否输入，脚本都执行的话，我们可以用`-t`选项设定一个计时器。`-t`指定`read`命令等待的秒数，计数完成后，`read`命令会返回一个非零退出状态码。

```shell
wangsx@SC-201708020022:~/tmp$ cat test23.sh
#!/bin/bash
# timing the data entry
#
if read -t 5 -p "Please enter your name: " name
then
    echo "Hello $name, welcome to my script"
else
    echo
    echo "Sorry, too slow!"
fi

wangsx@SC-201708020022:~/tmp$ ./test23.sh
Please enter your name: shixiang wang
Hello shixiang wang, welcome to my script
wangsx@SC-201708020022:~/tmp$ ./test23.sh # 这里输入后等以下 不要输入
Please enter your name:
Sorry, too slow!
```



也可以不对输入过程计时，而时让`read`命令来统计输入的字符数。当输入的字符数达到预设的字符数时，就自动退出，将输入的数据赋值给变量。

```shell
wangsx@SC-201708020022:~/tmp$ cat test24.sh
#!/bin/bash
# getting just one character of input
#
read -n1 -p "Do you want to continue [Y/N]? " answer
case $answer in
    Y | y ) echo
            echo "fine, continue on...";;
    N | n ) echo
            echo OK, goodbye
            exit;;
esac
echo "This is the end of the script."
wangsx@SC-201708020022:~/tmp$ ./test24.sh
Do you want to continue [Y/N]? Y
fine, continue on...
This is the end of the script.
wangsx@SC-201708020022:~/tmp$ ./test24.sh
Do you want to continue [Y/N]? n
OK, goodbye
```



### 隐藏方式读取

这种方式输入密码的时候有用。

`-s`选项可以避免在`read`命令输入的数据出现在显示器上（实际上，数据会被显示，只是`read`命令会将文本颜色设成跟背景色一样）。

```shell
wangsx@SC-201708020022:~/tmp$ cat test25.sh
#!/bin/bash
# hiding input data from the monitor
#
read -s -p "Enter your password: " pass
echo
echo "Is your password really $pass?"
wangsx@SC-201708020022:~/tmp$ ./test25.sh
Enter your password:
Is your password really what?
wangsx@SC-201708020022:~/tmp$ ./test25.sh
Enter your password:
Is your password really shixiang?
```



### 从文件中读取

当然，`read`也可以从系统文件中读取数据。每次调用`read`命令，它都会读取一行文本。当读完后，`read`命令会退出并返回非零退出状态码。

最常见的方法时对文本使用`cat`命令，将结果通过管道直接传给含`read`命令的`while`命令。

```shell
wangsx@SC-201708020022:~/tmp$ cat test26.sh
#!/bin/bash
# reading data from a file
#
count=1
cat test | while read line
do
    echo "Line $count: $line"
    count=$[ $count + 1 ]
done
echo "Finished processing the file"

wangsx@SC-201708020022:~/tmp$ cat test
The quick brown dog jumps over the lazy fox.
This is a test, this is only a test.
O Romeo, Romeo! Wherefore art thou Romeo?
wangsx@SC-201708020022:~/tmp$ ./test26.sh
Line 1: The quick brown dog jumps over the lazy fox.
Line 2: This is a test, this is only a test.
Line 3: O Romeo, Romeo! Wherefore art thou Romeo?
Finished processing the file
```





------------------------

写shell脚本的基本内容大体已经整完了，我自己也是边看边想边码过来的。shell博大精深，更多高级内容有待继续学习整理。码字实属不易，觉得内容还行的点赞支持下吧~
