# 事实
## 写在前面
其实大家最关心的其实是看trace的时候，一个任务在cpu上的各种操作（**唤醒、长时间跑，迁核**），**会不会提频**。

提频往往关联着**负载变化**

所以我们这里得关注**WALT的负载，究竟在什么时候更新**

## 触发点
WALT负载更新的入口是`walt_update_task_ravg`

看下调用点

![1669081982904](https://user-images.githubusercontent.com/31315527/203197627-7aad4f8b-2928-43ec-888b-1d4e79d15dca.png)

初步看了下，`__schedule`，`tick`,`try_to_wake_up`、`walt_irq_work`、`transfer_busy_time`、`cpufreq_notifier_trans`、`fixup_busy_time`、`walt_sched_account_irqend`，茫茫多的调用点，基本可以涵盖一下几类事件：

![823120ceb7728c757ca03e21072f8bb](https://user-images.githubusercontent.com/31315527/203198858-4236ec37-97da-4e11-aed4-6ddd4b9d84d5.png)

光看这6个event，貌似这个特性非常的trival，场景无非是上核、下核、唤醒、迁移、运行时更新、中断更新。

具体来分析下触发细节吧

### __schedule

![1669082969343](https://user-images.githubusercontent.com/31315527/203199986-e94ceab5-5c9c-4288-b555-733074189fcb.png)

下个任务已经选出来了，context_switch发生之前，先更新一波walt负载

![1669083093653](https://user-images.githubusercontent.com/31315527/203200220-69378990-5a2e-412c-b450-ee5b74fc3738.png)

这个逻辑简单，如果下个任务不是先前跑的那个任务，对prev做一个下核更新`PUT_PREV_TASK`、再对next做一个上核更新`PICK_NEXT_TASK`（这里有个疑问，**next之前下去的时候已经更新过了，为啥上核tm需要再更新一次？**）

如果下个任务还是先前跑的那个任务，那就单纯做一遍`TASK_UPDATE`





# 方案
# 洞察
# 观点
