# Modules.tcl: Components include script
# Copyright (C) 2024 CESNET z. s. p. o.
# Author(s): Oliver Gurka <oliver.gurka@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

set MVB_FIFOX_BASE      "$OFM_PATH/comp/mvb_tools/storage/fifox"

lappend COMPONENTS [list "MVB_FIFOX"      $MVB_FIFOX_BASE   "FULL"]

set MOD "$MOD $ENTITY_BASE/mvb_gate.vhd"
