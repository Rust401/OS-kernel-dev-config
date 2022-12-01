# 为什么要搞这个
在linux平台上归一化一套统一的qos

希望优雅地支持如下功能

1. 多维度的线程属性管控（时延、供给、时间片、选核）
2. 支持传递（mutex、sem、binder）
3. 插队支持
4. 调度属性支持、传递支持、插队支持做到多维度可配（全局、进程、线程粒度）
5. 新增调度属性易于拓展


`qos_entity`长下面这样

```
struct qos_entity {
  int owner;
  int qos_level;
  int attr_flag;
  int trans_flag;
  bool insert;
  bool is_trans;
};
```

per_task上维护一个`qos_entity`链表，一个task可能挂有n个`qos_entity`,由多种来源下发

qos_entity可在`task_struct之间传递`

# 一个简单的例子

有个线程，被设置了qos标签，那最终下发时，就会拿qos_entity，取其中的attr_flag和trans_flag，结合系统映射表，去算出最后真正生效的调度参数

# 一个有两个qos_entity的例子
一个线程，一个有3个执行阶段1-2-3。有两个qos下发源，一个是系统A，一个是系统B，系统A的qos标签，在线程整个生命周期都生效，系统B地qos标签，只在线程执行阶段2的qos时才生效

相当于阶段1只有A的qos，2有A和B两种qos,3有A的qos

整个过程一种会去下发3次qos，线程创建时，阶段2开始时，阶段2结束时

阶段2开始时，此时挂着两个qos_entity，实际下发的参数，取两个entity的交集，较大者胜

阶段2结束时，有一个qos_entity会被退出，此时又恢复回qosA的qos_entity，再以A的qos_eneity对应的属性下发一次调度参数

# 传递的例子
一旦传递发生，子线程会被挂上一个传递过来的qos_entity，会根据原entity和新entity的属性更改一次调度参数，传递结束时，又只剩一个源entity了，改回去

多级传递的情况下，同理

# 开发者可更改的qos_entity的属性
仅可设置level
插队、传递、支持的属性、由系统去指定

# 一些小总结
思想是，一个thread可以有n个qos_entity，分别来自不同的模块，或者传递

至于最后怎么生效，真正下发前，会拿各entity的规则算一下。
