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

#### 先从第一个开始看

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

这个for贼有意思

**由于回调发生的前提往往是timer已经到时间了，到时间了往往意味着默认的overrun**

这里面的hrtimer_forward_now的意思是：
* 如果已经到时间了，就把下一次到期时间加上一个period
* 如果没到时间，那就直接返回（当然这次forward加时间的动作也会失败）

当然绝大多数情况，肯定会到时间的

定时器加好之后，就乖乖通过`do_sched_rt_period_timer`给哪些可怜的rt_rq做一下replensh

另外通过一系列逻辑判断下是否符合rt idle的条件

`do_sched_rt_period_timer`里面逻辑比较长，但是照样trival：
1. 更新下rt_runtime（万一这时候bw变了对吧）
2. balance一下rt_runtime（人家那边借一下）
3. 把rt_time清理一下（所谓的充值，是把前面已经花了的钱，一笔勾销）
4. 然后做些充值后的收尾工作（比如把rt_rq放回上级队列）

最后返回下idle的判定

#### 再看第二个吧，就是那个exceed之后
<img width="776" alt="1698164030844" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/8bf05256-fb60-40c0-a932-7424b4a8384e">

其实rt已经在跑了，这时候这个period大概率是active的，所以绝大多数情况，这边根本不会走进去

<img width="753" alt="1698164109144" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1078d464-7af8-420c-af10-03f720126d72">

因此这里有段注释需要仔细看下：
意思是dl会吃掉rt的时间，但是并不会给rt充钱，就像渣男玩人家老婆，最后还得老实人接盘（老婆的爱是有限的，给了渣男玩了，老实人可能连插入的机会都没有，结果这个老婆的日常保养，都要老实人来）

反正就是老实人定期为渣男买下单

反正整个过程很trival，挺好理解的，有手就行。



























