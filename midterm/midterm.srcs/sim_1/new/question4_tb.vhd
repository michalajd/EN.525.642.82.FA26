library ieee;
use ieee.std_logic_1164.all;

entity question4_tb is
end entity;

architecture sim of question4_tb is
  signal c, d, e: std_logic;
  signal q1, q2 : std_logic;
begin
  uut : entity work.question4
    port map (c => c, d => d, e => e, q1 => q1, q2 => q2);
    
    	--100MHz clock
	process
	begin
		c <= '1';
		wait for 5 ns;
		c <= '0';
		wait for 5 ns;
	end process;

    d <= '0', '1' after 15 ns, '0' after 25 ns, '1' after 45 ns, '0' after 65 ns, '1' after 95 ns, '0' after 145 ns;
    e <= '0', '1' after 15 ns, '0' after 55 ns, '1' after 75 ns, '0' after 85 ns, '1' after 115 ns, '0' after 125 ns;

end architecture;
