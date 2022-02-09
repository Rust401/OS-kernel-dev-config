#!/bin/bash
for i in $(seq 1 40)
do
	while true; do ((cnt++)); sleep 0.1; done &
	echo "process ${i} generated"
done

while true
do
	cur_max_cpus=$(( ( RANDOM % 4 )  + 1 ))
	echo $cur_max_cpus > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
	echo "cur max cpus change to "$cur_max_cpus
	sleep 2
done


