#!/bin/bash

ninja -C./llvm-project-build
DESTDIR=`pwd`/toolchain  ninja -C./llvm-project-build install
