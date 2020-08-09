---
title: "初识sed与awk"
author: 王诗翔
date: 2017-12-25
categories: [shell]
tags: [linux, shell, sed, awk, note]

summary: "简单介绍sed与awk命令..."
---



**学习内容**：

>- 学习sed编辑器
>- gawk编辑器入门
>- sed编辑器基础

shell脚本最常见的一个用途就是处理文本文件，但仅靠shell脚本命令来处理文本文件的内容有点勉为其难。如果我们想在shell脚本中处理任何类型的数据，需要熟悉Linux中的sed和gawk工具。这两个工具可以极大简化我们需要进行的数据处理任务。

<!-- more -->

## 文本处理

当我们需要自动处理文本文件，又不想动用交互式文本编辑器时，sed和gawk是我们最好的选择。

### sed编辑器

也被称为**流编辑器**（stream editor），会在编辑器处理数据之前**基于预先提供的一组规则**来编辑数据流。

sed编辑器可以根据命令来处理数据流中的数据，这些命令既可以从终端输入，也可以存储进脚本文件中。

sed会执行以下的操作：

- 一次从输入中读取一行数据
- 根据所提供的命令匹配数据
- 按照命令修改流中的数据
- 将新的数据输出到STDOUT

这一过程会重复直至处理完流中的所有数据行。

sed命令的格式如下：

```shell
sed options script file
```

选项`options`可以允许我们修改`sed`命令的行为

| 选项        | 描述                            |
| --------- | ----------------------------- |
| -e script | 在处理输入时，将script中指定的命令添加到已有的命令中 |
| -f file   | 在处理输入时，将file中指定的命令添加到已有的命令中   |
| -n        | 不产生命令输出，使用`print`命令来完成输出      |

`script`参数指定用于流数据上的单个命令，如果需要多个命令，要么使用`-e`选项在命令行中指定，要么使用`-f`选项在单独的文件中指定。

#### 在命令行中定义编辑器命令

默认sed会将指定命令应用到STDIN输入流上，我们可以配合管道命令使用。

```shell
wsx@wsx-laptop:~/tmp$ echo "This is a test" | sed 's/test/big test/'
This is a big test
```

`s`命令使用斜线间指定的第二个文本来替换第一个文本字符串模式（注意是替换整个模式，支持正则匹配），比如这个例子用`big test`替换了`test`。

假如有以下文本：

```shell
wsx@wsx-laptop:~/tmp$ cat data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
```

键入命令，查看输出

```shell
wsx@wsx-laptop:~/tmp$ sed 's/dog/cat/' data1.txt
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
```

可以看到符合模式的字符串都被修改了。

要记住，sed并不会修改文本文件的数据，**它只会将修改后的数据发送到STDOUT**。

#### 在命令行上使用多个编辑器命令

使用`-e`选项可以执行多个命令

```shell
wsx@wsx-laptop:~/tmp$ sed -e 's/brown/green/; s/dog/cat/' data1.txt
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
The quick green fox jumps over the lazy cat.
```

两个命令都作用到文件中的每一行数据上。命令之间必须用分号隔开，并且**在命令末尾与分号之间不同有空格**。

如果不想使用分号，可以用bash shell中的次提示符来分隔命令。

```shell
wsx@wsx-laptop:~/tmp$ sed -e '
> s/brown/green/
> s/fox/elephant/
> s/dog/cat/' data1.txt
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
```

#### 从文件中读取编辑器命令

如果有大量要处理的sed命令，将其单独放入一个文本中会更方便，可以用sed命令的`-f`选项来指定文件。

```shell
wsx@wsx-laptop:~/tmp$ cat script1.sed
s/brown/green/
s/fox/elephant/
s/dog/cat/

wsx@wsx-laptop:~/tmp$ sed -f script1.sed data1.txt
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
The quick green elephant jumps over the lazy cat.
```

这种情况不用在每个命令后面放一个分号，sed知道每行都有一条单独的命令。



### gawk程序

gawk是一个处理文本的更高级工具，能够提供一个类编程环境来修改和重新组织文件中的数据。

```
说明	在所有的发行版都没有默认安装gawk程序，请先安装
```

gawk程序是Unix中原始awk的GNU版本，它让流编辑器迈上了一个新的台阶，提供了一种编程语言而不只是编辑器命令。

