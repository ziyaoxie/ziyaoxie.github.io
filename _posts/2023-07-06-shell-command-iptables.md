---
title: "iptables 命令整理"
date: 2023-07-06T12:38:00+08:00
author: Xie Ziyao
layout: post
permalink: /shell-command-iptables/
categories: [工作笔记]
tags: [shell, iptables]
---

`iptables` 是 Linux 系统上的 IP 信息包过滤系统。广义上的 `iptables` 实际上是由 `netfilter` 和 `iptables` 两个组件组成，而狭义上的 `iptables` 是指一个命令行工具，用于配置管理信息包的过滤规则。

`netfilter` 是内核的一个子系统，其工作在内核空间，核心是一个报文过滤架构；`iptables` 工作在用户空间，用于设置、维护和检查信息包的过滤规则，与 `netfilter` 子系统交互，它使插入、修改和除去信息包过滤表中的规则变得容易。

## 表/链/规则

使用 iptables 需要先理解表（table）、链（chain）、规则（rule）这三个概念。`netfilter/iptables` 系统可以理解成是 **表（table）** 的容器，这也是它被称为 iptables 的原因，而表则是 **链（chain）** 的容器，即所有的链都属于其对应的表，链又是 **规则（rule）** 的容器。

### 表(tables)

`iptables` 大致有 raw, filter, nat, mangle, security 等五类表，常用的表有 filter、nat、mangle 三个表。

### 链(chains)

链(chains)是数据包传输的路径，对应着前面提到的报文处理的五个阶段，也相当于是五个不同的关卡：INPUT, OUTPUT 链更多的应用在本机的网络控制中，即主要针对本机进出数据的安全控制；而 FORWARD, PREROUTING, POSTROUTING 链更多地应用在对我的网络控制中，特别是机器作为网关使用时的情况。

链是规则的容器，一条链中可能包含着众多的规则，当一个数据包到达一个链时，iptables 就会从链中第一条规则开始匹配，如果满足该规则的条件，系统就会根据该条规则所定义的方法处理该数据包，否则将继续匹配下一条规则，如果该数据包不符合链中任一条规则，iptables 就会根据该链预先定义的默认策略来处理数据包。

### 规则(rules)

规则(rules)是一些预定义的数据包过滤条件。规则存储在内核空间的信息包过滤表中，数据包每经过一个链(关卡)时，系统会根据链中规则指定的匹配条件来尝试匹配，一旦匹配成功，则由规则后面指定的处理动作进行处理。

规则分别指定了源地址、目的地址、传输协议（如TCP、UDP、ICMP）和服务类型（如HTTP、FTP和SMTP）等。当数据包与规则匹配时，iptables就根据规则所定义的方法来处理这些数据包，如放行（accept）、拒绝（reject）和丢弃（drop）等。配置防火墙的主要工作就是添加、修改和删除这些规则。

## 数据包流向

已知 tables 由 chains 组成，而 chains 又由 rules 组成。常用的表有 filter、nat、mangle 三种，链有五种，对应报文处理的五个阶段。对规则理解的关键：一条规则包括一个条件和一个动作(target)；如果满足条件，就执行处理动作；如果不满足条件，就继续匹配下一条规则。

以下简略图描述了网络数据包经过 `netfilter/iptables` 的过程：

