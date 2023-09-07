---
title: "解决 SQLite 并发异常问题的方法"
date: 2023-07-26T14:36:00+08:00
author: Xie Ziyao
layout: post
permalink: /sqlite-concurrency-exception/
categories: [工作笔记]
tags: [sqlite]
---

SQLite 是文件级别的数据库，其锁也是文件级别的：多个进程/线程可以同时读，但是同时只能有一个进程/线程写。

## 问题描述

在执行写操作时，数据库文件被琐定，此时任何其他读/写操作都被阻塞，如果阻塞超过5秒钟（默认是5秒，能过重新编译 SQLite 可以修改超时时间），就报"database is locked"错误。

## 解决方法

1、连接数据库时设置参数 `timeout`，设置当数据库处于锁定状态时最长等待时间，`sqlite3.connect()`函数的参数 `timeout` 默认值为 5 秒，不适合服务端程序；

2、使用锁机制使得多个进程/线程竞争进入临界区，确保同一时刻只有一个进程/线程执行写入数据库的代码；

{% highlight python %}
# 以多进程写为例, 注释 lock.acquire() 和 lock.release() 可复现问题

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Time : 2023/7/24 10:38
# @Author : ziyaoxie
# @File : write_sqlite_with_multiprocessing.py

import sqlite3
import traceback
import multiprocessing
from contextlib import closing


def prepare_db(db, tbl, col):
    sql = "CREATE TABLE {0} ({1} text);".format(tbl, col)
    with closing(sqlite3.connect(db)) as cnn:
        cursor = cnn.cursor()
        cursor.execute('DROP TABLE IF EXISTS {0};'.format(tbl))
        cursor.execute(sql)
        cnn.commit()
    return db, tbl, col


def write(db, tbl, col, value, lock):
    try:
        # The default timeout value of sqlite is 5s
        timeout = 1.0
        with closing(sqlite3.connect(db, timeout=timeout)) as cnn:
            lock.acquire()
            cursor = cnn.cursor()
            sql = "INSERT INTO {0} ({1}) VALUES ('{2}');".format(tbl, col, value)
            if value % 100 == 0:
                print(sql)
            cursor.execute(sql)
            cnn.commit()
            lock.release()
    except Exception:
        print(traceback.format_exc())
        lock.release()


def work(d, lock):
    db = r'multi.sqlite'
    tbl = 'logging'
    col = 'logged'
    write(db, tbl, col, d, lock)
    return d


def main():
    db = r'multi.sqlite'
    tbl = 'logging'
    col = 'logged'
    prepare_db(db, tbl, col)

    pool = multiprocessing.Pool(10)
    lock = multiprocessing.Manager().Lock()
    data = [(i, lock) for i in range(1000)]
    mapped = pool.starmap(work, data)
    pool.close()
    pool.join()

    return mapped


if __name__ == "__main__":
    main()
{% endhighlight %}

## 参考资料

- [The beets blog: the SQLite lock timeout nightmare](https://beets.io/blog/sqlite-nightmare.html)
- [sqlite 超时时间设置 [database is locked]](https://www.cnblogs.com/jasongrass/p/14609946.html)
