----------------------------------------------------------------------------------
--
-- Author: Michala Dennis
--
-- Description:
-- Top-level code utilizing the LEDs, switches, buttons, and seven-segment displays.
-- Switches 0-3 give a hexadecimal digit, and switches 4-11 determine which displays the
--digit should appear on.
-- Pushbuttons C, D, and U change the behavior of what is shown based on specific
--criteria.
-- This is part of lab 1 for EN.525.642.82.FA26 at Johns Hopkins University.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab1_top is
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
end lab1_top;

architecture Behavioral of lab1_top is

--Declare internal signals for the switches

signal binary_sw : STD_LOGIC_VECTOR (3 downto 0);

begin
    -- Assign binary_sw signals to their respective switches
    binary_sw <= x"0" when BTNC = '1' else SW (3 downto 0);
    
    -- Assign LED outputs to switch inputs (always occurs)
    LED <= SW;
    -- Instantiate seg7
    seg7_inst : entity work.seg7_hex port map(binary_sw, SEG7_CATH);
    -- Begin conditional chain
    -- Using when/else statements as priority is inferred. This prevents error of two buttons
    -- pressed at once
    -- Upper four displays:
    AN (7 downto 4) <= "0000" when BTNU = '1' else -- BTNU: Upper four displays show value
    -- from switches 3-0
    "1111" when BTND = '1' else -- BTND: Upper four displays are off
    "0000" when BTNC = '1' else -- BTNC: All eight displays show 0
    not SW (11 downto 8); -- DEFAULT: Show value from switches 3-0 when
    -- corresponding switch is HIGH
    -- Lower four displays:
    AN (3 downto 0) <= "1111" when BTNU = '1' else -- BTNU: Lower four displays are off
    "0000" when BTND = '1' else -- BTND: Lower four displays show value from
    -- switches 3-0
    "0000" when BTNc = '1' else -- BTNC: All eight displays show 0
    not SW (7 downto 4); -- DEFAULT: Show value from switches 3-0 when
    -- corresponding switch is HIGH

end Behavioral;