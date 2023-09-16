# linux中那些优先级

其实最核心的优先级是`prio`，所谓的动态优先级

这是真正和线程调度行为匹配的那个值，比如rt_mutex触发了rt优先级的变更，此时prio和normal_prio就不一样了。

这个时候生效的是prio，而不是normal_prio。

normal是它本来所属于的阶层

prio是它通过各种手段临时混到的prio，属于一种boost行为，没法长久。

当然prio变更还会触发调度类的变更

完全有可能从cfs被传递成rt

从SCHED_OTHER跃迁成SCHED_FIFO

当然这种rt的临时boost行为，其实是不受rt_bw管控的

可以去看下如何判断rt_rq是否throttle

这里有个经典的图，可以扩充
