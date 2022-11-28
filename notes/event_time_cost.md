# 一些常见事件的耗时
# for what？
* 为了方便看trace
* 为了预测并发时的时序
* 为了装逼

# 事实
## 线程创建
一般20-30us左右

## 线程唤醒
这里指的是入队，**不包括入队之后的runnable时间**

路径有很多，唤醒一个已经醒了的或者已经queued我们先不考虑

最长那条路径就是要走唤醒选核的，基本2-10us左右

随便抓个调度的trace，统计下`sched_wakeup`和`sched_waking`之间的interval即可

如果考虑端到端的唤醒，那就得把**入队的runnable**算上去

入队runnable是一个浮动很大的数值

一般C0的idle进来是15us左右，但C1的idle进来就可能变成150us

如果被唤醒时的优先级不太够，那runnable时间可就太长了

## pagefault
# 方案
# 洞察
# 观点
