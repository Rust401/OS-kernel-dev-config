# 一些pelt相关的问答

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




