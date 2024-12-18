-- axis_splitter.vhd: AXI-Stream splitter
-- Copyright (C) 2024 CESNET
-- Author(s): Ondřej Schwarz <Ondrej.Schwarz@cesnet.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.math_pack.all;
use work.type_pack.all;

-- Component AXIS_SPLITTER is used to split one input AXI Stream interface into
-- N output AXI Stream interfaces. The target output stream for each transaction
-- is determined by the RX_AXIS_SEL signal, which is valid with the first word
-- of the transaction.
--
entity AXIS_SPLITTER is
generic (
    -- width of AXI-Stream data signal in bits
    TDATA_WIDTH   : natural := 512;
    -- width of AXI-Stream user signal in bits
    TUSER_WIDTH   : natural := 64;
    -- number of TX AXI-Stream interfaces
    TX_STREAMS    : natural := 512;
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
    -- The signal RX_AXIS_SEL determines which output stream the transaction
    -- must be sent to. The signal is valid with the first word of the transaction.
    RX_AXIS_SEL    : in  std_logic_vector(log2(TX_STREAMS)-1 downto 0);
    RX_AXIS_TDATA  : in  std_logic_vector(TDATA_WIDTH-1 downto 0);
    RX_AXIS_TUSER  : in  std_logic_vector(TUSER_WIDTH-1 downto 0);
    RX_AXIS_TKEEP  : in  std_logic_vector(TDATA_WIDTH/8-1 downto 0);
    RX_AXIS_TLAST  : in  std_logic;
    RX_AXIS_TVALID : in  std_logic;
    RX_AXIS_TREADY : out std_logic;

    -- =========================================================================
    -- TX AXI-Stream interface (CLK)
    -- =========================================================================
    TX_AXIS_TDATA  : out slv_array_t(TX_STREAMS-1 downto 0)(TDATA_WIDTH-1 downto 0);
    TX_AXIS_TUSER  : out slv_array_t(TX_STREAMS-1 downto 0)(TUSER_WIDTH-1 downto 0);
    TX_AXIS_TKEEP  : out slv_array_t(TX_STREAMS-1 downto 0)(TDATA_WIDTH/8-1 downto 0);
    TX_AXIS_TLAST  : out std_logic_vector(TX_STREAMS-1 downto 0);
    TX_AXIS_TVALID : out std_logic_vector(TX_STREAMS-1 downto 0);
    TX_AXIS_TREADY : in  std_logic_vector(TX_STREAMS-1 downto 0);
);
end entity;

architecture FULL of AXIS_SPLITTER is

begin

    -- TODO @OndřejSchwarz

end architecture;
