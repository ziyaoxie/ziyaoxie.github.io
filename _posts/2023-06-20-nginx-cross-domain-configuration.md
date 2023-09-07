---
title: "Nginx 跨域配置"
date: 2023-06-20T15:30:00+08:00
author: Xie Ziyao
layout: post
permalink: /nginx-cross-domain-configuration/
categories: [工作笔记]
tags: [nginx, 跨域]
---

同源策略是一个安全策略。同源，指的是协议，域名，端口相同。浏览器处于安全方面的考虑，只允许本域名下的接口交互，不同源的客户端脚本，在没有明确授权的情况下，不能读写对方的资源。

同源策略主要是基于如下可能的安全隐患：

1、用户访问 `www.mybank.com`，登录并进行网银操作，这时 cookie 等资源都生成并存放在浏览器；
2、用户突然访问一个另一个网站；
3、该网站在页面中，拿到银行的 cookie，比如用户名，登录 token 等，然后发起对 `www.mybank.com` 的操作；
4、若此时浏览器不对跨域做限制，并且银行也没有做响应的安全处理的话，那么用户的信息有可能就这么泄露了。

CORS 是一个 W3C 标准，全称是跨域资源共享（Cross-origin resource sharing）。即从一个域名的网页去请求另一个域名的资源。本质上对于此类请求，只要协议、域名、端口有任何一个的不同，就被当作是跨域，即都被当成不同源。

通常基于安全考虑，Nginx 启用了同源策略，即限制了从同一个源加载的文档或脚本如何与来自另一个源的资源进行交互。这是一个用于隔离潜在恶意文件的重要安全机制。

Nginx跨域配置语法如下：

1、语法：

{% highlight text %}
add_header name value [always];
{% endhighlight %}

2、配置项释义：

{% highlight text %}
Access-Control-Allow-Origin
配置 Access-Control-Allow-Origin 为 * 表示服务器可以接受所有的请求源（Origin），即接受所有跨域的请求，也可以指定一个确定的URL。

Access-Control-Allow-Headers
配置 Access-Control-Allow-Headers，代表允许在请求该地址的时候带上指定的请求头，例如：Content-Type，Authorization，使用逗号（,）拼接起来放在双引号（"）中，可根据实际请求类型添加，可防止出现以下错误：Request header field Content-Type is not allowed by Access-Control-Allow-Headers in preflight response。这个错误表示当前请求Content-Type的值不被支持。其实是因为发起了"application/json"的类型请求导致的。

Access-Control-Allow-Methods
配置 Access-Control-Allow-Methods，代表允许使用指定的方法请求该地址，常见的方法有：GET, POST, OPTIONS, PUT, PATCH, DELETE, HEAD。可防止出现以下错误：Content-Type is not allowed by Access-Control-Allow-Headers in preflight response.

Access-Control-Max-Age
配置 Access-Control-Max-Age，代表着在 86400 秒之内不用请求该地址的时候 不需要再进行预检请求，也就是跨域缓存。

Access-Control-Allow-Credentials 'true'
可选字段，为true表示允许发送Cookie。同时，发送时，必须设置XMLHttpRequest.withCredentials为true才有效，请求若服务器不允许浏览器发送，删除该字段即可。

return 204
给OPTIONS 添加 204 的返回，为了处理在发送POST请求时Nginx依然拒绝访问的错误，发送"预检请求"时，需要用到方法 OPTIONS，所以服务器需要允许该方法。

对于简单请求，如GET，只需要在HTTP Response后添加Access-Control-Allow-Origin；
对于非简单请求，比如POST、PUT、DELETE等，浏览器会分两次应答。第一次preflight（method: OPTIONS），主要验证来源是否合法，并返回允许的Header等，第二次才是真正的HTTP应答。所以服务器必须处理OPTIONS应答。
{% endhighlight %}

更多的配置示例参考[链接](https://www.cnblogs.com/itzgr/p/13343387.html)。