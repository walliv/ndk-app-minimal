# general.xdc
# Copyright (C) 2024 BrnoLogic, Ltd.
# Author(s): David Beneš <benes@brnologic.com>
#
# SPDX-License-Identifier: BSD-3-Clause

# Bitstream configuration
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN enable [current_design]
set_property CONFIG_MODE B_SCAN [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN enable [current_design]

# General pins
set_property PACKAGE_PIN AT22 [get_ports SYSCLK]
set_property IOSTANDARD DIFF_SSTL12 [get_ports SYSCLK]

create_clock -period 3.333 -name sysclk [get_ports SYSCLK]
