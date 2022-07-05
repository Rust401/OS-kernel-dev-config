# QOS
# RTG权限管控
由SYSTEM下发，用来管控各app对RTG的ioctl接口的访问权限，约束不同app在不同状态下的行为。

主要由4个接口组成`auth_enable`、`auth_pause`、`auth_delete`、`auth_get`。

## auth_enable
### 函数声明
```c
int auth_enable(unsigned int uid, unsigned int ua_flag, unsigned int status);
```
### 描述
* app启动时调用：app添加一条权限管控的记录
* app切前台时调用：恢复app的qos相关操作权限，并将先前已申请过qos的属于该app的task的qos状态恢复
### 参数
* **uid**: 目标app的uid
* **ua_flag**: 目标app的权限控制flag
* **status**：app启动后的qos状态。0表示qos申请仅被缓存，不会生效，1表示qos申请会被立即生效
### 调用时机
* app启动
* app后台切前台
### 限制
* 只能由SYSTEM调用

