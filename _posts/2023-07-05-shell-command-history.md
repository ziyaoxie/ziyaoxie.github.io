---
title: "history 命令整理"
date: 2023-07-05T19:34:00+08:00
author: Xie Ziyao
layout: post
permalink: /shell-command-history/
categories: [工作笔记]
tags: [shell, history]
---

history 命令的常用方法记录。

## 显示时间戳

如果要让 `history` 在显示历史命令时同时显示记录命令的时间，则需要设置如下环境变量：

{% highlight bash %}
$ export HISTTIMEFORMAT='%F %T '
{% endhighlight %}

也可以设置 `alias` 语句来查看最近的历史命令：

{% highlight bash %}
alias h1='history 10'
alias h2='history 20'
alias h3='history 30'
{% endhighlight %}

## 搜索历史命令

按下 `Ctrl +R` 然后输入关键字，可以在历史命令中通过关键字来查找已经历史命名。例如，搜索 `red`，则显示以前的命令中含有 `red` 的命令 `cat/etc/redhat-release`：

{% highlight bash %}
# 在命令行提示符下按下Ctrl＋R, 终端将显示如下提示
(reverse-i-search)\`red`: cat/etc/redhat-release
# 当看到命令后按回车键，就可以重新执行这条命令
$ cat /etc/redhat-release
Fedora release 9 (Sulphur)
{% endhighlight %}

## 执行特定命令

用 `history` 显示历史命令的时候，在每个命令前边都有一个编号，用 `!` + `编号` 可以重新执行该条命令。例如：

{% highlight bash %}
$ history | more
1 service network restart
2 exit
3 id
4 cat /etc/redhat-release

$ !4
Fedora release 9 (Sulphur)
{% endhighlight %}

## 其他配置

{% highlight bash %}
# 控制历史命令的总数
export HISTSIZE=450
export HISTFLESIZE=450

# 改变历史文件名
export HISTFILE=/root/.commandline_warrior

# 消除命令历史中的连续重复条目
export HISTCONTROL='ignoredups'

# 禁止记录任何命令
export HISTSIZE=0
{% endhighlight %}
