---
title: "使用 Golang 绘制爱心文本"
author: "王诗翔"
date: "2020-01-24"
lastmod: "2020-01-24"
slug: "golang-text-heart"
categories: [golang]
tags: [golang, heart]
---



这两天利用最近所学，编写了一个 Golang [绘制爱心文本程序](https://github.com/ShixiangWang/GoArduino/blob/master/Go/practice/textHeart/main.go)。

```go
package main

import (
	"flag"
	"fmt"
	"math"
	"strings"
	"time"
)

// Print text heart
// Author: ShixiangWang
// LICENSE: MIT
// Reference: https://blog.csdn.net/su_bao/article/details/80355001
func main() {
	// MYWORD My word
	var head string
	var tail string
	var MYWORD string
	var sep string
	var zoom float64
	flag.StringVar(&head, "head", "There are some words I wana tell you:", "A sentence printed on the head")
	flag.StringVar(&tail, "tail", "\t\t\t\t--- Your lover", "A sentence printed on the tail")
	flag.StringVar(&MYWORD, "words", "Dear, I love you forever!", "The words you want to talk")
	flag.StringVar(&sep, "sep", " ", "The separator")
	flag.Float64Var(&zoom, "zoom", 1.0, "Zoom setting")
	flag.Parse()

	chars := strings.Split(MYWORD, sep)

	time.Sleep(time.Duration(1) * time.Second)
	fmt.Println(head)
	fmt.Println()
	time.Sleep(time.Duration(1) * time.Second)
	for _, char := range chars {
		allChar := make([]string, 0)

		for y := 12 * zoom; y > -12*zoom; y-- {
			lst := make([]string, 0)
			lstCon := ""
			for x := -30 * zoom; x < 30*zoom; x++ {
				x2 := float64(x)
				y2 := float64(y)
				formula := math.Pow(math.Pow(x2*0.04/zoom, 2)+math.Pow(y2*0.1/zoom, 2)-1, 3) - math.Pow(x2*0.04/zoom, 2)*math.Pow(y2*0.1/zoom, 3)
				if formula <= 0 {
					index := int(x) % len(char)
					if index >= 0 {
						lstCon += string(char[index])
					} else {
						lstCon += string(char[int(float64(len(char))-math.Abs(float64(index)))])
					}

				} else {
					lstCon += " "
				}
			}
			lst = append(lst, lstCon)
			allChar = append(allChar, lst...)
		}

		for _, text := range allChar {
			fmt.Printf("%s\n", text)
		}
	}
	time.Sleep(time.Duration(1) * time.Second)
	fmt.Println("\t\t\t\t", tail)
}

```

用法如下：

```shell
$ go run main.go -h
Usage of C:\Users\Shixiang\AppData\Local\Temp\go-build146721866\b001\exe\main.exe:
  -head string
        A sentence printed on the head (default "There are some words I wana tell you:")
  -sep string
        The separator (default " ")
  -tail string
        A sentence printed on the tail (default "\t\t\t\t--- Your lover")
  -words string
        The words you want to talk (default "Dear, I love you forever!")
  -zoom float
        Zoom setting (default 1)
exit status 2
```

我们简单看下使用的效果：

```shell
$ go run main.go
There are some words I wana tell you:

            ar,Dear,Dea               r,Dear,Dear
        r,Dear,Dear,Dear,Dea     r,Dear,Dear,Dear,Dea       
     Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,D    
    ,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,De   
   r,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dea  
  ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear 
  ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear 
  ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear
  ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear 
   r,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dea
   r,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dea
    ,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,De
     Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,D
       ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear
        r,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dea
          Dear,Dear,Dear,Dear,Dear,Dear,Dear,Dear,D
            ar,Dear,Dear,Dear,Dear,Dear,Dear,Dear
               Dear,Dear,Dear,Dear,Dear,Dear,D
                  r,Dear,Dear,Dear,Dear,Dea
                     ear,Dear,Dear,Dear,
                         Dear,Dear,D
                            r,Dea
                              D

            IIIIIIIIIII               IIIIIIIIIII
        IIIIIIIIIIIIIIIIIIII     IIIIIIIIIIIIIIIIIIII
     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
    IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
   IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 
   IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
   IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
    IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
       IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
        IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
          IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
            IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
               IIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
                  IIIIIIIIIIIIIIIIIIIIIIIII
                     IIIIIIIIIIIIIIIIIII
                         IIIIIIIIIII
                            IIIII
                              I

            velovelovel               lovelovelov
        velovelovelovelovelo     elovelovelovelovelov       
     elovelovelovelovelovelovelovelovelovelovelovelovelo
    velovelovelovelovelovelovelovelovelovelovelovelovelov
   ovelovelovelovelovelovelovelovelovelovelovelovelovelove
  lovelovelovelovelovelovelovelovelovelovelovelovelovelovel
  lovelovelovelovelovelovelovelovelovelovelovelovelovelovel
  lovelovelovelovelovelovelovelovelovelovelovelovelovelovel
  lovelovelovelovelovelovelovelovelovelovelovelovelovelovel
   ovelovelovelovelovelovelovelovelovelovelovelovelovelove
   ovelovelovelovelovelovelovelovelovelovelovelovelovelove
    velovelovelovelovelovelovelovelovelovelovelovelovelov
     elovelovelovelovelovelovelovelovelovelovelovelovelo
       ovelovelovelovelovelovelovelovelovelovelovelove
        velovelovelovelovelovelovelovelovelovelovelov
          lovelovelovelovelovelovelovelovelovelovel
            velovelovelovelovelovelovelovelovelov
               ovelovelovelovelovelovelovelove
                  lovelovelovelovelovelovel
                     elovelovelovelovelo
                         elovelovelo
                            velov
                              l

            youyouyouyo               uyouyouyouy
        uyouyouyouyouyouyouy     youyouyouyouyouyouyo
     uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
    ouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyou   
   youyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouy
  uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
  uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
  uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
  uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
   youyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouy
   youyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouy
    ouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyou
     uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
       ouyouyouyouyouyouyouyouyouyouyouyouyouyouyouyou
        uyouyouyouyouyouyouyouyouyouyouyouyouyouyouyo
          ouyouyouyouyouyouyouyouyouyouyouyouyouyou
            youyouyouyouyouyouyouyouyouyouyouyouy
               youyouyouyouyouyouyouyouyouyouy
                  youyouyouyouyouyouyouyouy
                     youyouyouyouyouyouy
                         ouyouyouyou
                            ouyou
                              y

            r!forever!f               forever!for
        rever!forever!foreve     ever!forever!forever
     !forever!forever!forever!forever!forever!forever!fo
    r!forever!forever!forever!forever!forever!forever!for   
   er!forever!forever!forever!forever!forever!forever!fore
  ver!forever!forever!forever!forever!forever!forever!forev
  ver!forever!forever!forever!forever!forever!forever!forev
  ver!forever!forever!forever!forever!forever!forever!forev
  ver!forever!forever!forever!forever!forever!forever!forev
   er!forever!forever!forever!forever!forever!forever!fore
   er!forever!forever!forever!forever!forever!forever!fore
    r!forever!forever!forever!forever!forever!forever!for   
     !forever!forever!forever!forever!forever!forever!fo
       orever!forever!forever!forever!forever!forever!
        rever!forever!forever!forever!forever!forever
          ver!forever!forever!forever!forever!forev
            r!forever!forever!forever!forever!for
               orever!forever!forever!forever!
                  ver!forever!forever!forev
                     !forever!forever!fo
                         ever!foreve
                            r!for
                              f

                                                                --- Your lover
```



在除夕之夜，谨以此献上我的祝福：

```shell
$ go run main.go -head "Best wishes to my readers:" -words "Happy Chinese New Year! I wish you good health, successful career, happy family reunion and good luck in everyth
ing!" -tail "--- Shixiang" -sep "zz" -zoom 1.5
Best wishes to my readers:

                  nd good luck in e                     se New Year! I wi
             ion and good luck in everyt           Chinese New Year! I wish yo
          eunion and good luck in everything   ppy Chinese New Year! I wish you g
         reunion and good luck in everything!Happy Chinese New Year! I wish you goo       
      ly reunion and good luck in everything!Happy Chinese New Year! I wish you good
     ily reunion and good luck in everything!Happy Chinese New Year! I wish you good h
    mily reunion and good luck in everything!Happy Chinese New Year! I wish you good he
    mily reunion and good luck in everything!Happy Chinese New Year! I wish you good he
   amily reunion and good luck in everything!Happy Chinese New Year! I wish you good hea
   amily reunion and good luck in everything!Happy Chinese New Year! I wish you good hea
   amily reunion and good luck in everything!Happy Chinese New Year! I wish you good hea  
   amily reunion and good luck in everything!Happy Chinese New Year! I wish you good hea
   amily reunion and good luck in everything!Happy Chinese New Year! I wish you good hea
    mily reunion and good luck in everything!Happy Chinese New Year! I wish you good he
    mily reunion and good luck in everything!Happy Chinese New Year! I wish you good he
     ily reunion and good luck in everything!Happy Chinese New Year! I wish you good h
      ly reunion and good luck in everything!Happy Chinese New Year! I wish you good
       y reunion and good luck in everything!Happy Chinese New Year! I wish you good
         reunion and good luck in everything!Happy Chinese New Year! I wish you goo
         reunion and good luck in everything!Happy Chinese New Year! I wish you go
           union and good luck in everything!Happy Chinese New Year! I wish you
            nion and good luck in everything!Happy Chinese New Year! I wish you
              on and good luck in everything!Happy Chinese New Year! I wish y
                 and good luck in everything!Happy Chinese New Year! I wish
                  nd good luck in everything!Happy Chinese New Year! I wi
                     good luck in everything!Happy Chinese New Year! I
                        d luck in everything!Happy Chinese New Year
                          luck in everything!Happy Chinese New Ye
                               in everything!Happy Chinese Ne
                                  everything!Happy Chinese
                                     rything!Happy Chi
                                        hing!Happy
                                            !Ha
                                             H


                                 --- Shixiang
```
