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
