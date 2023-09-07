---
title: "Linux 性能指标监控：CPU、Memory、IO、Network"
date: 2023-07-18T10:57:00+08:00
author: Xie Ziyao
layout: post
permalink: /linux-performance-monitoring/
categories: [技术文章]
tags: [linux, 性能]
---

|             | **指标**                                 | **工具**                           |
|-------------|----------------------------------------|----------------------------------|
| **cpu**     | usr <= 70%, sys <= 35%, usr+sys <= 70% | top                              |
| **memory**  | si == so == 0, 可用空间 >= 30%             | vmstat 5; free                   |
| **io**      | iowait% < 20%                          | iostat -x                        |
| **network** | 网络连通性/吞吐量, TCP连接状态 TIME_WAIT           | sar -n DEV 1; ping; netstat -nat |

## CPU

{% highlight bash %}
$ top
top - 09:14:56 up 264 days, 20:56,  1 user,  load average: 0.02, 0.04, 0.00
Tasks:  87 total,   1 running,  86 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.2%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.2%st
Mem:    377672k total,   322332k used,    55340k free,    32592k buffers
Swap:   397308k total,    67192k used,   330116k free,    71900k cached

PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
1 root      20   0  2856  656  388 S  0.0  0.2   0:49.40 init
2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
3 root      20   0     0    0    0 S  0.0  0.0   7:15.20 ksoftirqd/0
4 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0

# 第一行
# 09:14:56 ： 系统当前时间
# 264 days, 20:56 ： 系统开机到现在经过了多少时间
# 1 users ： 当前2用户在线
# load average: 0.02, 0.04, 0.00： 系统1分钟、5分钟、15分钟的CPU负载信息
# 
# 第二行
# Tasks：任务;
# 87 total：很好理解，就是当前有87个任务，也就是87个进程。
# 1 running：1个进程正在运行
# 86 sleeping：86个进程睡眠
# 0 stopped：停止的进程数
# 0 zombie：僵死的进程数
# 
# 第三行
# Cpu(s)：表示这一行显示CPU总体信息
# 0.0%us：用户态进程占用CPU时间百分比，不包含renice值为负的任务占用的CPU的时间。
# 0.7%sy：内核占用CPU时间百分比
# 0.0%ni：改变过优先级的进程占用CPU的百分比
# 99.3%id：空闲CPU时间百分比
# 0.0%wa：等待I/O的CPU时间百分比
# 0.0%hi：CPU硬中断时间百分比
# 0.0%si：CPU软中断时间百分比
# 注：这里显示数据是所有cpu的平均值，如果想看每一个cpu的处理情况，按1即可；折叠，再次按1；
# 
# 第四行
# Men：内存的意思
# 8175320kk total：物理内存总量
# 8058868k used：使用的物理内存量
# 116452k free：空闲的物理内存量
# 283084k buffers：用作内核缓存的物理内存量
# 
# 第五行
# Swap：交换空间
# 6881272k total：交换区总量
# 4010444k used：使用的交换区量
# 2870828k free：空闲的交换区量
# 4336992k cached：缓冲交换区总量
# 
# 进程信息
# 再下面就是进程信息：
# PID：进程的ID
# USER：进程所有者
# PR：进程的优先级别，越小越优先被执行
# NInice：值
# VIRT：进程占用的虚拟内存
# RES：进程占用的物理内存
# SHR：进程使用的共享内存
# S：进程的状态。S表示休眠，R表示正在运行，Z表示僵死状态，N表示该进程优先值为负数
# %CPU：进程占用CPU的使用率
# %MEM：进程使用的物理内存和总内存的百分比
# TIME+：该进程启动后占用的总的CPU时间，即占用CPU使用时间的累加值。
# COMMAND：进程启动命令名称
{% endhighlight %}

## Memory

{% highlight bash %}
$ free
                   1          2          3          4          5          6