我们可以利用它做下面的事情：

- 定义变量来保存数据
- 使用算术和字符串操作符来处理数据
- 使用结构化编程概念来为数据处理增加处理逻辑
- 通过提取数据文件中的数据元素，将其重新排列或格式化，生成格式化报告

gawk程序的报告生成能力通常用来从大文本文件中提取数据元素，并将它们格式化成可读的报告，使得重要的数据更易于可读。

#### 基本命令格式

```shell
gawk options program file
```

下面显示了gawk程序的可用选项

| 选项           | 描述                  |
| ------------ | ------------------- |
| -F fs        | 指定行中划分数据字段的字段分隔符    |
| -f file      | 从指定文件中读取程序          |
| -v var=value | 定义gawk程序中的一个变量及其默认值 |
| -mf N        | 指定要处理的数据文件中的最大字段数   |
| -mr N        | 指定数据文件中的最大数据行数      |
| -W keyword   | 指定gawk的兼容模式或警告等级    |

gawk的**强大之处在于程序脚本**（善于利用工具最强之处），可以写脚本来读取文本行的数据，然后处理并显示数据，创建任何类型的输出报告。

#### 从命令行读取脚本

我们必须将脚本命令放入两个花括号中，而由于gawk命令行假定脚本是单个文本字符串，所以我们必须把脚本放到单引号中。

下面是一个简单的例子：

```shell
wsx@wsx-laptop:~/tmp$ gawk '{print "Hello World!"}'

Hello World!
This is a test
Hello World!
This is
Hello World!

Hello World!

```

`print`命令将文本打印到STDOUT。如果尝试允许命令，我们可能会有些失望，因为什么都不会发生，原因是没有指定文件名，所以gawk会从STDIN接收数据，如果我们按下回车，gawk会对这行文本允许一遍程序脚本。

要终止这个程序必须表明数据流已经结束了，bash shell提供组合键来生成EOF(End-of-File)字符。Ctrl+D组合键会在bash中产生一个EOF字符。

#### 使用数据字段变量

gawk的主要特性之一是其处理文本文件中数据的能力，它自动给一行的每个数据元素分配一个变量。

- $0代表整个文本行
- $1代表文本行的第一个数据字段
- $2代表文本行的第二个数据字段
- $n代表文本行的第n个数据字段

gawk在读取一行文本时，会用预定义的字段分隔符划分每个数据字段。默认字段分隔符为任意的空白字符（例如空格或制表符）。

下面例子gawk读取文本显示第一个数据字段的值。

```shell
wsx@wsx-laptop:~/tmp$ cat data2.txt
One line of test text.
Two lines of test text.
Three lines of test text.
wsx@wsx-laptop:~/tmp$ gawk '{print $1}' data2.txt
One
Two
Three
```

我们可以使用`-F`选项指定其他字段分隔符：

```shell
wsx@wsx-laptop:~/tmp$ gawk -F: '{print $1}' /etc/passwd
root
daemon
bin
sys
sync
games
man
lp
mail
news
uucp
proxy
www-data
backup
...
```

这个简短程序显示了系统中密码文件的第一个数据字段。

#### 在程序脚本中使用多个命令

在命令之间放个分号即可。

```shell
wsx@wsx-laptop:~/tmp$ echo "My name is Shixiang" | gawk '{$4="Christine"; print $0}'
My name is Christine
```

也可以使用次提示符一次一行输入程序脚本命令（类似sed）。

#### 从文件中读取程序

```shell
wsx@wsx-laptop:~/tmp$ cat script2.gawk
{print $1 " 's home directory is " $6}
wsx@wsx-laptop:~/tmp$ gawk -F: -f script2.gawk  /etc/passwd
root 's home directory is /root
daemon 's home directory is /usr/sbin
bin 's home directory is /bin
sys 's home directory is /dev
sync 's home directory is /bin
games 's home directory is /usr/games
man 's home directory is /var/cache/man
lp 's home directory is /var/spool/lpd
mail 's home directory is /var/mail
news 's home directory is /var/spool/news
uucp 's home directory is /var/spool/uucp
proxy 's home directory is /bin
...
```

可以在程序文件中指定多条命令：

