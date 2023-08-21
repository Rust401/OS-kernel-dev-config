# futex
## 1. 这是个啥

futex(fast userspace mutex) 是一种用来实现用户态的mutex的机制

我们平时用的linux里面的`pthread_mutex`，`pthread_cond_wait`的底层，都是通过futex实现的

有兴趣可以看下libc里面，`pthread_mutex_lock`以及`pthread_mutex_unlock`的实现，底层都通过syscall走的futex系统调用

2003年在linux的2.6.x的stable引入的

## 2. 为什么出现

自然是为了线程同步

## 3. 应用场景

花式的pthread_mutex相关的场景

当然绕过pthread，自己基于futex去封装同步机制也没问题

## 4. 实现机理

很trival的来看，用户态的锁，需要对应到内核态的锁

内核态的锁上，需要知道owner是谁（futex的syscall把uaddr指向的32-bit futex word传下来），以及block了哪些task

* 用户态**加锁失败的时候，走wait**，找到对应的**内核锁**，然后把curr挂在阻塞队列上，然后调度走

* 当用户态**解锁的时候，走wake路径**，通过hash找到对应的**内核锁**，看下找到的内核锁上面到底挂着哪些task，然后把选一种方式把他们唤醒

当然，这里面的挂队列的方式/唤醒的顺序/唤醒的个数，都是可以调整的，其实并不重要

重要的是加锁/解锁的主流程


## 5. 抽象


## 6. 关键数据结构


## 7. 关键代码路径


## Reference

[wowo](http://www.wowotech.net/kernel_synchronization/futex.html)

[zhihu](https://zhuanlan.zhihu.com/p/372146187)

[kernel doc](https://docs.kernel.org/locking/rt-mutex-design.html)