{% highlight text %}
                                  XXXXXXXXXXXXXXXXXX
                                XXX     Network    XXX
                                  XXXXXXXXXXXXXXXXXX
                                          +
                                          |
                                          v
    +-------------+              +------------------+
    |table: filter| <---+        | table: nat       |
    |chain: INPUT |     |        | chain: PREROUTING|
    +-----+-------+     |        +--------+---------+
          |             |                 |
          v             |                 v
    [local process]     |           ****************          +--------------+
          |             +---------+ Routing decision +------> |table: filter |
          v                         ****************          |chain: FORWARD|
    ****************                                          +------+-------+
    Routing decision                                                  |
    ****************                                                  |
          |                                                           |
          v                         ****************                  |
    +-------------+       +------>  Routing decision  <---------------+
    |table: nat   |       |         ****************
    |chain: OUTPUT|       |               |
    +-----+-------+       |               |
          |               |               v
          v               |      +-------------------+
    +--------------+      |      | table: nat        |
    |table: filter | +----+      | chain: POSTROUTING|
    |chain: OUTPUT |             +--------+----------+
    +--------------+                      |
                                          v
                                  XXXXXXXXXXXXXXXXXX
                                XXX    Network     XXX
                                  XXXXXXXXXXXXXXXXXX
{% endhighlight %}

由图可知，当一个数据包进入计算机的网络接口时，数据首先进入 POSTROUTING 链，然后内核根据路由表决定数据包的目标。若数据包的目的地址是本机，则将数据包送往 INPUT 链进行规则匹配，当数据包进入 INPUT 链后，系统的任何进程都可以收到它，本机上运行的程序可以发送该数据包，这些数据包会经过 OUTPUT 链，再从 POSTROUTING 链发出；若数据包的目的地址不是本机，则检查内核是否允许转发，若允许，则将数据包送 FORWARD 链进行规则匹配，若不允许，则丢弃该数据包。若是主机本地进程产生并准备发出的包，则数据包被送往 OUTPUT 链进行规则匹配。

## 使用简介

`iptables` 工具的操作命令是比较复杂的，但大致的格式如下所示：

{% highlight bash %}
iptables [-t 表] 命令选项 [链] [匹配选项] [操作选项]
{% endhighlight %}

### 命令选项

| 选项名               | 功能及特点                             |
|-------------------|-----------------------------------|
| -A --append       | 在指定链的末尾添加一条新的规则                   |
| -D --delete       | 删除指定链中的某一条规则，按规则序号或内容确定要删除的规则     |
| -I --insert       | 在指定链中插入一条新的规则，默认在链的开头插入           |
| -R --replace      | 修改、替换指定链中的一条规则，按规则序号或内容确定         |
| -F --flush        | 清空指定链中的所有规则，默认清空表中所有链的内容          |
| -N --new          | 新建一条用户自己定义的规则链                    |
| -X --delete-chain | 删除指定表中用户自定义的规则链                   |
| -P --policy       | 设置指定链的默认策略                        |
| -F, --flush       | 清空指定链上面的所有规则，如果没有指定链，清空表上所有链的所有规则 |
| -Z, --zero        | 把指定链或表中的所有链上的所有计数器清零              |
| -L --list         | 列出指定链中的所有的规则进行查看，默认列出表中所有链的内容     |
| -S --list-rules   | 以原始格式列出链中所有规则                     |
| -v --verbose      | 查看规则列表时显示详细的信息                    |
| -n --numeric      | 用数字形式显示输出结果，如显示主机的 IP 地址而不是主机名    |
| --line-number     | 查看规则列表时，同时显示规则在链中的顺序号             |

### 匹配选项

| 选项名                | 功能及特点                    |
|--------------------|--------------------------|
| -i --in-interface  | 匹配输入接口，如 eth0，eth1       |
| -o --out-interface | 匹配输出接口                   |
| -p --proto         | 匹配协议类型，如 TCP、UDP 和 ICMP等 |
| -s --source        | 匹配的源地址                   |
| --sport            | 匹配的源端口号                  |
| -d --destination   | 匹配的目的地址                  |
| --dport            | 匹配的目的端口号                 |
| -m --match         | 匹配规则所使用的过滤模块             |

### 操作选项

一般为`-j 处理动作`的形式，处理动作包括 `ACCEPT、DROP、RETURN、REJECT、DNAT、SNAT` 等；使用 `iptables -j 动作名 --help` 可以查看处理动作帮助。

### 常用命令

查看帮助:

{% highlight bash %}
# 查看 iptables 的帮助
iptables --help

