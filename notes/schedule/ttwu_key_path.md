# 唤醒核心轨迹
![e346eb4c66a0fa35072e6b1e9da86ef](https://user-images.githubusercontent.com/31315527/222963471-87425856-113c-4c95-86fa-06d8eab1603d.png)

当前视角来看，唤醒分5步

* trace_sched_waking
* 选核
* set_task_cpu
* 入队
* trace_sched_wakeup

这里要稍微补充一下，唤醒之后的第一个调度点究竟在哪

![1698410679998](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/4c34e292-a36a-474f-a5f0-585a801bd275)

再仔细理解下这句话

另外ttwu流程会先持pi锁，然后再ttwu_queue里面再持rq锁

当然持pi锁显然是关中断的（不过退出之前又preempt_enable了一次）


