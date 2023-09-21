---
title: "PyAutoGUI 模拟鼠标点击"
date: 2023-09-21T14:44:00+08:00
author: Xie Ziyao
layout: post
permalink: /simulate-mouse-with-pyautogui/
categories: [工作笔记]
tags: [pyautogui, script]
---

如果你想在 Windows 系统中创建一个自动点击脚本，你可以使用脚本语言（如 Python、JavaScript 或者 PowerShell）来实现。

## 代码示例

Python 代码示例如下：

{% highlight python %}
# 需要先安装 PyAutoGUI 库: pip install pyautogui

import pyautogui

for i in range(10):
    pyautogui.click(100, 100)
{% endhighlight %}

JavaScript 代码示例如下：

{% highlight javascript %}
for (let i = 0; i < 10; i++) {
  setTimeout(() => {
    window.dispatchEvent(new MouseEvent('click', {
      view: window,
      bubbles: true,
      cancelable: true
    }));
  }, i * 1000);
}
{% endhighlight %}

PowerShell 代码示例如下：

{% highlight powershell %}
for ($i = 0; $i -lt 10; $i++) {
  [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(100, 100)
  [System.Windows.Forms.SendKeys]::SendWait("{LBUTTON}")
}
{% endhighlight %}

## 获取屏幕坐标

鼠标就会出现一个浮窗跟随，实时显示当前鼠标坐标，Python 代码示例如下：

{% highlight python %}
import pyautogui
import tkinter as tk

def update_position_label():
    # 获取鼠标当前位置的坐标
    x, y = pyautogui.position()
    position_label.configure(text=f"坐标：({x}, {y})")
    position_label.after(100, update_position_label)

# 创建主窗口
window = tk.Tk()
window.title("鼠标坐标")
window.geometry("200x50")

# 创建坐标标签
position_label = tk.Label(window, text="坐标：(0, 0)")
position_label.pack()

# 更新坐标标签
update_position_label()

# 设置窗口始终在最顶层显示
window.attributes("-topmost", True)

# 隐藏窗口标题栏
window.overrideredirect(True)

# 窗口跟随鼠标移动
def move_window(event):
    x, y = event.x_root, event.y_root
    window.geometry(f"+{x}+{y}")

window.bind("<Motion>", move_window)

# 运行窗口主循环
window.mainloop()
{% endhighlight %}
