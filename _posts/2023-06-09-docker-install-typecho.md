---
title: "Docker 部署 Typecho"
date: 2023-06-09T17:02:00+08:00
author: Xie Ziyao
layout: post
permalink: /docker-install-typecho/
categories: [技术文章]
tags: [docker, typecho]
---

博客搭建环境为腾讯云服务器资源，使用 Docker 容器部署 Typecho 服务，添加 Https 支持和常用的样式修改。

## 安装 Docker 并配置镜像加速源

参考[搭建 Docker](https://cloud.tencent.com/document/product/213/46000) 和[腾讯云软件源加速软件包下载和更新](https://cloud.tencent.com/document/product/213/8623)安装部署；

## 安装 Typecho 服务

使用 [80x86/typecho](https://hub.docker.com/r/80x86/typecho) 开源镜像，注意 `/srv/http/typecho` 为 `typecho` 解压安装的路径，下载地址参考[链接](https://typecho.org/download)； 安装执行命令：

{% highlight bash %}
$ docker run -d \
--name=typecho-blog \
--restart always \
--mount type=tmpfs,destination=/tmp \
-v /srv/http/typecho:/data \
-e PHP_TZ=Asia/Shanghai \
-e PHP_MAX_EXECUTION_TIME=600 \
-p 80:80 \
-p 443:443 \
80x86/typecho:latest
{% endhighlight %}

## Docker HTTPS 开启

腾讯云官网申请免费证书：[免费 SSL 证书申请流程](https://cloud.tencent.com/document/product/400/6814)，下载 `Nginx` 证书，得到 `xxxx.pem` 和 `xxxx.key` 文件，上传至 `/srv/http/typecho/crt` 文件夹中，需要先新建此文件夹。

进入 Docker 容器的 Nginx 配置目录：

{% highlight bash %}
$ docker exec -it typecho /bin/sh
$ cd /etc/nginx/sites-enabled
{% endhighlight %}

修改默认 server 配置 `default` 文件为：

{% highlight config %}
server {
  listen   443 ssl; ## listen for ipv4; this line is default and implied
  listen   [::]:443 ssl default ipv6only=on; ## listen for ipv6

  root /app;
  index index.php index.html index.htm;

  ssl_certificate "/data/crt/xxxx.com.pem";
  ssl_certificate_key "/data/crt/xxxx.com.key";
  ssl_session_cache shared:SSL:1m;
  ssl_session_timeout 10m;

  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!aNULL:!MD5:!ADH:!RC4;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;

  # 其余不改动
 }
{% endhighlight %}

新建 `redirect` 文件：

{% highlight config %}
server {
    listen 80;
    server_name yoursite.com www.yoursite.com;

    rewrite ^(.*)$  https://$host$1 permanent;
}
{% endhighlight %}

重启 Nginx 服务：

{% highlight bash %}
$ nginx -s reload
{% endhighlight %}

## 博客样式修改

适用于 `maupassant` 主题，下载参考[链接](https://github.com/pagecho/maupassant)，部分修改需要清空缓存重新加载生效。

### 文章日期修改

主要修改了首页标题下日期，以及边栏归档日期的显示。

打开 `index.php` 文件，改为 `date ('Y 年 n 月 j 日')`：

{% highlight php %}
<date class="post-meta">
    <?php $this->date('Y 年 n 月 j 日'); ?>
</date>
{% endhighlight %}

打开 `sidebar.php` 文件, 改为 `type=month&format=Y 年 m 月`：

{% highlight php %}
<section class="widget">
    <h3 class="widget-title"><?php _e('归档'); ?></h3>
    <ul class="widget-list">
        <?php $this->widget('Widget_Contents_Post_Date', 'type=month&format=Y年m月')
        ->parse('<li><a href="{permalink}">{date}</a></li>'); ?>
    </ul>
</section>
{% endhighlight %}

### 链接颜色修改

打开 `style.css` 文件, 将 `color` 改为 `#C83C23`：

{% highlight css %}
.post-content a, .comment-content a {
    border-bottom:1px solid #ddd;
    color: #C83C23;
}
{% endhighlight %}

### 代码高亮修改

打开 `footer.php` 文件, 引入 `highlight.js`：

{% highlight php %}
<script src="//cdn.jsdelivr.net/gh/highlightjs/cdn-release@10.5.0/build/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
{% endhighlight %}

打开 `header.php`, 引入 `css` 样式文件, 可以自行在 `highlight.js` 官网选择：

{% highlight php %}
<link rel="stylesheet" href="//cdn.jsdelivr.net/gh/highlightjs/cdn-release@10.5.0/build/styles/default.min.css">
{% endhighlight %}

### 中西文自动加空格

打开 `footer.php` 文件, 在 `\<body>` 标签中加入下面代码：

{% highlight php %}
<script>
  const text = pangu.spacing("當你凝視著bug，bug也凝視著你");
  // text = '當你凝視著 bug，bug 也凝視著你'

  pangu.spacingElementById('main');
  pangu.spacingElementByClassName('comment');
  pangu.spacingElementByTagName('p');

  document.addEventListener('DOMContentLoaded', () => {
    // listen to any DOM change and automatically perform spacing via MutationObserver()
    pangu.autoSpacingPage();
  });
</script>
{% endhighlight %}

### 文章页添加翻页

打开 `post.php` 文件, 在 `\</article>` 标签后添加下面代码：

{% highlight php %}
<div class="post-nav">
    <div class="post-nav-pre" style="float:left;">
        <?php $this->thePrev('上一篇 : %s', ''); ?>
    </div>
    <div class="post-nav-next" style="float:right;">
        <?php $this->theNext('下一篇 : %s', ''); ?>
    </div>
</div>
{% endhighlight %}

打开 `style.css` 添加下面代码：

{% highlight css %}
/* 文章翻页 */
.post-nav{
    overflow: hidden;
    margin: 35px 0;
    padding-top: 10px;
    border-top: 1px solid #ddd;
}

.post-nav-pre a{
    color:#C83C23;
}

.post-nav-next a{
    color:#C83C23;
}
{% endhighlight %}

### 添加版权声明

打开 `post.php`, 在 `\</article>` 标签后, 添加版权声明代码：

{% highlight php %}
<div class=copyright>
    <div class=cp-title>
        <strong>本文标题：</strong><?php $this->title(); ?>
    </div>
    <div class=cp-author>
        <strong>文章作者：</strong><?php $this->author(); ?>
    </div>
    <div class=cp-date>
        <strong>发布时间：</strong><?php $this->date('Y 年 m 月 d 日'); ?>
    </div>
    <div class=cp-update>
        <strong>更新时间：</strong><?php echo date('Y 年 m 月 d 日', $this->modified);?>
    </div>
    <div class=cp-url>
        <strong>原始链接：</strong><a href="<?php $this->permalink() ?>"><?php $this->permalink() ?></a>
    </div>
    <div class=cp-cc>
        <strong>许可协议：</strong><a href="http://creativecommons.org/licenses/by/4.0/deed.zh" target="_blank" rel="noopener noreferrer nofollow">署名 4.0 国际（CC BY 4.0）</a>，转载请保留原文链接和作者。
    </div>
</div>
{% endhighlight %}

打开 `style.css`, 添加版权声明样式：

{% highlight css %}
/* 版权声明 */
.copyright{
    background-color: #f0f0f0;
    padding: 12px;
    line-height: 1.6;
}
.cp-url a{
    color:#C83C23;
    border-bottom: 1px solid #ddd;
}
.cp-cc a{
    color: #C83C23;
    border-bottom: 1px solid #ddd;
}
{% endhighlight %}

### 添加打赏功能

打开 `post.php`, 添加下面代码在合适位置：

{% highlight php %}
<div style="padding: 10px 0; margin: 20px auto; width: 100%; font-size:16px; text-align: center;">
    <button id="rewardButton" disable="enable" onclick="var qr = document.getElementById('QR'); if (qr.style.display === 'none') {qr.style.display='block';} else {qr.style.display='none'}"> <span>打赏</span> </button>
    <p style="color:#999;font-size:14px;">多寡随意，丰俭由人</p>
    <div id="QR" style="display: none;">
        <div id="wechat" style="display: inline-block">
        <a class="fancybox" rel="group"><img id="wechat_qr" src="/yourpath/wechatpay.png" alt="WeChat Pay" /></a>
        <p> 微信打赏 </p>
        </div>
        <div id="alipay" style="display: inline-block">
        <a class="fancybox" rel="group"><img id="alipay_qr" src="/yourpath/alipay.png" alt="Alipay" /></a>
        <p> 支付宝打赏 </p>
        </div>
    </div>
</div>
{% endhighlight %}

打开 `style.css`, 添加打赏按钮样式文件：

{% highlight css %}
/* 文章打赏 */
#QR {
    padding-top: 20px;
    border: #f05050;
}

#QR a {
    border: 0
}

#QR img {
    width: 180px;
    max-width: 100%;
    display: inline-block;
    margin: .8em 2em 0 2em
}

#rewardButton {
    border: 1px solid #f05050;
    line-height: 36px;
    text-align: center;
    height: 36px;
    display: block;
    border-radius: 4px;
    -webkit-transition-duration: .4s;
    transition-duration: .4s;
    background-color: #f05050;
    color: #fff;
    margin: 0 auto;
    padding: 0 25px
}

