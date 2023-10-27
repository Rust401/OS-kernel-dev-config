# 调度路径的上下文（锁、中断）

## 一些基本的设定
1. scheduler_tick是关中断的，且前部持了rq锁
2. 调度主函数schedule是关中断关抢占的，且里面会持rq锁
3. 常见的set_user_nice(我们称之为set系列函数，里面会有dequeu/enqueue, get_next/put_prev)，都会持task_rq_lock，先持pi锁，再持rq锁，但持pi用的是irq_save的方式
4. sched_setscheduler这个的本质和set_user_nice这种比较类似，核心也是task_rq_lock里面做系列动作
