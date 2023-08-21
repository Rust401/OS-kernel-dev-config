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

整个步骤分成两部：
* 

