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
* Quiescent State(QS): 不在临界区内，并且可以用来确定不在临界区内的时间

## 用法
## 灵魂提问
## 机制
## Reference
[whatisRCU](https://www.kernel.org/doc/html/next/RCU/whatisRCU.html)
