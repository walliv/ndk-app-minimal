# Modules.tcl: script to compile single module
# Copyright (C) 2023 CESNET z. s. p. o.
# Author(s): Vladislav Valek <valekv@cesnet.cz>
#
# SPDX-License-Identifier: BSD-3-Clause

# converting input list to associative array (uncomment when needed)
array set ARCHGRP_ARR $ARCHGRP

# Component paths
set APP_CORE_UTILS_BASE "$OFM_PATH/../core/intel/src/comp/app_core_utils"

set RISCV_SRCS_ROOT "$ENTITY_BASE/../../../BarrelRISCV/runs"

# Packages
lappend PACKAGES "$OFM_PATH/comp/base/pkg/math_pack.vhd"
lappend PACKAGES "$OFM_PATH/comp/base/pkg/type_pack.vhd"
lappend PACKAGES "$RISCV_SRCS_ROOT/riscv_pack.vhd"

if {$ARCHGRP_ARR(APP_CORE_ENABLE)} {
    # Components

    # Files
    lappend MOD "$RISCV_SRCS_ROOT/alu.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/alu_control.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/Reg.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/Reg_ce.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/pipe_sl.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/pipe_vec.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/Adder32.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/branch_logic.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/control_unit.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/reservation_station.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/immsel_signext.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/mux2to1.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/mux3to1.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/mux4to1.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/mux8to1_vec.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/mux_vec_slv.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/generic_mux.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/generic_onehot_mux.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/generic_onehot_mux_sl.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/generic_onehot_demux.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/memory_mapped_interface.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/memory_map_decoder.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/instruction_decoder.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/load_unit.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/LUT_RAM.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/BRAM.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/BRAM_SDP.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/URAM.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/regfile.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/regfile_vec.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/pcreg_vec.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/store_unit.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_core.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_core_top.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/memory_arbiter.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/row_sync.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_minirow_cluster.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_row_cluster.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_rows_collection_cluster.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/handshake_pipe.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/uram_read_to_stream.vhd"
    lappend MOD "$RISCV_SRCS_ROOT/RISCV_manycore_wrapper.vhd"

    lappend MOD "$ENTITY_BASE/barrel_proc_debug_core.vhd"
    lappend MOD "$ENTITY_BASE/app_subcore.vhd"
    lappend MOD "$ENTITY_BASE/application_core.vhd"

    exec python3 "$RISCV_SRCS_ROOT/../vivado/floorplan_with_pci.py"
    lappend SRCS(CONSTR_VIVADO) [list "$RISCV_SRCS_ROOT/../vivado/floorplan_with_pci.xdc"]

} else {
    lappend MOD "$APP_CORE_UTILS_BASE/app_core_empty_arch.vhd"
}

lappend MOD "$ENTITY_BASE/DevTree.tcl"
