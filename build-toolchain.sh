#!/bin/bash
cd
git -C ./llvm-project fetch --all
git -C ./llvm-project reset --hard origin/master
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_LLD=ON \
              -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
              -DCMAKE_ASM_COMPILER=clang \
              -DCMAKE_INSTALL_PREFIX=/ \
              -DRPI4_CMAKE_SYSROOT=`pwd`/sysroots/aarch64-linux-gnu \
              -C./llvm-pi/llvm-rpi4.cmake \
              -S./llvm-project/llvm \
              -B./llvm-project-build

ninja -C./llvm-project-build
DESTDIR=`pwd`/toolchain  ninja -C./llvm-project-build install
