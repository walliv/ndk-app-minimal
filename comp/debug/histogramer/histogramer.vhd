-- histogramer.vhd: Component for creating histograms
-- Copyright (C) 2024 CESNET z. s. p. o.
-- Author(s): Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pack.all;
use work.type_pack.all;

-- .. vhdl:autogenerics:: HISTOGRAMER
entity HISTOGRAMER is
generic (
    -- Input values width
    INPUT_WIDTH             : integer;
    -- Histogram box width (number of occurences in a given range)
    -- Box probably overflowed when its value equals 2**BOX_WIDTH-1
    BOX_WIDTH               : integer;
    -- Number of histogram boxes (defines histogram precision)
    -- Must be power of 2
    BOX_CNT                 : integer;
    -- Defines if read or write should occur when both happen at the same time
    READ_PRIOR              : boolean := false;
    -- Defines if read should erase box content
    CLEAR_BY_READ           : boolean := true;
    -- Defines if BRAM should be sequentially erased after reset
    CLEAR_BY_RST            : boolean := true
);
port(
    CLK                     : in  std_logic;
    RST                     : in  std_logic;
    RST_DONE                : out std_logic;

    -- =======================================================================
    --  Input interface
    -- =======================================================================

    INPUT_VLD               : in  std_logic;
    INPUT                   : in  std_logic_vector(INPUT_WIDTH - 1 downto 0);

    -- =======================================================================
    --  Read interface
    -- =======================================================================

    -- Request to read box specified by READ_ADDR
    READ_REQ                : in  std_logic;
    -- Box adress
    READ_ADDR               : in  std_logic_vector(log2(BOX_CNT) - 1 downto 0);
    -- The requested box is valid
    READ_BOX_VLD            : out std_logic;
    -- Requested box
    READ_BOX                : out std_logic_vector(BOX_WIDTH - 1 downto 0)
);
end entity;

-- =========================================================================

