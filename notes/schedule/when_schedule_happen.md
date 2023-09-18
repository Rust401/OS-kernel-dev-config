# 调度介入时机
和其它耳熟能详的系统一样（比如调频系统），调度无外乎也就三个过程：**标记**，**检测**，**切换执行**。

为了有一个大致的了解，我们可以先看下位于`kernel/sched/core.c`里的`__scheudle`前面的介绍

```cpp
/*
   * __schedule() is the main scheduler function.
   *
   * The main means of driving the scheduler and thus entering this function are:
   *
   *   1. Explicit blocking: mutex, semaphore, waitqueue, etc.
   *
   *   2. TIF_NEED_RESCHED flag is checked on interrupt and userspace return
   *      paths. For example, see arch/x86/entry_64.S.
   *
   *      To drive preemption between tasks, the scheduler sets the flag in timer
   *      interrupt handler scheduler_tick().
   *
   *   3. Wakeups don't really cause entry into schedule(). They add a
   *      task to the run-queue and that's it.
   *
   *      Now, if the new task added to the run-queue preempts the current
   *      task, then the wakeup sets TIF_NEED_RESCHED and schedule() gets
   *      called on the nearest possible occasion:
   *
   *       - If the kernel is preemptible (CONFIG_PREEMPTION=y):
   *
   *         - in syscall or exception context, at the next outmost
   *           preempt_enable(). (this might be as soon as the wake_up()'s
   *           spin_unlock()!)
   *
   *         - in IRQ context, return from interrupt-handler to
   *           preemptible context
   *
   *       - If the kernel is not preemptible (CONFIG_PREEMPTION is not set)
   *         then at the next:
   *
   *          - cond_resched() call
   *          - explicit schedule() call
   *          - return from syscall or exception to user-space
   *          - return from interrupt-handler to user-space
   *
   * WARNING: must be called with preemption disabled!
   */
```
**年少不知曲中意，再听已是曲中人**

上面这个注释实在是太精彩了，讲的太透彻。

失敬失敬！

看代码前先看一个例子（**可抢占linux的场景**，CONFIG_PREEMPTION=y）：

有两个核1和2。

1上跑一个**普通任务A**，2核此时把一个**rt任务B扔到1核**上（不管是唤醒，还是迁移）。

此时2核比较AB的优先级，**发现B比A优先级高，就发一个核间中断给A**。

A处理这个中断，根据条件给自己标记`TIF_NEED_RESCHED`，然后在中断返回的路径上，触发`schedule()`，把自己调度出去（上面讲的第2点规则）。

如果是非抢占式内核，以上场景，B入1核队列时cpu2是不会给cpu1发中断的，cpu1只能等待调度介入。



