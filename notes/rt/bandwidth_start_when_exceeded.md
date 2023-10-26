# 两个rt_bw相关的有意思的问题

## 1. 为啥要在rt_time_exceeded的时候，再开一遍bandwidth？
![1698285233577](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/d9b7a1ac-e789-4f03-ae33-3e05f4247eed)

理论上，有rt在核上跑，rt的period必定是active的，没必要在这里面强起hrtimer做充值

查了下这个修改引入的commit 268f35245650

![1698285476179](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/026b63d4-f266-4c20-a999-9ad02d325c1c)

核心思想是说，**如果rt_runtime配成INF，那period永远不可能active**（即使rt_task入队）

那当rt_runtime突然被约束成0.95s（打个比方）

**由于period并没有active，充值的hrtimer也没起来**，那此时的rt_task就会一直被throttle

## 2. 为啥start_rt_bw的时候，需要让定时器立马expire？

![1698285842591](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/d510c697-d0b3-48f6-bcab-fbc2340baf92)

这个修改是commit c3a990dc9fab59 sched/rt: Kick RT bandwidth timer immediately on start up

意思是说dl任务会累加到rt_rq->rt_time，一个核上只跑dl任务，不跑rt任务，rt_rq->rt_time会一直居高不下

当rt任务真的开始跑了，就会立马throttle

所以需要在rt_task入队这种时机，先让定时器执行一遍到期的callback，把以前的时间清理清理










