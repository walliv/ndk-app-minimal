# Vivado.tcl: Vivado tcl script to compile whole FPGA design
# Copyright (C) 2024 BrnoLogic, Ltd.
# Author(s): David Beneš <benes@brnologic.com>
#
# SPDX-License-Identifier: BSD-3-Clause


# NOTE: The purpose of this file is described in the Parametrization section of
# the NDK-CORE documentation.

# ----- Setting basic synthesis options ---------------------------------------
# Sourcing all configuration parameters
source $env(CARD_BASE)/src/Vivado.inc.tcl

# Create only a Vivado project for further design flow driven from Vivado GUI
# "0" ... full design flow in command line
# "1" ... project composition only for further dedesign flow in GUI
set SYNTH_FLAGS(PROJ_ONLY) "0"

# Associative array which is propagated to APPLICATION_CORE, add other
# parameters if necessary.
set APP_ARCHGRP(APP_CORE_ENABLE) $APP_CORE_ENABLE

# Convert associative array to list
set APP_ARCHGRP_L [array get APP_ARCHGRP]

# ----- Add application core to main component list ---------------------------
lappend HIERARCHY(COMPONENTS) \
    [list "APPLICATION_CORE" "$OFM_PATH/apps/minimal/top" $APP_ARCHGRP_L]

# Call main function which handle targets
nb_main
