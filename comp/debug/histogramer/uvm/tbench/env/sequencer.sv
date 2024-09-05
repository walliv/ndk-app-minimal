// sequencer.sv: Virtual sequencer
// Copyright (C) 2023 CESNET z. s. p. o.
// Author: Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>

// SPDX-License-Identifier: BSD-3-Clause


`include "../tests/const.sv"

class virt_sequencer #(
    INPUT_WIDTH,
    BOX_WIDTH,
    BOX_CNT,
    READ_PRIOR,
    CLEAR_BY_READ,
    CLEAR_BY_RST,
    DEVICE,
    REQ_WIDTH,
    RESP_WIDTH,
    ADDR_WIDTH
) extends uvm_sequencer;
    `uvm_component_param_utils(uvm_histogramer::virt_sequencer #(
        INPUT_WIDTH,
        BOX_WIDTH,
        BOX_CNT,
        READ_PRIOR,
        CLEAR_BY_READ,
        CLEAR_BY_RST,
        DEVICE,
        REQ_WIDTH,
        RESP_WIDTH,
        ADDR_WIDTH
    ))

    uvm_reset::sequencer                            m_reset;
    uvm_logic_vector::sequencer #(REQ_WIDTH)        req_sqr;

    function new(string name = "virt_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
