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

# Reference
[crash-github](https://github.com/crash-utility/crash)

[crash使用参考-内核工匠](https://www.cnblogs.com/Linux-tech/p/14110330.html)
