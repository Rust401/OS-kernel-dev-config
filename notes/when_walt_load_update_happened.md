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

**负载更新是不是就意味着调频呢？** **不一定**。

但这`__schedule`这个场景中，由于hw_schedutil的存在，负载更新之后，就会顺便调个频。

### scheduler_tick

![8c10147a8fd887abeeee79e6ab3e804](https://user-images.githubusercontent.com/31315527/203208400-bf529742-a07b-417a-b198-882e3b58f848.png)

tick入口处，要先更新下负载

![1669089106898](https://user-images.githubusercontent.com/31315527/203217074-4b1993f1-c8ee-4489-bd4f-77a330bfe0dc.png)

tick的时候，走的是平平无奇的`TASK_UPDATE`。

当然，如果tick的时候发生调度了，那就又要重走`__schedule`的老路了。

另外，在hw_schedutil的加持下，tikc的时候显然也得调频。

### try_to_wake_up

![3f6ec521371b9b1ac687a18ecd50382](https://user-images.githubusercontent.com/31315527/203217789-74425927-e9a8-4391-92e1-0aa42137978a.png)

唤醒选rq时，要先更新一波负载

![1669089577855](https://user-images.githubusercontent.com/31315527/203218034-04244ef7-8b18-4e5f-b9a6-220543fa02b8.png)

这边也好理解，唤醒别人时，先`TASK_UPDATE`自己，然后再以`TASK_WAKE`的事件更新被唤醒者。

### walt_irq_work

![1669097950892](https://user-images.githubusercontent.com/31315527/203239550-46c766d5-1560-4f08-a8be-51626d0db02b.png)

`walt_irq_work`会发生在每次`update_task_ravg`的末尾，里面会拿住所有cpu的rq锁之后，再最所有cpu做一遍`TASK_UPDATE`版的`update_task_ravg`。

这边不会无限套娃吗？不会，因为只有当窗口切换时(window_rollover)，才会触发walt_irq_work。

### transfer_busy_time

![1669101722252](https://user-images.githubusercontent.com/31315527/203250419-2dc50407-bb74-4683-8c27-1859ffecc250.png)

这玩意是线程在组间迁移，用于修复由于task的进出对grp负载的影响

先以`TASK_UPDATE`更新rq上的curr，再以`TASK_UPDATE`去更新即将加组/退组的线程

### cpufreq_notifier_trans

![79e9256c6069db06abd9b1722a96b1a](https://user-images.githubusercontent.com/31315527/203255198-84765b3e-0e8d-46bc-a40d-387284658e8e.png)

如果频点要更新了，该cpu所属cluster上的所有cpu，都要做一遍`TASK_UPDATE`。

### fixup_busy_time

![1669103424048](https://user-images.githubusercontent.com/31315527/203256070-a37c86f6-186e-4cbd-af1d-02d0d40f6de3.png)

迁核的时候要做更新

先`TASK_UPDATE`更新目标task当前所属的cpu上的curr

再`TASK_UPDATE`更新目标cpu和目标cpu当前跑的task

最后`TASK_MIGRATE`更新当前task和当前task目前在的那个rq

（上面那3句描述太绕了，其实归纳下就是老核上的curr和p都更新下，然后目标核上的curr更新下）

### walt_sched_account_irqend

![28c3a305e58388d599f41b32d74c455](https://user-images.githubusercontent.com/31315527/203260911-0ee2e115-268e-4081-a9c8-a3003f5440a2.png)

这边单纯用`IRQ_UPDATE`去更新中断负载。

## 几个有趣的问题 
### 哪些event需要被计算到cpu的busytime中呢

![1669107295232](https://user-images.githubusercontent.com/31315527/203269655-ad712f79-510f-4eb2-8278-04060e202203.png)

* 如果撤下idle、更新idle、idle上跑了中断，此时将**中断**或者**等io**的时间算到负载内；
* 如果任务刚唤醒，就别统计时间了；
* 如果上一个非idle的task刚刚溜溜，或者由中断触发的更新，那就无脑算上；
* 如果是常规的任务更新，看是不是cpu上的curr，如果是就统计，如果只是runnable的，那就判断`SCHED_FREQ_ACCOUNT_WAIT_TIME`开着没有，开的话就把runnable的time也算上去；
* 迁移、选下个任务的时候，同样判断`SCHED_FREQ_ACCOUNT_WAIT_TIME`，决定是否将task负载计入rq负载。这个其实蛮好理解的，迁之前，这个任务是等在原来的核上的，那迁走之前，把这部分等的负载计算上去，十分合理。同样，被`pick_next_task`选择之前，这个任务也以ready状态在这个核上等了很久，context_switch发生之前，需要把task等的时间算在rq的负载上（需要，但没被满足的负载）

如果某个event压根不用更新rq负载，那此次update_cpu_busy_time就到此为止了。





# 方案
# 洞察
# 观点
