// dut.sv: Intel F-Tile DUT
// Copyright (C) 2024 CESNET z. s. p. o.
// Author(s): Yaroslav Marushchenko <xmarus09@stud.fit.vutbr.cz>

// SPDX-License-Identifier: BSD-3-Clause

module DUT #(
    string       ETH_CORE_ARCH,
    int unsigned ETH_PORTS,
    int unsigned ETH_PORT_SPEED[ETH_PORTS-1 : 0],

    int unsigned ETH_PORT_CHAN  [ETH_PORTS-1 : 0],
    int unsigned EHIP_PORT_TYPE [ETH_PORTS-1 : 0],
    int unsigned ETH_PORT_RX_MTU[ETH_PORTS-1 : 0],
    int unsigned ETH_PORT_TX_MTU[ETH_PORTS-1 : 0],

    int unsigned LANES,

    int unsigned QSFP_PORTS,
    int unsigned QSFP_I2C_PORTS,
    int unsigned QSFP_I2C_TRISTATE,

    int unsigned ETH_TX_HDR_WIDTH,
    int unsigned ETH_RX_HDR_WIDTH,

    int unsigned REGIONS,
    int unsigned REGION_SIZE,
    int unsigned BLOCK_SIZE,
    int unsigned ITEM_WIDTH,

    int unsigned MI_DATA_WIDTH,
    int unsigned MI_ADDR_WIDTH,

    int unsigned MI_DATA_WIDTH_PHY,
    int unsigned MI_ADDR_WIDTH_PHY,

    int unsigned LANE_RX_POLARITY,
    int unsigned LANE_TX_POLARITY,

    int unsigned RESET_WIDTH,

    string DEVICE,
    string BOARD,
    time CLK_ETH_PERIOD[ETH_PORTS]
)(
    output wire logic CLK_ETH[ETH_PORTS],
    input wire logic CLK_USR,
    input wire logic CLK_MI,
    input wire logic CLK_MI_PHY,
    input wire logic CLK_MI_PMD,
    input wire logic CLK_TSU,

    reset_if.dut rst_usr,
    reset_if.dut rst_eth[ETH_PORTS],
    reset_if.dut rst_mi,
    reset_if.dut rst_mi_phy,
    reset_if.dut rst_mi_pmd,
    reset_if.dut rst_tsu,

    intel_mac_seg_if.dut_rx eth_rx[ETH_PORTS],
    intel_mac_seg_if.dut_tx eth_tx[ETH_PORTS],

    mfb_if.dut_rx usr_rx     [ETH_PORTS],
    mfb_if.dut_tx usr_tx_data[ETH_PORTS],
    mvb_if.dut_tx usr_tx_hdr [ETH_PORTS],

    mi_if.dut_slave mi,
    mi_if.dut_slave mi_phy,
    mi_if.dut_slave mi_pmd,

    mvb_if.dut_rx tsu
);
    DUT_BASE #(
        .ETH_CORE_ARCH    (ETH_CORE_ARCH    ),
        .ETH_PORTS        (ETH_PORTS        ),
        .ETH_PORT_SPEED   (ETH_PORT_SPEED   ),
        .ETH_PORT_CHAN    (ETH_PORT_CHAN    ),
        .EHIP_PORT_TYPE   (EHIP_PORT_TYPE   ),
        .ETH_PORT_RX_MTU  (ETH_PORT_RX_MTU  ),
        .ETH_PORT_TX_MTU  (ETH_PORT_TX_MTU  ),
        .LANES            (LANES            ),
        .QSFP_PORTS       (QSFP_PORTS       ),
        .QSFP_I2C_PORTS   (QSFP_I2C_PORTS   ),
        .QSFP_I2C_TRISTATE(QSFP_I2C_TRISTATE),
        .ETH_TX_HDR_WIDTH (ETH_TX_HDR_WIDTH ),
        .ETH_RX_HDR_WIDTH (ETH_RX_HDR_WIDTH ),
        .REGIONS          (REGIONS          ),
        .REGION_SIZE      (REGION_SIZE      ),
        .BLOCK_SIZE       (BLOCK_SIZE       ),
        .ITEM_WIDTH       (ITEM_WIDTH       ),
        .MI_DATA_WIDTH    (MI_DATA_WIDTH    ),
        .MI_ADDR_WIDTH    (MI_ADDR_WIDTH    ),
        .MI_DATA_WIDTH_PHY(MI_DATA_WIDTH_PHY),
        .MI_ADDR_WIDTH_PHY(MI_ADDR_WIDTH_PHY),
        .LANE_RX_POLARITY (LANE_RX_POLARITY ),
        .LANE_TX_POLARITY (LANE_TX_POLARITY ),
        .RESET_WIDTH      (RESET_WIDTH      ),
        .DEVICE           (DEVICE           ),
        .BOARD            (BOARD            )
    ) DUT_BASE_U (
        .CLK_ETH    (CLK_ETH),
        .CLK_USR    (CLK_USR   ),
        .CLK_MI     (CLK_MI    ),
        .CLK_MI_PHY (CLK_MI_PHY),
        .CLK_MI_PMD (CLK_MI_PMD),
        .CLK_TSU    (CLK_TSU   ),

        .rst_usr    (rst_usr   ),
        .rst_eth    (rst_eth   ),
        .rst_mi     (rst_mi    ),
        .rst_mi_phy (rst_mi_phy),
        .rst_mi_pmd (rst_mi_pmd),
        .rst_tsu    (rst_tsu   ),

        .usr_rx      (usr_rx     ),
        .usr_tx_data (usr_tx_data),
        .usr_tx_hdr  (usr_tx_hdr ),

        .mi     (mi    ),
        .mi_phy (mi_phy),
        .mi_pmd (mi_pmd),

        .tsu (tsu)
    );

    generate;
        for (genvar eth_it = 0; eth_it < ETH_PORTS; eth_it++) begin
            localparam int unsigned ETH_PORT_CHAN_LOCAL = ETH_PORT_CHAN[eth_it];
            initial assert(ETH_PORT_CHAN_LOCAL == 1); // TODO

            localparam int unsigned SEGMENTS = ((ETH_PORT_SPEED[0] == 400) ? 16 :
                                                (ETH_PORT_SPEED[0] == 200) ? 8  :
                                                (ETH_PORT_SPEED[0] == 100) ? 4  :
                                                (ETH_PORT_SPEED[0] == 50 ) ? 2  :
                                                (ETH_PORT_SPEED[0] == 40 ) ? 2  :
                                                (ETH_PORT_SPEED[0] == 25 ) ? 1  :
                                                (ETH_PORT_SPEED[0] == 10 ) ? 1  :
                                                                             0  );
            logic [SEGMENTS*64-1:0]           mac_data     [ETH_PORT_CHAN[eth_it]-1:0];
            logic [SEGMENTS-1:0]              mac_inframe  [ETH_PORT_CHAN[eth_it]-1:0];
            logic [SEGMENTS*3-1:0]            mac_eop_empty[ETH_PORT_CHAN[eth_it]-1:0];
            logic [SEGMENTS-1:0]              mac_fcs_error[ETH_PORT_CHAN[eth_it]-1:0];
            logic [SEGMENTS*2-1:0]            mac_error    [ETH_PORT_CHAN[eth_it]-1:0];
            logic [SEGMENTS*3-1:0]            mac_status   [ETH_PORT_CHAN[eth_it]-1:0];
            logic [ETH_PORT_CHAN[eth_it]-1:0] mac_valid;

            assign eth_tx[eth_it].DATA      = {>>{DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_adapt_data}};
            assign eth_tx[eth_it].INFRAME   = {>>{DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_adapt_inframe}};
            assign eth_tx[eth_it].EOP_EMPTY = {>>{DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_adapt_eop_empty}};
            assign eth_tx[eth_it].FCS_ERROR = {>>{DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_adapt_error}}; // Both have the same width
            assign eth_tx[eth_it].VALID     = DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_adapt_valid;

                // TX connections
            //for (genvar chan_it = 0; chan_it < ETH_PORT_CHAN[eth_it]; chan_it++) begin

            assign mac_data[0]      = eth_rx[eth_it].DATA;
            assign mac_inframe[0]   = eth_rx[eth_it].INFRAME;
            assign mac_eop_empty[0] = eth_rx[eth_it].EOP_EMPTY;
            assign mac_fcs_error[0] = eth_rx[eth_it].FCS_ERROR;
            assign mac_error[0]     = eth_rx[eth_it].ERROR;
            assign mac_status[0]    = eth_rx[eth_it].STATUS_DATA;
            assign mac_valid[0]     = eth_rx[eth_it].VALID;
            //end

            initial begin

                // RX connections
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_data      = mac_data;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_inframe   = mac_inframe;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_eop_empty = mac_eop_empty;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_fcs_error = mac_fcs_error;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_error     = mac_error;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_status    = mac_status;
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_rx_mac_valid     = mac_valid;


                // TX READY connection
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_tx_mac_ready[0] = eth_tx[eth_it].READY;
                // CLK connection
                force DUT_BASE_U.VHDL_DUT_U.eth_core_g[eth_it].network_mod_core_i.ftile_clk_out_vec[0] = CLK_ETH[eth_it];
            end
        end
    endgenerate

endmodule
