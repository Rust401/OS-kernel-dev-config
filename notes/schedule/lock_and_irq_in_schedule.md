# 调度路径的上下文（锁、中断）

## 一些基本的设定
1. scheduler_tick是关中断的，且前部持了rq锁
2. 调度主函数schedule是关中断关抢占的，且里面会持rq锁
3. 常见的set_user_nice(我们称之为set系列函数，里面会有dequeu/enqueue, get_next/put_prev)，都会持task_rq_lock，先持pi锁，再持rq锁，但持pi用的是irq_save的方式
4. sched_setscheduler这个的本质和set_user_nice这种比较类似，核心也是task_rq_lock里面做系列动作
5. 常见的持rq_lock的场景，都会关中断

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














