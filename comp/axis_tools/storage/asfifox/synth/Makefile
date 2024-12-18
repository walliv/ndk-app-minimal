# Makefile: Makefile to compile module
# Copyright (C) 2024 CESNET
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

TOP_LEVEL_ENT=AXIS_ASFIFOX

SYNTH=quartus
export DEVICE=AGILEX

CLK_PORTS=RX_CLK TX_CLK
CLK_PERIOD=5.0 4.0

.PHONY: all
all: comp

include ../../../../../build/Makefile
