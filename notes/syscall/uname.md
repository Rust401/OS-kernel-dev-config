# 拿内核信息uname

也是个syscall，在`kernel/sys.c`

<img width="668" alt="1705498984305" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/a48351a7-658b-489a-bb92-5d39fbeec31a">

本质把utsname()下的数据丢回用户态

<img width="449" alt="1705499031635" src="https://github.com/Rust401/OS-kernel-dev-config/assets/31315527/4fe60c5a-0368-4693-9843-f11a6d84d743">

完事

