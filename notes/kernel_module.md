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



