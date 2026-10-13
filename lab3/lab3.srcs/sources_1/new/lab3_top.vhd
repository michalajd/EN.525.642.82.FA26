library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab3_top is
Port (
    --Clock
    CLK100MHZ : in STD_LOGIC;
    --Push Buttons
    BTNC : in STD_LOGIC;
    --Switches (16 Switches)
    SW : in STD_LOGIC_VECTOR (15 downto 0);
    --LEDs (16 LEDs)
    LED : out STD_LOGIC_VECTOR (15 downto 0);
    --Seg7 Display Signals
    SEG7_CATH : out STD_LOGIC_VECTOR (7 downto 0);
    AN : out STD_LOGIC_VECTOR (7 downto 0));
end lab3_top;

architecture Behavioral of lab3_top is
--Declare array for shift register inputs
type AA is array(7 downto 0) of std_logic_vector(3 downto 0);
signal r : AA;
--Declare internal signals for the switches
signal binary_sw : STD_LOGIC_VECTOR (3 downto 0);
--Declare enable for shift register
signal sr_enb : std_logic;
begin
    -- Assign binary_sw signals to their respective switches
    binary_sw <= "0000" when BTNC = '1' else SW (3 downto 0);
    -- Assign LED outputs to switch inputs (always occurs)
    LED <= SW;
    -- Instantiate the two modules
    inst_seg7 : entity work.seg7_controller port map (
    clk => CLK100MHZ,
    rst => BTNC,
    char0 => r(0),
    char1 => r(1),
    char2 => r(2),
    char3 => r(3),
    char4 => r(4),
    char5 => r(5),
    char6 => r(6),
    char7 => r(7),
    char_enc => SEG7_CATH,
    anode => AN);
    
    inst_pulse1hz : entity work.pulseGenerator port map (
    clk => CLK100MHZ,
    reset => BTNC,
    maxCount => "101111101011110000100000000", -- constant for 100,000,000 for 1Hz signal
    pulseOut => sr_enb);
    
    --Implement shift register
    process(CLK100MHZ, BTNC)
    begin
        if(BTNC = '1') then
            r <= (others=>"0000");
        elsif(rising_edge(CLK100MHZ)) then
	        if (sr_enb = '1') then
            	r <= r(6 downto 0) & "0000";
            	r(0) <= binary_sw;
	       end if;
        end if;
    end process;
end Behavioral;