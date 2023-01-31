# 调度核心轨迹
![355e00e0368f040af271ae6e5e82954](https://user-images.githubusercontent.com/31315527/215656911-5ef0b649-f2b7-493d-a914-960514e641e6.png)

其实重点就3个

* `prev` deactivate（如果是sleep的dq）
* `pick_next`
* 切换rq-curr
* `context_switch`

几个关键变量`on_rq/on_cpu`自己在这个图里仔细看下就好

可以查表看看调度路径中某个切片，各值是怎么变的，方便问题定位