```shell
wsx@wsx-laptop:~/tmp$ cat script3.gawk
{
text = "'s home directory is "
print $1 text $6
}
wsx@wsx-laptop:~/tmp$ gawk -F: -f script3.gawk /etc/passwd
root's home directory is /root
daemon's home directory is /usr/sbin
bin's home directory is /bin
sys's home directory is /dev
sync's home directory is /bin
games's home directory is /usr/games
man's home directory is /var/cache/man
lp's home directory is /var/spool/lpd
mail's home directory is /var/mail
news's home directory is /var/spool/news
...
```

#### 在处理数据前运行脚本

使用BEGIN关键字可以强制gawk再读取数据前执行BEGIN关键字指定的程序脚本。

```shell
wsx@wsx-laptop:~/tmp$ cat data3.txt
Line 1
Line 2
Line 3
wsx@wsx-laptop:~/tmp$ gawk 'BEGIN {print "The data3 File Contents:"}
> {print $0}' data3.txt
The data3 File Contents:
Line 1
Line 2
Line 3
```

在gawk执行了BEGIN脚本后，它会用第二段脚本来处理文件数据。

#### 在处理数据后允许脚本

与BEGIN关键字类似，END关键字允许我们指定一个脚本，gawk在读完数据后执行。

```shell
wsx@wsx-laptop:~/tmp$ gawk 'BEGIN {print "The data3 File Contents:"}
> {print $0}
> END {print "End of File"}' data3.txt
The data3 File Contents:
Line 1
Line 2
Line 3
End of File
```

我们把所有的内容放在一起组成一个漂亮的小程序脚本，用它从简单的数据文件中创建一份完整报告。

```shell
wsx@wsx-laptop:~/tmp$ cat script4.gawk
BEGIN {
print "The latest list of users and shells"
print " UserID \t Shell"
print "-------- \t ------"
FS=":"
}

{
print $1 "      \t " $7
}

END {
print "This concludes the listing"
}
wsx@wsx-laptop:~/tmp$ gawk -f script4.gawk /etc/passwd
The latest list of users and shells
 UserID          Shell
--------         ------
root             /bin/bash
daemon           /usr/sbin/nologin
bin              /usr/sbin/nologin
sys              /usr/sbin/nologin
sync             /bin/sync
games            /usr/sbin/nologin
man              /usr/sbin/nologin
lp               /usr/sbin/nologin
mail             /usr/sbin/nologin
news             /usr/sbin/nologin
uucp             /usr/sbin/nologin
proxy            /usr/sbin/nologin
www-data         /usr/sbin/nologin
backup           /usr/sbin/nologin
list             /usr/sbin/nologin
irc              /usr/sbin/nologin
gnats            /usr/sbin/nologin
nobody           /usr/sbin/nologin
systemd-timesync         /bin/false
systemd-network          /bin/false
systemd-resolve          /bin/false
systemd-bus-proxy        /bin/false
syslog           /bin/false
_apt             /bin/false
lxd              /bin/false
messagebus               /bin/false
uuidd            /bin/false
dnsmasq          /bin/false
sshd             /usr/sbin/nologin
pollinate        /bin/false
wsx              /bin/bash
This concludes the listing
```

我们以后会继续学习gawk高级编程。

## sed编辑器基础

下面介绍一些可以集成到脚本中的基本命令和功能。

### 更多的替换选项

之前我们已经学习了用`s`命令在行中替换文本，这个命令还有一些其他选项。

#### 替换标记

替换命令`s`默认只替换每行中出现的第一处。要让该命令能替换一行中不同地方出现的文本必须使用**替换标记**。该标记在替换命令字符串之后设置。

```shell
s/pattern/replacement/flags
```

替换标记有4种：

- 数字，表明替换第几处模式匹配的地方
- g，表明替换所有匹配的文本
- p，表明原先行的内容要打印出来
- w file，将替换的结果写入文件中

```shell
wsx@wsx-laptop:~/tmp$ cat data4.txt
This is a test of the test script.
This is the second test of the test script.
wsx@wsx-laptop:~/tmp$ sed 's/test/trial/2' data4.txt
This is a test of the trial script.
This is the second test of the trial script.
```

该命令只替换每行中第二次出现的匹配模式。而`g`标记替换所有的匹配之处。

