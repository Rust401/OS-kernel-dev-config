# futex_pi和rt_mutex的关系

普通的futex的实现很trival

pi版本的futex，底层借用的是`rt_mutex`，这样就不用自己去实现一套了

整件事无非是：

将上层锁对应的内核锁，与rt_mutex相互绑定

可以想一个很trival的实现：
* **`futex_hash_bucket`中加一个`rt_mutex`对象**
* **`futex_q`中加一个`rt_mutex_waiter`**

这样子就在lock和task层面上都做了关联

无非是:

* 一次常规的futex阻塞的操作，现在要锁两遍（futex锁以及rt_mutex锁）
* 一次常规的futex唤醒操作，现在要解锁两遍（rt_mutex的唤醒以及futex_q的唤醒）

这边不得不提一个重点：**上层的首次发生未持锁阻塞的时候(futex_pi_lock)，才会有对应的rt_mutex对象生成**

整个步骤分成两步：
1. 先让futex的owner去持有rt_mutex
2. 让尝试拿futex失败的task阻塞在这个rt_mutex之上

首次比较麻烦，但接下来新增的`futex_pi_lock`行为发生时，只要调用对应的rt_mutex_lock即可。

当前linux里的实现

![1692617098440](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/a939a35f-ea55-439d-b430-4d12f76fcdc3)

* `pi_state`是一个指向rt_mutex的指针（这里若干的`futex_q`的里面的`pi_state`其实都会指向一个rt_mutex结构体）。一个`futex_hash_bucket`会对应一个rt_mutex

*`rt_waiter`很好理解，把这个futex_q以rt_mutex_waiter的身份，加入rt_mutex的统计

从trival的实现，到它最后变成的样子，是经过收敛迭代的，所以一开始只能想到trival的实现，是合理的。

再来个简图吧，看看futex是怎套用rt_mutex实现pi的

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/769c5dfd-f7fc-4d80-a17d-c21610180770)

无非就是futex的对象（lock以及task），映射到对应的rt_mutex对象

OOP思想就是，rt_mutex是基类，futex反而是一种衍生

另外关系也很像是frameRTG和rtg的关系

frame如果想实现prefer_cluster、负载聚合统计、min_util之类的，要怎么办？

底层套用一个支持上述功能的容器即可。

**因此futex_pi和rt_mutex的关机，就想frame和rtg的关系一样**

属于对象映射





