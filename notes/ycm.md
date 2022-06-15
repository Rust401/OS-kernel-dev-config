# 配置YouCompleteMe
## 如果互联网访问是通畅的，走这个简明流程
### 安装依赖
```
apt install build-essential cmake vim-nox python3-dev
```
### 下载插件(默认vim插件管理已使能)
```
cd ~/.vim/bundle
git clone https://github.com/Valloric/YouCompleteMe.git
cd YouCompleteMe
git submodule update --init --recursive
```
### 编译 安装 配置

只安装c/c++相关的
```
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clangd-completer
```
全装
```
apt install mono-complete golang nodejs default-jdk npm
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
```
## 如果互联网访问不那么通常，比如在国内的云服务器上，或者自己的wsl上，走下面那个踩坑流程
### 安装依赖
```
apt install build-essential cmake vim-nox python3-dev
```
### 下载插件(默认vim插件管理已使能)
执行`git clone`和`git submodule update`时最好配上代理，毕竟submodule里面的依赖，很多是托管在美国本土的一些托管仓库的，并不一定在github，不设代理容易update失败
```
cd ~/.vim/bundle
git clone https://github.com/Valloric/YouCompleteMe.git
cd YouCompleteMe
git submodule update --init --recursive
```
### 编译插件
```
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clangd-completer
```
没配代理或者代理速度比较慢的，执行这部大概率报错，原因是clangd太大了，用python的download功能容易中途中断
```
vim ./third_party/ycmd/build.py
```
进到这里面，找到`DownloadClangd`这个函数
```python
1100 def DownloadClangd( printer ):
1101   CLANGD_DIR = p.join( DIR_OF_THIRD_PARTY, 'clangd', )
1102   CLANGD_CACHE_DIR = p.join( CLANGD_DIR, 'cache' )
1103   CLANGD_OUTPUT_DIR = p.join( CLANGD_DIR, 'output' )
1104
1105   target = GetClangdTarget()
1106   target_name, check_sum = target[ not IS_64BIT ]
1107   target_name = target_name.format( version = CLANGD_VERSION )
1108   file_name = f'{ target_name }.tar.bz2'
1109   download_url = ( 'https://github.com/ycm-core/llvm/releases/download/'
1110                    f'{ CLANGD_VERSION }/{ file_name }' )
1111
1112   file_name = p.join( CLANGD_CACHE_DIR, file_name )
1113
1114   MakeCleanDirectory( CLANGD_OUTPUT_DIR )
1115
1116   if not p.exists( CLANGD_CACHE_DIR ):
1117     os.makedirs( CLANGD_CACHE_DIR )
1118   elif p.exists( file_name ) and not CheckFileIntegrity( file_name, check_sum ):
1119     printer( 'Cached Clangd archive does not match checksum. Removing...' )
1120     os.remove( file_name )
1121
1122   if p.exists( file_name ):
1123     printer( f'[dude-debug] { file_name }' )
1124     printer( f'Using cached Clangd: { file_name }' )
1125   else:
1126     printer( f"Downloading Clangd from { download_url }..." )
1127     DownloadFileTo( download_url, file_name )
1128     if not CheckFileIntegrity( file_name, check_sum ):
1129       raise InstallationFailed(
1130         'ERROR: downloaded Clangd archive does not match checksum.' )
1131
1132   printer( f"Extracting Clangd to { CLANGD_OUTPUT_DIR }..." )
1133   with tarfile.open( file_name ) as package_tar:
1134     package_tar.extractall( CLANGD_OUTPUT_DIR )
1135
1136   printer( "Done installing Clangd" )
```
可以在1123行加个打印，再执行
```sh
/usr/bin/python3 ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py --clangd-completer --verbose
```
看下`clangd-14.0.0-x86_64-unknown-linux-gnu.tar.bz2`这玩意临时存放的位置，大概在
```
~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clangd/cache/
```

从[clangd下载地址](https://github.com/ycm-core/llvm/releases)里面手动下个对应版本的`clangd-14.0.0-x86_64-unknown-linux-gnu.tar.bz2`，放到上面的位置

重新执行
```
/usr/bin/python3 ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py --clangd-completer --verbose
```


