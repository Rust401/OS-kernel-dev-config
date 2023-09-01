# 一些有关rcu的碎碎念

## 历史
linux 2.5.x上主线的，主要为了解决read-mostly场景的性能

## 应用场景
read-mostly，如果要具体量化，拍脑袋来看是write场景只占10%以下的那种

## high level的理解
rcu的含义是Read-Copy-Update，但这么命名其实挺玄学的

read-copy，可以认为**有可能读到拷贝的数据**

copy-update，可以认为**更新之前需要先复制**

直观的感受，**reader和writer之间，都不用互相等待的**

这样会让临界区内的并行度高很多，适合压榨性能

对于Reader来说，其实不用等临界区，想读的时候直接去读就好，要么拿到的是新数据，要么拿到的是旧数据（这里的数据其实指的是**指针指向的内存区域**）

对于Writer来说，更新的时候，需要先对原有数据创建一个副本(copy), 把新数据更新上去，然后把这个copy给**发布**（发布后reader就能找个合适的时机了）

新数据发布之后，找个合适的时机，把之前不用的数据回收掉就行了。

所以

对于`reader`来说，就一件事：读！

对于`writer`来说，需要经历以下几个阶段
* copy
* update
* publish

至于最后的老数据回收阶段，可以让writer做，也可以随便找个人做，这个无所谓，我们可以叫这个人`reclaimer`

这个过程，叫做**reclaim**

这里面还有一些点需要澄清：
1. reader和reader之间是可以并行的
2. reader和writer之间是可以并行的
3. writer和writer之间是要加锁的
4. writer和reclaimer之间是可以并行

## 一些抽象的概念
整个系统中有3个角色

* Reader: 就是专门负责读的
* Updater: 负责更新数据的
* Reclaimer(Remover): 负责把更新完的旧数据回收的

还有两个关键的概念：

* Grace Period(GP): 新数据发布之后，到能够安全进行老数据的reclaim之间的阶段
* Quiescent State(QS): 不在临界区内，并且可以用来确定不在临界区内的时间（在linux内核中，通常认为，发生了一次调度，或者tick里面发现此时处于用户态，就可以判定某个cpu经过了一次Quiescent State）

![34c29a647d5abcb10a1f518ccdeb3cc](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/23df6db6-9e9d-4f92-83cf-e47bcac1dbdd)

这边这张图，很精髓地从high level描述了rcu究竟怎么运作的

* 上面有4个reader，每个reader随着时间推移在做各种read操作，时间长短不一
* 由于同步有个updater在更新，所以reader可能会读到两种不同的东西（灰色或者白色，灰色的不论边框粗细，其实都是读到一个东西，修改前的，白色是修改后的）
* Removal阶段的`rcu_assign_pointer`很关键。在assign之前发生的`rcu_dereference`，都会读到更新前的数据，assign之后发生dereference，都会读到新数据。
* 真正对老数据进行删除之前，要调用`synchronize_rcu`，这个函数的作用是等待已经进入临界区的readers都离开了临界区，其实它的名字叫`waiting_readers_to_leave`更合适一些，数然后这段时期就是Grace Period。
* 只要GP一过（可以看下图中灰色粗边框的方块），就没有任何线程持有对老数据的引用了，因此可以很安全的把老数据释放掉（其实对于reader来说，具体什么时候真的把老数据回收，早一点，晚一点，都不care，reader关心的是什么时候rcu_assign_pointer发生）

因此，**一个理想的rcu**的行为应该如下：
* 作为reader，要么读到新数据，要么读到老数据，区分点在于**读这个动作和updater的publish动作的先后顺序**
* 数据publish之后，reader就没法再读到老的数据了，**当所有所针对老数据的reader都完成了读动作，立马将老数据释放掉**

当然理想情况可以这么做

但实际，放到内核里的实现，就不是这么回事了

rcu整套机制并不是trival的，不是那种拍脑袋能想出来前，所以理清思路其实很难。

rcu最难的机制就是gc，如何准确计算出一个有效但尽可能短的Grace Period，对于gc回收的效率至关重要

（讲道理gc慢一点没什么问题）

因此，当一次GP发起时，是否我们只要确认GP发起之后，每个cpu都进入了一次Quiescent State(QS)，那就可以很安全地判定，所有之前的reader都已经溜溜了

这里先做个灵魂发问（那要rcu_read_lock/unlock）有啥用？反正都是通过调度或者tick去判读的

但其实rcu_read_lock/unlock只是为了保证这个临界区里面不要走到调度里面去，用来辅助调度和tick里的QS点判断的
  
## 用法
## 灵魂提问
## 机制
## Reference
[whatisRCU](https://www.kernel.org/doc/html/next/RCU/whatisRCU.html)
