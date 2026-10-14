library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulseGenerator is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           maxCount : in unsigned(5 downto 0);
           pulseOut : out STD_LOGIC);
end pulseGenerator;

architecture Behavioral of pulseGenerator is
signal pulseCnt : unsigned(5 downto 0);
signal clear : std_logic;
    begin
    --Pulse Generator
    process(clk, reset)
    begin
        if(reset = '1') then
            pulseCnt <= (others=>'0');
        elsif(rising_edge(clk)) then
            if (clear = '1') then
                pulseCnt <= (others=>'0');
            else
                pulseCnt <= pulseCnt + 1;
            end if;
        end if;
    end process;
    
    clear <= '1' when (pulseCnt = maxCount) else '0';
    pulseOut <= clear;
end Behavioral;
