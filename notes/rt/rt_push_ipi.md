## 划重点

一个针对服务器场景的rt负载均衡优化

把原本的pull操作用“ipi触发的串行push替代”

ipi串行push指的是：

puller给第一个rto核发ipi触发push操作，第一个rto核push完了发ipi给下一个rto核

减少了 **只有一个rto核, 但有多个核因为优先级降低同时触发pull_rt_task**导致的contention (double lock rq)


主要针对核很多的服务场景，终端很少会遇到这个问题

另外，ipi下的push，相比pull，多了3部分开销
1. find_lowest_rq
2. ipi开销
3. busy核更加busy

平时更喜欢用pull

终端场景引入这个，可能会带来额外的开销，值得实测下

**Notes**:
* pull触发时机:优先级变更，pick_next_task
* push触发时机:task_wake, tick

## 稍微插播一个case
rt被唤醒后入队，先`activate_task`再`ttwu_do_wakeup`

ttwu_do_wakeup里面会先`check_preempt_curr`然后再`push_rt_tasks`

![1676541215314](https://user-images.githubusercontent.com/31315527/219331196-ce407d2e-28a8-4541-a430-f5029fec920b.png)

![1676541242801](https://user-images.githubusercontent.com/31315527/219331319-73903579-98c9-4bd9-bbb3-cffa292ad85f.png)


## Reference
[PATCH-RT_PUSH_IPI](https://lore.kernel.org/lkml/20150318144946.2f3cc982@gandalf.local.home/)

[实时调度负载均衡](https://github.com/freelancer-leon/notes/blob/master/kernel/sched/sched_rt_load_balance.md)
