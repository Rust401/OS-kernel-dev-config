## 中断返回的调度
调度有很多时机，比较常见的有syscall返回（通常为内核态返回用户态`ret_to_user`），**中断返回**等

但中断返回其实是一个比较难理解的事，尤其是这个**中断发生在内核态**时

为了一探究竟，我们直接去看代码

路径在

`arch/arm64/kernel/entry.S`

直接找`el1_irq`


<img width="444" alt="1694789706381" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/f1ed24ba-51ab-410c-873d-3464862a9d6b">

看来核心是`el1_interrupt_handler`


<img width="801" alt="1694789653468" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/adedb653-c9e2-49d9-8b34-7f2453ba9ee4">

里面的`arm64_preempt_schedule_irq`是处理完中断要做的事

<img width="735" alt="1694789752148" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/46b4b82c-62cc-4d11-9dba-21cb7f2a8240">

紧接着进到`preempt_schedule_irq`（这是schedule的六大金刚之一）


<img width="781" alt="1694789816076" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/1b520502-328f-48c3-8c95-0d7bcabbc85d">

这边有个点事贼关键的，那就是这个入口的调度，是个**抢占式调度**，所以入参的preempt传了true（这盲猜是代码演进引入的）

其最大特征就是**不会把`prev`给deactivate掉，那prev在不久的将来还能被继续调度到**

这边的意思就是抢占式的调度，并不会改变prev执行的必要条件，属于强行加戏，没有这些抢占式调度，其实系统还像原本一样跑得好好的














