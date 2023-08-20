# rt mutex
## 这是个啥
首先当然还是个mutex，但**支持优先级继承（Priority Inheritance）**

简单概括就是说：**owner的优先级是所有waiter的max**。（一个task可能own若干的mutex，每个mutex都有若干个task block在上面）

从图论的角度也可以解释。

## 为什么出现



## 应用场景
## 实现机理
## 抽象
## 关键数据结构
## 关键代码路径
