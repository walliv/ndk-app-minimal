# Modules.tcl: Components include script
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Daniel Kondys <kondys@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# Paths to components
set FIFOXM_BASE      "$OFM_PATH/comp/base/fifo/fifox_multi"
set MFB_BASE         "$OFM_PATH/comp/mfb_tools"
set LOGIC_BASE       "$OFM_PATH/comp/base/logic"

# Packages
lappend PACKAGES "$OFM_PATH/comp/base/pkg/math_pack.vhd"
lappend PACKAGES "$OFM_PATH/comp/base/pkg/type_pack.vhd"

# Components
lappend COMPONENTS [ list "FIFOX_MULTI"     $FIFOXM_BASE                      "FULL" ]
lappend COMPONENTS [ list "MFB_FIFOX"       "$MFB_BASE/storage/fifox"         "FULL" ]
lappend COMPONENTS [ list "MFB_RECONF"      "$MFB_BASE/flow/reconfigurator"   "FULL" ]
lappend COMPONENTS [ list "OFFSET_REACHED"  "$MFB_BASE/logic/offset_reached"  "FULL" ]
lappend COMPONENTS [ list "FIRST_ONE"       "$LOGIC_BASE/first_one"           "FULL" ]
lappend COMPONENTS [ list "ONES_INSERTOR"   "$LOGIC_BASE/ones_insertor"       "FULL" ]
lappend COMPONENTS [ list "BARREL_SHIFTER"  "$LOGIC_BASE/barrel_shifter"      "FULL" ]

# Source files for implemented component
lappend MOD "$ENTITY_BASE/mfb_mvb_appender.vhd"

