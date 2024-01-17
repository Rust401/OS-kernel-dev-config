# 优先级设定一族的函数
<img width="1275" alt="1705498055904" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/24623dce-7392-49ad-acbc-224c1ed439f1">

说起来这帮哥们儿挺神奇的，明明差不多的功能，为啥要拆出来这么多

解释如下，注意看下注释

<img width="1002" alt="1705498188874" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/6ae9e424-5039-4c2b-b880-0290bec6c650">

总结如下:

`setscheduler`是只改调度类和rt优先级，举个例子: **从rt改回cfs，这时候nice是不会变的，需要再手动去改一遍nice**。

`sched_setparam`是只改rt优先级，连调度类都不带改的

`sched_setattr`啥都改



