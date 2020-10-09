#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# To fully customize the contents of this image, use the following Dockerfile instead:
# https://github.com/microsoft/vscode-dev-containers/tree/v0.117.1/containers/ubuntu-18.04-git/.devcontainer/Dockerfile
# FROM ubuntu:focal
FROM swift:focal

# ** [Optional] Uncomment this section to install additional packages. **
#
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && export GCC_VERS=10 \
    && apt install -y --no-install-recommends \
               binutils gnupg2 libc6-dev libcurl4 libedit2 \
               iputils-ping traceroute \
               libgcc-9-dev libpython2.7 libsqlite3-0 libstdc++-9-dev libxml2 libz3-dev pkg-config tzdata zlib1g-dev \
               cmake ninja-build clang clang-format clangd clang-tidy lldb lld cgdb gcc g++ vim cargo htop tmux git curl \
               python3-distutils expect net-tools di tig wget netcat rsync ca-certificates sudo less npm nodejs unzip \
               build-essential crossbuild-essential-arm64 libgcc-s1-arm64-cross openssh-server tinc \
               libstdc++-$GCC_VERS-dev-arm64-cross libstdc++6-arm64-cross \
               libgcc1-arm64-cross libgcc-$GCC_VERS-dev-arm64-cross \
    && cd \
    && mkdir -p sysroots/aarch64-linux-gnu/usr \
    && mkdir llvm-project-build \
    && mkdir llvm-test-suite-build \
    && mkdir toolchain \
    && cd sysroots/aarch64-linux-gnu/usr \
    && cp -r -v -L /usr/aarch64-linux-gnu/include /usr/aarch64-linux-gnu/lib . \
    && cd lib \
    && cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/*gcc* . \
    && cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/*crt* . \
    && cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/libsupc++.a . \
    && cp -r -v -L /usr/lib/gcc-cross/aarch64-linux-gnu/$GCC_VERS/libstdc++*  . \
    && cd ../../ \
    && mkdir tmp \
    && cd tmp \
    && export LIBCRYPT_URL="http://ports.ubuntu.com/ubuntu-ports/pool/main/libx/libxcrypt/" \
    && curl $LIBCRYPT_URL 2>&1 | grep -oh "\"libcrypt-dev.*arm64.deb\"" | sort -nr | head -n1 | xargs -I% wget $LIBCRYPT_URL/% \
    && dpkg-deb -R libcrypt-dev*arm64.deb . \
    && rm -rf usr/share libcrypt-dev*arm64.deb DEBIAN \
    && rsync -av usr ../ \
    && cd .. \
    && rm -rf tmp \
    && ln -s /usr/bin/lld-link-10 /usr/bin/lld-link \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && cargo install ripgrep \
    && cargo install fd-find \
    && cargo install exa \
    && cargo install bat \
    && cargo install sccache \
    && cd \
    && git clone https://github.com/plotfi/dotfiles.git \
    && ln -s ~/dotfiles/gitconfig ~/.gitconfig \
    && ln -s ~/dotfiles/tmux.conf ~/.tmux.conf \
    && echo "source ~/dotfiles/bashrc" >> ~/.bashrc \
    && ln -s ~/dotfiles/vim ~/.vim \
    && ln -s ~/dotfiles/vim/init.vim ~/.vimrc \
    && mkdir ~/Tools \
    && ln -s ~/toolchain ~/Tools/clang+llvm \
    && git clone http://github.com/plotfi/llvm-pi.git \
    && git clone http://github.com/plotfi/llvm-win.git \
    && git clone http://github.com/plotfi/LLVM-Runtimes-Builds.git \
    && git clone --depth 1 https://github.com/autozimu/LanguageClient-neovim.git \
    && cargo install --path ./LanguageClient-neovim/ \
    && git clone http://github.com/llvm/llvm-project \
    && git clone http://github.com/apple/swift \
    && bash -x ~/llvm-pi/configure-toolchain.sh \
    && bash -x ~/llvm-pi/create-symlinks.sh \
    && curl  https://codeload.github.com/compiler-explorer/compiler-explorer/zip/6cd1fab18f909cdcddd9f0528ec6b457b389b155 -o compiler-explorer.zip \
    && unzip compiler-explorer.zip \
    && rm compiler-explorer.zip \
    && mv compiler-explorer-* compiler-explorer \
    && cp ~/llvm-pi/c++.defaults.properties ~/compiler-explorer/etc/config/c++.defaults.properties \
    && git clone https://github.com/tpoechtrager/cctools-port.git \
    && git clone https://github.com/tpoechtrager/apple-libtapi.git \
    && chmod 755 ~/llvm-pi/*.sh
ENV DEBIAN_FRONTEND=dialog

