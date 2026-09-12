#!/usr/bin/env bash
# This script has been imported from the original Dynamatic repository
# and modified to fit the needs of this project. The original can be found at:
# https://github.com/EPFL-LAP/dynamatic/blob/main/tools/dynamatic/scripts/utils.sh
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# Prints some information to stdout.
#   $1: the text to print
echo_info() {
    echo "[INFO] $1"
}

# Prints a fatal error message to stdout.
#   $1: the text to print
echo_fatal() {
    echo "[FATAL] $1"
}


# Exits the script with a fatal error message if the last command that was
# called before this function failed, otherwise optionally prints an information
# message.
#   $1: fatal error message
#   $2: [optional] information message
exit_on_fail() {
    if [[ $? -ne 0 ]]; then
        if [[ ! -z $1 ]]; then
            echo_fatal "$1"
            exit 1
        fi
        echo_fatal "Failed!"
        exit 1
    else
        if [[ ! -z $2 ]]; then
            echo_info "$2"
        fi
    fi
}
