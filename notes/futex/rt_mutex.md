# rt mutex
## 1. 这是个啥
首先当然还是个mutex，但**支持优先级继承（Priority Inheritance）**

简单概括就是说：**owner的优先级是所有waiter的max**。（一个task可能own若干的mutex，每个mutex都有若干个task block在上面）

从图论的角度也可以解释。

## 2. 为什么出现
是为了解决优先级反转问题，这个网图虽然很多（先盗一张），但我再赘述一遍：

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/cac3f62b-a04e-42da-99fa-892e7980ce30)

1. A、B、C三个线程，优先级A > B > C（意味A应该最先执行）
2. 某个lock被C持有，A拿不到锁被阻塞。
3. B优先级比C高，C在临界区内被B抢占。
4. A只能等B执行完，C出临界区，才能继续执行。

我们期望的执行顺序 A->B->C
实际的执行顺序B->C->A

这显然不行

因此需要把C在成为锁owner那段时间的优先级，提高到与锁waiter同样的程序，这种现象才可以避免

因此rt_mutex横空出世。

## 3. 应用场景
1. 内核里直接用的貌似不多
<img width="1017" alt="1692505543759" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/d2e8e8a7-15ab-4823-832c-de8e10b26ce4">

2. futex_pi
这个是我目前已知最多的应用场景，服务于用户态

## 实现机理
## 抽象
## 关键数据结构
## 关键代码路径
