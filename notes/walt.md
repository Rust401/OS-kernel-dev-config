# 窗口辅助负载追踪（WALT）特性介绍


## 基本概念

WALT：Windows-Assist Load Tracing的缩写，一种负载追踪机制，用窗口来记录历史负载，用于调度、调频和负载均衡。


## 配置指导

### 使能WALT
打开相关配置项及依赖

启用CPU轻量级隔离，需要通过编译内核时打开相应的配置项及依赖，相关CONFIG如下：

```
CONFIG_SCHED_WALT
```

另有部分CONFIG被依赖：

```
CONFIG_SMP=y
```
## 相关接口

WALT提供了一些控制接口，位于/proc/sys/kernel
| 功能分类 | 接口名          | 描述                                       |
| ---- | ------------ | ---------------------------------------- |
| 控制接口 | sched_use_walt_cpu_util      | 是否用walt作为rq负载，1表示是，0表示否，默认值1                        |
|      | sched_use_walt_cpu_util     | 是否用walt作为task负载，1表示是，0表示关否，默认值1                    |
|      | sched_walt_init_task_load_pct    | 设置任务的初始walt负载大小的百分比，初始值15 |
|      | sched_cpu_high_irqload   | 设置判定cpu处于高中断负载状态的条件，初始值10000000，表示10ms |
