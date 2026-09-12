#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd -P )"
source "$SCRIPT_DIR/dynamatic_utils.sh"

# ============================================================================ #
# Variable definitions
# ============================================================================ #

# Script arguments
KERNEL_IDENT="$1"
KERNEL_NAME="$(basename "$KERNEL_IDENT")"

# Directories
EVAL_DIR="$(realpath "$SCRIPT_DIR/../")"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../../")"
HLS_TEST_SUITE_DIR="$ROOT_DIR/usr/hls-test-suite"
HLS_TEST_SUITE_BUILD_DIR="$HLS_TEST_SUITE_DIR/build"

# ============================================================================ #
# Assemble HDL files
# ============================================================================ #

KERNEL_BUILD_DIR="$EVAL_DIR/build/$KERNEL_IDENT"
KERNEL_HDL_DIR="$KERNEL_BUILD_DIR/hdl"
KERNEL_SIM_DIR="$KERNEL_BUILD_DIR/sim"

# Reset HDL directory
rm -rf "$KERNEL_HDL_DIR" && mkdir -p "$KERNEL_HDL_DIR"

# Copy all required HDL files
cp "$HLS_TEST_SUITE_BUILD_DIR/$KERNEL_IDENT.hls.v" "$KERNEL_HDL_DIR"
GREP_PATTERN="op_HLS_BUF_|op_HLS_DEC_LOAD_|op_FP_|op_FPOP_|op_FpToSInt_|op_SIToFP_"
EXTRA_MODULE_NAMES=$(grep -Po "^[[:space:]]*\K($GREP_PATTERN)[^[:space:]]*" "$KERNEL_HDL_DIR/$KERNEL_NAME.hls.v" || true)
for module_name in $EXTRA_MODULE_NAMES; do
    module_file="$(find "$HLS_TEST_SUITE_DIR/verilog_ops" -name "$module_name.sv" -print -quit)"
    cp "$module_file" "$KERNEL_HDL_DIR"
done

if grep -qrE "vivado_fadd_blocking|vivado_fmul_blocking" "$KERNEL_HDL_DIR"; then
    # FIXME: Add support for floating-point adders/multipliers in the future
    echo_fatal "Kernel '$KERNEL_IDENT' requires floating-point adders/multipliers which are not currently supported."
    exit 1
fi

# Reset simulation directory
rm -rf "$KERNEL_SIM_DIR" && mkdir -p "$KERNEL_SIM_DIR"

# Copy simulation log file
cp "$HLS_TEST_SUITE_BUILD_DIR/$KERNEL_IDENT.hls.log" "$KERNEL_SIM_DIR"

echo_info "Imported files for kernel '$KERNEL_IDENT' in $KERNEL_HDL_DIR"
