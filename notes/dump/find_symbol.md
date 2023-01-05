# 怎么找到出问题的代码究竟在哪？
## 如果有能反汇编的.o
```
aarch64-linux-gnu-objdump -D -l -g -S xxx.o > dude_test.txt
```

## 如果.o不能用，但有vmlinux
```
nm vmlinux | grep dude_symbol_name
```
先通过这样找到符号入口

然后**算一下偏移**

算完偏移之后

```
addr2line -fCpie vmlinux ffffffc0101d2c94
```

把你算出来的偏移替换其中那个地址就好了

## 有vmlinux也可以直接用gdb
```
aarch64-linux-gnu-gdb vmlinux
```
进去之后
```
disas /m symbol+100,symbol+200
```
这个100和200是偏移的起止，10进制的

符号比较短的话，直接
```
disas /m symbol
```
或
```
disas symbol
```

