# Modules.tcl: script to compile card
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array
array set ARCHGRP_ARR $ARCHGRP

# Paths

set FPGA_COMMON_BASE         "$ARCHGRP_ARR(CORE_BASE)"
set BOOT_CTRL_BASE           "$ARCHGRP_ARR(CORE_BASE)/boot_ctrl"
set AXI_QSPI_FLASH_CTRL_BASE "$ARCHGRP_ARR(CORE_BASE)/axi_quad_flash_controller"

# Components
lappend COMPONENTS [list "FPGA_COMMON"         $FPGA_COMMON_BASE         $ARCHGRP ]
lappend COMPONENTS [list "BOOT_CTRL"           $BOOT_CTRL_BASE           "FULL"   ]
lappend COMPONENTS [list "AXI_QSPI_FLASH_CTRL" $AXI_QSPI_FLASH_CTRL_BASE "FULL"   ]

# IP components
source $ARCHGRP_ARR(IP_TEMPLATE_ROOT)/common.tcl

#set ARCHGRP_ARR(IP_TEMPLATE_BASE) $ARCHGRP_ARR(IP_TEMPLATE_ROOT)/amd
set ARCHGRP_ARR(IP_MODIFY_BASE)   $ENTITY_BASE/ip
set ARCHGRP_ARR(USE_IP_SUBDIRS)   true

# see '$ARCHGRP_ARR(CORE_BASE)/src/ip/common.tcl' for more information regarding the fields
#                            script_path, script_name, ip_comp_name, type, modify
lappend IP_COMPONENTS [list "pcie" "pcie4_uscale_plus" "pcie4_uscale_plus" 0 1]

if {$ARCHGRP_ARR(VIRTUAL_DEBUG_ENABLE)} {
    lappend IP_COMPONENTS [list "misc" "xvc_vsec" "xvc_vsec" 0 1]
}

lappend MOD {*}[get_ip_mod_files $IP_COMPONENTS [array get ARCHGRP_ARR]]

# Top-level
lappend MOD "$ENTITY_BASE/fpga.vhd"