```shell
wsx@wsx-laptop:~/tmp$ sed 's/test/trial/g' data4.txt
This is a trial of the trial script.
This is the second trial of the trial script.
```

`p`替换标记会打印与替换命令中指定的模式匹配的行，通常与sed的`-n`选项一起使用。

```shell
wsx@wsx-laptop:~/tmp$ cat data5.txt
This is a test line.
This is a different line.
wsx@wsx-laptop:~/tmp$ sed -n 's/test/trial/p' data5.txt
This is a trial line.
```

`-n`选项禁止sed编辑器输出，但`p`标记会输出修改过的行。两者配合使用就是**只输出被替换命令修改过的行**。

`w`标记会产生同样的输出，不过会将输出（只输出被替换命令修改过的行）保存到指定文件中。

```shell
wsx@wsx-laptop:~/tmp$ sed 's/test/trial/w test.txt' data5.txt
This is a trial line.
This is a different line.
wsx@wsx-laptop:~/tmp$ cat test.txt
This is a trial line.
```

#### 替换字符

有一些字符不方便在替换模式中使用，常见的例子为正斜线。

替换文件中的路径名会比较麻烦，比如用C shell替换/etc/passwd文件中的bash shell，必须这样做（通过反斜线转义）：

```shell
wsx@wsx-laptop:~/tmp$ head /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
...
wsx@wsx-laptop:~/tmp$ sed 's/\/bin\/bash/\/bin\/csh/' /etc/passwd
root:x:0:0:root:/root:/bin/csh
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
...
```

为解决这样的问题，sed编辑器允许选择其他字符来替换命令中的字符串分隔符：

```shell
wsx@wsx-laptop:~/tmp$ sed 's!/bin/bash!/bin/csh!' /etc/passwd
root:x:0:0:root:/root:/bin/csh
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
...
```



### 使用地址

如果只想要命令作用于特定行或某些行，必须使用**行寻址**。

有两种形式：

- 以数字形式表示行区间
- 用文本模式来过滤出行

它们都使用相同地格式来指定地址：

```shell
[address]command
```

也可以将多个命令分组

```shell
address {
  command1
  command2
  command3
}
```

#### 以数字的方式行寻址

sed编辑器会将文本流中的第一行编号为1，然后继续按顺序给以下行编号。

指定的地址**可以是单个行号，或者用行号、逗号以及结尾行号指定的一定区间范围的行**。

```shell
wsx@wsx-laptop:~/tmp$ cat data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
wsx@wsx-laptop:~/tmp$ sed '2s/dog/cat/' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
wsx@wsx-laptop:~/tmp$ sed '2,3s/dog/cat/' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
wsx@wsx-laptop:~/tmp$ sed '2,$s/dog/cat/' data1.txt  # 美元符指代最后一行
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
```

#### 使用文本模式过滤器

sed允许指定文本模式来过滤出命令要作用的行，格式如下：

```
/pattern/command
```

比如我要修改默认的shell，可以使用sed命令：

```shell
wsx@wsx-laptop:~/tmp$ grep wsx /etc/passwd
wsx:x:1000:1000:"",,,:/home/wsx:/bin/bash
wsx@wsx-laptop:~/tmp$ grep '/wsx/s/bash/csh/' /etc/passwd
wsx@wsx-laptop:~/tmp$ sed '/wsx/s/bash/csh/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
...
wsx:x:1000:1000:"",,,:/home/wsx:/bin/csh
```

正则表达式允许创建高级文本模式匹配表达式来匹配各种数据，结合一系列通配符、特殊字符来生成几乎任何形式文本的简练模式。我们后续会学习到。

#### 命令组合

使用花括号可以将多条命令组合在一起。

```shell
wsx@wsx-laptop:~/tmp$ sed '2{
> s/fox/elephant/
> s/dog/cat/
> }' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown elephant jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
```

也可以在一组命令前指定一个地址区间。

```shell
wsx@wsx-laptop:~/tmp$ sed '3,${
s/brown/green/
s/lazy/active/
}' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
The quick green fox jumps over the active dog.
```

### 删除行

如果需要删除文本流中的特定行，使用删除命令`d`，它会删除匹配指定寻址模式的所有行。**使用时要特别小心**，如果忘记加入寻址模式，会将所有文本行删除。

