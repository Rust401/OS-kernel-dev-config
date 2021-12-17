# **Window Assitant Load Tracking**
## **Function Analysis**
### **void walt_sched_init_rq**✔
start_kernel->sched_init->**`walt_sched_init_rq`**

Initialize the dudes in rq. Almost all dudes here are given the value `zero`.

### **static void walt_init_once**✔
walt_sched_init_rq->**`walt_init_once`**. 

Called when rq on cpu0 is initializing. Initialize the irq_work and some global varible for walt such as `walt_cpu_util_freq_devisor`. 

### **int walt_proc_update_handler**❌
Use for handle group down-migrate and up-migrate about RTG. For pure walt, this function is no need.



