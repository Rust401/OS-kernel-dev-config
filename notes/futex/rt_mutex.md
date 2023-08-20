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

## 4. 实现机理
先不看linux上的实现，我们不妨猜一下，这种逻辑结构要如何设计

先从task的角度出发（毕竟这是最要提升优先级的对象），得先知道：
* **我hold了哪些mutex？**
* **这hold的mutex，分别都阻塞了哪些task？**
* **每个mutex阻塞的task的最高优先级是多少(top_waiter是谁)？**
* **我最后该提升到什么优先级？**

上面是第一层逻辑，其实已经把整条链路梳理通了

第二层逻辑，就是从mutex的角度，需要知道啥(辅佐下，别较真)：
* **我被谁own了**
* **谁阻塞在我身上**
* **阻塞在我身上的哥们儿，优先级最高的是哪位（top_waiter）**

这样整个逻辑就很清晰了，系统中就两个重要角色：`task`和`mutex`。

task只需要知道它owner了哪几个mutex即可

mutex只要知道它的owner是谁，阻塞了谁，top_waiter是谁

这里给一张原始思路图

<img width="729" alt="1692507467433" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/bda7dd06-d034-4bce-a7a2-439199747d22">

先**不考虑最后实现的优雅及效率**，trival的角度来看，这个逻辑图便应如此

* task只要知道持有哪些mutex就好了
* mutex自己知道谁被自己block了，并且这些block的人中，优先级最高的是谁

途中的话，task持有了mutexA、B、C， topwaiter都已经指出来了。其中C的topwaiter的能力是最强的

所以task应该去把优先级对标成C的topwaiter的优先级

当然这个关系应该是可以支持实时更新的

假设有一个优先级比C的top-waiter还要高的东西阻塞在mutexC上了，那mutexC的topwaiter就得相应更新，然后顺带着mutexC的owner也应该受到波及，进而更新优先级

这是个trival的过程

## 5. 抽象
其实上面已经抽象的差不多了，这里顶多再引入一个概念：

**PI_CHAIN**

这也是一个trival的概念，上面的无非是一层，如果我们把task和mutex的关系多弄几层，这个就很清楚了

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/6f859fe8-652a-4fe0-be62-4ec0a16c9d66)

这个图估计看一眼也就明白了，task14突然给了一个很高的优先级，优先级先通过mutexE传播到task6，再通过mutexC传播到task0

标红色的那个，就是一条**PI_CHAIN**

## 6. 关键数据结构
1. `rt_mutex`
   
这就是那个神奇的锁的本体


<img width="822" alt="1692509958356" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/a099d1f3-829e-47e8-9f80-051dc1dc07f9">
* waiter就是所有阻塞在这这个mutex上的task
* owner就是mutex当前被持有的那个哥们儿

2. `rt_mutex_waiter`

讲道理，**这个才是最难理解的那个数据结的，它是task和mutex之间的桥梁**，一个task想要阻塞在一个mutex上，就需要先把自己包装成waiter

<img width="840" alt="1692510269159" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/74b113a9-5d82-4d1e-9800-d14b4a8822d6">

* tree_entry是waiter挂在mutex的waiter上用的钩子
* pi_tree_entry是waiter挂在阻塞它的task所拥有的树上的钩子
* task_struct自然是这个waiter的本体

3. `task_struct`

<img width="775" alt="1692509704132" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/19441b89-0fe2-414c-aaf7-52a22c538f00">

* **pi_waiter**指所有被该task所阻塞的waiter
* 所有waiter里面的topwaiter的task_struct
* 阻塞该task的task

## 7. 关键代码路径
这个优先级放低吧，看到好的再贴出来

## Reference

[wowo](http://www.wowotech.net/kernel_synchronization/futex.html)

[zhihu](https://zhuanlan.zhihu.com/p/372146187)

[kernel doc](https://docs.kernel.org/locking/rt-mutex-design.html)