```shell
wsx@wsx-laptop:~/tmp$ cat data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
wsx@wsx-laptop:~/tmp$ sed 'd' data1.txt
```

和指定的地址一起使用才能发挥删除命令的最大功用。

```shell
wsx@wsx-laptop:~/tmp$ cat data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
wsx@wsx-laptop:~/tmp$ sed '3d' data6.txt
This is line number 1.
This is line number 2.
This is line number 4.
```

通过特定行区间指定：

```shell
wsx@wsx-laptop:~/tmp$ sed '2,3d' data6.txt
This is line number 1.
This is line number 4.
```

通过特殊文本结尾字符指定：

```shell
wsx@wsx-laptop:~/tmp$ sed '2,$d' data6.txt
This is line number 1.
```

还可以使用模式匹配特性：

```shell
wsx@wsx-laptop:~/tmp$ sed '/number 1/d' data6.txt
This is line number 2.
This is line number 3.
This is line number 4.
```

sed会删除包含匹配模式的行。

记住，sed不会修改原始文件。

还可以使用两个文本模式来删除某个区间内的行，但做的时候需要特别小心，指定的第一个模式会“打开”行删除功能，第二个模式会“关闭”行删除功能。sed会删除两个指定行之间的所有行（包括指定行）。

```shell
wsx@wsx-laptop:~/tmp$ cat data7.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
This is line number 1 again.
This is text you want to keep.
This is the last line in the file.
wsx@wsx-laptop:~/tmp$ sed '/1/,/3/d' data7.txt
This is line number 4.
```

第二个出现的数字“1”的行再次触发了删除命令，因为未能找到停止模式“3”，所以将数据流剩余的行全部删掉了。

```shell
wsx@wsx-laptop:~/tmp$ sed '/1/,/5/d' data7.txt
wsx@wsx-laptop:~/tmp$ sed '/2/,/4/d' data7.txt
This is line number 1.
This is line number 1 again.
This is text you want to keep.
This is the last line in the file.
```

### 插入和附加文本

sed允许向数据流插入和附加文本行：

- 插入命令`i`会在指定行前增加一个新行
- 附加命令`a`会在指定行后增加一个新行

注意，它们不能在单个命令行上使用，必须要指定是要插入还是要附加到的那一行。

```shell
wsx@wsx-laptop:~/tmp$ echo "Test Line 2" | sed 'i\Test Line 1'
Test Line 1
Test Line 2
wsx@wsx-laptop:~/tmp$ echo "Test Line 2" | sed 'a\Test Line 1'
Test Line 2
Test Line 1
```

要向数据流行内部插入或附加数据，必须用寻址来告诉sed数据应该出现在什么位置。

```shell
wsx@wsx-laptop:~/tmp$ sed '3i\ This is an inserted line.' data6.txt
This is line number 1.
This is line number 2.
 This is an inserted line.
This is line number 3.
This is line number 4.
wsx@wsx-laptop:~/tmp$ sed '3a\ This is an inserted line.' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
 This is an inserted line.
This is line number 4.
```

如果想要给数据流末尾添加多行数据，通过`$`指定位置即可。

```shell
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
 This is a new line.
```



### 修改行

修改（change）命令允许修改整个数据流中整行文本内容。它跟插入和附加命令的工作机制一样。

```shell
wsx@wsx-laptop:~/tmp$ sed '3c\This is a changed line.' data6.txt
This is line number 1.
This is line number 2.
This is a changed line.
This is line number 4.
wsx@wsx-laptop:~/tmp$ sed '/number 3/c\This is a changed line.' data6.txt
This is line number 1.
This is line number 2.
This is a changed line.
This is line number 4.
```



### 转换命令

转换命令（y）是**唯一可以处理单字符的sed命令**。格式如下：

```shell
[address]y/inchars/outchars
```

转换命令会对`inchars`和`outchars`值进行一对一的映射。如果两者字符长度不同，则sed产生一条错误信息。

```shell
wsx@wsx-laptop:~/tmp$ sed 'y/123/789/' data6.txt
This is line number 7.
This is line number 8.
This is line number 9.
This is line number 4.
```

转换命令是一个全局命令，**它会在文本行中找到的所有指定字符自动进行转换，而不会考虑它们出现的位置**。

### 回顾命令

另有3个命令可以用来打印数据流中的信息：

