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
lappend PACKAGES "$ENTITY_BASE/riscv_pack.vhd"

if {$ARCHGRP_ARR(APP_CORE_ENABLE)} {
    # Components

    # Files
    lappend MOD "$ENTITY_BASE/alu.vhd"
    lappend MOD "$ENTITY_BASE/alu_control.vhd"
    lappend MOD "$ENTITY_BASE/Reg.vhd"
    lappend MOD "$ENTITY_BASE/Reg_ce.vhd"
    lappend MOD "$ENTITY_BASE/pipe.vhd"
    lappend MOD "$ENTITY_BASE/pipe_vec.vhd" 
    lappend MOD "$ENTITY_BASE/Adder32.vhd"
    lappend MOD "$ENTITY_BASE/branch_logic.vhd"
    lappend MOD "$ENTITY_BASE/control_unit.vhd"
    lappend MOD "$ENTITY_BASE/reservation_station.vhd"
    lappend MOD "$ENTITY_BASE/immsel_signext.vhd"
    lappend MOD "$ENTITY_BASE/mux2to1.vhd"
    lappend MOD "$ENTITY_BASE/mux3to1.vhd"
    lappend MOD "$ENTITY_BASE/mux4to1.vhd"
    lappend MOD "$ENTITY_BASE/mux8to1_vec.vhd"
    lappend MOD "$ENTITY_BASE/mux_vec_slv.vhd"
    lappend MOD "$ENTITY_BASE/generic_mux.vhd"
    lappend MOD "$ENTITY_BASE/generic_onehot_mux.vhd"
    lappend MOD "$ENTITY_BASE/generic_onehot_mux_sl.vhd"
    lappend MOD "$ENTITY_BASE/generic_onehot_demux.vhd"
    lappend MOD "$ENTITY_BASE/memory_mapped_interface.vhd"
    lappend MOD "$ENTITY_BASE/memory_map_decoder.vhd"
    lappend MOD "$ENTITY_BASE/instruction_decoder.vhd"
    lappend MOD "$ENTITY_BASE/load_unit.vhd"
    lappend MOD "$ENTITY_BASE/LUT_RAM.vhd" 
    lappend MOD "$ENTITY_BASE/BRAM.vhd" 
    lappend MOD "$ENTITY_BASE/BRAM_SDP.vhd"
    lappend MOD "$ENTITY_BASE/URAM.vhd"
    lappend MOD "$ENTITY_BASE/regfile.vhd"
    lappend MOD "$ENTITY_BASE/regfile_vec.vhd"
    lappend MOD "$ENTITY_BASE/pcreg_vec.vhd"
    lappend MOD "$ENTITY_BASE/store_unit.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_core.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_core_top.vhd"
    lappend MOD "$ENTITY_BASE/memory_arbiter.vhd"
    lappend MOD "$ENTITY_BASE/row_sync.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_minirow_cluster.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_row_cluster.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_rows_collection_cluster.vhd"
    lappend MOD "$ENTITY_BASE/handshake_pipe.vhd"
    lappend MOD "$ENTITY_BASE/uram_read_to_stream.vhd"
    lappend MOD "$ENTITY_BASE/RISCV_manycore_wrapper.vhd"
    lappend MOD "$ENTITY_BASE/barrel_proc_debug_core.vhd"
    lappend MOD "$ENTITY_BASE/app_subcore.vhd"
    lappend MOD "$ENTITY_BASE/application_core.vhd"


    exec python3 "$ENTITY_BASE/floorplan_with_pci.py"
    lappend SRCS(CONSTR_VIVADO) [list "$ENTITY_BASE/floorplan_with_pci.xdc"]

} else {
    lappend MOD "$APP_CORE_UTILS_BASE/app_core_empty_arch.vhd"
}

lappend MOD "$ENTITY_BASE/DevTree.tcl"
