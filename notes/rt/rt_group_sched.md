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
rt_bw的充值逻辑，其实是最令人confuse的

我们仍旧需要从tg的角度去看（毕竟每个tg会拥有自己的rt_bw，然后这个rt_bw可以掌管8个rq）

整体框架是通过hrtimer去实现的

**每当group中有rt任务开始执行，整个bw的控制就开始了**

当前有两个rt_bw的起始点：
1. enqueue_rt_enrity流程中的inc_rt_group
2. update_curr_rt流程中的do_start_rt_bandwidth

第一个是很trival的，第二个可能有点令人confuse

先从第一个开始看

<img width="671" alt="1698162072754" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/2b47b8a6-2bc7-47d2-b1fe-4a7955f03474">

这个是大部分bw的真正的起始点，只有当rq上跑rt任务的时候，bw的计算才有意义（全是cfs你计算个锤子）

<img width="664" alt="1698162147471" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/5babf155-d943-4769-a2e7-0f51435bde48">

这里面还很鸡贼先做了个判断，如果bw压根没开或者这个group所绑定的bw对象的rt运行时间不受限，就啥也不管

<img width="686" alt="1698162236894" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/44dd56bc-6f61-476b-bcba-ca52b988dc62">

这个`rt_period_active`表示的是否处于活跃的rt限制周期（就是跑一会，停一会那个周期），所有cpu上都进入"rt idle"状态的话，这个rt_period_active就会置零

所以那个rt_period_active，在一些喜闻乐见的场景，很容易走进去

通过hrtimer_forward_now+hrtimer_start_expires会先触发一次定时器到时（目的是先把时间清一清）

然后最关键的其实是`sched_rt_period_timer`，我们尊贵的rt_period_timer的回调

<img width="811" alt="1698163198521" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/35eacdbc-c2be-4d16-9a92-be7818524ea9">






















