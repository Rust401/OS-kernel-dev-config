# 不得不引入的refcount
## 概括下
这个问题的关键是**保证性能的前提下，如何保证并发访问下对对象内存的释放**，拍脑袋了各种方案，最后演进到如今都在用的refcount方案。

## 遇到了啥问题
我有个`idr`表，用来保存每个app的权限管控信息`auth`，用app的`uid`作key，value是`auth`指向auth对象的指针

idr表有增删改查的各种接口

这个`auth`会被各种task并发访问

所以问题来了，存在这样一种情况：

某个task都拿到了自己所属uid的`auth`的指针。此时，idr表对这条auth做了一个delete操作，从idr中删除，并kfree(auth)。那么该task所拿到的auth就变成了野指针。

## 初版，全加大锁
当然，我们完全可以对`auth`的访问加一把锁，拿锁之后再去从`idr`表里拿指针。而要执行kfree之前，我们也要拿到一把锁
```c
main:
  lock()
  auth *dude = idr_remove(uid);
  kfree(dude);
  unlock();

task:
  lock();
  auth *dude = idr_find(); 
  do_sth_to_auth(dude);
  unlock();
```
直接加大锁固然很安全，但是并发情况下的性能会很差，当系统中同时有多个task想要从idr表中找到自己的auth信息，整个就变成了串行操作。

## 第二版，auth内部加一个小锁
为了解决并发问题，我们尝试用一把小锁去保护每个`auth`对象，比如
```
struct auth {
  ...
  lock auth_lock;
  ...
};
这样，我们我们的task，访问操作到不同auth时，可以并行执行
```
理想中的使用情况是这样的：
```
task:
  lock();
  auth *dude = idr_find();
  unlock();
  
  lock(auth->auth_lock);
  do_sth_to_auth(dude);
  unlock(auth->auth_lock);
```
但这并没有解决free时的问题，在`do_sth_to_auth`的过程中，dude可能已经变野指针了

main那边，无法做到先加小锁，再kfree，再释放小锁（因为这把小锁存在auth里面）

## 第三版，每个auth外部配一把小锁
```
task:
  lock();
  auth *dude = idr_find();
  unlock();
  
  lock(lock_for_dude);
  do_sth_to_auth(dude);
  unlock(lock_for_dude);
  
main()
  lock();
  auth *dude = idr_remove(uid);
  unlock();
  
  lock(lock_for_dude);
  kfree(dude);
  unlock(lock_for_dude);
```
task线程虽然不可能在`do_sth_to_auth`中突然发生指针失效的行为，但进临界区之前，task也感知不到什么时候指针已经野了

## 第四版，大小锁 + refcount
```
struct auth {
  ...
  lock auth_lock;
  refcount_t usage;
  ...
};

task:
  lock();
  auth *dude = idr_find(uid);
  if (!auth) {
    return;
  }
  refcount_inc(&dude->usage);  // get auth
  unlock();
  
  lock(&dude->auth_lock);
  do_sth_to_auth(dude);
  unlock(&dude->auth_lock);
  
  // put auth
  if (refcount_dec_and_test(&dude->usage)) {
    kfree(dude);
  }
  
 main:
  lock();
  auth *dude = idr_remove(uid);
  unlock();
  if (!dude)
    return;
    
  // put auth
  if (refcount_dec_and_test(&dude->usage)) {
    kfree(dude);
  }
```
这个&auth->usage在初始化时就会被设置成1，每当有task要用，引用计数自动加1，用完减回去，要delete时就-1，引用计数为0时执行真正的删除动作

最后这个第四版，完美解决了高并发下的性能问题，而且kfree很安全

但注意下几个要点
1. refcount需要在大锁内加
2. put的动作是原子的，可以放锁外
