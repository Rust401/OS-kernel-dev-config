# compile
from [llvm-github](https://github.com/llvm/llvm-project) select a fit release tag
```
git clone https://github.com/llvm/llvm-project.git
```

**make sure you checkout to a release branch!!!**

```
cd path/to/llvm-project

mkdir build 

cd build

cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/path/to/your/llvm -G "Unix Makefiles" ../llvm

make -j200

make install
```

notice the `-DCMAKE_INSTALL_PREFIX`

bin installed in `/path/to/your/llvm/bin`

lib installed int `/path/to/your/llvm/lib`

Note: For subsequent Clang development, you can just run make clang.

# Reference
[llvm-github](https://github.com/llvm/llvm-project)

[llvm-getting-started](https://clang.llvm.org/get_started.html)