architecture FULL of HISTOGRAMER is

    -- Should equal BRAM latency
    constant PIPELINE_ITEMS     : integer := 2;

    constant ADDR_WIDTH         : integer := log2(BOX_CNT);

    type PIPELINE_T is record
        vld                 : std_logic;
        is_read             : std_logic;
        collision           : std_logic;
        addr                : std_logic_vector(ADDR_WIDTH - 1 downto 0);
        box                 : std_logic_vector(BOX_WIDTH - 1 downto 0);
    end record;

    type PIPELINE_ARRAY_T is array (integer range <>) of PIPELINE_T;

    constant STAGES         : positive := 2;

    -- Last pip_in is the output
    signal pip_in           : PIPELINE_ARRAY_T(STAGES     downto 0);
    signal pip_out          : PIPELINE_ARRAY_T(STAGES - 1 downto -1);
    signal fin_data         : PIPELINE_T;
    signal new_data         : PIPELINE_T;

    signal collision_i      : std_logic_vector(STAGES downto 0);
    signal collision        : std_logic_vector(STAGES downto 0);

    signal rd_data_vld      : std_logic;
    signal rd_data          : std_logic_vector(BOX_WIDTH - 1 downto 0);

    signal wr               : std_logic;
    signal wr_i             : std_logic;
    signal wr_clear         : std_logic;
    signal wr_erase         : std_logic;
    signal wr_data_i        : std_logic_vector(BOX_WIDTH - 1 downto 0);
    signal wr_data          : std_logic_vector(BOX_WIDTH - 1 downto 0);
    signal wr_addr          : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal wr_addr_i        : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal wr_addr_clear    : std_logic_vector(ADDR_WIDTH - 1 downto 0);

    -- Add + handle overflow
    -- When overflow occurs, the value is set to maximum
    function add_f(a : std_logic_vector ; b : std_logic_vector) return std_logic_vector is
        constant DATA_WIDTH     : integer := a'length;
        -- Width is larger by 1 bit to detect overflow
        variable tmp            : std_logic_vector(DATA_WIDTH downto 0);
        variable res            : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        tmp     := std_logic_vector(unsigned('0' & a) + unsigned('0' & b));
        res     := std_logic_vector(tmp(DATA_WIDTH - 1 downto 0)) when (tmp(DATA_WIDTH) = '0') else
                   (others => '1');
        return res;
    end function;

    function first_one_f(bits : std_logic_vector)
    return std_logic_vector is
    begin
        return bits and std_logic_vector(unsigned(not bits) + 1);
    end;

    function last_one_f(bits : std_logic_vector)
    return std_logic_vector is
        constant DATA_WIDTH : integer := bits'length;
        variable in_rot     : std_logic_vector(DATA_WIDTH - 1 downto 0);
        variable first_one  : std_logic_vector(DATA_WIDTH - 1 downto 0);
        variable out_rot    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        for i in bits'range loop
            in_rot(i) := bits(bits'length - 1 - i);
        end loop;

        first_one := first_one_f(in_rot);

        for i in bits'range loop
            out_rot(i) := first_one(bits'length - 1 - i);
        end loop;

        return out_rot;
    end;

begin

    assert INPUT_WIDTH >= log2(BOX_CNT)
        report "Histogramer: there are more histogram boxes then possible states of the input" &
            " (input width: " & integer'image(INPUT_WIDTH) & ", box_cnt: " & integer'image(BOX_CNT) & ")!"
        severity FAILURE;

    assert 2 ** log2(BOX_CNT) = BOX_CNT
        report "Histogramer: BOX CNT is not power of 2!"
        severity FAILURE;

    -- Pipeline core --
    -------------------

    pipeline_g : for i in STAGES - 1 downto 0 generate
        pipeline_p : process (CLK)
        begin
            if (rising_edge(CLK)) then
                if (RST = '1' or RST_DONE = '0') then
                    pip_out(i).vld  <= '0';
                    pip_out(i).addr <= (others => '0');
                elsif (pip_in(i).vld = '1') then
                    pip_out(i)      <= pip_in(i);
                else
                    pip_out(i).vld  <= '0';
                end if;
            end if;
        end process;
    end generate;

    -- Pipeline input --
    --------------------

    new_data.vld       <= (INPUT_VLD or READ_REQ);
    new_data.collision <= '0';

    -- MSB bits selects histogram box
    new_data.addr   <= READ_ADDR when (new_data.is_read = '1') else
                       INPUT(INPUT_WIDTH - 1 downto INPUT_WIDTH - ADDR_WIDTH);

    read_prior_g : if (READ_PRIOR = true) generate
        new_data.is_read <= READ_REQ;
    else generate
        new_data.is_read <= READ_REQ and not INPUT_VLD;
    end generate;

    -- Write will increment box by 1
    new_data.box    <= (others => '0') when (new_data.is_read = '1') else
                       std_logic_vector(to_unsigned(1, new_data.box'length));

    pip_out(-1)     <= new_data;

    -- Histogram memory --
    ----------------------

    data_i : entity work.DP_BRAM_BEHAV
    generic map (
        DATA_WIDTH  => BOX_WIDTH,
        ITEMS       => BOX_CNT
    )
    port map (
        CLK         => CLK,
        RST         => RST,

        PIPE_ENA    => '1',
        REA         => pip_in(0).vld,
        WEA         => '0',
        ADDRA       => pip_in(0).addr,
        DIA         => (others => '0'),
        DOA         => rd_data,
        DOA_DV      => rd_data_vld,

        PIPE_ENB    => '1',
        REB         => '0',
        WEB         => wr_i,
        ADDRB       => wr_addr_i,
        DIB         => wr_data_i
    );

    wr_i            <= wr       when (RST_DONE = '1') else
                       wr_clear;
    wr_addr_i       <= wr_addr  when (RST_DONE = '1') else
                       wr_addr_clear;
    wr_data_i       <= wr_data  when (RST_DONE = '1') else
                       (others => '0');

    data_clear_i : entity work.MEM_CLEAR
    generic map (
        DATA_WIDTH  => BOX_WIDTH,
        ITEMS       => BOX_CNT,
        CLEAR_EN    => CLEAR_BY_RST
    )
    port map (
        CLK         => CLK,
        RST         => RST,

        CLEAR_DONE  => RST_DONE,
        CLEAR_WR    => wr_clear,
        CLEAR_ADDR  => wr_addr_clear
    );

    -- Collision detection (between pipeline and write back) --
    -----------------------------------------------------------

    -- If collision occurs (same adress is beeing edited),
    -- write-back value will be also saved in coresponding pipeline stage
    -- Corresponding pipeline stage will ignore BRAM read data

    collision_g : for i in STAGES - 1 downto 0 generate
        collision_i(i)  <= '1' when (pip_in(i).addr = fin_data.addr and pip_in(i).vld = '1' and fin_data.vld = '1') else
                           '0';
    end generate;
    collision_i(STAGES) <= '0';

    -- When multiple collisions occurs, handle only the closest one
    -- The other collision will be handeled when the closest collision will be at the end
    collision           <= last_one_f(collision_i);

    pip_data_g : for i in STAGES downto 0 generate
        pip_in(i).vld       <= pip_out(i - 1).vld;
        pip_in(i).is_read   <= pip_out(i - 1).is_read;
        pip_in(i).addr      <= pip_out(i - 1).addr;
        pip_in(i).collision <= collision(i) or pip_out(i - 1).collision;

        pip_data_box_g : if i = STAGES generate
            -- Last stage --
            -- Read data should be valid at exactly this point
            -- If collision occured, don't use read data
            pip_in(i).box   <= add_f(pip_out(i - 1).box, rd_data) when (fin_data.collision = '0') else
                               pip_out(i - 1).box;
        else generate
            -- 2 special cases can occur during collision with the last stage
            -- * Write at the last stage wrote a new value      => update current box
            -- * Read at the last stage caused clear of the box => write only current box (don't add with old box value)
            pip_in(i).box   <= pip_out(i - 1).box when (collision(i) = '0' or wr_erase = '1') else
                               add_f(pip_out(i - 1).box, fin_data.box);
        end generate;
    end generate;

    -- Output phase --
    ------------------

    fin_data        <= pip_in(STAGES);
    READ_BOX_VLD    <= fin_data.vld and fin_data.is_read;
    READ_BOX        <= fin_data.box;

    wr              <= fin_data.vld;
    wr_erase        <= '1' when (CLEAR_BY_READ = true and fin_data.is_read = '1') else
                       '0';
    wr_addr         <= fin_data.addr;
    wr_data         <= fin_data.box when (wr_erase = '0') else
                       (others => '0');

end architecture;
