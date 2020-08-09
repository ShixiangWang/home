---
title: "使用RMySQL简单操作mysql数据库"
author: "王诗翔"
date: "2019-08-22"
lastmod: "2019-08-22"
slug: ""
categories: [r]
tags: [r, database, mysql]
---

使用 MySQL 数据库创建一个用于存储用户信息的数据表：包含 username, email, password 三个字段，并分别使用 SQL 和 Python/R 客户端插入、删除和更新一行数据，密码使用 SHA256 进行加密

```r
library(RMySQL)
con = dbConnect(MySQL(), user = "root", password = "xxx")
# creating a database using RMySQL in R
dbSendQuery(con, "CREATE DATABASE test_user;")
dbSendQuery(con, "USE test_user;")
dbDisconnect(con)
# reconnecting to database we just created using following command in R :
mydb = dbConnect(MySQL(), user = "root", password = "xxx", dbname="test_user")

init_table = data.frame(
    username = "user1",
    email = "wxxx@163.com",
    password = digest::sha1("yes",algo = "sha256"),
    stringsAsFactors = FALSE
)

append_table = data.frame(
    username = "user2",
    email = "wxxx@163.com",
    password = digest::sha1("another password",algo = "sha256"),
    stringsAsFactors = FALSE
)

dbWriteTable(mydb, name = "test", value = init_table, row.names = FALSE, overwrite = TRUE)
dbReadTable(mydb, "test")

# 追加数据
dbWriteTable(mydb, name = "test", value = append_table, row.names = FALSE, append = TRUE)
dbReadTable(mydb, "test")

# 更新数据
dbSendQuery(mydb, "UPDATE test set username = 'user3' where username = 'user2'")
dbReadTable(mydb, "test")

# 删除数据
dbSendQuery(mydb, "DELETE FROM test where username = 'user1'")
dbReadTable(mydb, "test")

dbDisconnect(mydb)
```

参考： <https://mkmanu.wordpress.com/2014/07/24/r-and-mysql-a-tutorial-for-beginners/>