# 查看指定模块的可用参数
iptables -m 模块名 --help

# 查看指定动作的可用参数
iptables -j 动作名 --help
{% endhighlight %}

查看规则：

{% highlight bash %}
iptables -nvL
iptables -t nat -nvL

# 显示规则序号
iptables -nvL INPUT --line-numbers
iptables -t nat -nvL --line-numbers
iptables -t nat -nvL PREROUTING --line-numbers

# 查看规则的原始格式
iptables -t filter -S
iptables -t nat -S
iptables -t mangle -S
iptables -t raw -S
{% endhighlight %}

清除所有规则：

{% highlight bash %}
# 清空表中所有的规则
iptables -F
# 删除表中用户自定义的链
iptables -X
# 清空计数
iptables -Z

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
{% endhighlight %}

设置默认规则：

{% highlight bash %}
# 配置默认丢弃访问的数据表
iptables -P INPUT DROP

# 配置默认禁止转发
iptables -P FORWARD DROP

# 配置默认允许向外的请求
iptables -P OUTPUT ACCEPT
{% endhighlight %}

增加、删除、修改规则：

{% highlight bash %}
# 增加一条规则到最后
iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

# 注: 以下几条操作都需要使用规则的序号, 需要使用 -L --line-numbers 参数先查看规则的顺序号
# 添加一条规则到指定位置
iptables -I INPUT 2 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

# 删除一条规则
iptabels -D INPUT 2

# 修改一条规则
iptables -R INPUT 3 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
{% endhighlight %}

开放指定端口：

{% highlight bash %}
# 允许本地回环接口(即运行本机访问本机)
iptables -A INPUT -i lo -j ACCEPT

# 允许已建立的或相关连接的通行
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 允许所有本机向外的访问
iptables -A OUTPUT -j ACCEPT

# 允许 22,80,443 端口的访问
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dports 80,443 -j ACCEPT

# 如果有其他端口的需要开放, 则同上
iptables -A INPUT -p tcp --dport 8000:8010 -j ACCEPT

# 允许 ping
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# 禁止其他未允许的规则访问
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT
{% endhighlight %}

目的地址转换：

{% highlight bash %}
# 首先需要在开启中开启转发功能(源地址转换也需要开启)
echo 1 > /proc/sys/net/ipv4/ip_forward

# 把从 eth0 进来要访问 TCP/80 的数据包的目的地址转换到 192.168.1.18
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to 192.168.1.18

# 把从 1.1.1.1 进来要访问 TCP/80 的数据包的目的地址转换到 2.2.2.2:8000
iptables -t nat -A PREROUTING -p tcp -d 1.1.1.1 --dport 80 -j DNAT --to 2.2.2.2:8000
{% endhighlight %}

源地址转换：

{% highlight bash %}
# 最典型的应用是让内网机器可以访问外网
# 将内网 192.168.0.0/24 的源地址修改为 1.1.1.1 (可以访问互联网的机器的 IP)
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1

# 将内网机器的源地址修改为一个 IP 地址池
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1-1.1.1.10
{% endhighlight %}

持久化规则：

{% highlight bash %}
# 保存当前规则
iptables-save > iptables.20190721

# 恢复备份规则
iptables-restore < iptables.20190721
{% endhighlight %}

## 参考资料

- [Wiki Iptables](https://zh.wikipedia.org/wiki/Iptables)
- [Arch wiki Linux Iptables](https://wiki.archlinuxcn.org/wiki/Iptables?rdfrom=https%3A%2F%2Fwiki.archlinux.org%2Findex.php%3Ftitle%3DIptables_%28%25E7%25AE%2580%25E4%25BD%2593%25E4%25B8%25AD%25E6%2596%2587%29%26redirect%3Dno)
- [iptables命令手册](https://wangchujiang.com/linux-command/c/iptables.html)
- [iptables教程文档](https://www.cnblogs.com/Dicky-Zhang/p/5904429.html)
