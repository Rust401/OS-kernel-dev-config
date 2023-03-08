# 背景

一直有说法表明pelt视角里，一个task如果已经blocked了，那其负载会继续算在cfs_rq上

那说明task如果以sleep的方式dequeue，其task_se的负载不会直接从cfs_rq上摘掉(后面想想，是因为**并没有迁移事件发生**)

这点和walt一样（不如说是walt抄的pelt的实现）

首先`update_load_avg`这个函数，只是对各种负载表征值做结算用的！！！

dequeue_entity的负载更新流程中，只是做了一次结算，并没有想把se的pelt的统计从cfs_rq上拿掉的想法

![1678021341298](https://user-images.githubusercontent.com/31315527/222961970-1a5d174d-b4be-47d6-8422-4486abc6c761.png)

**cpu更改时，se的统计信息才会随着溜溜**

![1678021555207](https://user-images.githubusercontent.com/31315527/222962166-fde12bad-fe89-457a-8090-0a2d5d496dc9.png)

这边有点tricky，**detach和remove，虽然看着差不多，但其实是有区别的**

* remove只是先存起来，等到下次结算点时一并算
* detach可是当场直接拿走

**唤醒到别的核上时用remove（为什么？）**

**显式迁移时用detach**

**那个migrate_task_rq_fair是个重点，migrate不一定是在lb，可能只是在唤醒选核**

另外送一张wake的图

![e346eb4c66a0fa35072e6b1e9da86ef](https://user-images.githubusercontent.com/31315527/222963439-77119c6b-a7eb-4680-9ae7-4aa5f6dff322.png)















