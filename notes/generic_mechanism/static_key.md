# static key
一般我们判断if/else，是在运行时动态去读某个值，然后再去决定走哪个分支的，这个过程中代码段都是些写死的

而static key可以做根据key的情况去动态**修改代码段**。

真正做到了数据和代码的统一：)

这样省去了不必要的分支判断

其实搞两个图就完全明白了

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/101b3331-c899-4fa1-842b-cabb0e6b3481)

红色这个地方就是可以动态更改的地方，至于是nop还是jump，一旦staic key改变，代码段的这个指令也会被改掉

![image](https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/de885b87-a271-436c-8cde-0a9cca2b1b67)

关联的数据结构可以参考这个，如果对源码感兴趣的情况下

## Reference

[kernel_doc](https://docs.kernel.org/staging/static-keys.html#:~:text=Static%20keys%20allows%20the%20inclusion,and%20a%20code%20patching%20technique.)

[static key interval](https://terenceli.github.io/%E6%8A%80%E6%9C%AF/2019/07/20/linux-static-key-internals)

[risc-v](https://crab2313.github.io/post/static-key/)

[还不错的文章](https://www.cnblogs.com/schips/p/the_mechanism_of_static-key_in_linux.html)


