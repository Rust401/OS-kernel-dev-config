# 有关SCHED_FLAG

## 1. SCHED_FLAG_KEEP_POLICY
<img width="458" alt="1709129677600" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1530a6ec-324f-4f8d-94d0-2f1e4d857bd4">

这两个flag挺神奇的，先前没有好好研究过

`SCHED_FLAG_KEEP_POLICY`的唯一作用，是给提供了一个名为`SETPARAM_POLICY`的`sched_policy`

这玩意是为了在调度属性变更时把policy hold住

<img width="665" alt="1709129831263" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/d213b491-9407-4f47-b30a-80fabc9735e1">

反正最后都是为了把`SETPARAM_POLICY`传进去

那这个`SETPARAM_POLICY`的作用是什么呢

<img width="611" alt="1709130091979" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/b2881ccd-418a-4feb-b670-add7611ede56">

只是为了出队变更时别把policy变掉吧


## 2. SCHED_FLAG_KEEP_PARAMS

这哥们儿更搞笑

<img width="665" alt="1709130182493" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/ee58c7a6-733c-4949-8877-ae1c61ae3e7a">

这个flag如果在的话，优先级这些属性（policy、static_prio、rt_prio）直接不变了，跳过，看样子是为了uclamp/latency_nice这种专门准备的

## 题外话

感觉这里的耦合相当严重，真该好好重构下，充满了历史遗留原因

* 两者一起用相当保险

* 只用KEEP_POLICY还能改改rt优先级的

* 只用第二个我咋没见过，但理论上也没啥问题










