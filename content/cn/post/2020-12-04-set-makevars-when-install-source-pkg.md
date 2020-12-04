---
title: "安装 R 源码包时踩过的坑"
author: "王诗翔"
date: "2020-12-04"
lastmod: "2020-12-04"
slug: ""
# All available categories:
# bioinformatics, config, docker, golang, life, linux, ml, r, read, shell, thinking
categories: ["r"]
tags: ["r", "动态库", "安装"]
---

这两天在课题组服务器上安装微软的 R 版本，然后又操作了一波从头开始软件安装，遭遇了几个常见的几个坑。例如 XML 包和 RCurl 包第一次安装一半都需要提取安装好需要的系统依赖库（`libxml2-devel`、`libcurl-devel`）。这些都比较好解决，在安装包时如果缺乏它会提示你不同的系统应该输入什么命令。有些问题就比较难搞了，毕竟本人对 C 语言不懂，今天安装时出现安装完成后无法载入动态链接库的问题。

### 问题

这个问题是在安装 Rsamtools 是遇到的，Rhtslib 是它的依赖包。这个依赖包安装时老是提示 `undefined symbol lzma_easy_buffer_encode`。搞了半天我才知道这个符号是定义在其他的动态库中，但是 gcc 编译时找不到，所以出现了这个问题。

```
** R
** inst
** byte-compile and prepare package for lazy loading
 Loading required package: pacman
** help
*** installing help indices
** building package indices
 Loading required package: pacman
** installing vignettes
** testing if installed package can be loaded
 Loading required package: pacman
Error: package or namespace load failed for ‘Rhtslib’ in dyn.load(file, DLLpath = DLLpath, ...):
 unable to load shared object '/home/public/R/library/Rhtslib/libs/Rhtslib.so':
  /home/public/R/library/Rhtslib/libs/Rhtslib.so: undefined symbol: lzma_easy_buffer_encode
Error: loading failed
Execution halted
ERROR: loading failed
* removing ‘/home/public/R/library/Rhtslib’
Warning message:
In install.packages("~/Rhtslib_1.22.0.tar.gz", repos = NULL) :
  installation of package ‘/home/wsx/Rhtslib_1.22.0.tar.gz’ had non-zero exit status
```

### 最终怎么解决的

一开始我以为动态库没安装，但实际测试后已经安装所需要的 `xz-devel`（centos 7）。
然后我试着添加常见的动态库路径 `LD_LIBRARY_PATH` 并没有什么用。一般的情况下设置了这个环境变了后，编译器可以根据该变量进行查找就 ok 了。

最后通过谷歌搜索学习加逐步的试错通过在 `~/.R/Makevars` 文件中加入下面语句解决：

```
PKG_LIBS+=-llzma
```

### 有用的工具

在遇到上述这种问题，有几个命令会非常有用。

- `nm` 可以在 `.so` 文件中搜索 symbol

```
$ nm /home/anaconda3/lib/liblzma.so  | grep easy_buffer
00000000000074f0 T lzma_easy_buffer_encode
```

- `echo $LD_LIBRARY_PATH` 查看目前已经设置的搜索库路径

```
$ echo $LD_LIBRARY_PATH
/usr/lib64/openmpi/lib:/lib64:/home/anaconda3/lib/:/opt/anaconda3/bin/lib:/public/tools/GISTIC2/MATLAB_Compiler_Runtime/v83/runtime/glnxa64:/public/tools/GISTIC2/MATLAB_Compiler_Runtime/v83/bin/glnxa64:/public/tools/GISTIC2/MATLAB_Compiler_Runtime/v83/sys/os/glnxa64:
```

- `ldd` 查看某个动态库引用了哪些链接库，有时候报错就是依赖库没有安装或者找不到。

