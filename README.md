# Cross-build and deploy the llvm-test-suite for the RPI4.

Often when making changes to LLVM's aarch64 backend, inorder to get a LGTM to land changes you must build and run llvm's test suite on device. This guide will show how to build clang, llvm, lld, and the aarch64-linux compiler-rt and libc++ runtimes inorder to do this. This guide will standardize on Ubuntu 20.04 LTS for both the cross-building docker environment as well as the device deployment environment (RPI4).

## Step 1 (Create Docker Instance)

* First things first, install Docker: https://www.docker.com/
* Next, create a directory to share between your host system and the docker image:

```
cd /path/to/home/directory
mkdir share
```

* Pull the ubuntu docker repo:

```
docker pull ubuntu
```

* Finally, create your Ubuntu 20.04 LTS Docker instance while mapping your newly created 'share' directory to  '/mnt/share'
```
sudo docker run --privileged --interactive --tty --name ubuntu-llvm-test \
  --mount type=bind,source=`pwd`/share,target=/mnt/share  ubuntu:focal /bin/bash
```

## Step 2 (Install Dev Packages and setup Linux aarch64 sysroot)

* Before going any further, inside the newly created docker image, cd to root's home directory (we will be working out of /root inside of Docker) and clone the llvm-rpi4 repo:

```
cd
git clone https://github.com/plotfi/llvm-rpi4.git
```

* Now that we are inside our Docker instance of Ubuntu 20.04, we can install all of the devlopment packages and libaries needed to construct our sysroot and our cross compiler. To do this run the following:

```
# Sets the GCC Version. Latest currently on Ubuntu 20.04 is 10:
export GCC_VERS=10
cd
./llvm-rpi4/ubuntu-docker-presetup.sh
```

* The above installs a number of Ubuntu packages including cmake, clang, ninja, and various Gnu arm64 cross-build libraries.
* Once those packages are installed it will construct an aarch64 Linux sysroot at `/root/sysroots/aarch64-linux-gnu`
* You will also have build directories for `llvm-project-build`, `llvm-test-suite-build`, and `toolchain`.


## Step 3 (Build llvm-project including clang, lld, and Aarch64 libc++ runtimes)

* Now that we have our minimal sysroot we can build llvm-project. This is the same llvm-project you will be applying any of your patches to to determine any instruction count, instruction type, code size, size, and runtime deltas. We are building llvm, clang, lld, compiler-rt, compiler-rt runtimes for aarch64, libc++ runtimes for aarch64 and all the rest because we want to use LLVM's facilities as much as possible for testing and because we want as little dependence to our potentially haphazzardly constructed Gnu sysroot.
* To start first clone llvm-project:

```
cd
git clone http://github.com/llvm/llvm-project
```

* Now invoke cmake using the `llvm-rpi4/llvm-rpi4.cmake` cache file, don't forget to pass in the `RPI4_CMAKE_SYSROOT` for the Aarch64 Linux sysroot that was constructed earlier:

```
cd
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_LLD=ON \
              -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
              -DCMAKE_ASM_COMPILER=clang \
              -DCMAKE_INSTALL_PREFIX=/ \
              -DRPI4_CMAKE_SYSROOT=`pwd`/sysroots/aarch64-linux-gnu \
              -C./llvm-rpi4/llvm-rpi4.cmake \
              -S./llvm-project/llvm \
              -B./llvm-project-build
```

* Note that our install root has been set to /root/toolchain.
* Now build llvm-project with ninja and install it to /root/toolchain:

```
ninja -C./llvm-project-build
DESTDIR=`pwd`/toolchain  ninja -C./llvm-project-build install
```

We now have an llvm toolchain capable of building the llvm-test-suite for the Raspberry Pi 4.

# Step 4 (Build the llvm-test-suite for Aarch64 Linux):

* First, clone the llvm-test-suite:

```
git clone http://github.com/llvm/llvm-test-suite
```

* Next, built the llvm-test-suite using the `llvm-rpi4/llvm-test-suite-rpi4.cmake` cache file, the newly installed llvm toolchain, and provide the path to the Linux Aarch64 sysroot:

```
cd
cmake -B./llvm-test-suite-build -DLLVM_INSTALL_ROOT=`pwd`/toolchain/ \
      -DCMAKE_SYSROOT=`pwd`/sysroots/aarch64-linux-gnu \
      -DCMAKE_C_FLAGS="-save-temps" \
      -C./llvm-rpi4/llvm-test-suite-rpi4.cmake \
      -C./llvm-test-suite/cmake/caches/O3.cmake \
      ./llvm-test-suite
```

* Finally, build the llvm-test-suite:

```
make -j16 -C./llvm-test-suite-build VERBOSE=1
```
# Step 5 (Apply your new Clang/llvm/llvm-project/compiler-rt changes, rebuild llvm-project, rebuild llvm-test-suite):

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
      -C./llvm-rpi4/llvm-test-suite-rpi4.cmake \
      -C./llvm-test-suite/cmake/caches/O3.cmake \
      ./llvm-test-suite

make -j16 -C./llvm-test-suite-build-prime VERBOSE=1
```

# Step 6 (Lift the newly build llvm-test-suites off of the Docker instance for further analysis and device testing):

* Now that we are done building the llvm-test-suite both with an without our changes (llvm-test-suite-build and llvm-test-suite-build-prime artifacts), we can now rsync the artifacts off of the Docker container to our shared directory that we passed into the container earlier:

```
rsync -av llvm-test-suite-build  /mnt/share
rsync -av llvm-test-suite-build-prime  /mnt/share
```
* Now the test suite builds are in the `share` directory on your host systems home directory (ie probably ``/home/username/share` or `/Users/username/share` or `c:/Users/username/share`.

* These llvm-test-suite builds can now be used for device runs or just simple examination for code size or instruction count changes. 
