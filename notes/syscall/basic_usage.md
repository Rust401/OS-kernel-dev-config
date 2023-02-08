# 如何使用syscall调用内核函数
经常会遇到某个内核符号是开放了syscall入口

比如

![1675842127476](https://user-images.githubusercontent.com/31315527/217465593-524ad1ee-e1e5-4d00-a93e-e6897d68d950.png)

那如何在用户态调用到这个函数`sched_setattr`呢

![1675842474625](https://user-images.githubusercontent.com/31315527/217466818-c2916343-a169-4db6-8b8a-261b5b46684e.png)


## 1.找到系统调用号

![1675842389687](https://user-images.githubusercontent.com/31315527/217466479-b3f20a94-e6fc-426a-8c25-f3ef7c09d4e0.png)

搜索加上前缀后的符号`__NR_sched_setattr`

![1675842516967](https://user-images.githubusercontent.com/31315527/217466965-1fa33a7f-d15e-4221-bbdf-c3acc79df251.png)

路径在`include/uapi/asm-generic/unistd.h`

那个274就是我们想要找的系统调用号，不同内核估计不一样

## 2.使用
![image](https://user-images.githubusercontent.com/31315527/217467887-e7c3b4ab-3a8b-4dd3-8daf-c2c0c773f047.png)

用这种模式封装下就好了
