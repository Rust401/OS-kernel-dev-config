# 粗略介绍
这玩意其实是个高级版gdb，普通gdb搞用户态程序

crash可以debug内核

# 下载及编译
随便找个目录

```
git clone https://github.com/crash-utility/crash.git
```

进去

```
make target=ARM64 
```

然后本目录下就会生成了crash

最好重命名成`crash-arm64`这种，方便区分

随便放个有PATH的目录就行

# 有关ko
插入ko
```
mod -s <moudle_name> xxxx.ko
```
or
```
mod -S /path/to/ko
```
后者是知道ko想以什么身份插入的

更多的迷信，就`help mod`看下

# trace.so使能

这玩意是个crash的插件

可以看ringbuffer中的trace信息区辅助分析

[这篇blog](https://www.cnblogs.com/Linux-tech/p/14110330.html)里面有一些universal的介绍

个人也尝试里面的方式去进行编译，但是没有成功

总体流程：
1. 安装依赖
2. 安装trace-cmd
3. 安装trace.so

第一步和第二步在一下博文里面已详细描述
[github:trace-cmd](https://github.com/rostedt/trace-cmd)

第三步参考的github是
[github:crash-trace](https://github.com/fujitsu/crash-trace)

当前可以正常编译出`trace.so`

但在crash中尝试load时报错

```
no commands registered: shared object unloaded
```

报错位置其实可以从crash的源码中找到，当前还未分析，pending....

![1673596619184](https://user-images.githubusercontent.com/31315527/212267963-77e52044-89b3-4f67-8521-978392d2df13.png)


# Reference
[crash-github](https://github.com/crash-utility/crash)

[crash使用参考-内核工匠](https://www.cnblogs.com/Linux-tech/p/14110330.html)
