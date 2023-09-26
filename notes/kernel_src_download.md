# Download and compile kernel src

## download from official
[kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git)


## checkout to target branch
```sh
git checkout -b <local_branch_name> origin/xxxxxx
```

example:
```sh
git checkout -b lts510 origin/linux-5.10.y
```


## config kernel
```sh
make ARCH=arm64 defconfig
```

## compile
```sh
make -j8 ARCH=arm64 CC=clang-12 CROSS_COMPILE=aarch64-linux-gnu-
```

