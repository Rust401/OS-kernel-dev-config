# 神奇的ret_to_user

之前说到了el1_irq里的调度

[el1_irq里的调度](https://github.com/Rust401/OS-kernel-dev-config/blob/main/notes/schedule/el1_irq_schedule.md)

里面提到了**用户态返回内核态时的调度**

这其实是个很宽泛的概念

<img width="577" alt="eafe866ddfe9f89feaef5c85b4eb06e" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/2d312f9d-9524-44b0-bec5-906022782428">

在el0发生的花式需要进入到内核态的行为(el0_sync，el0_irq等）都需要走`ret_to_user`

<img width="670" alt="1694790827118" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/3a4f734c-ae6d-4956-8b56-48442d49c4a5">

如果检查到TIF_FLAG里面有些事情需要做的时候，会走到`do_notify_resume`

<img width="797" alt="1694790900008" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/68342fde-ee07-40ac-b292-cd3a235bd47d">

这里面会发生一个普普通通的调度

<img width="615" alt="1694790945712" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/9fcb1051-ab20-470a-9180-d3368386cdca">

这是`CONFIG_PREEMPTION`还没引入时就有的调度路径，**不是preempt的，所以有可能会把prev直接出队**

<img width="621" alt="1694791004116" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/3d720aae-77cc-4d91-b853-b5ede6f05b26">

所以下回说我们就别说系统调用返回触发调度了，它和用户态的中断返回其实是一路货色

**这些本质上都是（el1返回el0时的ret_to_user带来的调度）**












