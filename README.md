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

## Address Queue Configuration

The address queue configuration can be changed by psasing the `-J--addrq-config=<config>` option to `jhls`.
Possible values for `<config>` are:
- `none`: disables address queues entirely (*NoQ* mode from R-HLS paper)
- `exact:<capacity>`: creates an address queue with the specified capacity
The default configuration is `exact:10`, which matches the behavior of the original implementation.

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

### Running Individual Tests

To run an individual test, use the target `cycle-compare/<test-category>/<test-name>`, e.g.:
```sh
./scripts/hls-test-suite-make.sh -j$(nproc) cycle-compare/dynamatic/gemver
```

## Troubleshooting

### Assertion Failure During Verilator Simulation: Memory Queue Not Empty

In some edge cases, the following assertion was failing during Verilator simulation:
```
void run_hls(void*, int32_t): Assertion `memory_queues[0].empty()' failed.
```

This has previously happened when the address queue is disabled and can be explained as follows:
- Without address queues, memory operations generally take longer to complete.
- If the last memory operation in a test is a read whose result is unused, it may not have completed by the time the kernel signals its exit.
- The Verilator simulation checks that all memory queues are empty at the end of the kernel execution, and if the last read has not completed, this assertion fails.

We believe this failure can be safely ignored for our purposes, so we have disabled it.
