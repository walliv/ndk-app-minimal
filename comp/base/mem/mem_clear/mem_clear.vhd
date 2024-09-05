-- mem_clear.vhd: Unit for clearing BRAM memories
-- Copyright (C) 2024 CESNET z. s. p. o.
-- Author(s): Lukas Nevrkla <xnevrk03@stud.fit.vutbr.cz>
--
-- SPDX-License-Identifier: BSD-3-Clause

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pack.all;
use work.type_pack.all;

entity MEM_CLEAR is
generic (
    DATA_WIDTH  : integer := 32;
    ITEMS       : integer := 512;
    -- Will disable memory clearing during RST
    CLEAR_EN    : boolean := true
);
port (
    CLK         : in  std_logic;
    RST         : in  std_logic;

    -- All addresses were generated
    CLEAR_DONE  : out std_logic;
    -- Clear address given by CLEAR_ADDR
    CLEAR_WR    : out std_logic;
    CLEAR_ADDR  : out std_logic_vector(log2(ITEMS) - 1 downto 0)
);
end entity;

architecture FULL of MEM_CLEAR is

    type FSM_STATES_T is (
        CLEAR,
        RUNNING
    );

    -- State machine --

    signal curr_state           : FSM_STATES_T;
    signal next_state           : FSM_STATES_T;

    signal addr_i               : std_logic_vector(log2(ITEMS)-1 downto 0);
    signal addr_r               : std_logic_vector(log2(ITEMS)-1 downto 0);
    signal rst_r                : std_logic;

 begin

    CLEAR_ADDR          <= addr_i;

    reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            addr_r      <= addr_i;
            rst_r       <= RST;
        end if;
    end process;

    -------------------
    -- STATE MACHINE --
    -------------------

    state_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                if (CLEAR_EN = true) then
                    curr_state <= CLEAR;
                else
                    curr_state <= RUNNING;
                end if;
            else
                curr_state <= next_state;
            end if;
        end if;
    end process;

    -- Output logic
    process (all)
    begin
        CLEAR_DONE          <= '0';
        CLEAR_WR            <= '0';
        next_state          <= curr_state;

        case curr_state is
            when CLEAR =>
                if (RST = '0') then
                    CLEAR_wR    <= '1';

                    if (rst_r = '1') then
                        addr_i  <= (others => '0');
                    else
                        addr_i  <= std_logic_vector(unsigned(addr_r) + 1);
                    end if;

                    if (unsigned(addr_i) = (ITEMS - 1)) then
                        next_state  <= RUNNING;
                    end if;
                end if;

            when RUNNING =>
                CLEAR_DONE      <= '1';
        end case;
    end process;

end architecture;
