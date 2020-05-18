set(RPI4_CMAKE_SYSROOT "/root/sysroots/aarch64-linux-gnu" CACHE STRING "")

set(LLVM_INSTALL_BINUTILS_SYMLINKS ON CACHE BOOL "")
set(LLVM_INSTALL_CCTOOLS_SYMLINKS ON CACHE BOOL "")
set(CLANG_LINKS_TO_CREATE clang++ clang-cl CACHE STRING "")
set(CLANG_DEFAULT_OBJCOPY "llvm-objcopy" CACHE STRING "")

set(RUNTIMES runtimes)
set(LLVM_ENABLE_RUNTIMES compiler-rt libcxx libcxxabi libunwind CACHE STRING "")
set(LLD_TOOLS lld CACHE STRING "")
set(CLANG_LIBS libclang libclang-headers libclang-python-bindings
    CACHE STRING "")
set(CLANG_TOOLS clang clangd clang-format clang-resource-headers clang-rename
                clang-reorder-fields clang-tidy modularize
    CACHE STRING "")

set(LLVM_TOOLCHAIN_TOOLS
      # Apple Stuff
      dsymutil
      dwp
      lipo
      # llvm stuff
      llvm-ar
      llvm-cov
      llvm-cxxfilt
      llvm-dwarfdump
      llvm-dwp
      llvm-lib
      llvm-lipo
      llvm-nm
      llvm-ifs
      llvm-objcopy
      llvm-objdump
      llvm-pdbutil
      llvm-profdata
      llvm-ranlib
      llvm-readobj
      llvm-size
      llvm-strings
      llvm-strip
      llvm-symbolizer
      llvm-undname
      # symlink version of some of above tools that are enabled by
      # LLVM_INSTALL_BINUTILS_SYMLINKS.
      addr2line
      ar
      c++filt
      ranlib
      nm
      objcopy
      objdump
      readelf
      size
      strings
      strip
      obj2yaml
      yaml2obj
    CACHE STRING "")

# Runtimes and Builtins for RPI4 cross compiling:
set(LLVM_BUILTIN_TARGETS aarch64-unknown-linux-gnu CACHE STRING "")
set(LLVM_RUNTIME_TARGETS aarch64-unknown-linux-gnu CACHE STRING "")
set(target aarch64-unknown-linux-gnu)
# Builtins:
set(BUILTINS_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(BUILTINS_${target}_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(BUILTINS_${target}_CMAKE_SYSTEM_PROCESSOR aarch64 CACHE STRING "")
set(BUILTINS_${target}_CMAKE_SYSROOT ${RPI4_CMAKE_SYSROOT} CACHE STRING "")
set(BUILTINS_${target}_CMAKE_C_FLAGS "" CACHE STRING "")
set(BUILTINS_${target}_LLVM_ENABLE_PER_TARGET_RUNTIME_DIR NO CACHE BOOL "")
# Runtimes:
set(RUNTIMES_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_SYSTEM_NAME Linux CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_SYSROOT ${RPI4_CMAKE_SYSROOT} CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_SHARED_LINKER_FLAGS "-fuse-ld=lld" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_MODULE_LINKER_FLAGS "-fuse-ld=lld" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_EXE_LINKER_FLAGS "-fuse-ld=lld" CACHE STRING "")
set(RUNTIMES_${target}_LLVM_ENABLE_ASSERTIONS ON CACHE BOOL "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI "libc++" CACHE STRING "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI_INTREE ON CACHE BOOL "")
set(RUNTIMES_${target}_CMAKE_C_FLAGS "" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_CXX_FLAGS "" CACHE STRING "")
set(RUNTIMES_${target}_COMPILER_RT_SANITIZERS_TO_BUILD "asan;cfi;tsan;ubsan_minimal"
    CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE STRING "")
set(RUNTIMES_${target}_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")

# Add all the libc++ runtimes and buildins to the list.
# Building the test suite against libstdc++ can be painful and buggy.
foreach(target ${LLVM_BUILTIN_TARGETS})
  list(APPEND RUNTIMES builtins-${target})
endforeach()
foreach(target ${LLVM_RUNTIME_TARGETS})
  list(APPEND RUNTIMES runtimes-${target})
endforeach()

set(LLVM_DISTRIBUTION_COMPONENTS
      ${CLANG_LIBS}
      ${CLANG_TOOLS}
      ${LLVM_TOOLCHAIN_TOOLS}
      ${LLD_TOOLS}
      ${RUNTIMES}
    CACHE STRING "")

set(LLVM_ENABLE_PROJECTS clang clang-tools-extra lld CACHE STRING "")
