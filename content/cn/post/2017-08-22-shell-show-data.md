---
title: Linux脚本编程——呈现数据
author: 王诗翔
date: 2017-08-21
categories: ["shell"]
tags: ["linux", "shell", "note"]

summary: "怎么通过脚本呈现数据...包括重定向与日志文件等。"
---



> 本章内容：
>
> - 再探重定向
> - 标准输入和输出
> - 报告错误
> - 丢弃数据
> - 创建日志文件



<!-- more -->

## 理解输入和输出

显示输出的方法有：

- 在显示器屏幕上输出
- 将输出重定向到文件中
- 有时将一部分数据显示在显示器上；一部分保存到文件中。

之前涉及的脚本都是以第一种方式输出。现在我们来具体了解下输入和输出。

### 标准文件描述符

**Linux系统将每个对象当作文件处理**。着包括输入和输出进程。而标识文件对象是通过**文件描述符**完成的。文件描述符是一个非负整数，可以唯一标识会话中打开的文件。每个进程一次最多有九个文件描述符，bash shell保留勒前三个（0,1,2），见下表。

| 文件描述符 | 缩写     | 描述   |
| ----- | ------ | ---- |
| 0     | STDIN  | 标准输入 |
| 1     | STDOUT | 标准输出 |
| 2     | STDERR | 标准错误 |

shell用他们将shell默认的输入和输出导向到相应的位置。

**STDIN**

在使用输入重定向符号（<）时，Linux会用重定向指定的文件夹来替换标准输入文件描述符。它会读取文件并提取数据，就像它是从键盘上键入的。

```shell
wangsx@SC-201708020022:~/tmp$ cat
this is a test
this is a test
this is a second test
this is a second test
```

输入`cat`命令时，它从STDIN接受输入。输入一行，`cat`命令会显示一行。

当然也可以通过`<`符号强制`cat`命令接受来自另一个非STDIN文件的输入。

```shell
wangsx@SC-201708020022:~$ cat < testfile
This is the first line.
This is the second line.
This is the third line.
```

**STDOUT**

标准输出就是终端显示器。我们可以使用`<`输出重定向符号来改变它。

```shell
wangsx@SC-201708020022:~$ ls -l > test2
wangsx@SC-201708020022:~$ cat test2
总用量 28
drwxrwxrwx 0 wangsx wangsx 4096 8月   2 11:48 biosoft
-rw-rw-rw- 1 wangsx wangsx 2156 8月   4 00:12 biostar.yml
drwxrwxrwx 0 wangsx wangsx 4096 8月   3 22:24 miniconda2
drwxrwxrwx 0 wangsx wangsx 4096 8月   2 11:50 ncbi
-rw-rw-rw- 1 wangsx wangsx 5230 8月  14 00:14 spf13-vim.sh
drwxrwxrwx 0 wangsx wangsx 4096 8月  13 23:51 src
-rw-rw-rw- 1 wangsx wangsx    0 8月  21 22:43 test2
-rw-rw-rw- 1 wangsx wangsx   73 8月  21 22:39 testfile
drwxrwxrwx 0 wangsx wangsx 4096 8月  19 17:15 tmp
-rw-rw-rw- 1 wangsx wangsx 2156 8月  14 12:20 wsx_biostar.yml
```

如果文件存在，`>`符号会将导向的文件全部重写。如果想要以追加的形式，则使用`>>`。

**STDERR**

STDERR文件描述符代表shell的标准错误输出。运行脚本或命令的错误信息都会发送到这个位置。

默认，STDERR会和STDOUT指向同样的地方（屏幕终端）。使用脚本时，我们常常会希望将错误信息保存到日志文件中。



### 重定向错误

几种实现方法：

1. 只重定向错误

   将文件描述符值（2）放在重定向符号前。

   ```shell
   wangsx@SC-201708020022:~$ ls -al badfile 2> test4
   wangsx@SC-201708020022:~$ cat test4
   ls: 无法访问'badfile': 没有那个文件或目录
   ```

   命令生成的任何错误信息都会保存在输出文件中。**这个方法只重定向错误信息。**

2. 重定向错误和数据

   这必须用两个重定向符号。需要在符号前面放上待重定向数据所对应的文件描述符，然后指向用于保存数据的输出文件。

   ```shell
   wangsx@SC-201708020022:~$ ls -al test test2 test3 bad test 2> test6 1> test7
   wangsx@SC-201708020022:~$ cat test6
   ls: 无法访问'test': 没有那个文件或目录
   ls: 无法访问'test3': 没有那个文件或目录
   ls: 无法访问'bad': 没有那个文件或目录
   ls: 无法访问'test': 没有那个文件或目录
   wangsx@SC-201708020022:~$ cat test7
   -rw-rw-rw- 1 wangsx wangsx 571 8月  21 22:43 test2
   ```

   可以看到正常输出重定向到了test7，错误重定向到了test6。另外，也可以将STDERR和STDOUT的输出重定向到同一个输出文件，bash shell提供了符号`&>`。

   ```shell
   wangsx@SC-201708020022:~$ ls -al test test2 test3 bad &> test7
   wangsx@SC-201708020022:~$ cat test7
   ls: 无法访问'test': 没有那个文件或目录
   ls: 无法访问'test3': 没有那个文件或目录
   ls: 无法访问'bad': 没有那个文件或目录
   -rw-rw-rw- 1 wangsx wangsx 571 8月  21 22:43 test2
   ```

   使用这个符号的话，bash shell会自动赋予错误消息更高的优先级。这样能够集中浏览错误信息。

   ​

