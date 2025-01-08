# Modules.tcl: Components include script
# Copyright (C) 2025 CESNET z.s.p.o.
# Author(s): Jakub Cabal <cabal@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# Paths
set ASFIFOX_BASE "$OFM_PATH/comp/base/fifo/asfifox"

# Packages

# Components
lappend COMPONENTS [list "ASFIFOX" $ASFIFOX_BASE "FULL"]

# Files
lappend MOD "$ENTITY_BASE/tsu_async.vhd"
