# Quick Steps

* Before proceeding install Docker from https://www.docker.com 
* NOTE: Make sure to configure your Docker to give the instances more than the default 2GB of memory. The build process will use more. Change it to 6-8GB at the least. 

## Step 1 (Install llvm-pi docker instance)

Now that you've installed Docker pull the image from Docker Hub:

```
docker pull plotfi/llvm-pi
```

Now that you have your Docker image, run an instance of the image:

```
mkdir share
docker run --privileged --interactive --tty --name llvm-pi \
  --mount type=bind,source=`pwd`/share,target=/mnt/share \
  plotfi/llvm-pi:latest /bin/bash
```

Note that the share directory will be shared between the docker instance (at /mnt/share) and your host machine.

## Step 2 (clone and build llvm-project)

Update the llvm-project checkout and build the toolchain (the Dockerfile setup has already cloned and configured it for you):

```
cd
DESTDIR=`pwd`/toolchain  ninja -C./llvm-project-build install
```

We now have an llvm toolchain capable of building the llvm-test-suite for the AArch64 Linux.

## Step 3 (clone and build llvm-test-suite) 

Clone the latest llvm-test-suite, configure it, and build it using the newly built toolchain:

```
cd
git clone http://github.com/llvm/llvm-test-suite
cmake -B./llvm-test-suite-build -DLLVM_INSTALL_ROOT=`pwd`/toolchain/ \
      -DCMAKE_SYSROOT=`pwd`/sysroots/aarch64-linux-gnu \
      -DCMAKE_C_FLAGS="-save-temps <additional_flags_for_your_changes>" \
      -C./llvm-pi/llvm-test-suite-rpi4.cmake \
      -C./llvm-test-suite/cmake/caches/O3.cmake \
      ./llvm-test-suite
make -j8 -C./llvm-test-suite-build VERBOSE=1
```

The build artifacts for the llvm-test-suite should be at ~/llvm-test-suite-build
