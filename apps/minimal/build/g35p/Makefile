# Makefile: Makefile for iWave G35P Accelerator Card
# Copyright (C) 2024 BrnoLogic, Ltd.
# Author(s): David Beneš <benes@brnologic.com>
#
# SPDX-License-Identifier: BSD-3-Clause


# NOTE: Usage of the configuration parameters in this file is described
# in the Parametrization section of the NDK-CORE documentation.

# Set path to top-level of NDK-FPGA repository
COMBO_BASE = ../../../..
CARD_BASE = $(COMBO_BASE)/cards/iwave/g35p
APP_CONF = app_conf.tcl
OUTPUT_NAME = g35p-minimal

.PHONY: all 100g2

all: 100g2

100g2: ETH_PORTS=2
100g2: ETH_PORT_SPEED=100
100g2: ETH_PORT_CHAN=1
100g2: OUTPUT_NAME:=g35p-minimal-100g2
100g2: build

include $(CARD_BASE)/src/card.mk
