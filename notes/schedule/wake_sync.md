# sync_wake重点
waker如果知道自己马上进schedule，可以用sync_wake的方式去唤醒wakee(**注意是马上进调度，不一定是马上进sleep，比如开抢占就是一个调度时机**)

倾向于把wakee放在本核上唤醒，顺便标记抢占

这样就可以在waker调度时把wakee放上核执行

减少了额外的抢占开销，也减少了wakee被在各cpu上boucing的可能

当然如果waker用来sync_wake的唤醒方式，自己不进调度，那也ok

wakee下次会等下个中断返回时候再抢占(如果标记了preempt的话)

无伤大雅

**Notes：**

**抢占必须依赖调度，各种方式的入队抢占，都只是标记，实际调度发生都得依赖于调度，因此需要在系统调用或者中断返回中触发，当然preempt_enable时也有个点**

# 同步binder到底是怎么触发调度的？
![1676556165567](https://user-images.githubusercontent.com/31315527/219385760-3539c94a-b402-4f4e-bd96-dff1ef8081ed.png)

调用之后直接走restore_priority流程了，那说明restore之前binder应该让上核执行了

但是调度触发点究竟在哪？

`wake_up_interruptible_sync`经过层层调用

最后会走到`__wake_up_common_lock`

![1676556358825](https://user-images.githubusercontent.com/31315527/219386577-fc3b103e-59ad-482b-97f0-54d9e606a3d8.png)

注意那个`spin_unlock_irqrestore`

spin_lock解锁是会开抢占`preempt_enable`的

这有个调度触发时机点

![1676556613918](https://user-images.githubusercontent.com/31315527/219387584-8cb48ddc-2f8c-4d44-8d72-c98510999c62.png)

里面会抢占式调度

![1676556661638](https://user-images.githubusercontent.com/31315527/219387780-ecc506d6-7ee4-4cff-ba8f-dabf0daf6bc3.png)


# Reference
[why_wake_sync](https://stackoverflow.com/questions/16201468/purpose-of-wake-up-sync-wake-up-interruptible-sync-in-the-linux-kernel)
