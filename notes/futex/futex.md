# futex
## 1. 这是个啥

futex(fast userspace mutex) 是一种用来实现用户态的mutex的机制

我们平时用的linux里面的`pthread_mutex`，`pthread_cond_wait`的底层，都是通过futex实现的

有兴趣可以看下libc里面，`pthread_mutex_lock`以及`pthread_mutex_unlock`的实现，底层都通过syscall走的futex系统调用

2003年在linux的2.6.x的stable引入的

## 2. 为什么出现

自然是为了线程同步

## 3. 应用场景


## 4. 实现机理


## 5. 抽象


## 6. 关键数据结构


## 7. 关键代码路径


## Reference

[wowo](http://www.wowotech.net/kernel_synchronization/futex.html)

[zhihu](https://zhuanlan.zhihu.com/p/372146187)

[kernel doc](https://docs.kernel.org/locking/rt-mutex-design.html)


