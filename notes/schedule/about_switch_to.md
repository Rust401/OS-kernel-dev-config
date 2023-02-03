# 有关switch_to

## 1. 为啥对switch_to感兴趣
一个线程，往往会因为某种原因进入调度

比如futex、同步binder

花式路径，总会触发调度进到`__schedule`

`__schedule`的核心流程，可以看[这个](https://github.com/Rust401/OS-kernel-dev-config/blob/main/notes/schedule/key_path_schedule.md)

核心就是**选next，然后把next切上cpu执行**

那如何送上cpu执行呢？

不得不引出`context_switch`

而`context_switch`里最核心的函数，莫过于`switch_to`

## 2. switch_to

`switch_to`是上下文切换真的的分界线

```txt
AAA

switch_to

BBB
```

假设这是一个cpu上的执行序列(某个cpu上看到的)

AAA时(switch_to)之前，此时执行的调用栈，都是`prev`的调用栈

switch_to会把栈和寄存器都切成next的

切完之后，到了BBB，调用栈就变next的了

**这里切的是整个调用栈，包括内核态的栈**

从task视角，它一直是连续执行的

```txt
AAA1

switch_to （下cpu/重上cpu，task自己不感知）

AAA2
```

假设这是一个task的视角，AAA1和AAA2执行的代码，**都在它自己的栈上，但有可能是在两个不同的cpu上的**

task认为，它就是就是去内核态里逛了一圈，再溜回来，**中间没有停顿**

从哪个调用栈下去的，就从哪个调用栈走回来，再返回用户态

从task角度来说，它的栈变化一直是连续的(除了context_switch内prev在switch_to之后会被last覆盖掉)，感知不到调度走到switch_to带来的“切断”

## 3. 一些小问题
### 从cpu的视角来看，switch_to之前的prev和next是谁，switch_to之后的prev和next又是谁？

假设cpu视角看到的是A切B

* 之前(此时还是curr的栈)：
prev：prev是curr，就是A
next：next是之后选上的任务，就是B

* 之后(新换上的那个栈，也就是上面的next，B):
prev:当前的curr，就是B。**但在context_switch的栈中会被last覆盖，last就是这个CPU上一个执行的任务，在这里就是A。从context_switch返回后，prev又变回正常，又是B**
next:B之前被切掉时的next，在这里就是A

### context_switch栈里的prev和next，与__schedule栈里的prev和next是否相同？

不一定，`context_switch`栈中，prev会被last覆盖，这里的last就是该cpu在此次cs行为之前执行的那个任务

## Reference
[wowotech-进程切换](http://www.wowotech.net/process_management/context-switch-arch.html)





