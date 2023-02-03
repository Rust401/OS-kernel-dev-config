# 有关switch_to

## 为啥对switch_to感兴趣
一个线程，往往会因为某种原因进入调度

比如futex、同步binder

花式路径，总会触发调度进到`__schedule`

`__schedule`的核心流程，可以看[这个](https://github.com/Rust401/OS-kernel-dev-config/blob/main/notes/schedule/key_path_schedule.md)

核心就是**选next，然后把next切上cpu执行**

那如何送上cpu执行呢？

不得不引出`context_switch`

而`context_switch`里最核心的函数，莫过于`switch_to`

## switch_to

`switch_to`是上下文切换真的的分界线

```txt
AAA

switch_to

BBB
```

假设这是一个cpu上的执行序列

AAA时(switch_to)之前，此时执行的调用栈，都是`prev`的调用栈

switch_to会把栈和寄存器都切成next的

切完之后，到了BBB，调用栈就变next的了

**这里切的是整个调用栈，包括内核态的栈**
