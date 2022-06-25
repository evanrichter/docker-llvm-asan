# Build Stage
FROM ghcr.io/evanrichter/cargo-fuzz:latest as builder

## Install dependencies
RUN apt update && apt install -y wget cmake build-essential ninja-build

## build llvm with ASAN
run mkdir -p /opt/llvm/
workdir /opt/
run wget https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.5/llvm-14.0.5.src.tar.xz
run tar xJf llvm-14.0.5.src.tar.xz
run cd /opt/llvm-14.0.5.src/ && \
    mkdir build && cd build && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_NO_DEAD_STRIP=ON \
        -DLLVM_PARALLEL_LINK_JOBS=1 \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm/
run cd /opt/llvm-14.0.5.src/build && \
    cmake --build . --target install-llvm-libraries
run cd /opt/llvm-14.0.5.src/build && \
    cmake --build . --target install-llvm-headers
run cd /opt/llvm-14.0.5.src/build && \
    cmake --build . --target install-llvm-config

from ghcr.io/evanrichter/cargo-fuzz:latest as built
copy --from=builder /opt/llvm/ /opt/llvm/
