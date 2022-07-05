# QOS
# RTG权限管控
由SYSTEM下发，用来管控各app对RTG的ioctl接口的访问权限，约束不同app在不同状态下的行为。

主要由4个接口组成[auth_enable](#auth_enable)、[auth_delete](#auth_delete)、[auth_pause](#auth_pause)、[auth_get](#auth_get)。

# auth_enable
### 函数声明
```c
int auth_enable(unsigned int uid, unsigned int ua_flag, unsigned int status);
```
### 描述
* 为uid添加一条权限管控的记录
* 修改uid的权限管控flag
* 恢复uid所拥有的task的qos相关操作权限，并将先前已申请过qos的属于该uid的task的qos状态恢复
### 参数
* `uid`: 目标app的uid
* `ua_flag`: 目标app的权限控制flag
* `status`：app启动后的qos状态。0表示qos申请仅被缓存，不会生效，1表示qos申请会被立即生效
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* app启动
* app后台切前台
### 限制
* 只能由SYSTEM调用

# auth_delete
### 函数声明
```c
int auth_delete(unsigned int uid);
```
### 描述
* 重置uid所拥有task的qos状态，并删除uid关联的权限管控记录
### 参数
* `uid`: 目标app的uid
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* app退出
### 限制
* 只能由SYSTEM调用

# auth_pause
### 函数声明
```c
int auth_pause(unsigned int uid);
```
### 描述
* 暂停uid所拥有的task的qos状态
### 参数
* `uid`: 目标app的uid
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* app前台切后台
### 限制
* 只能由SYSTEM调用

# auth_get
### 函数声明
```c
int auth_get(unsigned int uid, unsigned int *ua_flag, unsigned int *status);
```
### 描述
* 获取当前uid的权限flag和status
### 参数
* `uid`: 目标app的uid
* `*ua_flag`: 目标app的权限控制flag指针
* `*status`：目标app的qos状态指针
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* 任意时刻
### 限制
* 只能由SYSTEM调用
