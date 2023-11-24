-- application_core.vhd: User application core
-- Copyright (C) 2023 CESNET z. s. p. o.
-- Author(s): Vladislav Valek <valekv@cesnet.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.math_pack.all;
use work.type_pack.all;
use work.eth_hdr_pack.all;
use work.combo_user_const.all;

architecture FULL of APPLICATION_CORE is
    signal sync_mi_dwr  : std_logic_vector(MI_DATA_WIDTH-1 downto 0);
    signal sync_mi_addr : std_logic_vector(MI_ADDR_WIDTH-1 downto 0);
    signal sync_mi_be   : std_logic_vector(MI_DATA_WIDTH/8-1 downto 0);
    signal sync_mi_rd   : std_logic;
    signal sync_mi_wr   : std_logic;
    signal sync_mi_drd  : std_logic_vector(MI_DATA_WIDTH-1 downto 0);
    signal sync_mi_ardy : std_logic;
    signal sync_mi_drdy : std_logic;

    signal proc_rst : std_logic;

    signal proc_rst_buffered : std_logic;
    --signal proc_rst0_buffered : std_logic;
    --signal proc_rst1_buffered : std_logic;
    --signal proc_rst2_buffered : std_logic;

    signal proc_rst_reg_1 : std_logic;
    signal proc_rst_reg_2 : std_logic;
    signal proc_rst_reg_3 : std_logic;
    signal proc_rst_reg_4 : std_logic;
    signal proc_rst_reg_5 : std_logic;
    signal proc_rst_reg_6 : std_logic;

    --signal proc_rst_reg_7 : std_logic;
    --signal proc_rst_reg_8 : std_logic;
    --signal proc_rst_reg_9 : std_logic;

    --attribute max_fanout : integer;
    --attribute max_fanout of proc_rst  : signal is 15;
    --attribute max_fanout of proc_rst_reg_1  : signal is 10;
    --attribute max_fanout of proc_rst_reg_2  : signal is 10;
    --attribute max_fanout of proc_rst_reg_3  : signal is 10;
    --attribute max_fanout of proc_rst_reg_4  : signal is 10;
    --attribute max_fanout of proc_rst_reg_5  : signal is 10;
    --attribute max_fanout of proc_rst_reg_6  : signal is 10;
    --attribute max_fanout of proc_rst_reg_7  : signal is 10;
    --attribute max_fanout of proc_rst_reg_8  : signal is 10;
    --attribute max_fanout of proc_rst_reg_9  : signal is 10;
    --signal proc_rst0_reg_4 : std_logic;
    --signal proc_rst0_reg_5 : std_logic;
    --signal proc_rst0_reg_6 : std_logic;

    --signal proc_rst1_reg_4 : std_logic;
    --signal proc_rst1_reg_5 : std_logic;
    --signal proc_rst1_reg_6 : std_logic;

    --signal proc_rst2_reg_4 : std_logic;
    --signal proc_rst2_reg_5 : std_logic;
    --signal proc_rst2_reg_6 : std_logic;

    attribute DONT_TOUCH                    : boolean;
    attribute DONT_TOUCH of proc_rst          : signal is true;

    --attribute DONT_TOUCH of proc_rst0_buffered : signal is true;
    --attribute DONT_TOUCH of proc_rst1_buffered : signal is true;
    --attribute DONT_TOUCH of proc_rst2_buffered : signal is true;

    attribute DONT_TOUCH of proc_rst_reg_1    : signal is true;
    attribute DONT_TOUCH of proc_rst_reg_2    : signal is true;
    attribute DONT_TOUCH of proc_rst_reg_3    : signal is true;

    attribute DONT_TOUCH of proc_rst_reg_4    : signal is true;
    attribute DONT_TOUCH of proc_rst_reg_5    : signal is true;
    attribute DONT_TOUCH of proc_rst_reg_6    : signal is true;

    --attribute DONT_TOUCH of proc_rst0_reg_4    : signal is true;
    --attribute DONT_TOUCH of proc_rst0_reg_5    : signal is true;
    --attribute DONT_TOUCH of proc_rst0_reg_6    : signal is true;

    --attribute DONT_TOUCH of proc_rst1_reg_4    : signal is true;
    --attribute DONT_TOUCH of proc_rst1_reg_5    : signal is true;
    --attribute DONT_TOUCH of proc_rst1_reg_6    : signal is true;

    --attribute DONT_TOUCH of proc_rst2_reg_4    : signal is true;
    --attribute DONT_TOUCH of proc_rst2_reg_5    : signal is true;
    --attribute DONT_TOUCH of proc_rst2_reg_6    : signal is true;
