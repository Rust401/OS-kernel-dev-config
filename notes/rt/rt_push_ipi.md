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


## Reference
[PATCH-RT_PUSH_IPI](https://lore.kernel.org/lkml/20150318144946.2f3cc982@gandalf.local.home/)

[实时调度负载均衡](https://github.com/freelancer-leon/notes/blob/master/kernel/sched/sched_rt_load_balance.md)
