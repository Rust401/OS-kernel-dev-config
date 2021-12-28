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
more infomations see taskset --help

## Syntax for a single-line while loop in Bash
while true; do; echo "dude"; sleep 2; done &

