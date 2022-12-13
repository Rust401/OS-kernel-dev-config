# WALT的组负载
## 写在前面
如果没有group这种东西，walt的负载一共就两个维度，task负载和rq负载，是一个相对优雅的trival的模型

但当grp这种东西进来之后，模型就变得复杂了，实现上也变得不优雅起来

grp这种东西，它该放在哪个位置，和谁平级，这个会让人confuse，拍脑袋想想，会有两种安排方式

* grp和task平级，一起为rq贡献负载
* grp和rq平级，都由task的负载贡献而成

每个人的直觉不太一样，但当前实现更倾向于**第二种**

`task`被加到组里之后，属于一种特殊的状态

虽然它仍旧在跑在rq上，task维度的负载会照常计算，但它的负载贡献却会被算到它所属的grp上

为了搞清楚grp负载计算的原理，视角锁定到一个**隶属于某个grp的task**，关注下面几个事件：

1. 如何正常更新`update_cpu_busy_time`
2. 进出组时如何操作`transfer_busy_time`
3. 迁核时如何操作`fixup_busy_time`

## 需要很多walt基础知识的分析（除了作者，没人看得下去，可能作者也看不下去）

### 进出组`transfer_busy_time`

![1670919820864](https://user-images.githubusercontent.com/31315527/207263672-87bf1b58-f986-4f08-8d71-faa30e0164ab.png)

调用关系很简单，线程进出组时触发

transfer_busy_time(rq, grp, p, ADD_TASK);

还是先看下函数长啥样

由于是线程加组的时候的要调用的动作

几个关键的条件作为入参:
* 加组的对象p
* p当前的rq
* 加哪个组
* 用啥event

(这里有个神奇的问题，如果某个task在sleep状态，要加组，这个rq究竟选谁？

里面实现的代码就不贴了，讲重点

#### 加组overview

加组，其实是一个**把task对rq的负载贡献移动到grp**的过程

流程：
1. rq的`prev_runnable_sum`和`current_runnable_sum`里把task的`prev_window_cpu[cpu]`和`cur_window_cpu[cpu]`减掉
  * rq上不会直接减wts->prev/curr_window，毕竟prev/curr_window可不是单一核贡献出来的
  
&nbsp;

2. 执行`update_cluster_load_subtractions`，把task在两个tracked_window里对同cluster上别的cpu的贡献收集起来，后面再用
  * tracked_window就是指prev和curr
  * 步骤1里面，只从task的当前rq上把task的负载贡献减掉，**同cluster的其它rq仍旧留有该task的痕迹，但当前状况又不方便更新其它rq上的负载**，因此只能暂存，等合适的时机
  * 合适的时机就是walt_rq_work，有个干净的上下文去拿rq锁，然后去更新一波

&nbsp;

3. 把task在tracked_window里的负载`prev/curr_window`加到grp里
  * 把task的整体负载贡献丢到grp中
  * 此时rq可能还没rollover，部分task的负载贡献还在rq上存着呢，这个中间态的总量其实是超的，账不平

&nbsp;

4. 把task在tracked_window里的负载`prev/curr_window_cpu`重新赋值，re_init当前task的"负载分布曲线"
  * 其实这个步骤影响并不大，这只是个非关键统计信息

&nbsp;

总结下：
* 其实这个逻辑很简单，一个哥们儿在两个银行A,B里面存钱，然后每个银行里面有8个账户，他要么在A1-A8里面存，要么在B1-B8里面存，不能有几个账户存在A里，有几个账户存在B里
* 从A往B迁的时候，往往只先把A1从银行A里面拿掉，A2-A7先记账记着，然后A里面所有的钱都存到B，但到A进入到真正结算期之前，A里面钱不会扣光的，B却已经得到了A转来的钱了，此时其实两边的总量已经超了，也就是**整个世界的钱变多了**
* 一旦加组，钱就会在账户之间迁移，一旦迁移，哥们儿就会认为，原本**钱散在8个账户里，现在都会集中到当前操作账户上**。













