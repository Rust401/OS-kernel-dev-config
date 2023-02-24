## Compile

```
git clone git://sourceware.org/git/glibc.git
cd glibc
git checkout glibc-2.32
mkdir build
cd build
export glibc_install="$(pwd)/install"
../configure --prefix "$glibc_install"
make -j `nproc`
make install -j `nproc`
```

## 重点
这玩意的历史包袱太重了，代码读起来也很累很扯

不如看小清新一点的[musl-libc](https://git.musl-libc.org/cgit/musl)

## Reference
[glibc](https://www.gnu.org/software/libc/)

[glibc-wiki](https://en.wikipedia.org/wiki/Glibc)
