# Makefile: Makefile for Terasic Mercury A2700 Accelerator Card
# Copyright (C) 2024 BrnoLogic, Ltd.
# Author(s): David Beneš <benes@brnologic.com>
#
# SPDX-License-Identifier: BSD-3-Clause

COMBO_BASE = ../../../..
CARD_BASE = $(COMBO_BASE)/cards/terasic/a2700
APP_CONF = app_conf.tcl


OUTPUT_NAME = a2700-400g-minimal

all: 400g1

400g1   : ETH_PORT_SPEED=400
400g1   : ETH_PORT_CHAN=1
400g1   : OUTPUT_NAME:=$(OUTPUT_NAME)-400g1
400g1   : EHIP_PORT_TYPE=0
400g1   : build
1x400g-8: 400g-1

include $(CARD_BASE)/src/card.mk
