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
它自己的顺序讲的比较乱，给他概括下，这里面讲了调度触发的3个要点：
* 显式阻塞，比如遇到锁，信号量，加入waitqueue等。**当执行的必要条件无法满足时，主动调度让出cpu**。
* 中断或者系统调用返回路径上检查`TIF_NEED_RESCHED`标记，**（当然这里包括了时钟中断）**。如果被标记了，那就触发一次调度。
* 任务**入队**时，或者**tick**时，标记`TIF_NEED_RESCHED`。

看代码前先看一个例子：
有两个核1和2。

1上跑一个**普通任务A**，2核此时把一个**rt任务B扔到1核**上（不管是唤醒，还是迁移）。

此时2核比较AB的优先级，**发现B比A优先级高，就发一个核间中断给A**。

A处理这个中断，根据条件给自己标记`TIF_NEED_RESCHED`，然后在中断返回的路径上，触发`schedule()`，上面讲的第二点规则。



