----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2026 09:25:45 PM
-- Design Name: 
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: A code to debounce a pushbutton.
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

entity debounce is
  Port (clk : in std_logic;
        rst : in std_logic;
        button_in : in std_logic;
        button_out : out std_logic );
end debounce;

architecture Behavioral of debounce is
signal counter : unsigned (23 downto 0); -- generate counter
signal count_max : unsigned (23 downto 0); -- generate counter
signal switch : std_logic; -- internal switch to track state
 
begin
    process (clk,rst)
        begin
        if (rst='1') then
            switch <= '0';
            counter <= (others=>'0');
        elsif (rising_edge(clk)) then
            if button_in = '1' then
                if counter < 10000000 then
                counter <= counter + 1;
            else
                switch <= '1';
            end if;
        else
            switch <= '0';
            counter <= (others=>'0');
        end if;
    end if;
end process;
    
    button_out <= switch;

end Behavioral;
