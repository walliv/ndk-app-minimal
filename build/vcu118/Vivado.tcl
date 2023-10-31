# Vivado.tcl: Vivado tcl script to compile whole FPGA design
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Vladislav Valek <valekv@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# NOTE: The purpose of this file is described in the Parametrization section of
# the NDK-CORE documentation.

# ----- Setting basic synthesis options ---------------------------------------
# NDK & user constants
source $env(CARD_BASE)/src/Vivado.inc.tcl

# Create only a Quartus project for further design flow driven from Quartus GUI
# "0" ... full design flow in command line
# "1" ... project composition only for further dedesign flow in GUI
set SYNTH_FLAGS(SYNTH_ONLY) "0"

# Specify custom build directives that will overwrite the card specific ones
# The list of directives that can be changed:
# Description:
#   <NAME_OF_THE_DIRECTIVE_IN_SYNTH_FLAGS> -> <the property in Vivado>
# Synthesis:
#   SYNTH_DIRECTIVE       -> SYNTH_DESIGN
#   SOPT_DIRECTIVE        -> opt_design command (Post-synthesis optimization)
# Implementation:
#   IOPT_DIRECTIVE        -> OPT_DESIGN
#   PLACE_DIRECTIVE       -> PLACE_DESIGN
#   POPT_DIRECTIVE        -> PHYS_OPT_DESIGN
#   ROUTE_DIRECTIVE       -> ROUTE_DESIGN
#   PROUTE_POPT_DIRECTIVE -> POST_ROUTE_PHYS_OPT_DESIGN
#
set SYNTH_FLAGS(FLATTEN_HIERARCHY)     none
set SYNTH_FLAGS(RETIMING)              true
set SYNTH_FLAGS(SYNTH_DIRECTIVE)       "PerformanceOptimized"
set SYNTH_FLAGS(IOPT_DIRECTIVE)        "ExploreWithRemap"
set SYNTH_FLAGS(PLACE_DIRECTIVE)       "EarlyBlockPlacement"
set SYNTH_FLAGS(POPT_DIRECTIVE)        "AddRetime"
set SYNTH_FLAGS(ROUTE_DIRECTIVE)       "AggressiveExplore"
set SYNTH_FLAGS(PROUTE_POPT_DIRECTIVE) "AddRetime"

# Associative array which is propagated to APPLICATION_CORE, add other
# parameters if necessary.
set APP_ARCHGRP(APP_CORE_ENABLE) $APP_CORE_ENABLE

# Convert associative array to list
set APP_ARCHGRP_L [array get APP_ARCHGRP]

# ----- Add application core to main component list ---------------------------
lappend HIERARCHY(COMPONENTS) \
    [list "APPLICATION_CORE" "../../app/top" $APP_ARCHGRP_L]

# Call main function which handle targets
nb_main
