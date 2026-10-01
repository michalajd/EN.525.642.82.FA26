library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

-- empty entity
entity testPulseGenerator_tb is
end testPulseGenerator_tb;

architecture testbench of testPulseGenerator_tb is
signal clock : std_logic;
signal reset : std_logic;
signal MaxCounter1 : unsigned(26 downto 0);
signal Pulse1KHz : std_logic;
begin
    
    pulseGenerator_cut: entity pulseGenerator port map (
        clk => clock,
        reset => reset,
        maxCount => MaxCounter1,
        pulseOut => Pulse1KHz);
    -- referenced from the start of the simulation
    reset <= '0', '1' after 20 ns, '0' after 120 ns;
    -- Binary value for 100,000 with 27 binary digits
    MaxCounter1 <= "000000000011000011010100000";
    process -- no sensitivity list
    begin
        clock <= '1';
        wait for 5 ns;
        clock <= '0';
        wait for 5 ns;
    end process;
end testbench;
