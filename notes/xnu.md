# 架构图
![a23e4052c8822bdc65a03c87c9f4576](https://user-images.githubusercontent.com/31315527/204992060-17b58881-bcdf-4011-8b3d-10ca57b8a9f2.png)

这是个混合内核，主要由mach和FreeBSD拼接而成。调度部分在mach里面，syscall，posix接口这部分，在BSD部分

# Reference
[darwin-xnu-github](https://github.com/apple/darwin-xnu)

[apple-opensource](https://opensource.apple.com/releases/)

[xnu-arch](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/Architecture/Architecture.html)

[mach-scheduling](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/scheduler/scheduler.html#//apple_ref/doc/uid/TP30000905-CH211-BEHJDFCA)

