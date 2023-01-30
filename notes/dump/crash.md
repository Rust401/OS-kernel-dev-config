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

# trace使能

这玩意是个crash的插件

可以看ringbuffer中的trace信息区辅助分析

[这篇blog](https://www.cnblogs.com/Linux-tech/p/14110330.html)里面有一些universal的介绍

总体流程：
1. 安装trace-cmd
2. 安装trace.so
3. 使用

## 安装trace-cmd
步骤在其官方github上已经详细描述
[github:trace-cmd](https://github.com/rostedt/trace-cmd)

装依赖
```
sudo apt-get install build-essential git pkg-config -y
sudo apt-get install libtracefs-dev libtraceevent-dev -y
```

如果装不了，需要手动编译`libtraceevent`和`libtracefs`
```
git clone https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git/
cd libtraceevent
make
sudo make install

git clone https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git/
cd libtracefs
make
sudo make install
```

前置搞完直接编译trace-cmd，不用纠结架构，直接上和server一样的x86-64的
```
make
sudo make install
```

## 安装trace.so
可以从这边获取源码
[github:crash-trace](https://github.com/fujitsu/crash-trace)

或者从[crash-github](https://github.com/crash-utility/crash)里面选7.2.9的tag

从`extensions`里面找trace.c，复制到本地crash的`extensions`目录下

```
make extensions target=ARM64
```

把产物trace.so放到和vmlinux和vmcore同目录下

## 使用
先导出
```
crash> extend trace.so
crash> trace dump -t trace.dat
crash> exit
```

然后解析
```
trace-cmd report trace.dat > trace.txt
```


# Reference
[crash-github](https://github.com/crash-utility/crash)

[crash使用参考-内核工匠](https://www.cnblogs.com/Linux-tech/p/14110330.html)
