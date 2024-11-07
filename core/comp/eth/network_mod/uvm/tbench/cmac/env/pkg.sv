// pkg.sv: Package for the Xilinx CMAC environment
// Copyright (C) 2024 CESNET z. s. p. o.
// Author(s): Yaroslav Marushchenko <xmarus09@stud.fit.vutbr.cz>

// SPDX-License-Identifier: BSD-3-Clause

`ifndef NETWORK_MOD_CMAC_ENV_SV
`define NETWORK_MOD_CMAC_ENV_SV

package uvm_network_mod_cmac_env;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "sequencer_port.sv"
    `include "sequence.sv"
    `include "tx_error_expander.sv"
    `include "env.sv"

endpackage

`endif
