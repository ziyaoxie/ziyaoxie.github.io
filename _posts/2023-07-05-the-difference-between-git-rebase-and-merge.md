---
title: "Git rebase 与 merge 的区别"
date: 2023-07-05T19:32:00+08:00
author: Xie Ziyao
layout: post
permalink: /the-difference-between-git-rebase-and-merge/
categories: [工作笔记]
tags: [git]
---

`git rebase` 与 `git merge` 的区别在于，`merge` 会将不同分支的提交合并成一个新的节点，之前的提交分开显示；而 `rebase` 则是将两个分支的提交融合成一个线性的提交。

如下图所示，一个项目在 `C2` 时基于主分支创建了一个 `experiment` 分支，并做了一个 `C3` 版本的提交：

{:refdef: style="text-align: center;"}
![git_flow](https://f005.backblazeb2.com/file/wml5yw8gwgll/20230705/git_flow.jpg)
{: refdef}

如果用 `merge` 命令合并，结果如下图：

{:refdef: style="text-align: center;"}
![git_merge](https://f005.backblazeb2.com/file/wml5yw8gwgll/20230705/git_merge.jpg)
{: refdef}

如果用 `rebase` 命令合并，结果如下图：

{:refdef: style="text-align: center;"}
![git_rebase](https://f005.backblazeb2.com/file/wml5yw8gwgll/20230705/git_rebase.jpg)
{: refdef}

单纯的从功能上来讲，Rebase 与 Merge 没有什么区别。但实际上，Rebase 更干净，因为提交历史最后会是线性的，但是 commit 不一定按日期先后排列，而是 local commit 总在后边；Merge 会保留各分支的提交历史，commit 会按日期先后排序，但这样看起来会比较复杂。

在操作过程中，Merge 操作遇到冲突的时候，当前 `merge` 不能继续进行下去，需手动修改冲突内容后再做一次提交；而 `rebase` 操作的话，会中断 `rebase`，同时会提示去解决冲突。解决冲突后，将修改 `add`，然后执行 `git rebase --continue` 继续操作，或者 `git rebase --skip` 忽略冲突。

需要注意的一点是，我们平时 `git pull` 时，实际上是将远程提交与本地提交进行 `merge`。`git pull` 默认是 `git fetch` + `git merge FETCH_HEAD` 的缩写。如果希望 `pull` 时使用 `rebase`，可以加上 `--rebase` 参数。

至于 `merge` 与 `rebase` 的使用场景，则是众说纷纭，具体可以根据自己的需求选择合适的方式。