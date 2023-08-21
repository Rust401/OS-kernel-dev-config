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

![1692600578231](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/14a461ef-7943-44e3-b190-3472e193ca90)

方便理解的核心流程，其实应该是这样的

`TASK1`已经持锁进入临界区

在这个期间，`TASK2/3/4`都想尝试持锁进入临界区

但是很不幸，持锁失败了

那只能顺着用户态那把锁，然后进到内核找到内核锁，把自己挂在waiter的链表上

当然当TASK1离开临界区时，也会找到内核锁上的链表，按照某种规则做对应的wake操作

## 5. 抽象

抽象上的事，其实上面也讲的差不多了

核心就是：

1. 用户态锁要在内核中有对应对象
2. 有wait接口把自己挂在某个资源的等待队列(block)
3. 释放资源时要wake对应的队列(wake)

剩下的东西，就很琐碎了
   
## 6. 关键数据结构

那现在看下具体实现吧

![1692602809953](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/47638fb4-55fe-4deb-8c72-528cb25c4823)

* 那个`__futex_data`就是内核里的锁array，里面存了所有的锁对象（这里面叫futex_hash_bucket）

* 然后这个`futex_hash_bucket`就是futex锁的对象，里面有waiters的数量以及waiters需要呆的链表

* `futex_q`就是waiter(task）的封装，里面的`pi_state`和`rt_waiter`比较关键，这是跟futex_pi（关联rt_mutex实现）

其实futex如果不考虑priority inheritence的话，还是个蛮简单的实现

为了借助rt_mutex实现pi的话，大脑会稍微痛苦一点

## 7. 关键代码路径

`futex_wait`和`futex_wake`有空看下吧

真的需要分析了再看，现在不值当


## Reference

[wowo](http://www.wowotech.net/kernel_synchronization/futex.html)

[zhihu](https://zhuanlan.zhihu.com/p/372146187)

[kernel doc](https://docs.kernel.org/locking/rt-mutex-design.html)


