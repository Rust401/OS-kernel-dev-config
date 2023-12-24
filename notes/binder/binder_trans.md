## binder跟调度的紧密联系（看到这章，我只能说你太幸运了）

先看一张binder神图

<img width="551" alt="1702393322962" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/04bcd867-17eb-4370-84a6-6fd914da1686">

交互图也看下

<img width="592" alt="1702394067158" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1a4f986a-cc55-4ab5-b0b2-1c902b0345f1">

当然，如果把这个交互图和调度结合

<img width="1430" alt="64258820d29c0afa66e93d97accf41a" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/e547cec1-c263-406b-8fcb-f0b1be5562cf">

想必网上也是独此一张

仔细想下，为啥binder要用同步唤醒

<img width="1401" alt="a1f6636f2430ed29cc5bccd8d68153b" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/27485651-834a-40a5-bedd-7d68d242bc22">

有没有一种恍然大悟的感觉

让被唤醒的worker，继续在client的cpu上跑

**这样子整个业务逻辑连续了，虽然中间context-switch，换了个进程来执行**

这种感觉，就好似，**同一个调度context，上面用了不同进程context**

但这只是感觉，实际上里面还是有调度的

但如果我们能把这次调度简化掉（只切换地址空间，不切换调度实体），我们是不是就发明了一种新的ipc机制

企图去简化context-switch和lb等ping-pang带来的微观开销

从而企图达成端到端的收益

这就是所谓的**调度上下文和地址空间分离**吧



##  低端理解，懒得删了

这个BC和BR有点意思

BC是binder_command的意思，用于用户态发给内核态

BR是binder_reply的意思，用于内核态发回给用户态（这里面咋通信？cpunetlink？）




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









