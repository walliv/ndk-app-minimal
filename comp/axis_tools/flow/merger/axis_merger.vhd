-- axis_merger.vhd: AXI-Stream merger
-- Copyright (C) 2024 CESNET
-- Author(s): David Vodák <vodak@cesnet.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.math_pack.all;
use work.type_pack.all;

-- Component AXIS_MERGER is used to merge N input AXI Stream interfaces into one
-- output AXI Stream interface. The merging is done in random order.
--
entity AXIS_MERGER is
generic (
    -- width of AXI-Stream data signal in bits
    TDATA_WIDTH   : natural := 512;
    -- width of AXI-Stream user signal in bits
    TUSER_WIDTH   : natural := 64;
    -- number of RX AXI-Stream interfaces
    RX_STREAMS    : natural := 512;
    -- target device: AGILEX, STRATIX10, ULTRASCALE,...
    DEVICE        : string  := "AGILEX"
);
port (
    -- =========================================================================
    -- Clock and reset signals
    -- =========================================================================
    CLK            : in  std_logic;
    RESET          : in  std_logic;

    -- =========================================================================
    -- RX AXI-Stream interfaces (CLK)
    -- =========================================================================
    RX_AXIS_TDATA  : in  slv_array_t(RX_STREAMS-1 downto 0)(TDATA_WIDTH-1 downto 0);
    RX_AXIS_TUSER  : in  slv_array_t(RX_STREAMS-1 downto 0)(TUSER_WIDTH-1 downto 0);
    RX_AXIS_TKEEP  : in  slv_array_t(RX_STREAMS-1 downto 0)(TDATA_WIDTH/8-1 downto 0);
    RX_AXIS_TLAST  : in  std_logic_vector(RX_STREAMS-1 downto 0);
    RX_AXIS_TVALID : in  std_logic_vector(RX_STREAMS-1 downto 0);
    RX_AXIS_TREADY : out std_logic_vector(RX_STREAMS-1 downto 0);

    -- =========================================================================
    -- TX AXI-Stream interface (CLK)
    -- =========================================================================
    TX_AXIS_TDATA  : out std_logic_vector(TDATA_WIDTH-1 downto 0);
    TX_AXIS_TUSER  : out std_logic_vector(TUSER_WIDTH-1 downto 0);
    TX_AXIS_TKEEP  : out std_logic_vector(TDATA_WIDTH/8-1 downto 0);
    TX_AXIS_TLAST  : out std_logic;
    TX_AXIS_TVALID : out std_logic;
    TX_AXIS_TREADY : in  std_logic;
);
end entity;

architecture FULL of AXIS_MERGER is

begin

    -- TODO @DavidVodák

end architecture;
