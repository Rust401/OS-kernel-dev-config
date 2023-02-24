## phtread_create核心流程简析
![1677229267772](https://user-images.githubusercontent.com/31315527/221136720-bc15fe66-7e12-4bd9-9f0f-151bb40b331d.png)

本质上是那个个clone，再加一个`sched_setscheduler`

clone内部就是一个系统调用，对应的NR是220

![1677229361184](https://user-images.githubusercontent.com/31315527/221137055-b8786791-7c66-486a-b2e3-bb8073b6b90f.png)


![1677231142857](https://user-images.githubusercontent.com/31315527/221143493-03b07d24-3ce1-4611-8c18-f7fe3f721e2d.png)

内部就是`kernel_clone`了

![1677231028121](https://user-images.githubusercontent.com/31315527/221142982-29eed21d-1fe2-4742-8cec-dc4e6ec6ce33.png)





