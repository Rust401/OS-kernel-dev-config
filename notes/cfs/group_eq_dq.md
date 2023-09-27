# Fair Group Sched下的进出队

cfs组调度的代码，一直以来，都是比较难读懂的（即使它的设计很trival)，说它是notorius，也不为过。

尤其是连着的`for_each_sched_entity`一出，大脑直接炸掉

每次重新看都要重新理解一遍，所以这回干脆记下来

![1695802973768](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/01f39be2-b38f-4964-9869-8d38b1f107f6)

对于`enqueue_task_fair`

这里红框是重点

视角放到一个平平无奇的task身上

它要入队，那势必要把它的se加入某个组织

这个se显然是一个task_se

**第一轮入队，se->on_rq必为false**

**所以一定会触发enqueue_entity逻辑**

对于一个普通的task（不属于任何的group

这个狗屁循环，跑一下就结束了

直接来个enqueue_entity套餐就完事了

但对于一个隶属于某个组的task

第一轮循环，显然得来个enqueue_entity套餐

随后，如果它所归属的cfs_rq还没有on_rq，那就继续来一波

如果cfs_rq已经是挂在rq上的状态，那就跳出第一个循环，不用再重复入队了，走第二个循环原地更新cfs_group就好了

## 这里插播一下enqueue_entity到底干了啥

![1695804444988](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/f69cf964-aa15-4923-933a-98b3e29f564d)

* **1里面只会对group_se更新，（其实只会）更新了group_se的weight，并不会向上传递**，毕竟这个时候压根没在cfs_rq上
* 2里面会把se的weight加到cfs_rq上，因为一会要真正插到红黑树上，所以先把lw这些加上，**记住，是把这个se的lw，加到它归属的cfs_rq上的**
* 3是真正插红黑树的过程

## 再来看看update_cfs_group到底干了啥
![1695804854797](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/578b3ab9-88f1-458a-898c-c39aedbe9fb7)

核心其实是这个reweight，上面无非是算个值而已

![1695804980536](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/72ca6aa7-f36d-496b-89f2-639aab6b1875)

这个reweight其实是有讲究的

分两种情况
* on_rq时的reweight，需要先从爸爸摘下来，更新，再放回去
* 非on_rq时的reweight，就单独改下权重就好（反正后面会加一个add动作）

这里突然想到一句很经典的，为啥会有两个for_each_sched_entity？

**这里面的分割点就是当某个group_se的on_rq状态不一样了，需要区别对待**

* 没on_rq的se，需要通过enqueue_entity把自己挂到上级部门，这里面顺便就要更新下se的lw，然后加到se所属的cfs_rq上的lw
* 已经on_rq的se（肯定是个group），通过update_cfs_group去更新下se的lw，以及所属的cfs_rq的lw。继续逐级传递

只能说这个代码里面确实很优雅

函数解耦也很棒

**dequeue流程也大同小异**
无非是dequeue到某个层级，已经没法把上级一起拉下马了，那上级就乖乖走update流程吧

两个循环也是一样用法的

**顺便再来看下task_tick_fair**

![1695806276034](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/a5e94795-3a4d-4045-9934-71017ef0dd5a)

![1695806314974](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/695ec01b-390e-4532-ab4d-2f05b305b1da)

这个就很均一了，没有带上带下的苦恼，一视同仁

## 核心归纳
* 进出队时两个for_each_sched_entity，是用来区别对待on_rq与否的se的
* update_cfs_group函数的核心是reweight_entity，而reweight的动作其实会因group_se是否on_rq而有区别，on_rq的情况下需要传导到cfs_rq上
* enqueue_entity中，通过update_cfs_group更新se，再account_entity_enqueue是极度合理的，前者肯定不是on_rq的，因此更新完统一加就完事
* dequeue其实就是镜像，只不过on_rq变成了cfs_rq->load.weight是否为零

## 随便再说些装逼的话
思路意识流，无非效率低点，最后也能归纳出来一些金句

很多东西，多看几遍，里面的内在联系也逐渐显露出来了

没有任何事情，是可以轻轻松松掌握并且装逼的

回想起来，cfs的组调度，是如此的trival

只能说

**人生毫无意义**

很多东西，先有，再精，没什么毛病

写这种小文章也是，别纠结那些格式，reference啥的

只有真正懂了，才能洋洋洒洒下笔如有神的写下来

这种从打字的轻快程度都能感受到

每当你懂了之后，再去看那些不懂的受折磨，那是何其的爽






