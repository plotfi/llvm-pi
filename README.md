# Cross-build and deploy the llvm-test-suite for AArch64.

Often when making changes to LLVM's AArch64 backend, inorder to get a LGTM to land changes you must build and run llvm's test suite on device. This guide will show how to build clang, llvm, lld, and the aarch64-linux compiler-rt and libc++ runtimes inorder to do this. This guide will standardize on Ubuntu 20.04 LTS (Update: we are using Swift focal-nightly based on Ubuntu 20.04 as a way to easily bundle swift) for both the cross-building docker environment as well as the device deployment environment (On to the Raspberry Pi 4).

The following step by step guide will show how to cross-build the llvm-test-suite for the Raspberry Pi 4. For step on how to setup the Raspberry Pi 4 itself for on-device runs of the llvm-test-suite, please seem [README-RPI4.md](README-RPI4.md).

## Pre Step

* Node: This repo is synced with the docker repo at https://hub.docker.com/r/plotfi/llvm-pi.
* Before proceeding install Docker from https://www.docker.com 
* If you'd like to see more detailed steps that can be reproduced outside of the Docker environment on Ubuntu 20.04 see [README-OLD.md](README-OLD.md).


## Step 1 (Install llvm-pi docker instance)

Now that you've installed Docker pull the image from Docker Hub:

```
docker pull plotfi/llvm-pi
```

Alternatively you can build the Docker image yourself:

```
git clone https://github.com/plotfi/llvm-pi.git
cd llvm-pi
docker build -t plotfi/llvm-pi:latest .
```

Now that you have your Docker image, run an instance of the image:

```
mkdir share
docker run --privileged --interactive --tty --name llvm-pi \
  --mount type=bind,source=share,target=/mnt/share \
  plotfi/llvm-pi:latest /bin/bash
```

Note that the share directory will be shared between the docker instance (at /mnt/share) and your host machine.

## Step 2 (clone and build llvm-project)

Update the llvm-project checkout and build the toolchain (the Dockerfile setup has already cloned and configured it for you):

```
cd
git -C ./llvm-project fetch --all
git -C ./llvm-project reset --hard origin/master 
ninja -C./llvm-project-build
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
      -DCMAKE_C_FLAGS="-save-temps" \
      -C./llvm-pi/llvm-test-suite-rpi4.cmake \
      -C./llvm-test-suite/cmake/caches/O3.cmake \
      ./llvm-test-suite
make -j8 -C./llvm-test-suite-build VERBOSE=1
```
# Step 4 (Apply your new Clang/llvm/llvm-project/compiler-rt changes, rebuild llvm-project, rebuild llvm-test-suite)

* Now we want to apply and build our changes to the llvm-project tree and use that to rebuild the llvm-test-suite.
* Before we start, the easiest way to proceed is to grab your diff from a review you've already posted to phabricator or from a link you've generated from a paste website like seashells.io.
* To do this, lets assume you've already put your diff into a patch called `mypatch.diff`. We can post this diff to seashells.io by doing the following:

```
$ cat mypatch.diff | nc seashells.io 1337
serving at https://seashells.io/v/PNHBFVpj
```

* Now the URL https://seashells.io/v/PNHBFVpj will have the context if the diff. Switching the /v/ to /p/ in the URL will produce a raw text output.
* To apply and build llvm-project with your patch simply do the following:

```
cd
curl https://seashells.io/p/some_hash | patch -d./llvm-project -p1
DESTDIR=`pwd`/toolchain-prime  ninja -C./llvm-project-build install
git -C ./llvm-project clean -fdx 
git -C ./llvm-project reset --hard origin/master 
```

* Now /root/toolchain-prime should be populated with a toolchain that has your changes.

* Proceed to rebuild the llvm-test-suite with your new changes to the compiler, linker, and/or runtimes by doing the following (make sure you add any new flags required to the `CMAKE_C_FLAGS`, these flags are inherited by  the `CMAKE_CXX_FLAGS` as well):

```
cd
mkdir llvm-test-suite-build-prime
cmake -B./llvm-test-suite-build-prime -DLLVM_INSTALL_ROOT=`pwd`/toolchain-prime/ \
      -DCMAKE_SYSROOT=`pwd`/sysroots/aarch64-linux-gnu \
      -DCMAKE_C_FLAGS="-save-temps <additional_flags_for_your_changes>" \
      -C./llvm-pi/llvm-test-suite-rpi4.cmake \
      -C./llvm-test-suite/cmake/caches/O3.cmake \
      ./llvm-test-suite

make -j16 -C./llvm-test-suite-build-prime VERBOSE=1
```

# Step 5 (Lift the newly build llvm-test-suites off of the Docker instance for further analysis and device testing)

* Now that we are done building the llvm-test-suite both with an without our changes (llvm-test-suite-build and llvm-test-suite-build-prime artifacts), we can now rsync the artifacts off of the Docker container to our shared directory that we passed into the container earlier:

```
rsync -av llvm-test-suite-build  /mnt/share
rsync -av llvm-test-suite-build-prime  /mnt/share
```
* Now the test suite builds are in the `share` directory on your host system. You can analyze them or run them on a Raspberry Pi 4 or other AArch64 Linux device for perf deltas.

# Step 6 (You're done)

* These llvm-test-suite builds can now be used for device runs or just simple examination for code size or instruction count changes.
* Check out [README-RPI4.md](README-RPI4.md) to see how to setup a Raspberry Pi 4 to actually run the llvm-test-suite builds you have lifted off of your Docker instance. 
