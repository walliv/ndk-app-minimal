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
#   <NAME_OF_THE_FIELD_IN_SYNTH_FLAGS> -> <allowed value(s)>
# Synthesis:
#   SYNTH_DIRECTIVE           -> predefined directive OR the string of switches
# Implementation:
#   SOPT_DIRECTIVE            -> predefined directive OR the string of switches
#   POWER_OPT_EN              -> true/false for running power_opt_design after Synthesis
#   PLACE_DIRECTIVE           -> predefined directive OR the string of switches
#   PPLACE_POWER_OPT_EN       -> true/false for running power_opt_design after Placement
#   PPLACE_PHYS_OPT_DIRECTIVE -> predefined directive OR the string of switches (leave empty to disable)
#   ROUTE_DIRECTIVE           -> predefined directive OR the string of switches
#   PROUTE_PHYS_OPT_DIRECTIVE -> predefined directive OR the string of switches (leave empty to disable)
#
set SYNTH_FLAGS(FLATTEN_HIERARCHY)         rebuilt
set SYNTH_FLAGS(RETIMING)                  true
#set SYNTH_FLAGS(SYNTH_DIRECTIVE)          "PerformanceOptimized"
set SYNTH_FLAGS(SYNTH_DIRECTIVE)           "AreaOptimized_high"
set SYNTH_FLAGS(SOPT_DIRECTIVE)            "ExploreWithRemap"
#set SYNTH_FLAGS(PLACE_DIRECTIVE)          "Explore"
set SYNTH_FLAGS(PLACE_DIRECTIVE)           "ExtraPostPlacementOpt"
#set SYNTH_FLAGS(PLACE_DIRECTIVE)          "ExtraTimingOpt"
set SYNTH_FLAGS(PPLACE_PHYS_OPT_DIRECTIVE) "AddRetime"
#set SYNTH_FLAGS(POPT_DIRECTIVE)           "Explore"
set SYNTH_FLAGS(ROUTE_DIRECTIVE)           "AggressiveExplore"
set SYNTH_FLAGS(PROUTE_PHYS_OPT_DIRECTIVE) "AddRetime"
#set SYNTH_FLAGS(PROUTE_POPT_DIRECTIVE)    "Explore"
#set SYNTH_FLAGS(PROUTE_POPT_DIRECTIVE)    "AggressiveExplore"

set SYNTH_FLAGS(WRITE_SOPT_DCP) true

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
