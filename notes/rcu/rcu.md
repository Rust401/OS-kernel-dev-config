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

## 一些抽象的概念
## 用法
## 灵魂提问
## 机制
## Reference
[whatisRCU](https://www.kernel.org/doc/html/next/RCU/whatisRCU.html)
