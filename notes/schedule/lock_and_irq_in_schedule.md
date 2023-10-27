# 调度路径的上下文（锁、中断）

## 一些基本的设定
1. scheduler_tick是关中断的，且前部持了rq锁
2. 调度主函数schedule是关中断关抢占的，且里面会持rq锁
3. 常见的set_user_nice(我们称之为set系列函数，里面会有dequeu/enqueue, get_next/put_prev)，都会持task_rq_lock，先持pi锁，再持rq锁，但持pi用的是irq_save的方式
4. sched_setscheduler这个的本质和set_user_nice这种比较类似，核心也是task_rq_lock里面做系列动作
5. 常见的持rq_lock的场景，都会关中断(目前我还没找到反例)

## tick
![1698405992862](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/99cd8c98-8b63-41c1-b102-bab4e9a61609)

首先进入scheduler_tick，那必定是关了中断的

然后里面会持rq锁

task_tick这类的都是持了rq锁做的，里面不会发生调度，但会发生resched_curr这种动作，这种往往会在中断返回路径上检查下标记位，然后真正调度

## 调度主函数

在外面关抢占显然是家常便饭(当然后面对应的那次开抢占就别调度了哈

![1698407957075](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/f8bfcec7-68eb-40c5-80b7-6b5a84d7a5ed)

调度的开头，先关抢占（意味着这段时间反正没法调度了），再拿rq锁

![1698408300223](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/743d2644-f7a3-4d78-b817-95e142b5113c)

结尾永远都是解rq锁+关抢占（当然这里其实不用对称）

这里面涉及一个lock_switch，有点东西，到时候再单独看吧（毕竟lock的owner在cs时是要切换的）

![1698408453431](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/7ff9d726-1228-4d8e-bcbd-0a6947dbe660)

抢占式调度也是类似的，显然得关抢占

但调度里面貌似没持pi锁？但是优先级修改那种函数，都是先pi锁再rq锁的，所以拿了rq锁再持pi锁就会变成一个笑话

## 常见的set系列函数

![1698408850631](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/8f5fbb97-a774-41e4-abb4-2cd99f978270)

我指的是这些，最trival的，拿set_user_nice为例

![1698409027305](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/ee1e65f8-a66d-4f26-94e2-6a880e2415a6)

task_rq_lock是先pi_irq_save再加普通的rq_lock的

所以这个流程里面又 关中断+关抢占的 可以说是安全的不得了（看样子task_rq_lock的情况下可以随意dequeu/enqueue以及set/put?）

**优先级变更的本质是，摘下来改造改造，再放回去**

然后这个put/set，本质上的行为，是**在cpu上跑**和**回去排队**之间的变更，针对于rt这种情况，那无非是对pushable_task做一个变更

噢，这里多说一句，`__sched_setscheduler`本质上是一个大号的`set_user_nice`

前面是一堆check流程，核心流程一样离不开task_rq_lock，关中断关抢占去修改task的调度属性

不过插个题外话，尾巴上的rt_mutex_adjust_pi可是要在锁外去干的

![1698410009676](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/ecd1b1ab-7d91-4bcd-ae2f-d283b80f4fa0)

**中断上下文其实是不允许pi类型的优先级设置的（why？）**


























