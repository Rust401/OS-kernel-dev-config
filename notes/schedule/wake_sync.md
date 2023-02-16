# 划重点
waker如果知道自己马上进sleep，可以用sync_wake的方式去唤醒wakee

倾向于把wakee放在本核上唤醒，顺便标记抢占

这样就可以在waker sleep时触发的那次系统调用返回时触发调度，刚好把wakee放上cpu执行

减少了额外的抢占开销，也减少了wakee被在各cpu上boucing的可能

当然如果waker用来sync_wake的唤醒方式，自己不睡，那也ok

wakee下次会等下个中断返回时候再抢占

无伤大雅

Notes：
抢占必须依赖调度，各种方式的入队抢占，都只是标记，实际调度发生都得依赖于调度，因此需要在系统调用或者中断返回中触发

# Reference
[why_wake_sync](https://stackoverflow.com/questions/16201468/purpose-of-wake-up-sync-wake-up-interruptible-sync-in-the-linux-kernel)
