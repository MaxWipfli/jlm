FROM ubuntu:24.04 AS base

ARG LLVM_VERSION=18

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/lib/llvm-${LLVM_VERSION}/bin:${PATH}

# Keep the LLVM/MLIR packages in sync with the project's GitHub Actions.
# apt.llvm.org's Jammy LLVM 18 repository is also the repository used by CI.
# Like CI, expose both MLIR's versioned library filename and its unversioned
# linker alias in the default system linker path.
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        build-essential \
        cmake \
        git \
        ninja-build \
        pkg-config \
        python3 \
        python3-pip \
        verilator \
        wget \
    && install -d -m 0755 /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/apt.llvm.org.asc \
        https://apt.llvm.org/llvm-snapshot.gpg.key \
    && echo "deb [signed-by=/etc/apt/keyrings/apt.llvm.org.asc] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${LLVM_VERSION} main" \
        > /etc/apt/sources.list.d/llvm.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        clang-${LLVM_VERSION} \
        libgtest-dev \
        libmlir-${LLVM_VERSION}-dev \
        llvm-${LLVM_VERSION}-dev \
        mlir-${LLVM_VERSION}-tools \
    && rm -rf /var/lib/apt/lists/*

RUN if [ ! -f /usr/lib/x86_64-linux-gnu/libMLIR.so ]; then \
        ln -s /usr/lib/llvm-${LLVM_VERSION}/lib/libMLIR.so.${LLVM_VERSION}* \
            /usr/lib/x86_64-linux-gnu/; \
        ln -s /usr/lib/llvm-${LLVM_VERSION}/lib/libMLIR.so.${LLVM_VERSION}* \
            /usr/lib/x86_64-linux-gnu/libMLIR.so; \
    fi

RUN python3 -m pip install --no-cache-dir --break-system-packages "lit~=${LLVM_VERSION}.0"

# Build the CIRCT revision selected by scripts/build-circt.sh in a temporary build environment
FROM base AS circt-builder

WORKDIR /build/jlm

COPY scripts/build-circt.sh scripts/build-circt.sh

RUN ./scripts/build-circt.sh \
        --build-path /build/circt \
        --install-path /opt/circt

# Create final Docker image using base image + CIRCT installation
FROM base AS development

WORKDIR /workspace/jlm

COPY --from=circt-builder /opt/circt /opt/circt

CMD ["bash"]
