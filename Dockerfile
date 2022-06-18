# Build Stage
FROM ghcr.io/evanrichter/cargo-fuzz:latest as builder

## Install dependencies
RUN apt update && apt install -y wget cmake build-essential ninja-build

## build llvm with ASAN
run mkdir -p /opt/llvm/
workdir /opt/
run wget https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.1/llvm-13.0.1.src.tar.xz
run tar xJf llvm-13.0.1.src.tar.xz
run cd /opt/llvm-13.0.1.src/ && \
    mkdir build && cd build && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_NO_DEAD_STRIP=ON \
        -DLLVM_USE_SANITIZER=Address \
        -DLLVM_PARALLEL_LINK_JOBS=1 \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_ENABLE_LTO=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm/ && \
    cmake --build . --target install
