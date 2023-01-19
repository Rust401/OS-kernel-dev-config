# vim compile


dependency:

```
sudo apt install -y git \
                 libatk1.0-dev \
                 libcairo2-dev \
                 libgtk2.0-dev \
                 liblua5.1-0-dev \
                 libncurses5-dev \
                 libperl-dev \
                 libx11-dev \
                 libxpm-dev \
                 libxt-dev \
                 lua5.1 \
                 python3-dev \
                 ruby-dev 
```

get source

```
git clone https://github.com/vim/vim.git
```

then enter source dir

```
python3-config --configdir  #optional
```

change last line's `/usr/local` if you want to install vim to a specific dir
```
./configure --with-features=huge \
--enable-multibyte \
--enable-rubyinterp=yes \
--enable-python3interp=yes \
--with-python3-command=$PYTHON_VER \
--with-python3-config-dir=$(python3-config --configdir) \
--enable-perlinterp=yes \
--enable-gui=gtk2 \
--enable-cscope \
--prefix=/usr/local
```

compile
```
make
```

install
```
sudo make install
```

## Reference
[vim-github](https://github.com/vim/vim)


