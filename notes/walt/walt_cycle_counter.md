## 0x00正题

walt是个事件驱动的lt模型

以rq为主视角，看起来会更容易

rq上会有各种event发生，以触发load更新

两个event之间，需要做cycles的结算

## 0x01说起cycles，讲点铺垫

**负载的本质是能量消耗，cycles和能量消耗正相关，因此可表征能量消耗**

这里又能联想到ipc

整条链其实是这样的：

**能量->cycles->instructions->完成的工作**

这条链，其实也符合对封闭系统输入能量以获得熵减，其实跟人体工作原理也差不多

其中ipc无非就是`instructions`和`cycles`的比值

显然不同核有不同的ipc，执行不同的代码，也会有不同的ipc（甚至cpu在不同频点上，ipc也不同）

要么在能量->cycles转化这步提高点效率（制程+架构）

要么在cycles核instruction转化这步提高效率，即提高能效比（架构+软件逻辑）

提升能效比是永恒的关键

## 0x02回到正题

walt在event间的负载结算，用了cycles

![1677119644641](https://user-images.githubusercontent.com/31315527/220809178-c7367e21-fefd-462e-9ccd-ca88a9400324.png)

结算点在此

![1677119688936](https://user-images.githubusercontent.com/31315527/220809273-888d61eb-ca46-4a1a-b1bf-73457f3aaf5d.png)

核心逻辑如上

`cycles_delta`是event之间，这个rq上，跑过了多少个cpu_cycles

这里用cycles_delta/time_delta，能获取这段时间的平均freq

用平均freq/max_freq，再乘上该rq所属cpu的capacity

就得到了一个结算后的负载，即**两个event之间跑代码加工的信息，需要消耗这个cpu多少的能力**

另外插一句

task在计算demand更新时，用的是rq上的cycles

![1677120154598](https://user-images.githubusercontent.com/31315527/220810151-472b13ae-c079-4ba1-a95f-9714b88dca40.png)

详见`update_task_demand`

## 影响

最直观的影响，频点更新时不需要强制结算了

没cycles_counter的情况下，只能通过当前频点结合时间去换成load

假设频点变更时没结算，下回结算时用的那个频点，就不能表示这个阶段内的均值了

引起精度的下降

qcom对cycles_counter的引入，可以降低频点更新事件引发的walt负载更新

## Reference
[msm5.10-codeauora](https://source.codeaurora.org/quic/la/kernel/msm-5.10/)
