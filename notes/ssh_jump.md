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

然后会让你先输入JUMPER的密码，再让你输入TARGET的密码

为了防止输入两次密码，可以在两个机器上都把公钥配好

## 怎么配公钥登录
