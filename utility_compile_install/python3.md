## Dependency
```sh
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
```

## Download
```sh
curl -O https://www.python.org/ftp/python/3.9.1/Python-3.9.2.tar.xz
```

## unzip
```
tar -Jxvf Python-3.9.2.tar.xz
```

## compile
```
./configure --prefix=/home/ruty/bin --enable-optimizations
make
make install
```

## Reference
[zhihu-python3.8](https://zhuanlan.zhihu.com/p/101953103)
