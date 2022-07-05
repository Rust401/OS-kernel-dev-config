# QOS
- [RTG权限管控](#rtg权限管控)
    - [auth_enable](#auth_enable)
    - [auth_delete](#auth_delete)
    - [auth_pause](#auth_pause)
    - [auth_get](#auth_get)
    - [auth_xxx使用举例](#auth_xxx使用举例)
- [QOS下发模块](#qos下发模块)
    - [qos_apply](#qos_apply)
    - [qos_leave](#qos_leave)
    - [qos_xxx使用举例](#qos_xxx使用举例)

qos模块主要分两部分，[RTG权限管控](#RTG权限管控)和[QOS下发模块](#QOS下发模块)
# RTG权限管控
由SYSTEM下发，用来管控各app对RTG的ioctl接口的访问权限，约束不同app在不同状态下的行为。

主要由4个接口组成[auth_enable](#auth_enable)、[auth_delete](#auth_delete)、[auth_pause](#auth_pause)、[auth_get](#auth_get)。

可以直接看[使用举例](#auth_xxx使用举例)

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
# auth_xxx使用举例
```c
/*
 * task can access all ioctl cmd of rtg
 * except the auth_manipulate
 */
#define AF_RTG_ALL                0x7fff

enum rtg_auth_status {
    AUTH_STATUS_CACHED = 0,
    AUTH_STATUS_ENABLE,
};

void start_app()
{
    unsigned int uid = 10086;
    unsigned int ua_flag = AF_RTG_ALL;
    unsigned int status = AUTH_STATUS_ENABLE;
    ...
    /* start rtg authroity control for app whose uid is 10086 */
    ret = auth_enable(uid, ua_flag, status);
    if (ret)
        pr_err("oops!")
    ...
}

void app_swap_to_front()
{
    unsigned int uid = 10086;
    unsigned int ua_flag = 0x7ff0;             //rtg cmd 1-4 are disabled
    unsigned int status = AUTH_STATUS_ENABLE;
    ...
    /* resume tasks' qos request and disable the rtg cmd 1-4 for this uid */
    ret = auth_enable(uid, ua_flag, status);
    if (ret)
        pr_err("oops!")
    ... 
}

void app_swap_to_background()
{
    unsigned int uid = 10086;
    ...
    /* temporary tasks' qos request */
    ret = auth_pause(uid);
    if (ret)
        pr_err("oops!")
    ... 
}

void app_quit()
{
    unsigned int uid = 10086;
    ...
    /* disable the app's authority control for RTG */
    ret = auth_delete(uid);
    if (ret)
        pr_err("oops!")
    ... 
}

void some_routine_want_know_app_status()
{
    unsigned int uid = 10086;
    unsigned int ua_flag;
    unsigned int status;
    ...
    /* disable the app's authority control for RTG */
    ret = auth_get(uid, &ua_flag, &status);
    if (ret)
        pr_err("oops!")
        
    printf("ua_flag=%x, status=%d\n", ua_flag, status);
    ... 
}

```

# QOS下发模块
由每个task自己下发，申请qos服务来保证cpu的供给。

task在前台时，qos请求能立马生效，task在后台时，qos请求仅会被缓存，待切回前台时再统一生效。

主要由2个接口组成[qos_apply](#qos_apply)、[qos_leave](#qos_leave)。

可以直接看[使用举例](#qos_xxx使用举例)
# qos_apply
### 函数声明
```c
int qos_apply(unsigned int level);
```
### 描述
* 为当前task申请qos服务。
* 如果task当前在前台，该qos请求立马生效，如果task在后台，qos请求仅被缓存，在下回切前台时再生效。
### 参数
* `level`: qos等级，1-5有效，数值越大，cpu供给程度越高
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* task运行时
### 限制
* 可由任意task调用
# qos_leave
### 函数声明
```c
int qos_leave();
```
### 描述
* 停止当前task的qos服务，并把task移出qos链表
### 参数
* 无
### 返回值
* 0表示返回成功，负值表示error
### 调用时机
* task运行时
### 限制
* 可由任意task调用
# qos_xxx使用举例
```c
void task_want_to_get_more_cpu_supply()
{
    ...
    ret = qos_apply(5);          //add self to RTG group
    if (ret)
        pr_err("oops!\n"); 
    ...
    ret = qos_apply(4);          //leave the RTG group and give self a latency nice
    if (ret)
        pr_err("oops!\n"); 
    ...
}

void task_dont_need_advanced_cpu_apply_anymore()
{
    ...
    ret = qos_leave();          //give self a latency nice
    if (ret)
        pr_err("oops!\n");
    ...
}
```