1              total       used       free     shared    buffers     cached
2 Mem:      24677460   23276064    1401396          0     870540   12084008
3 Swap:     25151484     224188   24927296

# 第二行说明内存使用情况
# 第一列是总量（total），第二列是使用量（used），第三列是可用量（free），第四列表示被几个进程共享的内存（shared），第五列表示被 OS buffer 住的内存，第六列表示被 OS cache 的内存。
# buffer/cache:
# A buffer is something that has yet to be "written" to disk.
# A cache is something that has been "read" from the disk and stored for later use.
# 释放掉被系统 cache 占用的数据：释放掉被系统 cache 占用的数据。
#
# 第三行为交换区的信息
# 分别是交换的总量（total），使用量（used）和有多少空闲的交换区（free）。
{% endhighlight %}

{% highlight bash %}
$ vmstat 5
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
6  0      0 27900472 204216 28188356    0    0     0     9    1    2 11 14 75  0  0
9  0      0 27900380 204228 28188360    0    0     0    13 33312 126221 22 20 58  0  0
2  0      0 27900340 204240 28188364    0    0     0    10 32755 125566 22 20 58  0  0

# Procs（进程）:
# r: 运行队列中进程数量
# b: 等待IO的进程数量
#
# Memory（内存）:
# swpd: 使用虚拟内存大小
# free: 可用内存大小
# buff: 用作缓冲的内存大小
# cache: 用作缓存的内存大小
#
# Swap:
# si: 每秒从交换区写到内存的大小
# so: 每秒写入交换区的内存大小
#
# IO：（现在的Linux版本块的大小为1024bytes）
# bi: 每秒读取的块数
# bo: 每秒写入的块数
#
# system：
# in: 每秒中断数，包括时钟中断
# cs: 每秒上下文切换数
#
# CPU（以百分比表示）
# us: 用户进程执行时间(user time)
# sy: 系统进程执行时间(system time)
# id: 空闲时间(包括IO等待时间)
# wa: 等待IO时间
{% endhighlight %}

## IO

