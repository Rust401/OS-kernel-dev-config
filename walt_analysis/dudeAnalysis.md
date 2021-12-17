# include/linux/sched.h
## extern void sched_exit(struct task_struct *p);✅
```c
void sched_exit(struct task_struct *p)
{
        struct rq_flags rf;
        struct rq *rq;
        u64 wallclock;

        sched_set_group_id(p, 0); //回到分组0，rtg相关

        rq = task_rq_lock(p, &rf);

        /* rq->curr == p */
        wallclock = sched_ktime_clock(); //获取当前系统时间
        update_task_ravg(rq->curr, rq, TASK_UPDATE, wallclock, 0); //更新自己和所属队列的负载
        dequeue_task(rq, p, 0); //出队
        /*
         * task's contribution is already removed from the
         * cumulative window demand in dequeue. As the
         * task's stats are reset, the next enqueue does
         * not change the cumulative window demand.
         */
        reset_task_stats(p); //重置ravg里面的成员变量
        p->ravg.mark_start = wallclock; //标记执行exiting的开始时间
        p->ravg.sum_history[0] = EXITING_TASK_MARKER; //在历史负载中标记EXITING

        enqueue_task(rq, p, 0); //重新入队
        clear_ed_task(p, rq); //ed_task相关
        task_rq_unlock(rq, p, &rf);
        free_task_load_ptrs(p); // curr(prev)_window_cpu申请的地址释放掉
}
```
被`do_exit调用`，在各种进程退出的场景中调用，用于清空walt相关的数据结构
```
sched_set_group_id❌
update_task_ravgs✅
reset_task_stats✅
clear_ed_task❌
free_task_load_ptrs✅
```

## int register_cpu_cycle_counter_cb(struct cpu_cycle_counter_cb *cb)
```c
int register_cpu_cycle_counter_cb(struct cpu_cycle_counter_cb *cb)
{
        mutex_lock(&cluster_lock);
        // 原生的get的函数指针没被赋值就直接返回
        if (!cb->get_cpu_cycle_counter) {
                mutex_unlock(&cluster_lock);
                return -EINVAL;
        }

        cpu_cycle_counter_cb = *cb; //将驱动传入的get函数给walt静态定义的cb用
        use_cycle_counter = true; //标记flag
        mutex_unlock(&cluster_lock);

        //驱动中取消注册notifier
        cpufreq_unregister_notifier(&notifier_trans_block,
                                    CPUFREQ_TRANSITION_NOTIFIER);
        return 0;
}
```
`use_cycle_counter`只有在驱动里注册了`get_cpu_cycle_counter`的函数，才会被置成true
有三个地方都会用到这个bool
- update_task_cpu_cycles
```c
static inline u64 read_cycle_counter(int cpu, u64 wallclock)
{
    struct rq *rq = cpu_rq(cpu);

    if (rq->last_cc_update != wallclock) { //当前的cc还是以前的值，就更新
            rq->cycles = cpu_cycle_counter_cb.get_cpu_cycle_counter(cpu); //从驱动里面读（是个累计值）
            rq->last_cc_update = wallclock; //标记更新时间
    }

    return rq->cycles; 把rq上的cc返回给p
}
static void update_task_cpu_cycles(struct task_struct *p, int cpu, u64 wallclock)
{
        if (use_cycle_counter) // 如果注册了，我就更新，没注册过，直接啥也不做
                p->cpu_cycles = read_cycle_counter(cpu, wallclock);
}
```
`update_task_cpu_cycles`更新本task的cpu_cycles，这个值实际上是从所属的rq里面拿的，拿的时候顺便更新一波rq的cycles。当然如果一开始都没有注册，那这个更新动作就啥也没做。

- 



