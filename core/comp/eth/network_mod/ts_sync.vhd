-- ts_sync.vhd: Timestamps synchronizer for the Network_mod
-- Copyright (C) 2024 CESNET z. s. p. o.
-- Author(s): Stepan Friedl <friedl@cesnet.cz>
-- SPDX-License-Identifier: BSD-3-Clause

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TS_SYNC is
generic (
    DEVICE       : string := "STRATIX10"; -- AGILEX, STRATIX10, ULTRASCALE
    TS_TIMEOUT_W : natural := 3
);
port (
    TSU_RST      : in std_logic;
    TSU_CLK      : in std_logic;
    TSU_TS_NS    : in std_logic_vector(63 downto 0);
    TSU_TS_DV    : in std_logic;
    --
    SYNC_RST     : in std_logic;
    SYNC_CLK     : in std_logic;
    SYNCED_TS_NS : out std_logic_vector(63 downto 0);
    SYNCED_TS_DV : out std_logic
 );
end entity;

architecture behavioral of TS_SYNC is

    signal asfifox_ts_ns       : std_logic_vector(63 downto 0);
    signal asfifox_ts_dv_n     : std_logic;
    signal asfifox_ts_timeout  : unsigned(TS_TIMEOUT_W-1 downto 0);
    signal asfifox_ts_last_vld : std_logic;

begin

    ts_asfifox_i : entity work.ASFIFOX
    generic map(
        DATA_WIDTH => 64    ,
        ITEMS      => 32    ,
        RAM_TYPE   => "LUT" ,
        FWFT_MODE  => true  ,
        OUTPUT_REG => true  ,
        DEVICE     => DEVICE
    )
    port map (
        WR_CLK    => TSU_CLK   ,
        WR_RST    => TSU_RST   ,
        WR_DATA   => TSU_TS_NS ,
        WR_EN     => TSU_TS_DV ,
        WR_FULL   => open      ,
        WR_AFULL  => open      ,
        WR_STATUS => open      ,

        RD_CLK    => SYNC_CLK       ,
        RD_RST    => SYNC_RST       ,
        RD_DATA   => asfifox_ts_ns  ,
        RD_EN     => '1'            ,
        RD_EMPTY  => asfifox_ts_dv_n,
        RD_AEMPTY => open           ,
        RD_STATUS => open
    );

    process(SYNC_CLK)
    begin
        if (rising_edge(SYNC_CLK)) then
            if (asfifox_ts_dv_n = '1' and asfifox_ts_timeout(TS_TIMEOUT_W-1) = '0') then
                asfifox_ts_timeout <= asfifox_ts_timeout + 1;
            end if;
            if (SYNC_RST = '1' or asfifox_ts_dv_n = '0') then
                asfifox_ts_timeout <= (others => '0');
            end if;
        end if;
    end process;

    process(SYNC_CLK)
    begin
        if (rising_edge(SYNC_CLK)) then
            if (asfifox_ts_dv_n = '0') then
                asfifox_ts_last_vld <= '1';
            end if;
            if (SYNC_RST = '1') then
                asfifox_ts_last_vld <= '0';
            end if;
        end if;
    end process;

    -- Synced TS is valid if the value is current or if the value is a few
    -- clock cycles old. This provides filtering for occasional flushing of
    -- the asynchronous FIFO.
    process(SYNC_CLK)
    begin
        if (rising_edge(SYNC_CLK)) then
            if (asfifox_ts_dv_n = '0') then
                SYNCED_TS_NS <= asfifox_ts_ns;
            end if;

            SYNCED_TS_DV <= (not asfifox_ts_dv_n) or
                               (asfifox_ts_last_vld and not asfifox_ts_timeout(TS_TIMEOUT_W-1));

            if (SYNC_RST = '1') then
                SYNCED_TS_DV <= '0';
            end if;
        end if;
    end process;

end architecture;
