#!/bin/sh

NDK_FPGA_PATH=../../../..
source $NDK_FPGA_PATH/env.sh

ndk_fpga_venv_prepare "venv-cocotb"

pip install .
#pip install "cocotbext-ofm[nfb]@$NDK_FPGA_COCOTBEXT_OFM_URL"
