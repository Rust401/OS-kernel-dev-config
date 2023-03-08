# 一些pelt相关的问答
[TOC]## [TOC]load/runnable/running的又一层次的理解？[TOC]
![1678240865672](https://user-images.githubusercontent.com/31315527/223600029-bac390d2-6598-48d1-8ee2-6894aa5113c4.png)

看到了这个函数，用于更新blocked_se的负载，那个`0，0, 0`让人感觉有点意思

![1678240969794](https://user-images.githubusercontent.com/31315527/223600263-f2d0e612-7e3e-4d33-9669-2bd3cac4ff9c.png)

这个`load`、`runnable`、`running`对应上面那个`0，0，0`

虽然名字是上有点玄乎，但其实是3个递进的角度

running表示task真正在跑，对应的表征值就是utlization

runnable表示可但没在跑，对应的表征值就是runnable

load范围最大，表示虽然没在跑，但是还是有隐含压力的，对应的表征值就是load

![5e518d7b29f3784f51b24e8ca62b69c](https://user-images.githubusercontent.com/31315527/223602605-62096e97-ee71-4447-a6ed-110226e9398e.png)

对应图如上

所以每次更新se时，都会在load、runnable、running上去传不同的值，然后结算的时候就只会inc特定的量


## load/util/runnable_sum和load/util/runnable_avg分别代表什么？

`*_sum`指的是历史窗口加权后的和，`*_avg`指前者的均值（前者除以divider，divider可以认为是几何级数的最大值）

`*_sum`通常只是一个过程量，`*_avg`通常是外界在乎的量

**这里从`*_avg`的角度去考虑这个问题，另外简单点的话，从task_se的角度出发**

* `load_avg`指`se_weight`**加权后**的表征量均值，包含了runnable和running时间
* `runnable_avg`指**不加权**的表征量均值，包含了runnable和running时间
* `util_avg`指**不加权**的表征量，且只包含running时间

关于**加权**和**不加权**，看下面

![1678006079097](https://user-images.githubusercontent.com/31315527/222950855-d903a5b5-8021-4f4f-872e-020419a58276.png)

**首先这个的delta，是us为单位的pelt时间，而且做过了freq和capacity两个维度的换算**

所以delta可以用一个量纲为时间的值去表征归一后的负载量

204行开始很tricky，util和runnable去递增的时候，都用delta去multi上一个1024，而load并没有这么做，该是归一化时间，还是归一化时间

因此从`*_sum`的角度来看，`load_sum`其实比`util_sum`小了1024

但从`*_avg`的计算过程，会把这个找补回来

![1678006444550](https://user-images.githubusercontent.com/31315527/222951110-7f21e23f-214c-4a27-b50d-3e1c72cbe5b5.png)

这个327里面多乘的load值，是`se_weight`，其实就是那个跟nice值关联那个，从20到19，se_weight从1024变成1024*1.25

这个load值就把`*_sum`里没乘的1024补回来了

对se来说，`load_avg`就是一个weight加权后的`runnable_avg`



se维度的看似很简单，**但cfs_rq维度的看起来却不是这么回事**

![1678009666461](https://user-images.githubusercontent.com/31315527/222953307-80e9ef21-833d-4945-b774-54ab386b594b.png)

se时，load,runnable和running是111

cfs_rq更新时，变成了实际值

* load: cfs_rq上所承载的总的load_weight（假设有3个task，nice分别-1、0、1，那这个值就是1024/1.25 + 1024 + 1024*1.25）
* runnable: cfs_rq上的`h_nr_running`（真正穿透到每个task的）
* running: cfs_rq->curr != NULL(cfs_rq上running时间的更新，前提是该cfs_rq上确实有任务在跑)

**此处逻辑未闭环**

在`___update_load_avg`也不在把load传进去（毕竟`___update_load_sum`算的时候传load没传1，已经把量纲统一好了）

**看样子，类似形状的函数，每个都是特例，比如`update_rt_rq_load_avg`**

![1678010439816](https://user-images.githubusercontent.com/31315527/222953782-53666412-cd54-43d4-8da2-6c7cf13362be.png)

## pelt体系中的计时系统
![1678007253914](https://user-images.githubusercontent.com/31315527/222951660-82598dc4-376d-4eff-bb23-a0934dd3d663.png)

这个now很关键，拿了一个叫pelt时间的玩意

![1678007316226](https://user-images.githubusercontent.com/31315527/222951704-37fc5141-18b3-46d4-8a48-96b2519329d5.png)

对应的其实是rq上的这个`clock_pelt`

![1678007401394](https://user-images.githubusercontent.com/31315527/222951753-cf0411cb-eda8-457a-bfd3-bfcb9e46e836.png)

解释也很形象，**如果cpu跑得慢，那对应的pelt时间也会走得慢**

**freq和capacity的两层缩放也写得很明显**，至于那个idle的情况，后面会讲

这个delta是传进来的，整个调用链如下

```
update_rq_clock =>
  update_rq_clock_task =>
    update_rq_clock_pelt =>
```

**delta单位是ns，就是真正的用于调度系统的cpu时间**

详见`sched_clock`

![1678007864475](https://user-images.githubusercontent.com/31315527/222952075-38783423-1514-42de-8d33-3f7a6bf38a77.png)

**基于这套体系，pelt负载的增量，都可以直接看这个`clock_pelt`**








