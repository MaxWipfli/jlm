#!/bin/bash
set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
JLM_ROOT_DIR="$(realpath "${SCRIPT_DIR}/..")"

export PATH="${JLM_ROOT_DIR}/build:${PATH}"
cd "${JLM_ROOT_DIR}/usr/hls-test-suite"
make clean
make "$@"
