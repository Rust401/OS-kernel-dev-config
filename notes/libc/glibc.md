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
