## Dependency
```sh
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
```

## Download
```sh
curl -O https://www.python.org/ftp/python/3.9.16/Python-3.9.16.tar.xz
```

## unzip
```
tar -Jxvf Python-3.9.16.tar.xz
```

## compile
```
./configure --enable-shared --prefix=/home/ruty/bin/python3 LDFLAGS=-Wl,-rpath=/home/ruty/bin/python3/lib
make
make install
```

## Reference
[zhihu-python3.8](https://zhuanlan.zhihu.com/p/101953103)
