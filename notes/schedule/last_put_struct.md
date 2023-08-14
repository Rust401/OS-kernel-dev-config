## 最后一次put_task_struct

调用栈
```sh
do_exit=>
  do_task_dead=>
    __schedule=>
      context_switch=>
        finish_task_switch=>
          put_task_struct_rcu_user
```

`do_exit`是一个export的接口，同时也是个syscall，如果用户态调到了，会走进来把某个线程清理掉，然后触发`__schedule`

上面描述的这个路径，是理论上最后一次的`put_task_struct`

可以在这之前判断`task`的的usage是否为1，如果不为1，只能说大概率有个特性多调用了`get_task_struct`
