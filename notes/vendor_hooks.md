# android vendor hooks分析

## 起因
最近要把vendor_hook机制移植到裸的linux上，移植之前，还是先弄弄懂吧，光回放patch，一知半解

## 准备
android_vendor_hook是AOSP的东西，我们索性先把[codeauora的msm-5.10](https://source.codeaurora.org/quic/la/kernel/msm-5.10/)下载下来

记得branch选`kernel.lnx.5.10.r1-rel`，这里面qcom的特性都已经加上去

## vendor_hook架构分析
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

这一个`DECLARE_RESTRICTED_HOOK`的动作，生成了一坨东西

1. `__traceiter_##name`，先不看
2. `DECLARE_STATIC_CALL`，先不看
3. `struct tracepoint __tracepoint_##name`，这玩意的结构如下

![1665458973241](https://user-images.githubusercontent.com/31315527/194990653-f6626777-fc0c-4649-8295-7d6c0e5f6d5b.png)

稍微有个印象就好

4. `trace_##name`，这玩意是调用点，调用的话就会通过`DO_HOOK`执行调用点，调用3里的__tracepoint_##name里那个func

5. `trace_##name##_enabled`,这玩意是判断当前trace点是否已经被注册了的

6. `register_trace_##name`这玩意是给trace点注册里面哪个func用的，里面调了`trace_point.c`里的`android_rvh_probe_register`

流水账记到这里，总结下
`DECLARE_RESTRICTED_HOOK`定义了tracepoint（含func）的**调用**和**注册**接口

`DECLARE_HOOK`则走的是`DECLARE_TRACE`那条路径，大同小异，先不看了。

### vendor_hooks.h
这文件其实上面已经看过了，花式宏定义，整个vendor_hooks机制的核心


### tracepoint.c
这个是trace点内的func注册用的实际实现函数

## 使用分析
这边以walt为例

![ef96cecbe7d11d4c89b081aa2e56275](https://user-images.githubusercontent.com/31315527/194993632-f601dda8-73df-4c64-b08c-6896ef530d42.png)

walt涉及到的trace点，要先include

![4066a7fff4b08288c6d3ce9bf121a3c](https://user-images.githubusercontent.com/31315527/194993711-99ee295f-25c2-40ab-845d-d156f460c0df.png)

模块初始化时一通注册，这些tracepoint点就活了

![1665460602413](https://user-images.githubusercontent.com/31315527/194993798-0dfef72b-f0c1-4439-a98d-bcdbf2b8616e.png)

显然注册的时候，得把真正用于实现的东西塞进去

归纳下：

1. kernel本体通过`DECLARE_RESTRICTED_HOOK`在`include/trace/hooks/xxx.h`定义好各种hook点

2. 在内核逻辑适当的地方插入调用点，就是那些`trace_##name`开头的

3. module通过include条目1里面的那个头文件，就可以为该hook点注册真实的动作

## 移植
移植有两种方式，一种是回放patch，另一种是直接硬移

回放patch的问题是很难把所有相关的commit都弄进去（当前只能通过git log --oneline <target_path>去寻找相关的commit）

比如说，`CONFIG_ANDROID_STRUCT_PADDING`也是个和vendor_hook相关的宏，但是被我忘记了，与之相关的还有`include/linux/android_vendor.h`这种文件

内心还是想回放patch的，硬移就需要各种复制，但鬼知道回放patch会不会给自己留暗坑

整理下patch吧

### vendor_hooks.h
```txt
774f1bd29cba ANDROID: Disable CFI on restricted vendor hooks in TRACE_HEADER_MULTI_READ
cc6eed90a467 ANDROID: vendor_hooks: Allow multiple attachments to restricted hooks
ba75b92fefa9 ANDROID: simplify vendor hooks for non-GKI builds
384becf1643b ANDROID: Disable CFI on restricted vendor hooks
4cc2f83c77aa ANDROID: vendor_hooks: fix __section macro
5e767aa07eea ANDROID: use static_call() for restricted hooks
e706f27c765b ANDROID: fix redefinition error for restricted vendor hooks
7f62740112ef ANDROID: add support for vendor hooks
```

### tracepoint.c
```txt
cc6eed90a467 ANDROID: vendor_hooks: Allow multiple attachments to restricted hooks
```

### android_vendor.h
```
b7a6c15a6f06 ANDROID: Configure out the macros in android_kabi and android_vendor
c417bec8b3d9 ANDROID: add macros to create OEM data fields
dc419bab7424 ANDROID: fix copyright notice (这个要后面打，没啥用其实)
626b81751134 ANDROID: GKI: add android_vendor.h(很容易打)
```

然后要真的开始干了，日















