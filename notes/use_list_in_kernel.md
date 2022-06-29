## kernel中list的使用
内核中的linkList，本质是在struct中专门开辟两个存指针的地址空间，用于跟同类数据结构联系起来，这个开启出来存指针的地方叫做`list_head`

这个概念比较像一个人隶属不同组织，比如某公司员工，某篮球队，某地政协人员。所以一个struct中可以拥有多个不同种类的`list_head`，可以通过不同种类的链表头去索引

用的时候需要一个头，可以这么定义
```c
struct list_head cluster_head;
```

struct内部的就可以这么定义
```c
struct task_struct {

...

#ifdef CONFIG_SCHED_RTG
	int rtg_depth;
	struct related_thread_group	*grp;
	struct list_head		grp_list;
#endif

...

#ifdef CONFIG_PREEMPT_RCU
	int				rcu_read_lock_nesting;
	union rcu_special		rcu_read_unlock_special;
	struct list_head		rcu_node_entry;
	struct rcu_node			*rcu_blocked_node;
#endif /* #ifdef CONFIG_PREEMPT_RCU */

#ifdef CONFIG_TASKS_RCU
	unsigned long			rcu_tasks_nvcsw;
	u8				rcu_tasks_holdout;
	u8				rcu_tasks_idx;
	int				rcu_tasks_idle_cpu;
	struct list_head		rcu_tasks_holdout_list;
#endif /* #ifdef CONFIG_TASKS_RCU */

#ifdef CONFIG_TASKS_TRACE_RCU
	int				trc_reader_nesting;
	int				trc_ipi_to_cpu;
	union rcu_special		trc_reader_special;
	bool				trc_reader_checked;
	struct list_head		trc_holdout_list;
#endif /* #ifdef CONFIG_TASKS_TRACE_RCU */

	struct sched_info		sched_info;

	struct list_head		tasks;
  
  ...
}
```

用之前一般得初始化，把`prev`和`next`都指向自己
```c
void init_clusters(void)
{
  ...
  INIT_LIST_HEAD(&cluster_head);
  ...
```

属于struct内部的自然也得在struct内存申请完毕后通过`INIT_LIST_HEAD(&list_head_in_dude)`初始化

要把哥们儿加进去，就`list_add(new, head)`或者`list_add_tail(new, head)`

要删哥们儿，就`list_del(dude_to_delete)`很神奇，都不用找到链的`list_head`，无脑的O1删除

一般用list_del_init更多，把`dude_to_delete`摘下来后，再init一把，免得出现新的麻烦

要遍历这个list，关注下iter和tmp就行
```c
static void
insert_cluster(struct sched_cluster *cluster, struct list_head *head)
{
	struct sched_cluster *tmp;
	struct list_head *iter = head;

	list_for_each_entry(tmp, head, list) {
		if (cluster->max_power_cost < tmp->max_power_cost)
			break;
		iter = &tmp->list;
	}

	list_add(&cluster->list, iter);
}
```
但这个遍历是没法一边遍历一边删的，但我们可以用`list_for_each_entry_safe`

例子见

```c
int authority_remove_handler(int id, void *p, void *para)
{
	struct rtg_authority *auth = (struct rtg_authority *)p;
	struct task_struct *tmp;
	struct task_struct *next;
	int i;

	raw_spin_lock(&auth->auth_lock);
	auth->status = AUTH_STATUS_DEAD;

	/* delete all p in auth->tasks[NR_QOS] */
	for (i = 0; i < NR_QOS; ++i) {
		list_for_each_entry_safe(tmp, next, &auth->tasks[i], qos_list) {
			tmp->in_qos = 0;
			list_del_init(&tmp->qos_list);
		}
	}
	raw_spin_unlock(&auth->auth_lock);

	kfree(auth);

	return 0;
}
```
内核中很多例子，可以随时参考，基本知道这些就能用了