```
$ ldd /home/public/R/library_bk/Rhtslib/libs/Rhtslib.so
        linux-vdso.so.1 =>  (0x00007fff801e6000)
        libcurl.so.4 => /lib64/libcurl.so.4 (0x00007f7dce74f000)
        libR.so => not found
        libc.so.6 => /lib64/libc.so.6 (0x00007f7dce381000)
        libnghttp2.so.14 => /lib64/libnghttp2.so.14 (0x00007f7dce15a000)
        libssh2.so.1 => /lib64/libssh2.so.1 (0x00007f7dcdf20000)
        libpsl.so.0 => /lib64/libpsl.so.0 (0x00007f7dcdca8000)
        libssl3.so => /lib64/libssl3.so (0x00007f7dcda4b000)
        libsmime3.so => /lib64/libsmime3.so (0x00007f7dcd823000)
        libnss3.so => /lib64/libnss3.so (0x00007f7dcd4ef000)
        libnssutil3.so => /lib64/libnssutil3.so (0x00007f7dcd2bf000)
        libplds4.so => /lib64/libplds4.so (0x00007f7dcd0bb000)
        libplc4.so => /lib64/libplc4.so (0x00007f7dcceb6000)
        libnspr4.so => /lib64/libnspr4.so (0x00007f7dccc78000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f7dcca5c000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007f7dcc858000)
        libgssapi_krb5.so.2 => /lib64/libgssapi_krb5.so.2 (0x00007f7dcc60b000)
        libkrb5.so.3 => /lib64/libkrb5.so.3 (0x00007f7dcc322000)
        libk5crypto.so.3 => /lib64/libk5crypto.so.3 (0x00007f7dcc0ef000)
        libcom_err.so.2 => /lib64/libcom_err.so.2 (0x00007f7dcbeeb000)
        libldap-2.4.so.2 => /lib64/libldap-2.4.so.2 (0x00007f7dcbc96000)
        liblber-2.4.so.2 => /lib64/liblber-2.4.so.2 (0x00007f7dcba87000)
        libz.so.1 => /lib64/libz.so.1 (0x00007f7dcb871000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7dcec5d000)
        libssl.so.10 => /lib64/libssl.so.10 (0x00007f7dcb5ff000)
        libcrypto.so.10 => /lib64/libcrypto.so.10 (0x00007f7dcb19c000)
        libicuuc.so.50 => /lib64/libicuuc.so.50 (0x00007f7dcae23000)
        libicudata.so.50 => /lib64/libicudata.so.50 (0x00007f7dc9850000)
        librt.so.1 => /lib64/librt.so.1 (0x00007f7dc9648000)
        libkrb5support.so.0 => /lib64/libkrb5support.so.0 (0x00007f7dc9438000)
        libkeyutils.so.1 => /lib64/libkeyutils.so.1 (0x00007f7dc9234000)
        libresolv.so.2 => /lib64/libresolv.so.2 (0x00007f7dc901a000)
        libsasl2.so.3 => /lib64/libsasl2.so.3 (0x00007f7dc8dfd000)
        libstdc++.so.6 => /lib64/libstdc++.so.6 (0x00007f7dced14000)
        libm.so.6 => /lib64/libm.so.6 (0x00007f7dc8afb000)
        libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007f7dc88e5000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007f7dc86be000)
        libcrypt.so.1 => /lib64/libcrypt.so.1 (0x00007f7dc8487000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007f7dc8225000)
        libfreebl3.so => /lib64/libfreebl3.so (0x00007f7dc8022000)
```

- `gcc -Wl, -v /dev/null` 查看编译器是怎么搜索头文件或库的。

```
$ gcc -x c -v -E /dev/null
Using built-in specs.
COLLECT_GCC=gcc
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++,objc,obj-c++,java,fortran,ada,go,lto --enable-plugin --enable-initfini-array --disable-libgcj --with-isl=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/isl-install --with-cloog=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/cloog-install --enable-gnu-indirect-function --with-tune=generic --with-arch_32=x86-64 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
COLLECT_GCC_OPTIONS='-v' '-E' '-mtune=generic' '-march=x86-64'
 /usr/libexec/gcc/x86_64-redhat-linux/4.8.5/cc1 -E -quiet -v /dev/null -mtune=generic -march=x86-64
ignoring nonexistent directory "/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include-fixed"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../x86_64-redhat-linux/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-redhat-linux/4.8.5/include
 /usr/local/include
 /usr/include
End of search list.
# 1 "/dev/null"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "/dev/null"
COMPILER_PATH=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/:/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/:/usr/libexec/gcc/x86_64-redhat-linux/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/:/usr/lib/gcc/x86_64-redhat-linux/
LIBRARY_PATH=/usr/lib/gcc/x86_64-redhat-linux/4.8.5/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64/:/lib/../lib64/:/usr/lib/../lib64/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-v' '-E' '-mtune=generic' '-march=x86-64'

$ gcc -Wl, -v /dev/null
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++,objc,obj-c++,java,fortran,ada,go,lto --enable-plugin --enable-initfini-array --disable-libgcj --with-isl=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/isl-install --with-cloog=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/cloog-install --enable-gnu-indirect-function --with-tune=generic --with-arch_32=x86-64 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
COMPILER_PATH=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/:/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/:/usr/libexec/gcc/x86_64-redhat-linux/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/:/usr/lib/gcc/x86_64-redhat-linux/
LIBRARY_PATH=/usr/lib/gcc/x86_64-redhat-linux/4.8.5/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64/:/lib/../lib64/:/usr/lib/../lib64/:/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-v' '-mtune=generic' '-march=x86-64'
 /usr/libexec/gcc/x86_64-redhat-linux/4.8.5/collect2 --build-id --no-add-needed --eh-frame-hdr --hash-style=gnu -m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64/crt1.o /usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64/crti.o /usr/lib/gcc/x86_64-redhat-linux/4.8.5/crtbegin.o -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5 -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64 -L/lib/../lib64 -L/usr/lib/../lib64 -L/usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../.. "" /dev/null -lgcc --as-needed -lgcc_s --no-as-needed -lc -lgcc --as-needed -lgcc_s --no-as-needed /usr/lib/gcc/x86_64-redhat-linux/4.8.5/crtend.o /usr/lib/gcc/x86_64-redhat-linux/4.8.5/../../../../lib64/crtn.o
/usr/bin/ld: cannot find : No such file or directory
/dev/null: file not recognized: File truncated
collect2: error: ld returned 1 exit status
```

参考：<https://stackoverflow.com/questions/43597632/understanding-the-contents-of-the-makevars-file-in-r-macros-variables-r-ma>
