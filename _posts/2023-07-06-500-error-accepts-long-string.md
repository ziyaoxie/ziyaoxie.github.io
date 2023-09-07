---
title: "PHP POST 接受长字符串时出现 500 错误"
date: 2023-07-06T15:02:00+08:00
author: Xie Ziyao
layout: post
permalink: /500-error-accepts-long-string/
categories: [工作笔记]
tags: [typecho, nginx]
---

今天发布 typecho 文章出现 500 错误，字符串短没有任何问题，长文章直接报错 `500 Internal Server Error`。
<!--more-->

查看 nginx 错误日志 `/var/log/nginx/error.log` 发现以下错误信息：

{% highlight text %}
2023/07/06 12:40:08 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000004" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
2023/07/06 12:41:43 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000005" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
2023/07/06 12:42:26 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000006" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
2023/07/06 12:42:40 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000007" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
2023/07/06 12:43:11 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000008" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
2023/07/06 12:44:35 [crit] 15896#0: *2125 open() "/var/lib/nginx/tmp/client_body/0000000009" failed (13: Permission denied), client: 119.147.10.212, server: imx.ink, request: "POST /action/contents-post-edit?_=8679a495ae30a8c84ff2fc1fccb8a4e7 HTTP/2.0", host: "imx.ink", referrer: "https://imx.ink/admin/write-post.php?cid=42"
{% endhighlight %}

进到 `/var/lib` 目录下查看 nginx 目录的权限：

{% highlight bash %}
$ ls -al /var/lib
drwx------  3 root    root     4096 Jun 13 12:50 nginx
{% endhighlight %}

执行命令 `chmod -R 775 /var/lib/nginx` 问题解决。