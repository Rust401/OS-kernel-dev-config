# Notes for Cmake
## For what
Use for generate "makefile"
## install
download
```sh
wget https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz
tar -xvf cmake-3.23.1.tar.gz
cd cmake-3.23.1
```
config && install
```
./bootstrap
make
make install
```
for install in specific path
use ```make DESTDIR=/path/for/bin install``` instead, and do not forget to add the path to `$PATH`
## reference
[cmake in github](https://github.com/Kitware/CMake)
[wiki](https://en.wikipedia.org/wiki/CMake)
