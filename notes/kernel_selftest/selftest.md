# 编译kernel自带的测试套
首先要编出来

先进到kernel根目录
```
make ARCH=arm64 -C tools/testing/selftests TARGETS=pidfd
```

这个`TARGETS`就是

![1673314913223](https://user-images.githubusercontent.com/31315527/211442578-91b61fa7-bd69-41a3-909b-e2700c8d23c8.png)

上面这张图里各种子模块

(想全量编就把TARGETS去掉就行, 但一般只想跑感兴趣的子模块

编完之后会有

![1673315059561](https://user-images.githubusercontent.com/31315527/211442926-d0215094-1e86-489d-94c7-6059098f1997.png)

这种二进制，目标机器上执行就行了

如果想编x86的，ARCH那个变量改下就好

# Reference
[kernel self test](https://www.kernel.org/doc/html/v5.0/dev-tools/kselftest.html)
