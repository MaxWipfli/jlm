#!/usr/bin/env bash
# This script has been imported from the original Dynamatic repository
# and modified to fit the needs of this project. The original can be found at:
# https://github.com/EPFL-LAP/dynamatic/blob/main/tools/dynamatic/scripts/synthesize.sh
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd -P )"
source "$SCRIPT_DIR/dynamatic_utils.sh"

set -euo pipefail

# ============================================================================ #
# Variable definitions
# ============================================================================ #

# Script arguments
KERNEL_IDENT="$1"
FULL_CLOCK="$2"

# Directories
EVAL_DIR="$(realpath "$SCRIPT_DIR/../")"
ROOT_DIR="$(realpath "$SCRIPT_DIR/../../")"
HLS_TEST_SUITE_DIR="$ROOT_DIR/usr/hls-test-suite"
HLS_TEST_SUITE_BUILD_DIR="$HLS_TEST_SUITE_DIR/build"

# Various
KERNEL_NAME="$(basename "$KERNEL_IDENT")"
HALF_CLOCK="$(awk -v fc="$FULL_CLOCK" 'BEGIN {printf "%.3f", fc/2}')"

# Generated directories/files
SYNTH_DIR="$EVAL_DIR/build/$KERNEL_IDENT/synth"
SYNTH_HDL_DIR="$SYNTH_DIR/hdl"
F_REPORT="$SYNTH_DIR/report.txt"
F_SCRIPT="$SYNTH_DIR/synthesize.tcl"
F_PERIOD="$SYNTH_DIR/period_${FULL_CLOCK}.xdc"
F_UTILIZATION_SYN="$SYNTH_DIR/utilization_post_syn.rpt"
F_TIMING_SYN="$SYNTH_DIR/timing_post_syn.rpt"
F_UTILIZATION_PR="$SYNTH_DIR/utilization_post_pr.rpt"
F_TIMING_PR="$SYNTH_DIR/timing_post_pr.rpt"

# ============================================================================ #
# Synthesis flow
# ============================================================================ #

# Reset simulation directory
rm -rf "$SYNTH_DIR" && mkdir -p "$SYNTH_DIR"

# Copy all synthesizable components to specific folder for Vivado
mkdir -p "$SYNTH_HDL_DIR"
cp "$HLS_TEST_SUITE_BUILD_DIR/$KERNEL_IDENT.hls.v" "$SYNTH_HDL_DIR"
# FIXME: Add additional files from $HLS_TEST_SUITE_DIR/verilog_ops as needed
# FIXME: How to handle floating-point kernels???

READ_VERILOG="read_verilog [glob $SYNTH_HDL_DIR/*.v]"

# Only used for floating-point kernels, which are not currently supported
# FIXME: Re-enable this
# # Source tcl resources
# READ_TCL=""
# if ls "$RESOURCE_DIR"/*.tcl 1> /dev/null 2>&1; then
#   for f in "$RESOURCE_DIR"/*.tcl; do
#     READ_TCL="$READ_TCL\nsource $f"
#   done
# fi

# Set vivado commands for vivado IPs for floating point operations
VIVADO_CMDS="set vivado_ver [version -short]
set fpo_ver 7.1
if {[regexp -nocase {2015\.1.*} $vivado_ver match]} {
    set fpo_ver 7.0
}
"

# Generate synthesis script
echo -e \
"set_param general.maxThreads 8
$VIVADO_CMDS
$READ_VERILOG
$READ_TCL
read_xdc "$F_PERIOD"
synth_design -top $KERNEL_NAME -part xc7k160tfbg484-2 -no_iobuf -mode out_of_context
report_utilization > $F_UTILIZATION_SYN
report_timing > $F_TIMING_SYN
opt_design
place_design
phys_opt_design
route_design
phys_opt_design
report_utilization > $F_UTILIZATION_PR
report_timing > $F_TIMING_PR
exit" > "$F_SCRIPT"

echo -e \
"create_clock -name clk -period $FULL_CLOCK -waveform {0.000 $HALF_CLOCK} [get_ports clk]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk]

#set_input_delay 0 -clock CLK  [all_inputs]
#set_output_delay 0 -clock CLK [all_outputs]" > "$F_PERIOD"

echo_info "Created synthesis scripts"
echo_info "Launching Vivado synthesis"
cd "$SYNTH_DIR"
vivado -mode tcl -source "$F_SCRIPT" > "$F_REPORT"
exit_on_fail "Logic synthesis failed" "Logic synthesis succeeded"
