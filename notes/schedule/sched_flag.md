# 有关SCHED_FLAG
<img width="458" alt="1709129677600" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1530a6ec-324f-4f8d-94d0-2f1e4d857bd4">

这两个flag挺神奇的，先前没有好好研究过

`SCHED_FLAG_KEEP_POLICY`的唯一作用，是给提供了一个名为`SETPARAM_POLICY`的`sched_policy`

这玩意是为了在调度属性变更时把policy hold住
