----------------------------------------------------------------------------------
--
-- Author: Michala Dennis
--
-- Description:
-- Top-level code utilizing the LEDs, switches, buttons, and seven-segment displays.
-- Switches 0-3 give a hexadecimal digit, and switches 4-11 determine which displays the
-- digit should appear on.
-- Pushbuttons C, D, and U change the behavior of what is shown based on specific
-- criteria.
-- This is part of lab 1 for EN.525.642.82.FA26 at Johns Hopkins University.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab2_top is
    Port (
            --Push Buttons
            BTNC : in STD_LOGIC;
            BTND : in STD_LOGIC;
            BTNU : in STD_LOGIC;
            --Switches (16 Switches)
            SW : in STD_LOGIC_VECTOR (15 downto 0);
            --LEDs (16 LEDs)
            LED : out STD_LOGIC_VECTOR (15 downto 0);
            --Seg7 Display Signals
            SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0);
            AN : out STD_LOGIC_VECTOR (7 downto 0));
end lab2_top;

architecture Behavioral of lab2_top is

--Declare internal signals for the switches

signal binary_sw : STD_LOGIC_VECTOR (3 downto 0);

begin
    -- Assign binary_sw signals to their respective switches
    binary_sw <= x"0" when BTNC = '1' else SW (3 downto 0);
    
    -- Assign LED outputs to switch inputs (always occurs)
    LED <= SW;
    -- Instantiate seg7
    seg7_inst : entity work.seg7_hex port map(binary_sw, SEG7_CATH);
    
    -- Instantiate process for the behavior of the 7-seg and pushbuttons
    process(BTNU, BTND, BTNC, SW)
    begin
        -- Using if/then/else to avoid scenario of two buttons pushed at once
        if (BTNU = '1') then AN <= "00001111"; -- left 4 displays on
        elsif (BTND = '1') then AN <= "11110000"; -- right 4 displays on
        elsif (BTNC = '1') then AN <= "00000000"; -- all displays show 0
        else AN <= not SW (11 downto 4); -- displays on correspond with switches
        end if;
    end process;
    
end Behavioral;