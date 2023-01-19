# compile
from [llvm-github](https://github.com/llvm/llvm-project) select a fit release tag
```
git clone https://github.com/llvm/llvm-project.git
```

```
cd path/to/llvm-project

mkdir build 

cd build

cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm

make
```

Note: For subsequent Clang development, you can just run make clang.

# Reference
[llvm-github](https://github.com/llvm/llvm-project)
[llvm-getting-started](https://clang.llvm.org/get_started.html)
