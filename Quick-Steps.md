# Quick Steps

* Before proceeding install Docker from https://www.docker.com 
* NOTE: Make sure to configure your Docker to give the instances more than the default 2GB of memory.
  * The build process will use more.
  ** Change it to 6-8GB at the least. 

## Step 1 (pull and run a llvm-pi docker instance)

```
docker pull plotfi/llvm-pi
docker run --privileged --interactive --tty --name llvm-pi plotfi/llvm-pi:latest /bin/bash
```

## Step 2 (build and install llvm-project toolchain)

```
DESTDIR=$HOME/toolchain ninja -C$HOME/llvm-project-build install
```

## Step 3 (clone, configure and build llvm-test-suite) 

Clone the latest llvm-test-suite, configure it, and build it using the newly built toolchain:

```
git clone http://github.com/llvm/llvm-test-suite $HOME/llvm-test-suite
cmake -B$HOME/llvm-test-suite-build -DLLVM_INSTALL_ROOT=$HOME/toolchain/ \
      -DCMAKE_SYSROOT=$HOME/sysroots/aarch64-linux-gnu \
      -DCMAKE_C_FLAGS="-save-temps <additional_flags_for_your_changes>" \
      -C$HOME/llvm-pi/llvm-test-suite-rpi4.cmake \
      -C$HOME/llvm-test-suite/cmake/caches/O3.cmake \
      $HOME/llvm-test-suite
make -j8 -C$HOME/llvm-test-suite-build VERBOSE=1
```

The build artifacts for the llvm-test-suite should be at $HOME/llvm-test-suite-build
