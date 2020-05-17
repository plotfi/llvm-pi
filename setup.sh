#!/bin/bash

apt update
apt install cmake ninja-build clang clang-format lldb lld gcc g++ vim cargo htop tmux git curl \
            python3-distutils expect net-tools di tig wget \
            libstdc++-8-dev-arm64-cross libstdc++6-arm64-cross libgcc1-arm64-cross libgcc-8-dev-arm64-cross
