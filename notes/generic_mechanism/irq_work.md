# irq_work简述
一般我们在当前上下文里不太方便做操作的时候（比如调度上下文）

我们就可以用最后一个大招，借助irq_work去获取一个干净的上下文去执行我们想要的动作（当然里面不能调那种会让人进入睡眠的函数哈）

![1698398014339](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/d58e3d26-5769-4a26-9a54-9934aff9cf12)

一般都会用这个`irq_work_queue`把我们的中断func挂到local的队列上

![1698398074317](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/82bc6483-29b8-4b1e-88a2-da9a66b7140d)

这里有两种queue的方式

如果是lazy模式，就挂在lazy_list上，等下个tick过来执行(是不是其它中断也行，带带进？)

如果是普通模式，就挂在raised_list上，表明我们需要立马处理

随后调用smp_cross_call，发送一个IPI_IRQ_WORK给对应核

![1698405490426](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/04718495-2fef-4a4f-9be3-b9f1c6d2d81c)

然后就是gic的事情了，发一个中断给本核

随后本核在开中断的上下文去响应中断处理

![1698405593122](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/ded0a3b2-0122-4d29-863e-8a1b28492cd9)

接下来，把两个list上的irq的func处理下

![1698405692875](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/a3785f3e-bda0-4e06-8602-89b3d43cfed1)

轻松愉快







