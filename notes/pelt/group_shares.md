# 有关group_shares
linux系统中往往有多个cgroup

我们希望不同cgroup在调度中占据不同的权重

可以通过更改group_shares去达成目标，使得隶属于不同`task_group`的`cfs_rq`，能够在同一个核上分到不同的时间片

## 接口
```sh
/dev/cpuctl/<group_name>/cpu.shares
```

通过这个节点去改share值

![1679493678869](https://user-images.githubusercontent.com/31315527/226928286-21e289cf-67eb-4ae0-8a1f-979a091134a7.png)

实际调用的函数是这个，tg的shares一改，tg所拥有的cfs_rq的都得做层级更新

最后都绕不开`update_cfs_group`

## 流程
核心函数是`update_cfs_group`，重计算当前cfs_rq的权重

![1679494011856](https://user-images.githubusercontent.com/31315527/226929667-1a522fd8-1fe3-4fe3-9844-e50a28c4b233.png)

其调用路径如此

三种情况：**出入队**、**tick时负载更新**、**group的share被改了**

上述3中event，都会触发group的load.weight的更新

![1679494144321](https://user-images.githubusercontent.com/31315527/226930347-52bd8b9c-c490-40b5-8cf2-3764d73f071c.png)

其核心流程也简单，先重计算shares(这玩意和load.weight同量纲)，然后走reweight的流程

## 核心算法
核心算法指shares重计算这部分

![1679494347947](https://user-images.githubusercontent.com/31315527/226931270-8e7c54a0-d2de-4b01-b6dd-68baa34ae484.png)

 $\frac{load}{tg_weight} * tg_shares$
 
 test


## 作用
## Reference