## 在脚本中重定向输出

两种方法在脚本中重定向输出：

- 临时重定向输出
- 永久重定向脚本中的所有命令

### 临时重定向

如果**有意**在脚本中生成错误信息，可以将单独的一行输出重定向到STDERR。

使用时需要在文件描述符数字前加`&`:

```shell
echo "This is an error message" >&2
```

下面看个例子：

```shell
wangsx@SC-201708020022:~$ cat test8
#!/bin/bash
# testing STDERR message

echo "This is an error" >&2
echo "This is normal output"
```

像平常一样运行的话，看出不会有什么差别。

```shell
wangsx@SC-201708020022:~$ sh test8
This is an error
This is normal output
```

但是如果重定向STDERR的话，所有导向STDERR的文本都会被重定向

```shell
wangsx@SC-201708020022:~$ sh test8 2> test9
This is normal output
wangsx@SC-201708020022:~$ cat test9
This is an error
```

**这个方法非常适合在脚本中生成错误信息**。

### 永久重定向

如果脚本中涉及大量重定向，上述的方法就会非常繁琐。我们可以用`exec`命令告诉shell在脚本执行期间重定向某个特定文件描述符。

```shell
wangsx@SC-201708020022:~$ cat test10
#!/bin/bash
# redirecting all output to a file
exec 1>testout

echo "This is a test of redirecting all output"
echo "from a script to another file"
echo "without having to redirect every individual line"
wangsx@SC-201708020022:~$ sh test10
wangsx@SC-201708020022:~$ cat testout
This is a test of redirecting all output
from a script to another file
without having to redirect every individual line
```

再结合STDERR看看

```shell
wangsx@SC-201708020022:~$ cat test11
#!/bin/bash
# redirecting output to different locations

exec 2>testerror

echo "This is the start of the script"
echo "now redirecting all output to another location"

exec 1>testout
echo "This output should go to the testout file"
echo "but this should go to the testerror file" >&2
wangsx@SC-201708020022:~$ sh test11
This is the start of the script
now redirecting all output to another location
wangsx@SC-201708020022:~$ cat testout
This output should go to the testout file
wangsx@SC-201708020022:~$ cat testerror
but this should go to the testerror file
```

**这个脚本用`exec`命令将STDERR的输出重定向到文件testerror。接着echo语句向STDOUT显示几行文本。随后使用`exec`命令将STDOUT重定向到testout文件。**最后，虽然STDOUT被重定向了，但依然可以将echo语句发给STDERR。

这里存在一个问题，一旦重定向了STDOUT或STDERR，就很难将他们重定向回原来的位置。

这个问题可以用以下方式解决。

前面提到shell只用了3个文件描述符，而总共有9个，我们可以利用其他6个来操作。

这里只需要另外使用一个，就可以重定向文件描述符：

```shell
wangsx@SC-201708020022:~$ cat test14
#!/bin/bash
# storing STDOUT, the coming back to it

exec 3>&1
exec 1>test14out

echo "This should store in the output file"
echo "along with this line"

exec 1>&3
echo "Now things should be back to normal"
wangsx@SC-201708020022:~$ sh test14
Now things should be back to normal
wangsx@SC-201708020022:~$ cat test14out
This should store in the output file
along with this line
```

这里有意思的是把重定向当程序变量在玩，类似

```shell
a=b # 把b的内容存到a
b=c # 修改b的内容
# 使用完后
b=a # 将b原来的内容还原
```

输入文件描述符也可以进行类似的操作。



## 阻止命令输出

有时候不想显示脚本的输出就要这么干。

一种通用的方法是将STDERR重定向到`null`的特殊文件（里面什么都没有）。shell输出到null文件的任何数据都不会保存，全部被丢掉了。

null文件在Linux中的标准位置是`/dev/null`。

```shell
wangsx@SC-201708020022:~$ ls -al > /dev/null
wangsx@SC-201708020022:~$ cat /dev/null
wangsx@SC-201708020022:~$
```

这是避免出现错误消息，也无需保存它们的一个常用方法。

```shell
wangsx@SC-201708020022:~$ ls -al badfile test2 2> /dev/null
-rw-rw-rw- 1 wangsx wangsx 571 8月  21 22:43 test2
```

由于null文件不含有任何内容，程序员通常用它来快速清除现有文件中的数据，而不用先删除文件再重新创建。

```shell
wangsx@SC-201708020022:~$ cat testfile
This is the first line.
This is the second line.
This is the third line.
wangsx@SC-201708020022:~$ cat /dev/null > testfile
wangsx@SC-201708020022:~$ cat testfile
wangsx@SC-201708020022:~$
```



