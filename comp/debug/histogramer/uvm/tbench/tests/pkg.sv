//-- pkg.sv: Test package
//-- Copyright (C) 2022 CESNET z. s. p. o.
//-- Author: Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>

//-- SPDX-License-Identifier: BSD-3-Clause

`ifndef UVM_HISTOGRAMER_TEST
`define UVM_HISTOGRAMER_TEST

package test;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "const.sv"

    `include "sequence.sv"
    `include "sequence_virt.sv"
    `include "test.sv"

endpackage
`endif
