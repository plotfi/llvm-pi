#!/bin/bash

# GCC_VERS=10

apt update
apt install cmake ninja-build clang clang-format lldb lld gcc g++ vim cargo htop tmux git curl \
            python3-distutils expect net-tools di tig wget netcat rsync \
            build-essential crossbuild-essential-arm64 libgcc-s1-arm64-cross \
            libstdc++-$GCC_VERS-dev-arm64-cross libstdc++6-arm64-cross \
            libgcc1-arm64-cross libgcc-$GCC_VERS-dev-arm64-cross

cd
mkdir -p sysroots/aarch64-linux-gnu/usr
mkdir llvm-project-build
mkdir llvm-test-suite-build
mkdir toolchain

pushd .
cd sysroots/aarch64-linux-gnu/usr
cp -r -v -L /usr/aarch64-linux-gnu/include /usr/aarch64-linux-gnu/lib .

cd lib
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
cd ..
rm -rf tmp
popd
