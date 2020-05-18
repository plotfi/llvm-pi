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


## Step 3 (Build llvm-project including clang, lld, and Aarch64 libc++ runtimes)
