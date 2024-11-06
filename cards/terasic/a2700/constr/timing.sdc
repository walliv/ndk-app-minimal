# timing.sdc: Timing constraints
# Copyright (C) 2024 BrnoLogic, Ltd.
# Author(s): David Beneš <benes@brnologic.com>
#
# SPDX-License-Identifier: BSD-3-Clause

derive_clock_uncertainty

create_clock -name {altera_reserved_tck} -period 41.667 [get_ports { altera_reserved_tck }]

create_clock -name {AG_SYSCLK0} -period 10.000 [get_ports { AG_SYSCLK0_P }]
# create_clock -name {AG_SYSCLK1} -period 10.000 [get_ports { AG_SYSCLK1_P }]
create_clock -name {AG_SYSCLK1} -period 20.000 [get_ports { AG_SYSCLK1_P }]

create_clock -name {PCIE_CLK0} -period 10.000 [get_ports { PCIE_CLK0_P }]
create_clock -name {PCIE_CLK1} -period 10.000 [get_ports { PCIE_CLK1_P }]
create_clock -name {QSFP_REFCLK0} -period 6.400 [get_ports { QSFP_REFCLK0_P }]

# Cut (set_false_path) this JTAG clock from all other clocks in the design
set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]

# DDR4A
create_clock -period 30 [get_ports SODIMM_HPS_REFCLK_P]
# DDR4B
create_clock -period 30 [get_ports SODIMM0_REFCLK_P]
# DDR4C
create_clock -period 30 [get_ports SODIMM1_REFCLK_P]
# DDR4D
create_clock -period 30 [get_ports SODIMM0_REFCLK_P]


# ===========
# Global clks
# ===========
set MI_CLK_CH3  [get_clocks ag_i|clk_gen_i|iopll_i|iopll_0_outclk3]


# ============
# 400G1 design
# ============
set FHIP_400G1_CLK_CH23 [get_clocks ag_i|network_mod_i|eth_core_g[0].network_mod_core_i|ftile_1x400g8_g.eth_ip_g[0].FTILE_1x400g8_i|ftile_eth_ip_i|eth_f_0|tx_clkout|ch23]

# Fix hold timing issues for 400G1 design
set_clock_groups -asynchronous -group $MI_CLK_CH3          -group $FHIP_400G1_CLK_CH23
