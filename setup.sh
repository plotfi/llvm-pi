#!/bin/bash

apt update
apt install cmake ninja-build clang clang-format lldb lld gcc g++ vim cargo htop tmux git curl \
            python3-distutils expect net-tools di tig wget netcat rsync \
            build-essential crossbuild-essential-arm64 \
            libstdc++-8-dev-arm64-cross libstdc++6-arm64-cross libgcc1-arm64-cross libgcc-8-dev-arm64-cross

cd
mkdir -p sysroot/aarch64-linux-gnu/usr
mkdir llvm-project-build
mkdir llvm-test-suite-build
mkdir toolchain

cd sysroot/aarch64-linux-gnu/usr
cp -r -v -L /usr/aarch64-linux-gnu/include /usr/aarch64-linux-gnu/lib .

cd lib
GCC_VERS=`\ls /usr/lib/gcc-cross/aarch64-linux-gnu/ | tr ' ' '\n' | sort -nr | head -n1`
cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/*gcc* .
cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/*crt* .
cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/libsupc++.a .
cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/libstdc++*  .
cd ../../

mkdir tmp
cd tmp
LIBCRYPT_URL="http://ports.ubuntu.com/ubuntu-ports/pool/main/libx/libxcrypt/"
curl $LIBCRYPT_URL 2>&1 | grep -oh "\"libcrypt-dev.*arm64.deb\"" | sort -nr | head -n1 | xargs -I% wget $LIBCRYPT_URL/%
dpkg-deb -R libcrypt-dev*arm64.deb .
rm -rf usr/share libcrypt-dev*arm64.deb DEBIAN
rsync -av usr ../

git clone https://github.com/plotfi/llvm-rpi4.git
git clone http://github.com/llvm/llvm-project
git clone http://github.com/llvm/llvm-test-suite

cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_LLD=ON \
              -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
              -DCMAKE_ASM_COMPILER=clang -DCMAKE_INSTALL_PREFIX=./toolchain \
              -DLLVM_INSTALL_ROOT=./toolchain \
              -C./llvm-rpi4/llvm-rpi4.cmake \
              -S./llvm-project/llvm \
              -B./llvm-project-build

cmake -B./llvm-test-suite-build -DLLVM_INSTALL_ROOT=/root/toolchain/ -DRPI4_SYSROOT=/root/sysroots/aarch64-linux-gnu \
      -C./llvm-rpi4/llvm-test-suite-rpi4.cmake -C./llvm-test-suite/cmake/caches/O3.cmake ./llvm-test-suite

ninja -C./llvm-project-build
ninja -C./llvm-project/build install

cd llvm-test-suite-build
make -j16
cd


