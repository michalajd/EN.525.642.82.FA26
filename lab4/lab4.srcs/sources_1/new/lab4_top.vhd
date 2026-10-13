----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2026 10:39:30 PM
-- Design Name: 
-- Module Name: lab4_top - Behavioral
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
use IEEE.NUMERIC_STD.all;

entity lab4_top is
    Port (CLK       : in std_logic; --100MHz clock signal
          RST       : in std_logic; --reset (sw0)
          BTNU      : in std_logic; --btnu (up)
          BTND      : in std_logic; --btnd (down)
          BTNL      : in std_logic; --btnl (left)
          BTNR      : in std_logic; --btnr (right)
          VGA_R     : out std_logic_vector (3 downto 0); --vga red input
          VGA_B     : out std_logic_vector (3 downto 0); --vga blue input
          VGA_G     : out std_logic_vector (3 downto 0); --vga green input
          VGA_HS    : out std_logic; --vga horizontal sync
          VGA_VS    : out std_logic; --vga vertical sync
          SEG7_CATH : out std_logic_vector (7 downto 0); -- seg7 cathodes
          AN        : out std_logic_vector (7 downto 0)); --seg7 anodes
end lab4_top;

architecture Behavioral of lab4_top is
-- Define internal logic
signal en25 : std_logic; -- 25MHz enable
signal cnt_40 : unsigned (5 downto 0); -- constant for 25MHz signal
signal h_max : unsigned (9 downto 0); -- constant for horizontal counter (799)
signal v_max : unsigned (9 downto 0); -- constant for vertical counter (520)
signal h_cnt : unsigned (9 downto 0); -- horizontal counter
signal v_cnt : unsigned (9 downto 0); -- vertical counter
signal h_clear : std_logic; -- clear signal for horizontal count
signal v_clear : std_logic; -- clear signal for vertical count

begin
    -- Create 25MHz enable pulse
    cnt_40 <= "101000"; -- 40 in binary for pulse
    mhz25_inst : entity work.pulseGenerator port map (CLK, RST, cnt_40, en25);
    
    -- Assign constants for the process counters
    h_max <= "1100011111"; --799 in binary
    v_max <= "1000001000"; --520 in binary
    
    -- Sequential process for the two counters
    process (CLK, RST)
    begin
        if rst = '1' then
            h_max <= (others=>'0');
            v_max <= (others=>'0');
        elsif rising_edge(CLK) then
            if en25 = '1' then
                -- Statements for horizontal counter
                if (h_clear = '1') then
                    h_cnt <= (others=>'0');
                else
                    h_cnt <= h_cnt + 1;
		        end if;
		        
		        -- Statements for vertical counter
		        if (v_clear = '1') then
                    v_cnt <= (others=>'0');
                else
                    v_cnt <= v_cnt + 1;
		        end if;
            end if;
        end if;
        h_clear <= '1' when (h_cnt = h_max) else '0';
        v_clear <= '1' when (v_cnt = v_max) else '0';
    end process;

end Behavioral;
