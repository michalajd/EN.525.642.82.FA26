----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.04.2020 11:07:41
-- Design Name: 
-- Module Name: VGA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;

entity VGA is
    Port ( red_out : out STD_LOGIC;
           green_out : out STD_LOGIC;
           blue_out : out STD_LOGIC;
           hs_out : out STD_LOGIC;
           vs_out : out STD_LOGIC;
           clk100_in : in STD_LOGIC);
end VGA;

architecture Behavioral of VGA is
signal horizontal_counter : unsigned(10 downto 0);
signal vertical_counter   : unsigned(10 downto 0);

type font_array is array (0 to 31) of std_logic_vector(31 downto 0);
constant big_C : font_array := (
    "00000111111111111111111111110000",
    "00011111111111111111111111111100",
    "00111111111111111111111111111110",
    "01111111111111111111111111111110",
    "01111100000000000000000000000000",
    "11111000000000000000000000000000",
    "11110000000000000000000000000000",
    "11110000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11100000000000000000000000000000",
    "11110000000000000000000000000000",
    "11110000000000000000000000000000",
    "11111000000000000000000000000000",
    "01111100000000000000000000000000",
    "01111111111111111111111111111110",
    "00111111111111111111111111111110",
    "00011111111111111111111111111100",
    "00000111111111111111111111110000",
    "00000000000000000000000000000000",
    "00000000000000000000000000000000",
    "00000000000000000000000000000000",
    "00000000000000000000000000000000"
);

constant SCREEN_WIDTH  : integer := 1280;
constant SCREEN_HEIGHT : integer := 1024;

constant C_WIDTH  : integer := 32;
constant C_HEIGHT : integer := 32;

constant C_X : integer := SCREEN_WIDTH / 2 - C_WIDTH / 2;
constant C_Y : integer := SCREEN_HEIGHT / 2 - C_HEIGHT / 2;

begin

--generate a 50Mhz clock
process (clk100_in)
    variable x, y   : integer;
    variable char_x, char_y : integer;
begin

    if clk100_in'event and clk100_in = '1' then
        -- Default to black
        red_out   <= '0';
        green_out <= '0';
        blue_out  <= '0';

        x := to_integer(horizontal_counter);
        y := to_integer(vertical_counter);

        -- Draw the big C in white
        if (x >= C_X and x < C_X + C_WIDTH) and
           (y >= C_Y and y < C_Y + C_HEIGHT) then

            char_x := x - C_X;
            char_y := y - C_Y;

            if big_C(char_y)(31 - char_x) = '1' then
                red_out   <= '1';
                green_out <= '1';
                blue_out  <= '1';
            end if;
        end if;

        -- Horizontal sync
        if horizontal_counter < 112 then
            hs_out <= '0';
        else
            hs_out <= '1';
        end if;

        -- Vertical sync
        if vertical_counter < 3 then
            vs_out <= '0';
        else
            vs_out <= '1';
        end if;

        -- Horizontal Counter
        if horizontal_counter = 1687 then  -- 1280 + 408
            horizontal_counter <= (others => '0');

            -- Vertical Counter
            if vertical_counter = 1065 then  -- 1024 + 41
                vertical_counter <= (others => '0');
            else
                vertical_counter <= vertical_counter + 1;
            end if;
        else
            horizontal_counter <= horizontal_counter + 1;
        end if;

    end if;
end process;

end Behavioral;