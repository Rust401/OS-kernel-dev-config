## Compile

```
git clone https://github.com/bminor/glibc/tree/release/2.37/master
```

must build in another dir
```
mkdir build
cd build
```

prefix must be config
```
export glibc_install="$(pwd)/install"
../configure --prefix "$glibc_install"
make
make install
```

如果使用bear，确保`compile_commands.json`生成在合适位置
```
bear -o ../compile_commands.json make
```

## Notes
这玩意的历史包袱太重了，代码读起来也很累很扯

不如看小清新一点的[musl-libc](https://git.musl-libc.org/cgit/musl)

## Reference
[glibc](https://www.gnu.org/software/libc/)

[glibc-wiki](https://en.wikipedia.org/wiki/Glibc)
