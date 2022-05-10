# 简明的termianl环境看代码的配置

## 前置（推荐）：
1. 配置terminal代理，为了能正常curl或clone一些网络资源
2. 替换shell为zsh（推荐）
3. 开启鼠标左键点击复制

## 配置vim
将以下内容添加到~/.vimrc
```vim
set number
set hlsearch
set statusline+=%f
set laststatus=2
set paste

set listchars=tab:>-,trail:-,extends:#,nbsp:-
set list

set noexpandtab
set tabstop=8
"-------------------setting for pathogen------------------
execute pathogen#infect()
syntax on
filetype plugin indent on

"-------------------setting for kernel format-------------
" 80 characters line
set colorcolumn=101
"execute "set colorcolumn=" . join(range(81,335), ',')
highlight ColorColumn ctermbg=Black ctermfg=DarkRed

" Highlight trailing spaces
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"-------------------setting for NERDTree-------------
nnoremap <F2> :NERDTreeToggle<CR>
" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"-------------------setting for row-column highlight------------
set cursorcolumn
set cursorline

highlight CursorLine   cterm=NONE ctermbg=black ctermfg=NONE guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black ctermfg=NONE guibg=NONE guifg=NONE
```
每项配置做了啥，都有相关注释

## 安装vim的插件管理工具，pathogen
[pathogen的介绍点这里看](https://github.com/tpope/vim-pathogen)

terminal中执行如下命令
```sh
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```
在`.vimrc`中添加以下语句（上述给的脚本中已包含），让vim打开文件时自动启动pathogen，加载相关插件
```
execute pathogen#infect()
syntax on
filetype plugin indent on
```

## 安装cscope maps
vim对cscope有默认支持，可以在命令模式下通过`:cs f g __schedule`之类的命令查到某个特定的symbol，但这还是不够方便，可以给cscope的查找行为映射快捷键，此外，该脚本还可以递归搜索上层路径，自动打开当前文件所在path的父路径中离的最近的cscope database

[cscope maps的介绍看这里](https://github.com/joe-skb7/cscope-maps.git)

terminal中执行
```sh
cd ~/.vim/bundle
$ git clone https://github.com/joe-skb7/cscope-maps.git ~/.vim/bundle/cscope-maps
```
装完这个插件后，我们就可以通过```ctrl```+```\```，后面跟一个```g```去找某个symbol的定义了

## 生成cscope database
我们先下个c或者cpp的代码仓，以libco为例

[libco](https://github.com/Tencent/libco)
先下载下来
```sh
cd /path/to/store/dude
git clone https://github.com/Tencent/libco
```
写一个libco cscope生成脚本
```sh
cd /path/to/libco
vim tags_gen.sh
```
里面填入如下内容
```sh
DUDE_PATH="/path/to/libco"
find $DUDE_PATH -name "*.h" > $DUDE_PATH/cscope.files
find $DUDE_PATH -name "*.cpp" >> $DUDE_PATH/cscope.files
cscope -b -k -q
echo "database generated"
```
执行生成脚本
```
sh tags_gen.sh
```
脚本就做了两件事
1. 依此找到工程下的的`*.h`文件和`*.cpp`文件，并将**其绝对路**径送入`cscope.files`
2. 根据cscope.files内的文件作为限定范围，生成索引用的数据库(这句```cscope -b -k -q```)、

至此，cscope的database就自动生成了，随意打开libco下的某个文件，比如`example_cond.cpp`，将光标停留在感兴趣的symbol上，通过```ctrl```+```\```后跟```g```的方式就可以找到其定义了，当然也可以在命令模式下通过```:cs f g symbol_you_care```列出索引，选择对应的数字找到其定义。

我们根据不同项目的目录结构，可以动态调整我们find文件的顺序（通常.h在前），或者忽略某类文件（驱动、不感兴趣的模块）

## 用于生成kernel索引的的cscope配置
```sh
#!/bin/bash

TARGET=$1
VALID="false"

#add new linux-kernel dir here
if [ $TARGET = "qcom414" ]; then
LNX_PATH="/home/ruty/ext/qcom414/msm-4.14"
VALID="true"
fi

if [ $TARGET = "oh510" ]; then
LNX_PATH="/home/ruty/ext/linux-kernel/linux"
VALID="true"
fi

if [ $TARGET = "rk3568" ]; then
LNX_PATH="/home/ruty/3568/kernel/linux/linux-5.10"
VALID="true"
fi

if [ $VALID = "true" ]; then

#find paths for files to be linked
echo start to generate cscope.files in $LNX_PATH
find $LNX_PATH                                                                     \
	-path "$LNX_PATH/arch/*" ! -path "$LNX_PATH/arch/arm64*" -prune -o         \
	-path "$LNX_PATH/include/asm-*" -prune -o                                  \
	-path "$LNX_PATH/tmp*" -prune -o                                           \
	-path "$LNX_PATH/Documentation*" -prune -o                                 \
	-path "$LNX_PATH/scripts*" -prune -o                                       \
	-name "*.[chxsS]" -print > $LNX_PATH/cscope.files
echo cscope.files generated !

#generate cscope database
echo change dir
cd $LNX_PATH
echo begin to generate cscope database
cscope -b -k -q
echo database generated in cscope.out
cd -
echo change dir back

fi
```
内核开发者往往会在电脑里塞各种内核，此时不如就留一份脚本，在脚本中配置常用内核的别名（如脚本中的`qcom414`）和路径```/home/ruty/ext/qcom414/msm-4.14```，并在`.zshrc`中添加alias，便可以在全局通过```csgen qcom414(内核路径对应的别名)```生成cscope的database了
```sh
alias csgen="sh /path/to/kernel/cscope/script/csgen.sh"
```
## 参考链接
[A Nasty Config Tutorial](https://stackoverflow.com/questions/33676829/vim-configuration-for-linux-kernel-development)


