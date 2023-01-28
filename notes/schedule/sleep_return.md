# sleep的本质？
当调用sleep这个syscall时，系统究竟发生了什么？

能讲清楚这个，才算是对内核有了新的了解

# nanosleep分析
sleep是libc里一个函数，对应的底层syscall是`nanosleep`

![1674891104483](https://user-images.githubusercontent.com/31315527/215253349-f897e7c0-91dc-49dc-923b-2ad80b40e4f6.png)

![1674891135202](https://user-images.githubusercontent.com/31315527/215253371-8fc6539b-21c3-4403-8a58-fdd749ba2765.png)

上面两个只是调用入口

![1674891191219](https://user-images.githubusercontent.com/31315527/215253411-0e025fbe-dbb4-4c81-887a-ada4edb1bee2.png)

真正的精髓在这个红框里

某个用户态线A程通过syscall进入内核态，然后内核态里面走到`freezable_schedule()`

这里面是一个非抢占式的`__schedule`

`__schedule`内部会通过`context_switch`把A的栈保存好(此时栈顶函数就是__)，然后换另外一个哥们儿B执行

当切回A之后，`context_switch`会reload那个A的栈，然后从`__schedule`的内部继续执行

切回之后才能从系统调用返回

所以这里有个重点，线程是进去系统调用之类的玩意，卡在一个很深的地方X被调度切走，然后切回来之后，继续从原先卡住的X继续执行

# 总结
* sleep本质是触发了调度，`context_switch`是在内核态直接切走的
* 切回来时，返回到`switch_to`之后，继续执行






