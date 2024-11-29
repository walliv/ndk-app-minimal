//-- sequencer.sv: Virtual sequencer
//-- Copyright (C) 2022 CESNET z. s. p. o.
//-- Author(s): Radek Iša <isa@cesnet.cz>

//-- SPDX-License-Identifier: BSD-3-Clause

class sequencer#(USR_ITEM_WIDTH, PCIE_REGIONS, PCIE_REGION_SIZE, PCIE_BLOCK_SIZE, PCIE_ITEM_WIDTH, PCIE_META_WIDTH, CHANNELS) extends uvm_sequencer;
    `uvm_component_param_utils(uvm_dma_ll::sequencer#(USR_ITEM_WIDTH, PCIE_REGIONS, PCIE_REGION_SIZE, PCIE_BLOCK_SIZE, PCIE_ITEM_WIDTH, PCIE_META_WIDTH, CHANNELS))

    uvm_reset::sequencer  m_reset;
    uvm_dma_ll_rx::sequencer#(USR_ITEM_WIDTH) m_packet;
    uvm_mfb::sequencer #(PCIE_REGIONS, PCIE_REGION_SIZE, PCIE_BLOCK_SIZE, PCIE_ITEM_WIDTH, PCIE_META_WIDTH) m_pcie;
    uvm_dma_ll::regmodel #(CHANNELS)  m_regmodel;

    function new(string name = "virt_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
