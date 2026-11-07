library ieee;
use ieee.std_logic_1164.all;

entity question4 is
  port (
    c    : in  std_logic;
    d    : in  std_logic;
    e  : in std_logic;
    q1 : out std_logic;
    q2 : out std_logic
  );
end entity;

architecture rtl of question4 is
begin
  proc1: process(d, e)
  begin
    if (e = '1') then
      q1 <= d;
    end if;
  end process proc1;


  proc2: process(c)
  begin
    if (rising_edge(c)) then
      if (e = '1') then
        q2 <= d;
      end if;
    end if;

  end process proc2;
end architecture;