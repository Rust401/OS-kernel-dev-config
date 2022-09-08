# Useful notes for kernel developer
## wsl2 terminal proxy
### v2ray allow connection from LAN
### stop nameserver auto update
Edit the `wsl.conf`
```
[network]
generateResolvConf = false
```
### reboot the wsl
run this command in elevated powershell

```
Get-Service LxssManager | Restart-Service
```
### specify nameserver
edit `resolv.conf`
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```
After we change `generateResolvConf` to `false`, the true file soft-linked by resolv.conf may disapper.
So recreat the disappered dude before edit `resolv.conf`
###

### add proxy
add these dudes into ~/.zshrc
```sh
# add for proxy
export hostip=$(ip route | grep default | awk '{print $3}')
export hostport=10808
alias proxy='
    export HTTPS_PROXY="socks5://${hostip}:${hostport}";
    export HTTP_PROXY="socks5://${hostip}:${hostport}";
    export ALL_PROXY="socks5://${hostip}:${hostport}";
    echo -e "Acquire::http::Proxy \"http://${hostip}:${hostport}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null;
    echo -e "Acquire::https::Proxy \"http://${hostip}:${hostport}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf > /dev/null;
'
alias unproxy='
    unset HTTPS_PROXY;
    unset HTTP_PROXY;
    unset ALL_PROXY;
    sudo sed -i -e '/Acquire::http::Proxy/d' /etc/apt/apt.conf.d/proxy.conf;
    sudo sed -i -e '/Acquire::https::Proxy/d' /etc/apt/apt.conf.d/proxy.conf;
'
```

### start proxy
run this dude in shell
```
proxy
```

### verify
```
curl https://google.com.hk
```

## bind a task with a CPU
bind task to target cpu
```
taskset -p -c <cpus> <pid>
taskset -pc 0,4-6,7 414
```
check which cpus are prefered by task
```
taskset -pc <pid>
taskset -pc 414
```
More infomations see `taskset --help`, actually see the manual page directly is more fancy.
Check the `utils/walt_test/timer.c` for usage in the actual scene.

```
# SYNOPSIS
taskset [options] mask command [command's args]
taskset [options] -p [mask] pid

# the mask if important

0x00000001
	is processor #0,

0x00000003
	is processors #0 and #1,

0xFFFFFFFF
	is processors #0 through #31,

32
	is processors #1, #4, and #5,

--cpu-list 0-2,6
	is processors #0, #1, #2, and #6.

--cpu-list 0-10:2
	is processors #0, #2, #4, #6, #8 and #10. The suffix ":N"
	specifies stride in the range, for example 0-10:3 is
	interpreted as 0,3,6,9 list.
```

## Syntax for a loop start n cfs tasks
```sh
for i in $(seq 1 400)
do
while true; do ((cnt++)); sleep 0.1; done &
cur_pid=$!
if [ ${i} -lt 4 ];then
chrt -f -p ${cur_pid} 1
echo ${cur_pid}" change to rt"
fi
done
```

## Syntax for a single-line while loop in Bash
```
while true; do; echo "dude"; sleep 2; done &
```

## Syntax for multi-threads fucking the system
```
for num in {1..200}
do
while true;do ((cnt++)); sleep 0.1;done &
done
```

## Don't reboot kernel when panic occurs
```
echo 0 > /proc/sys/kernel/panic
```

## change the printk level
```
cat /proc/sys/kernel/printk
```

## kernel buffer(in memory)
```
cat /proc/kmsg
```

## thread capacity check
```
cat /proc/<pid>/stats | grep Cap
```

## Dump frace when kenrel pancic occurs
```
echo 1 > /proc/sys/kernel/ftrace_dump_on_oops
```
## Trigger a kernel panic on purpose
```
echo 'c' > /proc/sysrq-trigger
```

## vim configuration for linux kernel development
[a nasty config](https://stackoverflow.com/questions/33676829/vim-configuration-for-linux-kernel-development)

## compile a arm64 linux kernel
pick a suitable config
```
cp path/to/config path/to/kernel/root/dir/.config
```
make menuconfig
```
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
```
make
```
make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

## objdump .o
```
aarch64-linux-gnu-objdump -D -l -g xxx.o > dude_test.txt
```

## zsh
```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