- `p`命令用来打印文本行
- 等号`=`命令用来打印行号
- `l`用来列出行

#### 打印行

```shell
wsx@wsx-laptop:~/tmp$ echo "this is a test" | sed 'p'
this is a test
this is a test
```

`p`打印已有的数据文本。最常用的用法是打印符合匹配文本模式的行。

```shell
wsx@wsx-laptop:~/tmp$ cat data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
wsx@wsx-laptop:~/tmp$ sed -n '/number 3/p' data6.txt
This is line number 3.
```

在命令行上使用`-n`选项，可以禁止输出其他行，只打印包含匹配文本模式的行。

也可以用来快速打印数据流中的某些行：

```shell
wsx@wsx-laptop:~/tmp$ sed -n '2,3p' data6.txt
This is line number 2.
This is line number 3.
```

#### 打印行号

```shell
wsx@wsx-laptop:~/tmp$ cat data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
wsx@wsx-laptop:~/tmp$ sed '=' data1.txt
1
The quick brown fox jumps over the lazy dog.
2
The quick brown fox jumps over the lazy dog.
3
The quick brown fox jumps over the lazy dog.
4
The quick brown fox jumps over the lazy dog.
5
The quick brown fox jumps over the lazy dog.
6
The quick brown fox jumps over the lazy dog.
7
The quick brown fox jumps over the lazy dog.
8
The quick brown fox jumps over the lazy dog.
9
The quick brown fox jumps over the lazy dog.
```

这用来查找特定文本模式的话非常方便：

```shell
wsx@wsx-laptop:~/tmp$ sed -n '/number 4/{
> =
> p
> }' data6.txt
4
This is line number 4.
```

#### 列出行

```shell
wsx@wsx-laptop:~/tmp$ cat data9.txt
This    line    contains        tabs.
wsx@wsx-laptop:~/tmp$ sed -n 'l' data9.txt
This\tline\tcontains\ttabs.$
```

### 使用Sed处理文件

#### 写入文件

`w`命令用来向文件写入行。该命令格式如下：

```shell
[address]w filename
```

将文本的前两行写入其他文件：

```shell
wsx@wsx-laptop:~/tmp$ sed '1,2w test.txt' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
wsx@wsx-laptop:~/tmp$ cat test.txt
This is line number 1.
This is line number 2.
```

如果不想让行显示到STDOUT（因为sed默认数据文本流），可以使用sed命令的`-n`选项。

#### 读取数据

读取命令为`r`。

```shell
wsx@wsx-laptop:~/tmp$ cat data12.txt
This is an added line.
This is the second added line.
wsx@wsx-laptop:~/tmp$ sed '3r data12.txt' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is an added line.
This is the second added line.
This is line number 4.
```

这效果有点像插入文本命令`i`和补充命令`a`。

 同样适用于文本模式地址：

```shell
wsx@wsx-laptop:~/tmp$ sed '/number 2/r data12.txt' data6.txt
This is line number 1.
This is line number 2.
This is an added line.
This is the second added line.
This is line number 3.
This is line number 4.
```

文本末尾添加：

```shell
wsx@wsx-laptop:~/tmp$ sed '$r data12.txt' data6.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
This is an added line.
This is the second added line.
```

**读取命令的一个很酷的用法是和删除命令配合使用：利用另一个文件中的数据来替换文件中的占位文本**。假如你有一份套用信件保存在文本中：

```shell
wsx@wsx-laptop:~/tmp$ cat notice.std
Would the following people:
LIST
please report to the ship's captain.
```

套用信件将通用占位文本`LIST`放在人物名单的位置，我们先根据它插入文本字符，然后删除它。

```shell
wsx@wsx-laptop:~/tmp$ sed '/LIST/{
> r data10.txt
> d
> }' notice.std
Would the following people:
This line contains an escape character.
please report to the ship's captain.
wsx@wsx-laptop:~/tmp$ cat data10.txt
This line contains an escape character.
wsx@wsx-laptop:~/tmp$ cat data11.txt
wangshx zhdan
wsx@wsx-laptop:~/tmp$ sed '/LIST/{
r data11.txt
d
}' notice.std
Would the following people:
wangshx zhdan
please report to the ship's captain.
```

可以看到占位符被替换成了数据文件中的文字。

完。
