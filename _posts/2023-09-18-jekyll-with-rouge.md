---
title: "在 Jekyll 中使用 Rouge 代码语法高亮"
date: 2023-09-18T20:36:00+08:00
author: Xie Ziyao
layout: post
permalink: /jekyll-with-rouge/
categories: [工作笔记]
tags: [jekyll]
---

Jekyll 内置支持使用 Rouge 或 Pygments 对代码片段进行语法高亮显示，Rouge 是 Jekyll 3 及更高版本中的默认语法高亮显示，且支持 Github Pages。

## 安装 Rouge

安装 Rouge 和普通的 Jekyll 插件安装一样：

{% highlight bash %}
$ gem install rouge
{% endhighlight %}

然后在 `_config.yml` 文件声明使用：

{% highlight yaml %}
highlighter: rouge
{% endhighlight %}

如果你使用 `kramdown`，那么添加以下内容：

{% highlight yaml %}
markdown: kramdown
kramdown:
input: GFM
syntax_highlighter: rouge
{% endhighlight %}

## 使用 Rouge 代码语法高亮

Rouge 可以支持 100 多种语言的语法突出显示，参考[官方说明](https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers)。要使用语法突出显示来呈现代码块，示例如下：

{% highlight markdown %}
{% raw %}
{% highlight ruby linenos %}
def foo
  puts 'foo'
end
{% endhighlight %}
{% endraw %}
{% endhighlight %}

包含 `linenos` 参数将强制突出显示的代码包含行号。

## Rouge 样式

Rouge 提供了一些语法突出显示样式主题，参考官方说明：[Rouge 主题文档](https://rouge-ruby.github.io/docs/Rouge/Themes.html) / [Rouge 主题](https://github.com/mzlogin/rouge-themes)。

Rouge 内置有 `rougify`，这是一个将样式主题转换为 CSS 文件的命令行工具，参考上面链接的文档使用。

## 特殊代码处理

{% assign openTag = '{%' %}

Markdown 解析代码块时，如遇到 Liquid 的源码，由于转义字符 { 及 }，会使用得 Liquid 的部分不被渲染，可以用标签 `{{ openTag }} raw %}` 与 `{{ openTag }} endraw %}` 包裹转义字符进行处理。

## 参考资料

- [Syntax Highlighting your code in Jekyll with Rouge](https://dqdongg.com/blog/2018/12/22/Blog-rouge.html)
- [使用Jekyll和github搭建自己的个人博客](http://blog.17study.com.cn/2017/12/11/setting-your-own-jekyll-blog/)