#rewardButton:hover {
    color: #f77b83;
    border-color: #f77b83;
    outline-style: none
}

#rewardButton {
    background-color: #f05050;
    color: white;
    border-radius: 50px;
    cursor: pointer;
}
{% endhighlight %}

### 图片 & 引用样式优化

文章中的图片之前容易跟背景色融合，于是加上 border 和圆角处理，加了二层阴影。

打开 `style.css`：

{% highlight css %}
.post-content img, .comment-content img {
    max-width:100%;
    margin-left: auto;
    margin-right:auto;
    display:block;
    border: 1px solid #f0f0f0;
    border-radius: 6px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 1px 3px rgba(0, 0, 0, 0.08);
}
{% endhighlight %}

打开 `style.css`：

{% highlight css %}
blockquote {
    margin: 1.5em 0em;
    padding: 0.5em 1.5em;
    /* padding-left: 1.5em; */
    border-left: 4px solid #ddd;
    color: #777;
    font-size: 0.82em;
    background-color: #f9f9f9;
}
{% endhighlight %}

### 配置网站浏览器图标

制作 ico 图片文件，可以参考[链接](https://www.bitbug.net/)，文件下载到 `typecho/themes/{theme_name}/favicon.ico` 路径。

在 `header.php` 的 `<head></head>` 标签之间添加：

{% highlight php %}
<link rel="shortcut icon" href="<?php $this->options->themeUrl('favicon.ico'); ?>" type="image/x-icon" />
# 如果有下面这一行就删掉
<link data-n-head="true" rel="icon" type="image/x-icon" href="/favicon.ico">
{% endhighlight %}

### 主页只显示摘要方法

在编写文章时在摘要和全文中间使用分隔符 `<!--more-->`，例如：

{% highlight html %}
[文章摘要BALABALA ...]
<!--more-->
[文章正文BALABALA ...]
{% endhighlight %}
