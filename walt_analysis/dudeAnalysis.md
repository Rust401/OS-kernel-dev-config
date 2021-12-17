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


