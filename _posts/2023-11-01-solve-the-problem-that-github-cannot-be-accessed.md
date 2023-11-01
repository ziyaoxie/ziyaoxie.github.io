---
title: "解决国内服务器 Github 无法访问"
date: 2023-11-01T17:00:00+08:00
author: Xie Ziyao
layout: post
permalink: /solve-the-problem-that-github-cannot-be-accessed/
categories: [工作笔记]
tags: [github, script]
---

GitHub 访问慢、访问超时一直是国内服务器困扰的问题，网上各种 ping IP、配 Host 的方式无法一劳永逸。[GitHub520](https://github.com/521xueweihan/GitHub520) 开源项目轻松解决了 GitHub 访问的难题，配置简单，自动化更新。

## 使用方法（适用于类 Unix 系统）

{% highlight bash %}
# GNU（Ubuntu/CentOS/Fedora）
$ sudo sh -c 'sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts'

# BSD/macOS
$ sed -i "" "/# GitHub520 Host Start/,/# Github520 Host End/d" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
{% endhighlight %}

将上面的命令添加到 `crontab` 定时执行，使用前确保 GitHub520 内容在该文件最后部分。
