# 唤醒核心轨迹
![e346eb4c66a0fa35072e6b1e9da86ef](https://user-images.githubusercontent.com/31315527/222963471-87425856-113c-4c95-86fa-06d8eab1603d.png)

当前视角来看，唤醒分5步

* trace_sched_waking
* 选核
* set_task_cpu
* 入队
* trace_sched_wakeup
