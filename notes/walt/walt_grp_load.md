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
  * 合适的时机就是walt_irq_work，有个干净的上下文去拿rq锁，然后通过`account_load_subtractions`去更新cluster内其它核上的prev/curr_window_cpu[cpu]

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


#### 退组overview

其实退组和加组总体来说很像，只不过是把**task的负载贡献，从grp上，还回到rq**

对比上面那个银行的例子，就从B丢回到A

流程：
1. grp的`prev_runnable_sum`和`current_runnable_sum`里把task的`curr/prev_window`减掉
  * 这边跟加组有区别
  * 做个猜想：进组之后，负载是聚合的，存到银行B之后，哥们会认为钱只会在1个账户里面，而不会散在其它账户，所以从B回到A时，直接把B那个存钱的账户里面的钱扣光就好了
  
&nbsp;

2. 把所有cpu的`prev/curr_window_cpu[i]`清理成零
  * 原因未知，但跟`inter_cluster_migrations`相关，官方解释说前者不准

&nbsp;

3. 把task在tracked_window里的负载`prev/curr_window`加到rq里
  * 这边也很trival，task在tracked_window里面对grp的负载，挪回到rq里面

&nbsp;

4. 把task在tracked_window里的负载`prev/curr_window_cpu`重新归一赋值，re_init当前task的"负载分布曲线"
  * 用上面那个例子，把钱从B挪回到A里面时，把可能已经散在B的各账户的钱，重新归一到一个账户里

&nbsp;

总结下：
逻辑类似，此时变成哥们儿把钱从B挪回A，由于B里面常年运算，有可能钱已经散在B的各账户里了，不过我们不管。我们直接把哥们儿在B那存的所有钱都给A，然后都放到A的一个账户里
此时到不至于出现数量超的问题


### task迁核`fixup_busy_time`

调用链不说了，就是set_task_cpu => fixup_busy_time

![1670979018111](https://user-images.githubusercontent.com/31315527/207477307-8ada7b3d-cf8b-41e3-8a07-ae14e9b673e4.png)

核心逻辑在这

### 如果被迁移的task，当前隶属于某个grp

task负载需要在src_rq的grp里面拿掉，放到dest_rq（但这个过程中，task自己的book keeping是不会调动的）


```
这里插播一句，rq上的grp_time，其实包含的是该rq上，所有隶属于某个组的task的负载之和，所以很可能这个grp_time是n个组贡献的
```

放完之后，会紧接着来一个`walt_migration_irq_work`，用来清算某些数据（比如load_subtractions）

当然，大部分情况下，task的迁核，实际上是不带grp的

### 无grp的task的迁移

那就会走到`inter_cluster_migration_fixup`

如果是同一个freq_domain(cluster)走来走去，那其实啥都不做

```
这里其实就应该联想到，prev/curr_cpu_window到底是干嘛用的
单纯的cluster内迁移，并不会引发task维度的booking keeping变化
所以如果一个task在0cluster上跑来跑去，它的prev/curr_cpu_window[0-3]上应该都有数据
但如果从cluster0迁到cluster1这种，prev/curr_cpu_window[0-3]会被一并带走
```

接下来的流程其实和线程加组比较类似

* 直接把task自己的book keeping聚合到wts->prev/curr_cpu_window[new_cpu]上

* 然后dst_rq直接加上wts->prev/curr_window(其实就是聚合后的booking)

* src_rq里面减掉task的prev/curr_cpu_window[src_cpu]里的值(减的是没聚合的值)

* task的prev/curr_cpu_window[src_cpu]清空

* update_cluster_load_substraction做余下的配平(等下次irq_work到来)

其实一样的，账没有平，都依赖于irq_work平账

### 重点问题：wts->prev/curr_window_cpu引进的目的到底是啥？



## 实际case简图
1. 同cluster迁核（无组)

![1676614889848](https://user-images.githubusercontent.com/31315527/219565080-39313d0b-291d-4bed-ad64-190889e05f11.png)

* 图为1核迁2核（同cluster）
* cpu记录的占空比不做变更，cycles分布不做变更，仅改**变增量位置**
* `inter_cluster_migration_fixup`之前已做各核结算

2. 迁cluster(无组)

![1676614856360](https://user-images.githubusercontent.com/31315527/219564983-e9f005af-9a9b-4b10-a71b-4ed9ab7a3cb7.png)


* 图例为3核迁4核
* cluster0中的负载会被一并加到4核上
* 0-2核负载不会立马减，需要walt_irq_work时才触发减
* 3核只移出tsk在tracked window中对3核的贡献部分
* 4核承载了tsk在tracked window中对cluster0所有的负载
* walt_irq_work发生之前账目不平

3. 同cluster迁核(有组)
![1676615919994](https://user-images.githubusercontent.com/31315527/219568340-df55d3cf-1ca8-4eb9-a949-9f3b67be3951.png)

* 图例为1核迁2核（同cluster，但是负载统计在grp上)
* 直接将tsk在tracked_window里负载全都从1核的grp_time上移动到2核的grp_time（有何用意？）

4. 迁cluster(有组)
![1676617256045](https://user-images.githubusercontent.com/31315527/219572507-44c0800f-6560-4628-aa1a-17c89dc27a29.png)


* 图例为1核迁2核（cluster间迁移，但是负载统计在grp上)
* 跟case3几乎一样，tsk在tracked_window里的贡献随着迁核，直接移到per_cpu的grp_time上

5. 加组
![1676618750068](https://user-images.githubusercontent.com/31315527/219577912-2f444dd3-a543-4bda-a959-7088e18bc8d2.png)

* 图例为3核加组，不迁核
* tsk在tracked window中四散在每个cpu上的贡献，收集在一起，放到tsk所属rq的grp_time中
* 同cluster见迁移，0-2核负载不会立马减，需要walt_irq_work时才触发减
* walt_irq_work发生之前账目不平

6. 退组
![1676619517395](https://user-images.githubusercontent.com/31315527/219580907-aa7a54a9-8a16-4b2e-a784-f421753e7612.png)

* 图例为3核退组，不迁核
* tsk在tracked window中四散在每个cpu上的贡献，收集在一起，放到tsk当前核上（另外几个核当场就减了，不用等irq）
* tsk对组负载贡献直接全还给当前rq

**为啥不分别还给每个rq？**

**因为不准！！！**

**有组的情况下再迁核，贡献根本说不清楚**