begin

    assert (ETH_STREAMS = 1 and DMA_STREAMS = 1)
        report "APPLICATION: Unsupported amount of streams, only 1 is supported for DMA and ETH"
        severity FAILURE;

    -- =========================================================================
    --  CLOCK AND RESETS DEFINED BY USER
    -- =========================================================================

    MI_CLK     <= CLK_USER;
    DMA_CLK    <= CLK_USER_X2;
    DMA_CLK_X2 <= CLK_USER_X4;
    APP_CLK    <= CLK_USER_X4;

    MI_RESET     <= RESET_USER;
    DMA_RESET    <= RESET_USER_X2;
    DMA_RESET_X2 <= RESET_USER_X4;
    APP_RESET    <= RESET_USER_X4;

    -- =========================================================================
    --  MI32 LOGIC
    -- =========================================================================
    mi_async_i : entity work.MI_ASYNC
        generic map(
            ADDR_WIDTH => MI_ADDR_WIDTH,
            DATA_WIDTH => MI_DATA_WIDTH,
            DEVICE     => DEVICE
            )
        port map(
            CLK_M     => MI_CLK,
            RESET_M   => MI_RESET(0),

            MI_M_DWR  => MI_DWR,
            MI_M_ADDR => MI_ADDR,
            MI_M_RD   => MI_RD,
            MI_M_WR   => MI_WR,
            MI_M_BE   => MI_BE,
            MI_M_DRD  => MI_DRD,
            MI_M_ARDY => MI_ARDY,
            MI_M_DRDY => MI_DRDY,

            CLK_S     => APP_CLK,
            RESET_S   => APP_RESET(0),

            MI_S_DWR  => sync_mi_dwr,
            MI_S_ADDR => sync_mi_addr,
            MI_S_RD   => sync_mi_rd,
            MI_S_WR   => sync_mi_wr,
            MI_S_BE   => sync_mi_be,
            MI_S_DRD  => sync_mi_drd,
            MI_S_ARDY => sync_mi_ardy,
            MI_S_DRDY => sync_mi_drdy
            );

    barrel_proc_debug_core_i : entity work.BARREL_PROC_DEBUG_CORE
        generic map (
            MI_WIDTH => MI_ADDR_WIDTH)
        port map (
            CLK       => APP_CLK,
            RESET     => APP_RESET(0),

            RESET_OUT => proc_rst ,
            MI_ADDR   => sync_mi_addr,
            MI_DWR    => sync_mi_dwr,
            MI_BE     => sync_mi_be,
            MI_RD     => sync_mi_rd,
            MI_WR     => sync_mi_wr,
            MI_DRD    => sync_mi_drd,
            MI_ARDY   => sync_mi_ardy,
            MI_DRDY   => sync_mi_drdy);

    prebufg_rst_regs:process (APP_CLK) is
    begin
        if (rising_edge(APP_CLK)) then
                proc_rst_reg_1  <= proc_rst;
                proc_rst_reg_2  <= proc_rst_reg_1;
                proc_rst_reg_3  <= proc_rst_reg_2;

                proc_rst_reg_4  <= proc_rst_reg_3;
                proc_rst_reg_5  <= proc_rst_reg_4;
                proc_rst_reg_6  <= proc_rst_reg_5;
                --proc_rst_reg_7  <= proc_rst_reg_6;
                --proc_rst_reg_8  <= proc_rst_reg_7;
                --proc_rst_reg_9  <= proc_rst_reg_8;
		--proc_rst_buffered <= proc_rst_reg_9;
        end if;
    end process;

    --mi_rst0_buf_i : BUFG
    --port map (
    --    O => proc_rst0_buffered,
    --    I => proc_rst_reg_6
    --);

    mi_rst_buf_i : BUFG
    port map (
        O => proc_rst_buffered,
        I => proc_rst_reg_6
    );
    --prebufg_rst0_regs:process (APP_CLK) is
    --begin
    --    if (rising_edge(APP_CLK)) then
    --            proc_rst0_reg_4  <= proc_rst_reg_3;
    --            proc_rst0_reg_5  <= proc_rst0_reg_4;
    --            proc_rst0_reg_6  <= proc_rst0_reg_5;
    --    end if;
    --end process;

    --mi_rst0_buf_i : BUFG
    --port map (
    --    O => proc_rst0_buffered,
    --    I => proc_rst0_reg_6
    --);

    --prebufg_rst1_regs:process (APP_CLK) is
    --begin
    --    if (rising_edge(APP_CLK)) then
    --            proc_rst1_reg_4  <= proc_rst_reg_3;
    --            proc_rst1_reg_5  <= proc_rst1_reg_4;
    --            proc_rst1_reg_6  <= proc_rst1_reg_5;
    --    end if;
    --end process;

    --mi_rst1_buf_i : BUFG
    --port map (
    --    O => proc_rst1_buffered,
    --    I => proc_rst1_reg_6
    --);

    --prebufg_rst2_regs:process (APP_CLK) is
    --begin
    --    if (rising_edge(APP_CLK)) then
    --            proc_rst2_reg_4  <= proc_rst_reg_3;
    --            proc_rst2_reg_5  <= proc_rst2_reg_4;
    --            proc_rst2_reg_6  <= proc_rst2_reg_5;
    --    end if;
    --end process;

    --mi_rst2_buf_i : BUFG
    --port map (
    --    O => proc_rst2_buffered,
    --    I => proc_rst2_reg_6
    --);

    -- =========================================================================
    --  APPLICATION SUBCORE(s)
    -- =========================================================================
    subcore_i : entity work.APP_SUBCORE
        generic map (
            MFB_REGIONS     => MFB_REGIONS,
            MFB_REGION_SIZE => MFB_REG_SIZE,
            MFB_BLOCK_SIZE  => MFB_BLOCK_SIZE,
            MFB_ITEM_WIDTH  => MFB_ITEM_WIDTH,

            USR_PKT_SIZE_MAX => DMA_RX_FRAME_SIZE_MAX)
        port map (
            CLK   => APP_CLK,
            -- RESET => APP_RESET(1) or proc_rst,
            -- RESET => APP_RESET(1) or proc_rst,
            RESET => proc_rst_buffered,
            --RESET(0) => proc_rst0_buffered,
            --RESET(1) => proc_rst1_buffered,
            --RESET(2) => proc_rst2_buffered,

            DMA_RX_MFB_META_PKT_SIZE => DMA_RX_MVB_LEN,
            -- <put_your_nice_channel_output_here> => DMA_RX_MVB_CHANNEL
            channel             => DMA_RX_MVB_CHANNEL,

            DMA_RX_MFB_DATA    => DMA_RX_MFB_DATA,
            DMA_RX_MFB_SOF     => DMA_RX_MFB_SOF,
            DMA_RX_MFB_EOF     => DMA_RX_MFB_EOF,
            DMA_RX_MFB_SOF_POS => DMA_RX_MFB_SOF_POS,
            DMA_RX_MFB_EOF_POS => DMA_RX_MFB_EOF_POS,
            DMA_RX_MFB_SRC_RDY => DMA_RX_MFB_SRC_RDY(0),
            DMA_RX_MFB_DST_RDY => DMA_RX_MFB_DST_RDY(0));

    -- =============================================================================================
    -- Connection of interfaces that can be OPTIONALLY used
    -- =============================================================================================

    DMA_TX_MFB_DST_RDY <= (others => '1');

    DMA_RX_MVB_HDR_META <= (others => '0');

    -- =============================================================================================
    -- Connection of interfaces that will NEVER be used
    -- =============================================================================================
    DMA_TX_MVB_DST_RDY <= (others => '1');

    DMA_RX_MVB_DISCARD  <= (others => '0');
    DMA_RX_MVB_VLD      <= (others => '0');
    DMA_RX_MVB_SRC_RDY  <= (others => '0');

    ETH_TX_MFB_DATA    <= (others => '0');
    ETH_TX_MFB_HDR     <= (others => '0');
    ETH_TX_MFB_SOF     <= (others => '0');
    ETH_TX_MFB_EOF     <= (others => '0');
    ETH_TX_MFB_SOF_POS <= (others => '0');
    ETH_TX_MFB_EOF_POS <= (others => '0');
    ETH_TX_MFB_SRC_RDY <= (others => '0');

    ETH_RX_MVB_DST_RDY <= (others => '1');
    ETH_RX_MFB_DST_RDY <= (others => '1');

    MEM_AVMM_READ       <= (others => '0');
    MEM_AVMM_WRITE      <= (others => '0');
    MEM_AVMM_ADDRESS    <= (others => (others => '0'));
    MEM_AVMM_BURSTCOUNT <= (others => (others => '0'));
    MEM_AVMM_WRITEDATA  <= (others => (others => '0'));

    MEM_REFR_PERIOD <= (others => (others => '0'));
    MEM_REFR_REQ    <= (others => '0');

    EMIF_RST_REQ        <= (others => '0');
    EMIF_AUTO_PRECHARGE <= (others => '0');
end architecture;
