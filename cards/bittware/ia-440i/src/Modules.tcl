# Modules.tcl: script to compile Bittware IA-440I card
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#            Tomas Hak <hak@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths
set FPGA_COMMON_BASE "$ARCHGRP_ARR(CORE_BASE)/top"
#set BOOT_CTRL_BASE   "$OFM_PATH/core/comp/misc/boot_ctrl"

# Components
lappend COMPONENTS [list "FPGA_COMMON" $FPGA_COMMON_BASE $ARCHGRP]
#lappend COMPONENTS [list "BOOT_CTRL"   $BOOT_CTRL_BASE   "FULL"  ]

# IP components
set IP_COMMON_TCL $ARCHGRP_ARR(IP_TEMPLATE_ROOT)/common.tcl
source $IP_COMMON_TCL

set ARCHGRP_ARR(IP_COMMON_TCL)    $IP_COMMON_TCL
set ARCHGRP_ARR(IP_TEMPLATE_BASE) $ARCHGRP_ARR(IP_TEMPLATE_ROOT)/intel
set ARCHGRP_ARR(IP_MODIFY_BASE)   $ENTITY_BASE/ip
set ARCHGRP_ARR(IP_DEVICE_FAMILY) "Agilex"
set ARCHGRP_ARR(IP_DEVICE)        $ARCHGRP_ARR(FPGA)

set PCIE_CONF [dict create 0 "1x16" 1 "2x8"]
set RTILE_PCIE_IP_NAME "rtile_pcie_[dict get $PCIE_CONF $ARCHGRP_ARR(PCIE_ENDPOINT_MODE)]"

set ETH_CONF [dict create 400 "1x400g" ]
# TODO: 200 "2x200g" 100 [expr {$ARCHGRP_ARR(ETH_PORT_CHAN,0) == 2 ? "2x100g" : "4x100g"}] 50 "8x50g" 40 "2x40g" 25 "8x25g" 10 "8x10g"
set FTILE_ETH_IP_NAME "ftile_eth_[dict get $ETH_CONF $ARCHGRP_ARR(ETH_PORT_SPEED,0)]"

# see '$ARCHGRP_ARR(CORE_BASE)/src/ip/common.tcl' for more information regarding the fields
#                         script_path     script_name        ip_comp_name       type  modify
lappend IP_COMPONENTS [list  "clk"     "iopll"             "iopll_ip"             0      1]
lappend IP_COMPONENTS [list  "misc"    "mailbox_client"    "mailbox_client_ip"    0      0]
lappend IP_COMPONENTS [list  "misc"    "reset_release"     "reset_release_ip"     0      0]
lappend IP_COMPONENTS [list  "pcie"    "rtile_pcie"        $RTILE_PCIE_IP_NAME    0      1]

if {$ARCHGRP_ARR(VIRTUAL_DEBUG_ENABLE)} {
    lappend IP_COMPONENTS [list "misc"  "jtag_op"          "jtag_op_ip"           0      0]
}

if {$ARCHGRP_ARR(NET_MOD_ARCH) eq "F_TILE"} {
    if {$ARCHGRP_ARR(EHIP_PORT_TYPE,0) == 0} {
        lappend IP_COMPONENTS [list "clk"  "ftile_pll"     "ftile_pll"            0      1]
        lappend IP_COMPONENTS [list "eth"  "ftile_eth"     $FTILE_ETH_IP_NAME     0      1]
    }
}

lappend MOD {*}[get_ip_mod_files $IP_COMPONENTS [array get ARCHGRP_ARR]]

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
