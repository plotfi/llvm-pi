#!/bin/bash

apt update
apt install cmake ninja-build clang clang-format lldb lld gcc g++ vim cargo htop tmux git curl \
            python3-distutils expect net-tools di tig wget \
            build-essential crossbuild-essential-arm64 \
            libstdc++-8-dev-arm64-cross libstdc++6-arm64-cross libgcc1-arm64-cross libgcc-8-dev-arm64-cross

git clone https://github.com/plotfi/llvm-rpi4.git
git clone http://github.com/llvm/llvm-project
mkdir llvm-project/build
mkdir toolchain

cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_LLD=ON \
              -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
              -DRPI4_SYSROOT=/mnt/sysroots/aarch64-linux-gnu-pi4 \
              -DLLVM_INSTALL_ROOT=./toolchain \
              -C./llvm-rpi4/llvm-rpi4.cmake \
              -S./llvm-project/llvm \
              -B./llvm-project/build

ninja -C./llvm-project/build
ninja -C./llvm-project/build install
