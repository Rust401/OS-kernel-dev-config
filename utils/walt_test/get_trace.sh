# start local ftrace
echo 0 > /sys/kernel/debug/tracing/tracing_on
cat /dev/null > /sys/kernel/debug/tracing/trace
echo "delete original trace content"

echo 1 > /sys/kernel/debug/tracing/tracing_on

echo "waiting ..."
sleep 2

echo "start running task!!"
/data/local/tmp/test &
ps_result=$(ps -A | grep test)
cur_pid=${ps_result:1:5}
echo "running task is ${cur_pid}"
taskset -p 8 ${cur_pid}
echo "${cur_pid} bind to cpu 3"

echo "trace start!!!!"
echo "wait 8 seconds ..."

for i in `seq 8`
do
	echo "${i}"
	sleep 1
done

echo "${cur_pid} killed!"
kill -9 ${cur_pid}

echo "done!!"
echo "trace end!!!"

echo 0 > /sys/kernel/debug/tracing/tracing_on

cat /sys/kernel/debug/tracing/trace > /data/local/tmp/hanpi_trace.txt
echo "trace file saved in /data/local/tmp/hanpi_trace.txt"
