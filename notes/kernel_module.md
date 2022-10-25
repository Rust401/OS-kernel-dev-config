# linux kernel module
## insmod插入分析
正式看代码前，先拍脑袋想下，如果让你自己去设计ko的插入流程，你大致会怎么做？

```txt
把ko文件读到内存 =>
    解析ko的layout =>
        校验ko里存的各项信息是否和我们的系统匹配 =>
            把ko里各section塞到内存的合适角落，使之成为内核的一部分 =>
                给各内存设置权限 =>
                    初始化ko =>
                        相关清理
```
                        
乍一看相当简单，有手就行。而实际上，ko就是这么插入的，相当trival

这里面有2个点特别重要：
1. **.ko这个elf文件里各section，最后被加载到了vm的哪个区域里去了？**
2. **如何给各section去赋权？**

第二个问题相对简单，我们先来看下
```c
__arm64_sys_init_module =>
        load_module =>
             complete_formation =>
                    module_enable_ =>
```
![d5e5933174561fd6a2040c3ecee772f](https://user-images.githubusercontent.com/31315527/197718434-8e65c593-62a6-42c4-9d4b-7b578b3b0b81.png)

这边先来看张图，`module`在内存里面是放在一起的，`text`用来放代码段，`ro`用来放只读数据，`ro-after-init`用来放初始化做完之后就不用的代码，最后的`writeable`用来放可读写的数据。

接下来看下实际的赋权代码

![adb274b0a195eaf186d8f8fd30111c7](https://user-images.githubusercontent.com/31315527/197720215-d8017a9f-fa47-46cf-8ae6-01fd642164ed.png)

主要对mod设置了3种权限：ro(只读)，nx(不许执行？)，x(可执行)

先看下`module_enable_ro`

![97df0cbb362df9ec9e05a1a0d018432](https://user-images.githubusercontent.com/31315527/197720819-cd6fa326-d10c-4bde-8d35-7766e5148a29.png)

给`core_layout`和`init_layout`的ro和text段设置了只读（如果是after_init的状况，还需要把`ro_after_init`段也设置成ro

这边肯定会有个疑问，**为啥要专门搞出一个init_layout和一个core_layout**，只搞一个layout不香吗？

这个先不管，继续往下看

![1666686210230](https://user-images.githubusercontent.com/31315527/197722493-d4b48d5c-5cba-4d24-8cfb-1244cceb1af8.png)

将ro和writable给赋予nx权限我理解，不让执行，为啥要给`core_layout`的的ro_after_init去nx权限？莫非core_layout里压根就不允许有用于init的代码？

![1666686436588](https://user-images.githubusercontent.com/31315527/197723310-c456a1a2-e281-476b-9de9-a3616763d5e9.png)

设置执行权限x的时候，只对text段生效

`before_init`的情况下上述流程走完之后，我们看下各section当前拥有的权限：

core_layout:
    text: x, ro
    ro: nx, ro
    ro-after-init: nx
    
init_layout:
    text: x, ro
    ro: nx, ro
    ro-after-init: NULL
    
看来对`ro-after-init`和`writable`没做啥管控











