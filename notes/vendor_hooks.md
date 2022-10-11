# android vendor hooks分析

## 起因
最近要把vendor_hook机制移植到裸的linux上，移植之前，还是先弄弄懂吧，光回放patch，一知半解

## 准备
android_vendor_hook是AOSP的东西，我们索性先把[codeauora的msm-5.10](https://source.codeaurora.org/quic/la/kernel/msm-5.10/)下载下来

记得branch选`kernel.lnx.5.10.r1-rel`，这里面qcom的特性都已经加上去

## 分析
废话不多说，直接上分析

这玩意的宏是`CONFIG_ANDROID_VENDOR_HOOKS`，先大致看下涉及的文件分布

![1ac2ef17707864b7ef0af104a450099](https://user-images.githubusercontent.com/31315527/194986491-566320de-3bd8-4d20-9b75-6eb5d219f37f.png)

看了下，这几个文件是比较关键的：
`./kernel/tracepoint.c`
`./include/trace/hooks/vendor_hooks.h`
`./drivers/android/Makefile`
`./drivers/android/vendor_hooks.c`

### Makefile
一个个来吧，先从Makefile看起
![1b728e6eb4a5d41b39f35d45582106d](https://user-images.githubusercontent.com/31315527/194986980-60f2e425-3ae7-4441-9916-3bafb2db04d9.png)
`Makefile`里的内容很无聊，只是将`vendor_hooks.c`纳入了编译，`vendor_hooks.c`所属的子模块其实叫`driver/android`

### Kconfig
再看下Kconfig
![9058db7953aacf7590ff101f632e01a](https://user-images.githubusercontent.com/31315527/194987335-17173841-1edb-45ea-ae34-257d10fbc330.png)
也没啥花头，意识是module可以在内核hooks点里注册自己的动作

### vendor_hooks.c
回到上面，我们还是先看`vendor_hooks.c`里面究竟做了些啥神奇的东西
![74a58a3fd5ece5069cbf7d3e8e00e02](https://user-images.githubusercontent.com/31315527/194987858-eb062653-f516-4d6f-9b92-f103b53e1bec.png)
一看就傻眼了，上面一堆include，都是`trace/hooks/xxx.h`，下面一堆`EXPORT_SYMBOL`，让人摸不着头脑。

先看下`EXPORT_TRACEPOINT_SYMBOL_GPL`做了啥
![1665457782820](https://user-images.githubusercontent.com/31315527/194988318-6e66e4ce-b682-4b16-9185-639bb291360f.png)
平平无奇的符号导出，只不过导出了3种东西，`__tracepoint`，`__traceiter`，`tp_func`。
所以这3种肯定得有个地方定义对吧，疑点就到了上面的`trace/hooks/xxx.h`

随便到`trace/hooks/sched.h`里看下
![30d37d4d98c53f4af9603356e48b380](https://user-images.githubusercontent.com/31315527/194988877-bf05c0bf-836c-400d-8415-3201737a7469.png)
重头戏来了

我们看下`DECLARE_RESTRICTED_HOOK`究竟如何实现
![1665458151208](https://user-images.githubusercontent.com/31315527/194989054-44442743-112b-49a7-8a11-66d9489c0dde.png)










