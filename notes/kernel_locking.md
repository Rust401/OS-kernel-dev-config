# Senarial for using kernel lock
[nasty_link](https://www.kernel.org/doc/htmldocs/kernel-locking/cheatsheet.html)

* If you are in a process context (any syscall) and want to lock other process out, use a mutex. You can take a mutex and sleep (copy_from_user*( or kmalloc(x,GFP_KERNEL)).

* Otherwise (== data can be touched in an interrupt), use spin_lock_irqsave() and spin_unlock_irqrestore().

* Avoid holding spinlock for more than 5 lines of code and across any function call (except accessors like readb).

![8230d955e3c21ac0c2b28a7684da3c8](https://user-images.githubusercontent.com/31315527/187341775-7fda5e1f-a08c-457a-bf4a-a406c9781740.png)
![f34b14aac59bb6cd4e83cecc3d7ad95](https://user-images.githubusercontent.com/31315527/187341789-9f146b0c-26be-40e0-843b-33523bcd9d41.png)
