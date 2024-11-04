# Modules.tcl: Components include script
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>
#
# SPDX-License-Identifier: BSD-3-Clause


# Paths to components
set CNT_BASE            "$OFM_PATH/comp/base/logic/cnt"
set SDP_BRAM_BASE       "$OFM_PATH/comp/base/mem/sdp_bram"
set DP_BRAM_BASE        "$OFM_PATH/comp/base/mem/dp_bram"
set MEM_CLEAR_BASE      "$OFM_PATH/comp/base/mem/mem_clear"

# Packages
lappend PACKAGES "$OFM_PATH/comp/base/pkg/math_pack.vhd"
lappend PACKAGES "$OFM_PATH/comp/base/pkg/type_pack.vhd"

lappend COMPONENTS [ list "CNT"                 $CNT_BASE               "FULL" ]
lappend COMPONENTS [ list "DP_BRAM"             $DP_BRAM_BASE           "FULL" ]
lappend COMPONENTS [ list "MEM_CLEAR"           $MEM_CLEAR_BASE         "FULL" ]

# Source files for implemented component
lappend MOD "$ENTITY_BASE/histogramer.vhd"
