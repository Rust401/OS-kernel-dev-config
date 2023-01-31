# 有关组调度
稍微记录下cfs的组调度，免得过一段时间一直忘记

## 一图胜千言
![1675149243682](https://user-images.githubusercontent.com/31315527/215691665-18768e3e-ceb0-4c17-9118-af8cefeae67f.png)
这个图摘自wowo科技

## 一些基本概念
主要会有3个东西傻傻分不清楚，`se`、`cfs_rq`、`task_group`

### se(sched_entity)
se就是sched_entity，很trival的理解，就是调度实体，真正用来在调度过程中占位的玩意（也是直接挂在红黑树上的东西）

有两种，`task_se`和`group_se`

* `task_se`代表该entity隶属于一个`task_struct`,是一个可以执行的线程

* `group_se`代表该entity其实是一个group，这个不能直接跑，里面还有一堆`task_se`或者嵌套`group_se`

se里面有3个很关键指针，`cfs_rq`和`my_q`和`parent`

* `cfs_rq`该se隶属于的cfs_rq

* `my_q`指该se所拥有的cfs_rq（只有group_se才会拥有rq）

* `parent`指的是其上一层级的`sched_entity`。如果这个`sched_entity`直接挂在根上，那它的parent就是null（毕竟root cfs_rq是没有sched_entity的）。这个parent经常会被用来做se的向上遍历

### cfs_rq
这东西其实是红黑树的容器，维护了一堆拓展信息，比如curr，next，nr_running，h_nr_running，load

每个`group_se`拥有一个cfs_rq，通过红黑树的根rb_root_cached把一堆哥们儿都串起来

另外整个rq有一个`root cfs_rq`，不隶属于任何`sched_entity`，功能和普通的cfs_rq一样，维护了整个rq上的运行信息

### task_group
这里指的是实实在在的组，组不是per_cpu的概念，因此一个组里面会在每个cpu上都布设自己的`group_se`以及对应的`cfs_rq`

当前组也可以嵌套，有嵌套的话，组和组之间也会有parent的关系

最上面也会有个root task_group


## 关联
组其实是一个上层用户比较关心的概念，搞清楚组的拓扑，就能算出资源在组之间的分配

cfs_rq和se则是互相纠缠的关系，se中有cfs_rq, cfs_rq中又通过红黑树串联各se

其实整个就是个套娃模型

树上有挂着很多宇宙，宇宙中又有新的树

# Reference
[wowo-tech的文章-组调度](http://www.wowotech.net/process_management/449.html)
