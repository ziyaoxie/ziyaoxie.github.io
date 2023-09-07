---
title: "如何删除 Docker 镜像，容器和卷"
date: 2023-06-25T16:19:00+08:00
author: Xie Ziyao
layout: post
permalink: /delete-docker-images-containers-and-volumes/
categories: [工作笔记]
tags: [docker]
---

Docker 本身提供了从命令行清理系统所需的所有工具，可用于释放磁盘空间并通过删除未使用的 Docker 镜像，容器和卷来保持系统的有序性。

## 清除所有未使用或悬空的镜像，容器，卷和网络

Docker 提供了一个命令，可以清理悬空的任何资源（镜像，容器，卷和网络）（与容器无关）：

{% highlight bash %}
$ docker system prune
{% endhighlight %}

要另外删除任何已停止的容器和所有未使用的图像（不只是悬空图像），请将该 -a 标志添加到命令：

{% highlight bash %}
$ docker system prune -a
{% endhighlight %}

## 删除镜像

删除悬空镜像：

{% highlight bash %}
# 列出悬空镜像
$ docker images -f dangling=true
# 删除悬空镜像
$ docker images purge

# 删除所有镜像
$ docker rmi $(docker images -a -q)
{% endhighlight %}

## 删除容器

使用多个过滤器移除容器：

{% highlight bash %}
# 如果要删除标记为Created的所有容器（运行具有无效命令的容器时可能导致的状态）或Exited，则可以使用两个过滤器
$ docker rm $(docker ps -a -f status=exited -f status=created -q)

# 停止所有容器
$ docker stop $(docker ps -a -q)
# 删除所有容器
$ docker rm $(docker ps -a -q)
{% endhighlight %}

## 删除卷

仅 Docker 1.9 及更高版本支持。由于卷的位置与容器无关，因此在移除容器时，不会同时自动删除卷；当卷存在且不再连接到任何容器时，它称为悬空卷。

删除悬空卷：

{% highlight bash %}
# 列出悬空卷
$ docker volume ls -f dangling=true
# 删除悬空卷
$ docker volume prune

# 删除容器及其卷
$ docker rm -v container_name
{% endhighlight %}
