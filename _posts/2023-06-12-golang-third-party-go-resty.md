---
title: "Golang 工具：第三方 http 库 go-resty"
date: 2023-06-12T15:49:00+08:00
author: Xie Ziyao
layout: post
permalink: /golang-third-party-go-resty/
categories: [工作笔记]
tags: [goland, 工具, go-resty]
---

golang 里的 http 标准库，发起 http 请求时，写法比较繁琐；这里介绍一个好用的第三方 http 库：[go-resty](https://github.com/go-resty/resty) 。

go-resty 有很多特性：

- 发起 GET, POST, PUT, DELETE, HEAD, PATCH, OPTIONS, etc. 请求
- 简单的链式书写
- 自动解析 JSON 和 XML 类型的文档
- 上传文件
- 重试功能
- 客户端测试功能
- Resty client
- Custom Root Certificates and Client Certificates
- ...

go-resty 更多功能特性请查看文档：[go-resty features](https://github.com/go-resty/resty#features)，本文编写的示例基于 go-resty: v2.3.0。

## 简单的 GET

{% highlight go %}
package main

import (
	"fmt"

	"github.com/go-resty/resty/v2"
)

func main() {
	client := resty.New() // 创建一个restry客户端
	resp, err := client.R().EnableTrace().Get("https://httpbin.org/get")

	// Explore response object
	fmt.Println("Response Info:")
	fmt.Println("  Error      :", err)
	fmt.Println("  Status Code:", resp.StatusCode())
	fmt.Println("  Status     :", resp.Status())
	fmt.Println("  Proto      :", resp.Proto())
	fmt.Println("  Time       :", resp.Time())
	fmt.Println("  Received At:", resp.ReceivedAt())
	fmt.Println("  Body       :\n", resp)
	fmt.Println()

	// Explore trace info
	fmt.Println("Request Trace Info:")
	ti := resp.Request.TraceInfo()
	fmt.Println("  DNSLookup     :", ti.DNSLookup)
	fmt.Println("  ConnTime      :", ti.ConnTime)
	fmt.Println("  TCPConnTime   :", ti.TCPConnTime)
	fmt.Println("  TLSHandshake  :", ti.TLSHandshake)
	fmt.Println("  ServerTime    :", ti.ServerTime)
	fmt.Println("  ResponseTime  :", ti.ResponseTime)
	fmt.Println("  TotalTime     :", ti.TotalTime)
	fmt.Println("  IsConnReused  :", ti.IsConnReused)
	fmt.Println("  IsConnWasIdle :", ti.IsConnWasIdle)
	fmt.Println("  ConnIdleTime  :", ti.ConnIdleTime)
	// fmt.Println("  RequestAttempt:", ti.RequestAttempt)
	// fmt.Println("  RemoteAddr    :", ti.RemoteAddr.String())
}
{% endhighlight %}

## 增强的 GET

{% highlight go %}
client := resty.New()
resp, err := client.R().
    SetQueryParams(map[string]string{
        "page_no": "1",
        "limit":   "20",
        "sort":    "name",
        "order":   "asc",
        "random":  strconv.FormatInt(time.Now().Unix(), 10),
    }).
    SetHeader("Accept", "application/json").
    SetAuthToken("BC594900518B4F7EAC75BD37F019E08FBC594900518B4F7EAC75BD37F019E08F").
    Get("/search_result")

// Request.SetQueryString method
resp, err := client.R().
    SetQueryString("productId=232&template=fresh-sample&cat=resty&source=google&kw=buy a lot more").
    SetHeader("Accept", "application/json").
    SetAuthToken("BC594900518B4F7EAC75BD37F019E08FBC594900518B4F7EAC75BD37F019E08F").
    Get("/show_product")

// 解析返回的内容，内容是json解析到struct
resp, err := client.R().
    SetResult(result).
    ForceContentType("application/json").
    Get("v2/alpine/mainfestes/latest")
{% endhighlight %}

更多用法示例参考[链接](https://github.com/go-resty/resty#usage)。
