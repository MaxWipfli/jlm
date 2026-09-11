# JLM

> The upstream README from https://github.com/phate/jlm is available at [README_UPSTREAM.md](./README_UPSTREAM.md).

## Setup

The easiest way to set up the JLM build environment is to use the provided Docker image (see below).
For more detailed build instructions, see the [upstream README](./README_UPSTREAM.md).

### Docker

A Docker-based development environment is available.
Its supported is limited to the HLS backend.
The Docker image contains all necessary tools, with a pre-built CIRCT distribution available in `/opt/circt` in the container.

To build the Docker image (which may take a while to compile CIRCT), run the following command:
```sh
docker build -t jlm-hls .
```

To enter a temporary container with this repository mounted as a volume, run:
```sh
docker run --rm -it -v "$(pwd):/workspace/jlm" jlm-hls
```

To build JLM, run the following commands in the container:
```sh
./configure.sh --enable-hls=/opt/circt
make -j$(nproc) all
```

## HLS Test Suite

To run the HLS test suite, run the following commands in the container:
```sh
./configure.sh --enable-hls=/opt/circt
make -j$(nproc) all-without-tests
./scripts/run-hls-test.sh
```
On its first run, the script clones the pinned `hls-test-suite` repository into `./usr/hls-test-suite`.

For more fine-grained control over the test suite (e.g., running only particular tests), a bare-bones test script is available, which mostly just wraps `make` calls for the `./usr/hls-test-suite` subdirectory. To run it, execute:
```sh
./scripts/hls-test-suite-make.sh <make-target>
```

Example:
```sh
make -j$(nproc) all-without-tests
./scripts/hls-test-suite-make.sh -j$(nproc) run-base
```
