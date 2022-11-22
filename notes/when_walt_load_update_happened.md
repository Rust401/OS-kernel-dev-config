# 事实
## 写在前面
其实大家最关心的其实是看trace的时候，一个任务在cpu上的各种操作（**唤醒、长时间跑，迁核**），**会不会提频**。

提频往往关联着**负载变化**

所以我们这里得关注**WALT的负载，究竟在什么时候更新**

## 触发点
WALT负载更新的入口是`walt_update_task_ravg`

看下调用点

![1669081982904](https://user-images.githubusercontent.com/31315527/203197627-7aad4f8b-2928-43ec-888b-1d4e79d15dca.png)

初步看了下，`__schedule`，`tick`,`try_to_wake_up`、`walt_irq_work`、`transfer_busy_time`、`cpufreq_notifier_trans`、`fixup_busy_time`、`walt_sched_account_irqend`，茫茫多的调用点。




# 方案
# 洞察
# 观点
