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

anyway这个不重要，重要的是目标核上现在在干嘛

* 如果是抢占的的入队，那就会发ipi给目标核的，开中断之后可以立马响应
  
（如果目标核只是关了抢占，没关中断，ipi能进去，但其实不会触发调度的，这时的**中断返回路径上是会检查preempt_count，如果还处于关抢占状态，会跳过调度代码**）

看这里的608行
  
![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/b2b0e999-723d-4f66-bcab-e23a65e1cc3c)

* 非抢占的入队，那就乖乖等目标核preempt_enable自动调度，或者目标核从中断返回





