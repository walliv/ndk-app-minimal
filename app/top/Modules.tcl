# Modules.tcl: script to compile single module
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Vladislav Valek <valekv@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array (uncomment when needed)
array set ARCHGRP_ARR $ARCHGRP

# Component paths
set APP_CORE_UTILS_BASE "$OFM_PATH/../core/intel/src/comp/app_core_utils"

# Packages
lappend PACKAGES "$OFM_PATH/comp/base/pkg/math_pack.vhd"
lappend PACKAGES "$OFM_PATH/comp/base/pkg/type_pack.vhd"

if {$ARCHGRP_ARR(APP_CORE_ENABLE)} {
    # Components

    # Files
    lappend MOD "$ENTITY_BASE/barrel_proc_debug_core.vhd"
    lappend MOD "$ENTITY_BASE/app_subcore.vhd"
    lappend MOD "$ENTITY_BASE/application_core.vhd"

    exec python3 "$ENTITY_BASE/floorplan_with_pci.py"
    lappend SRCS(CONSTR_VIVADO) [list "$ENTITY_BASE/floorplan_with_pci.xdc"]

} else {
    lappend MOD "$APP_CORE_UTILS_BASE/app_core_empty_arch.vhd"
}

lappend MOD "$ENTITY_BASE/DevTree.tcl"
