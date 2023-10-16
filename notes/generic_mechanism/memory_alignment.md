## 有关内存对齐
<img width="774" alt="1697469983070" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/cc222f83-1af2-4019-b2b0-7d52709db284">

mutex的代码里面看到这句话，有点好奇

意思是说mutex的owner（是个指向task_struct的指针），它的低6位随便用，反正都是0

问题来了，为什么如此肯定 **一个指向task_struct的指针，其LSB的6bit一定为0呢**

后面发现task_struct本身是针对L1_CACHE_BYTES对齐的

也就是说，task_struct的首地址，必须能被**L1_CACHE_BYTES（arm64上默认是6bit）整除**

**整除就是没有余数呀，余数就是后面6bit呀**

所以，归根结底，task_struct自己躺的位置比较特殊。

## 顺便随便找两张图解释下内存对齐

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/38e1a506-cfb6-48d9-9204-3dffe6e24264)

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/5f26c8fa-64c1-4e06-9165-2f0c3bfd0a8f)

要用的时候研究下吧，直接打印也可以

主要是让cpu用尽可能少的次数捞到需要的数据




