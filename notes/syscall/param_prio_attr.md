# 优先级设定一族的函数
<img width="1275" alt="1705498055904" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/24623dce-7392-49ad-acbc-224c1ed439f1">

说起来这帮哥们儿挺神奇的，明明差不多的功能，为啥要拆出来这么多

解释如下，注意看下注释

<img width="1002" alt="1705498188874" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/6ae9e424-5039-4c2b-b880-0290bec6c650">

总结如下:

`setscheduler`是只改调度类和rt优先级，举个例子: **从rt改回cfs，这时候nice是不会变的，需要再手动去改一遍nice**。

`sched_setparam`是只改rt优先级，连调度类都不带改的

`sched_setattr`啥都改

说到这里，不得不说下`set_user_nice`

这个和上面那3个哥们儿没有同流合污

nice入口在libc

<img width="585" alt="1705498485267" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/520d6b3c-a0ef-424d-825e-23981b974fd1">

里面本质是个syscall

<img width="601" alt="1705498667860" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/56680b72-7f71-4643-9c61-c4f6e2fdfa0d">

<img width="801" alt="1705498756277" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/dda7bbe4-f3df-47bd-a409-b5bbbb0e456d">

这玩意竟然有tid，grp，uid维度的，牛逼

里面就是个set_user_nice

就不多阐述了












