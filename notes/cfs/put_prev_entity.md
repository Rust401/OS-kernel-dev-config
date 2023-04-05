# 有关put_prev_entity的一些碎碎念
经常看到`put_prev_entity`

但对里面的实现又觉得奇怪

<img width="749" alt="1680712480312" src="https://user-images.githubusercontent.com/31315527/230145911-cbb5186b-4cbb-4abb-86e3-9cc12642bb8e.png">

看名字是拿掉，为啥还要入队？

它还有个难兄难弟叫`set_next_entity`

看名字是放进来，里面却是出队

<img width="619" alt="1680712643972" src="https://user-images.githubusercontent.com/31315527/230146545-2fdb8dfa-bd94-42a8-8f74-2dda2fe1e6e4.png">

里面还要判断`on_rq`

所以它到底是干啥的？

## 一个可以自圆其说的猜想
**`put_prev_entity`是把在cpu上执行的任务放回红黑树**

**`set_next_entity`是把即将上cpu执行的任务从红黑树上拿掉**

至于`on_rq`，如果任务不是因为阻塞让出cpu的，那显然还在挂在rq上

此时的上下cpu，并不会影响`on_rq`的值




