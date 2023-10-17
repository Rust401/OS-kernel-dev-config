# 有关rt组调度
rt组调度这个宏一般都不开的，很少有文章讲得清楚，尤其涉及到rt_bandwidth那块

## rt组调度的基本设定
<img width="757" alt="8a7b9d4eb346e19de0de7b14a3785c9" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/ce0d9fc9-5313-449a-8418-d74ce3f69a00">

整体架构还是和cfs比较接近的

几个重要关注点：
* group_entity的**parent是NULL**（因为parent是个sched_rt_entity, 但是root_rt_rq没有属于自己的entity）
* group_entity虽然像task_entity一样悬挂在某个优先级A上，但这只代表**该group内优先级最高的entity的优先级是A**（剩余entity的优先级不能高过这个A，图例子上这个优先级就是98）
* top_rt_rq和下面隶属于group的rt_rq是套娃关系（group的my_q）

### pick流程
### 出入队流程

## rt_bandwidth的实现
### 消耗
### 充值