{% highlight bash %}
$ iostat -xk 1
Linux 4.14.105-1-tlinux3-0023.1 (TENCENT64.site) 	07/17/2023 	_x86_64_	(48 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.10    0.00    0.06    0.00    0.00   99.83

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
nvme0n1           0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
nvme1n1           0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
nvme2n1           0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
nvme3n1           0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
sda               0.00    43.00    0.00   60.00     0.00  2592.00    86.40     0.01    0.13    0.00    0.13   0.13   0.80
md0               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00

# cpu属性值说明
# %user：CPU处在用户模式下的时间百分比。
# %nice：CPU处在带NICE值的用户模式下的时间百分比。
# %system：CPU处在系统模式下的时间百分比。
# %iowait：CPU等待输入输出完成时间的百分比。
# %steal：管理程序维护另一个虚拟处理器时，虚拟CPU的无意识等待时间百分比。
# %idle：CPU空闲时间百分比。
# 
# 如果%iowait的值过高，表示硬盘存在I/O瓶颈，%idle值高，表示CPU较空闲，如果%idle值高但系统响应慢时，有可能是CPU等待分配内存，此时应加大内存容量。
# %idle值如果持续低于10，那么系统的CPU处理能力相对较低，表明系统中最需要解决的资源是CPU。
#
# disk属性值说明
# rrqm/s： 每秒进行 merge 的读操作数目.即 delta(rmerge)/s
# wrqm/s： 每秒进行 merge 的写操作数目.即 delta(wmerge)/s
# r/s： 每秒完成的读 I/O 设备次数.即 delta(rio)/s
# w/s： 每秒完成的写 I/O 设备次数.即 delta(wio)/s
# rsec/s： 每秒读扇区数.即 delta(rsect)/s
# wsec/s： 每秒写扇区数.即 delta(wsect)/s
# rkB/s： 每秒读K字节数.是 rsect/s 的一半,因为每扇区大小为512字节.(需要计算)
# wkB/s： 每秒写K字节数.是 wsect/s 的一半.(需要计算)
# avgrq-sz：平均每次设备I/O操作的数据大小 (扇区).delta(rsect+wsect)/delta(rio+wio)
# avgqu-sz：平均I/O队列长度.即 delta(aveq)/s/1000 (因为aveq的单位为毫秒).
# await： 平均每次设备I/O操作的等待时间 (毫秒).即 delta(ruse+wuse)/delta(rio+wio)
# svctm： 平均每次设备I/O操作的服务时间 (毫秒).即 delta(use)/delta(rio+wio)
# %util： 一秒中有百分之多少的时间用于 I/O 操作,或者说一秒中有多少时间 I/O 队列是非空的，即 delta(use)/s/1000 (因为use的单位为毫秒)
#
# 如果 %util 接近 100%，说明产生的I/O请求太多，I/O系统已经满负荷，该磁盘可能存在瓶颈。
# 如果svctm的值与await很接近，表示几乎没有I/O等待，磁盘性能很好，如果await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢。
{% endhighlight %}

## Network

{% highlight bash %}
# 通过ping命令检测网络的连通性
{% endhighlight %}

{% highlight bash %}
$ netstat -nat
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:56000           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:36000           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:48369           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:42222         0.0.0.0:*               LISTEN     
tcp        0      0 9.135.140.130:44888     9.134.205.9:9922        ESTABLISHED
tcp        0    224 9.135.140.130:36000     30.20.62.33:63640       ESTABLISHED
tcp        0      0 9.135.140.130:58860     169.254.0.35:9988       ESTABLISHED
tcp        0      0 9.135.140.130:36000     30.20.62.33:64643       ESTABLISHED
tcp        0      0 9.135.140.130:55180     9.134.37.243:80         ESTABLISHED
tcp        0      0 9.135.140.130:55306     9.134.104.10:80         ESTABLISHED
tcp6       0      0 :::36000                :::*                    LISTEN     
tcp6       0      0 :::3306                 :::*                    LISTEN     
tcp6       0      0 :::80                   :::*                    LISTEN     
tcp6       0      0 :::33060                :::*                    LISTEN     
tcp6       0      0 9.135.140.130:3306      9.30.4.220:41902        ESTABLISHED

# 查看TCP连接状态
# Recv-Q：当连接为ESTABLISHED状态时，表示没有被应用程序取走的字节数。当连接为LISTEN状态时，表示syn backlog的当前值。
# Send-Q：当连接为LISTEN状态时，表示没有被远端确认的字节数。当连接为LISTEN状态时，表示最大的syn backlog值。
# Local Address：本地端口地址。
# Foreign Address：远端端口地址。
# State：套接字状态。
#
# TIME_WAIT状态的出现，是由于主动断开连接导致的，也就是说，应用程序中存在大量的短连接。
# 当出现大量CLOSE_WAIT状态时，通常是应用程序，未及时调用close()关闭连接。
{% endhighlight %}

{% highlight bash %}
$ sar -n DEV 1
Linux 5.4.119-1-tlinux4-0010.3 (TENCENT64.site) 	07/19/2023 	_x86_64_	(32 CPU)

11:56:35 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
11:56:36 AM      eth1      7.00      6.00      0.75      0.58      0.00      0.00      0.00
11:56:36 AM      eth0      0.00      0.00      0.00      0.00      0.00      0.00      0.00
11:56:36 AM        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00

# IFACE：LAN接口
# rxpck/s：每秒钟接收的数据包
# txpck/s：每秒钟发送的数据包
# rxbyt/s：每秒钟接收的字节数
# txbyt/s：每秒钟发送的字节数
{% endhighlight %}

## 参考资料

- [Linux 服务器维护简易指南](https://blog.donothing.site/2019/05/01/linux-server-maint/#part-2e9bff25d9134309)
- [Linux工具快速教程](https://linuxtools-rst.readthedocs.io/zh_CN/latest/index.html)
