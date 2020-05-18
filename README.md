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
