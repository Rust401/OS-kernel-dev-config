# ssh跳转
## 先说下有什么需求
公司有个`高性能服务器`，只能内网访问。

但公司内网里面还有一些`低性能服务`器，**可以访问上面说得那个高性能服务器**，且它们拥有**公网ip**。

**我想在家里访问这个高性能服务器**
## 怎么办
用OpenSSH的`ProxyJump`，原理就是个包转发

先看下SSH的版本

```sh
ssh -V
```

7.3以上版本才可以用
```
ssh USERNAME_TARGET@IP_TARGET -p PORT_TARGET -J USERNAME_JUMPER@IP_JUMPER:PORT_JUMPER
```
举个例子
```
ssh private_server@1.1.1.1 -p 2222 -J jumper@2.2.2.2:22
```
`private_server`和`1.1.1.1`分别是内网服务器的用户和ip(跳板机才能访问到的)

`jumper`和`2.2.2.2`是跳板机的用户和ip(你能访问到)

`2222`和`分别是两边的端口`

输完那条ssh命令后，对面会先让你输入JUMPER的密码，再让你输入TARGET的密码

为了防止输入两次密码，可以在**两个机器上都把公钥配好**

## 怎么配公钥登录

### 更改服务器sshd属性
在**被ssh连接的server**上的`/etc/ssh/sshd_config`尾部添加这几行

```sh
PasswordAuthentication yes
RSAAuthentication yes
PubkeyAuthentication yes
```

### 将本机公钥添加到server白名单
本机公钥位于`~/.ssh/id_rsa.pub`，里面有写成一行的一串内容，大概长这样
![1659337630314](https://user-images.githubusercontent.com/31315527/182092050-b47dfca4-1aad-489f-82c6-27bb19ca0fe1.png)


不管用什么办法，把上面那一串内容append到**被ssh连接的server**的`~/.ssh/authorized_keys`中
![1659337822700](https://user-images.githubusercontent.com/31315527/182092566-047abe0f-777e-473f-af24-d0289b8c138a.png)

### 测试是否能连
把公钥在跳板机和内网服务器上都配好

执行一波

```
ssh USERNAME_TARGET@IP_TARGET -p PORT_TARGET -J USERNAME_JUMPER@IP_JUMPER:PORT_JUMPER
```

连上则ok

![1659338349404](https://user-images.githubusercontent.com/31315527/182094146-26897716-59e3-41ff-ba9d-1e8519343ea5.png)







