----------------------------------------------------------------------------------
--
-- Author: Michala Dennis
--
-- Description:
--
--
--
-- This is part of lab 3 for EN.525.642.82.FA26 at Johns Hopkins University.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity seg7_controller is
Port (
    --Synchronous inputs (clock, rst)
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    --Eight 4-bit character inputs
    char0 : in STD_LOGIC_VECTOR(3 downto 0);
    char1 : in STD_LOGIC_VECTOR(3 downto 0);
    char2 : in STD_LOGIC_VECTOR(3 downto 0);
    char3 : in STD_LOGIC_VECTOR(3 downto 0);
    char4 : in STD_LOGIC_VECTOR(3 downto 0);
    char5 : in STD_LOGIC_VECTOR(3 downto 0);
    char6 : in STD_LOGIC_VECTOR(3 downto 0);
    char7 : in STD_LOGIC_VECTOR(3 downto 0);
    --Cathode and anode outputs
    char_enc : out STD_LOGIC_VECTOR (7 downto 0);
    anode : out STD_LOGIC_VECTOR (7 downto 0));
end seg7_controller;

architecture Behavioral of seg7_controller is
--Declare internal signals for encoder, 1kHz pulse
signal count_sel : STD_LOGIC_VECTOR (2 downto 0);
signal counter : unsigned (2 downto 0);
signal maxCount8 : unsigned (2 downto 0);
signal maxCount : unsigned(26 downto 0);
signal to_7seg : STD_LOGIC_VECTOR(3 downto 0);
signal pulse_1khz : STD_LOGIC;
signal clear : STD_LOGIC;
begin
    -- Instantiate clock divider
    maxCount <= "000000000011000011010100000"; --100,000 in 26 binary digits
    maxCount8 <= "111";
    
    khzdiv_inst : entity work.pulseGenerator port map (clk, rst, maxCount, pulse_1khz);
    -- Process to count the pulses from 0-7
    process (clk, rst)
    begin
        if(rst = '1') then
            counter <= (others=>'0');
        elsif(rising_edge(clk)) then
            if (pulse_1khz = '1') then
		      if (clear = '1') then
                counter <= (others=>'0');
              else
                counter <= counter + 1;
		      end if;
            end if;
        end if;
    end process;
    clear <= '1' when (counter = maxCount8) else '0';
    count_sel <= STD_LOGIC_VECTOR(counter);
    
    -- Create multiplexer for the seven segment decoder
    with count_sel select
    to_7seg <=
        char0 when "000" ,
        char1 when "001" ,
        char2 when "010" ,
        char3 when "011" ,
        char4 when "100" ,
        char5 when "101" ,
        char6 when "110" ,
        char7 when "111" ,
        "0000" when others;
        
    -- Instantiate seg7 and assign anode output
    seg7_inst : entity work.seg7_hex port map(to_7seg, char_enc);

    with count_sel select
    anode <=
        "11111110" when "000" ,
        "11111101" when "001" ,
        "11111011" when "010" ,
        "11110111" when "011" ,
        "11101111" when "100" ,
        "11011111" when "101" ,
        "10111111" when "110" ,
        "01111111" when "111" ,
        "11111111" when others;

end Behavioral;