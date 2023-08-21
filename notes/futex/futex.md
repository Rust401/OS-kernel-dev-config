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

内核态的锁上，挂着各种


## 5. 抽象


## 6. 关键数据结构


## 7. 关键代码路径


## Reference

[wowo](http://www.wowotech.net/kernel_synchronization/futex.html)

[zhihu](https://zhuanlan.zhihu.com/p/372146187)

[kernel doc](https://docs.kernel.org/locking/rt-mutex-design.html)


