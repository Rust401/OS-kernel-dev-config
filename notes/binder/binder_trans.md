## binder跟调度的紧密联系
首先binder本质上跟个http-server很像，都是C-S模式的，内部都有个线程池

http-server么接收到请求，拉起个小弟处理下

binder也一样，有工作来了么，就拉小弟处理

终端一个很典型的业务场景，就是主线程ui请求system_server的一个服务，然后就拉起一个binder线程，自己需要等这个binder线程做完事了，才能继续执行。

这就是所谓的同步binder，本质上是一种阻塞。

为了防止优先级反转，这个同步binder的优先级，无论如何是一定要给它设上去的，否则critical的线程执行就老慢了。

所以我们往往会听到"传递"这个词

我们想尽可能多的把属性去传给这个同步binder

那问题来了，在哪个代码里面加呢？

<img width="797" alt="1701963786935" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1332d65c-a2e7-4321-bb0c-89ee195f4fef">

`binder_proc_transaction`是个关键函数，它的大意就是把某个任务(transaction)交给某个特定的thread/proc

oneway跟thread一定是冲突的

红框就是同步binder的核心流程，把某个任务交给这个thread，然后唤醒这个thread

所以如果要传递调度属性啥的，就放到第一个红框里面，给这个thread设置就完事了

上下文很安全，直接也不用irq，直接干就完了。

## Reference
[binder好文](https://wangkuiwu.github.io/2014/09/01/Binder-Introduce/)

[binder数据结构参考](https://wangkuiwu.github.io/2014/09/02/Binder-Datastruct/)









