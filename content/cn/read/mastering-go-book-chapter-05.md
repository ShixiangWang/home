---
title: "《Mastering Go》第五章笔记"
author: "王诗翔"
date: "2020-08-26"
slug: ""
categories: [golang]
tags: ['golang', '数据结构']
---


Go 的一些数据结构（图、树、队列等）都由标准包 container 提供。

### 图和顶点

图G(V,E)是顶点V(或节点)的有限非空集合和边E的集合。图有两种主要类型:循环图和无环图。

### 算法复杂度

用大 O 表示。

常见的有：

`$$
O(1) \\
O(n) \\
O(n^2) \\
O(n^3) \\
O(n!)
$$`

通常来说，使用数组比使用字典要快。

### 二叉树

概念：

- 根节点 root
- 树的深度 depth of a tree
- 节点深度 depth of a node
- 叶节点 leaf
- 平衡树 balanced tree：树的根到所有叶子的距离都差不多
- 非平衡树 unbalanced tree

Go 实现：

```go
package main

import (
	"fmt"
	"math/rand"
	"time"
)

type Tree struct {
	Left  *Tree
	Value int
	Right *Tree
}

func traverse(t *Tree) {
	if t == nil {
		return
	}
	traverse(t.Left)
	fmt.Print(t.Value, " ")
	traverse(t.Right)
}

func create(n int) *Tree {
	var t *Tree
	rand.Seed(time.Now().Unix())
	for i := 0; i < 2*n; i++ {
		temp := rand.Intn(n * 2)
		t = insert(t, temp)
	}
	return t
}

func insert(t *Tree, v int) *Tree {
	if t == nil {
		return &Tree{nil, v, nil}
	}
	if v == t.Value {
		return t
	}
	if v < t.Value {
		t.Left = insert(t.Left, v)
		return t
	}
	t.Right = insert(t.Right, v)
	return t
}

func main() {
	tree := create(10)
	fmt.Println("The value of the root of the tree is", tree.Value)
	traverse(tree)
	fmt.Println()
	tree = insert(tree, -10)
	tree = insert(tree, -2)
	traverse(tree)
	fmt.Println()
	fmt.Println("The value of the root of the tree is", tree.Value)
}
```

如果二叉树是平衡的，搜索、插入和删除需要 `log(n)` 步，`n` 是整个树包含的元素数量。因此极大的增大数量速度也非常快。

缺点：

- 树的形状取决于插入的顺序，如果键很长和复杂，那么速度就慢了。
- 如果是非平衡的，性能就难以预测。