## 创建临时文件

Linux使用/tmp目录来存放不需要永久保留的文件。大多数Linux发行版配置了在启动时删除/tmp目录的所有文件。

### 创建本地临时文件

默认`mktemp`会在本地目录创建一个文件。你只需要指定文件名模板，可以是任意文本名，后面加六个`X`即可。

```shell
wangsx@SC-201708020022:~/tmp$ mktemp testing.XXXXXX
wangsx@SC-201708020022:~/tmp$ mktemp testing.XXXXXX
wangsx@SC-201708020022:~/tmp$ ll
总用量 12
drwxrwxrwx 0 wangsx wangsx 4096 8月  22 21:34 ./
drwxr-xr-x 0 wangsx wangsx 4096 8月  22 21:31 ../
-rw------- 1 wangsx wangsx    0 8月  22 21:33 testing.R6dAku
-rw------- 1 wangsx wangsx    0 8月  22 21:32 testing.V5psXP
```

`mktemp`命令会用6个字符码替换这6个`X`，从而保证文件名在目录中是唯一的。

在脚本中使用`mktemp`命令时，可能要将文件名保存到变量中，这样就可以在脚本后面引用了。

```shell
wangsx@SC-201708020022:~/tmp$ cat test19
#!/bin/bash t nomore" \
# creating and using a temp file
tempfile=$(mktemp test19.XXXXXX)

exec 3>$tempfile
echo "This script writes to temp file $tempfile
echo "This is the first line." >&3
echo "This is the last line." >&3
exec 3>&-

echo "Done creating temp file. The contents are:"
cat $tempfile
rm -f $tempfile 2> /dev/null
wangsx@SC-201708020022:~/tmp$ sh test19
This script writes to temp file test19.fVVEwn
Done creating temp file. The contents are:
This is the first line.
This is the last line.
```

显示的内容大致如上，我的ubuntu子系统有点怪怪的，不知道为毛。



`-t`选项回强制`mktemp`命令在系统的临时目录来创建该文件，它会返回临时文件的全路径，而不是只有文件名。

```shell
wangsx@SC-201708020022:~/tmp$ mktemp -t test20.XXXX
/tmp/test20.bY3Q
wangsx@SC-201708020022:~/tmp$ mktemp -t test20.XXXXXX
/tmp/test20.WrkAia
```

`-d`选项告诉`mktemp`创建一个临时目录而不是临时文件。



## 记录消息

有时候想将消息同时发送到显示器和日志文件，用`tee`命令可以搞定。

`tee`命令的功能就像一个`T`，它将从STDIN过来的数据同时发往两处。一处是STDOUT，一处是`tee`命令行所指定的文件名。

```shell
wangsx@SC-201708020022:~/tmp$ date | tee testfile
2017年 08月 22日 星期二 21:49:07 DST
wangsx@SC-201708020022:~/tmp$ cat testfile
2017年 08月 22日 星期二 21:49:07 DST
```

如果要追加文件，请使用`-a`选项。



## 实例

文件重定向常见于脚本需要读入文件和输出文件时。

下面是一个具体的实例：shell脚本使用命令行参数指定待读取的.csv文件。.csv格式用于从电子表格中导出数据，所以我们可以把数据库数据放入电子表格，把电子表格保存成.csv格式，读取文件，然后创建INSERT语句将数据插入MySQL数据库。

```shell
#!/bin/bash
# read file and create INSERT statements for MySQL

outfile='members.sql'
IFS=","
while read lname fname address city state zip # read 使用IFS字符解析读入的文本
do
    cat >> $outfile << EOF
    # >> 将cat的输出追加到$outfile指定的文件中
    # cat的输入不再取自于标准输入，而是被重定向到脚本中存储的数据，EOF符号标记了追加到文件中的数据的起止（两个）
    INSERT INTO members (lname,fname,address,city,state,zip) VALUES
    ('$lname', '$fname', '$address', '$city', '$state', '$zip');
EOF
    # 上面是标准的SQL语句
done < $1 # 将命令行第一个参数指明的数据文件导入while
```

造一个符合的csv文件

```shell
wangsx@SC-201708020022:~/tmp$ cat members.csv
Blum,Richard,123 Main St.,Chicago,IL,60601
Blum,Barbara,123 Main St.,Chicago,IL,60601
Bresnahan,Timothy,456, Oak Ave.,Columbus,OH,43201
```

运行脚本

```shell
wangsx@SC-201708020022:~/tmp$ ./test23 members.csv
wangsx@SC-201708020022:~/tmp$ cat members.sql
    INSERT INTO members (lname,fname,address,city,state,zip) VALUES
    ('Blum', 'Richard', '123 Main St.', 'Chicago', 'IL', '60601');
    INSERT INTO members (lname,fname,address,city,state,zip) VALUES
    ('Blum', 'Barbara', '123 Main St.', 'Chicago', 'IL', '60601');
    INSERT INTO members (lname,fname,address,city,state,zip) VALUES
    ('Bresnahan', 'Timothy', '456', ' Oak Ave.', 'Columbus', 'OH,43201');
```
