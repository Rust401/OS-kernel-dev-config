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
vim ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py
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
1123     printer( f'Using cached Clangd: { file_name }' )
1124   else:
1125     printer( f'[dude-debug] { file_name }' )
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
可以在1125行加个打印，再执行
```sh
/usr/bin/python3 ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py --clangd-completer --verbose
```
根据`dude-debug`关键词，看下`clangd-14.0.0-x86_64-unknown-linux-gnu.tar.bz2`这玩意临时存放的位置，大概在
```
~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clangd/cache/
```

从[clangd下载地址](https://github.com/ycm-core/llvm/releases)里面手动下个对应版本的`clangd-14.0.0-x86_64-unknown-linux-gnu.tar.bz2`，放到上面的位置

重新执行
```
/usr/bin/python3 ~/.vim/bundle/YouCompleteMe/third_party/ycmd/build.py --clangd-completer --verbose
```
如果看到`Done installing Clangd`，说明装好了

## 使用
进到vim，命令模式输入
```
:YcmDebugInfo
```
如果命令能正确被解析，说明安装成功，如果解析不了，可能是.vimrc的配置有冲突

清空下vimrc里面不必要的命令，再试下

我这边是和`NERDTree`的配置冲突了
```
" autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
```
注释掉这行即可

### 用来看内核代码
这玩意不配置的话，写个普通的helloWorld倒是没问题，但是看内核就各种不行了，得搞定compile flags才行

好在内核的`./scripts/clang-tools/gen_compile_commands.py`可以用来生成`compile_commands.json`，这玩意记录了每个文件的编译选项

ycm可以通过`compile_commands.json`里的内容，找到对应文件`xxx.c`的编译选项并载入，这样就可以实现精确跳转+语法检查

`compile_commands.json`需要编译过一次之后才能生成，所以我们得先把内核目录编译一遍，需要先装下clang-12（老版本的clang不支持编译linux内核）

```sh
sudo apt-get install clang-12 --install-suggests
```

然后用clang-12编译内核，我这边用的arm64版本的，交叉编译工具过程中有缺失的就自己装
```sh
cd /path/to/kernel/dir

make CC=clang-12 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig

make -j8 CC=clang-12 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

生成`compile_commands.json`

```sh
cd /path/to/kernel/dir

./scripts/clang-tools/gen_compile_commands.py
```

执行完后，我们会发现
`compile_commands.json`在内核源代码的根目录生成，这个文件不用配置，ycm在初始化时会自动检测

```py
211   # Return a compilation database object for the supplied path or None if no
212   # compilation database is found.
213   def LoadCompilationDatabase( self, file_dir ):
214     # We search up the directory hierarchy, to first see if we have a
215     # compilation database already for that path, or if a compile_commands.json
216     # file exists in that directory.
217     for folder in PathsToAllParentFolders( file_dir ):
218       # Try/catch to synchronise access to cache
219       try:
220         return self.compilation_database_dir_map[ folder ]
221       except KeyError:
222         pass
223
224       compile_commands = os.path.join( folder, 'compile_commands.json' )
225       if os.path.exists( compile_commands ):
226         database = ycm_core.CompilationDatabase( folder )
227
228         if database.DatabaseSuccessfullyLoaded():
229           self.compilation_database_dir_map[ folder ] = database
230           return database
231
232     # Nothing was found. No compilation flags are available.
233     # Note: we cache the fact that none was found for this folder to speed up
234     # subsequent searches.
235     self.compilation_database_dir_map[ file_dir ] = None
236     return None
```
YCM插件中的`third_party/ycmd/ycmd/completers/cpp/flags.py`定义了这个函数，用来寻找compile_commands.json，感兴趣可以自己看下调用点

里面的语法检查是贼好用的，写内核代码速度可以快很多，而且边写就把编译问题fix了

如果一个1w行的文件有3行有语法错误的，想要快速找，肯定不能傻傻pageup和pagedown

.vimrc里面加入`let g:ycm_always_populate_location_list = 1`

这样每检查一个错误，ycm就会把这个错误的行数填到vim的location_list中

我们可以用`lnext`和`lprevious`在每个错误间跳转

讲道理，直接看[YCM官方文档](https://github.com/ycm-core/YouCompleteMe#quick-feature-summary)，各种option以及怎么用就一目了然了，有追求还是得仔细学一下

自此，随便开个kernel的.c文件，就会发现语法检查，自动补全，自动跳转功能都好用了。
