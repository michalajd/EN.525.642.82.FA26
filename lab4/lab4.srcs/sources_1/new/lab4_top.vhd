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
signal cnt_40 : unsigned (26 downto 0); -- constant for 25MHz signal
signal h_max : unsigned (9 downto 0); -- constant for horizontal counter (799)
signal v_max : unsigned (9 downto 0); -- constant for vertical counter (524)
signal h_cnt : unsigned (9 downto 0); -- horizontal counter
signal v_cnt : unsigned (9 downto 0); -- vertical counter
signal h_clear : std_logic; -- clear signal for horizontal count
signal v_clear : std_logic; -- clear signal for vertical count
signal x_square : unsigned(7 downto 0); -- x-coordinate of square's top left corner
signal y_square : unsigned(7 downto 0); -- y-coordinate of square's top left corner
signal x_default : unsigned (7 downto 0); -- default x-coordinate
signal y_default : unsigned (7 downto 0); -- default y-coordinate
signal btnu_db : std_logic; -- debounced up button
signal btnd_db : std_logic; -- debounced down button
signal btnl_db : std_logic; -- debounced left button
signal btnr_db : std_logic; -- debounced right button
signal x_coord : std_logic_vector (7 downto 0);
signal y_coord : std_logic_vector (7 downto 0);
signal vgaRedT : std_logic; -- enb for red
signal vgaBlueT : std_logic; -- enb for blue
signal vgaGreenT : std_logic; --enb for green

begin
    -- Create 25MHz enable pulse
    cnt_40 <= "000000000000000000000000011"; -- 3 in binary for pulse, 27 bits for pulsegen
    mhz25_inst : entity work.pulseGenerator port map (CLK, RST, cnt_40, en25);
    
    -- Assign constants for the process counters
    h_max <= "1100011111"; --799 in binary
    v_max <= "1000001100"; --524 in binary
    
    -- Assign constants for the default coordinates of square
    x_default <= "00001011"; -- 11 in binary
    y_default <= "00000111"; -- 7 in binary
    
    -- Debounce input buttons
    up_debounce : entity work.debounce port map (CLK, RST, BTNU, btnu_db);
    down_debounce : entity work.debounce port map (CLK, RST, BTND, btnd_db);
    left_debounce : entity work.debounce port map (CLK, RST, BTNL, btnl_db);
    right_debounce : entity work.debounce port map (CLK, RST, BTNR, btnr_db);
    
    -- Set up seven segment encoder
    x_coord <= std_logic_vector(x_square);
    y_coord <= std_logic_vector(y_square);
    
    inst_seg7 : entity work.seg7_controller port map (
        clk => CLK,
        rst => RST,
        char0 => y_coord(3 downto 0),
        char1 => y_coord(7 downto 4),
        char2 => x_coord(3 downto 0),
        char3 => x_coord(7 downto 4),
        char4 => "0000",
        char5 => "0000",
        char6 => "0000",
        char7 => "0000",
        char_enc => SEG7_CATH,
        anode => AN);
    
    
    -- Sequential process for the two counters
--    counters: process (CLK, RST)
--    begin
--        if RST = '1' then
--            h_cnt <= (others=>'0');
--            v_cnt <= (others=>'0');
--        elsif rising_edge(CLK) then
--            if en25 = '1' then
--                -- Statements for horizontal counter
--                if (h_clear = '1') then
--                    h_cnt <= (others=>'0');
                    
--                    -- Statements for vertical counter
--		            if (v_clear = '1') then
--                        v_cnt <= (others=>'0');
--                    else
--                        v_cnt <= v_cnt + 1;
--		            end if;
--                else
--                    h_cnt <= h_cnt + 1;
--		        end if;
--            end if;
--        end if;
--    end process counters;
    
--    h_clear <= '1' when (h_cnt = h_max) else '0';
--    v_clear <= '1' when (v_cnt = v_max) else '0';

    counters: process (CLK, RST)
    begin
        if (rst = '1') then
            h_cnt <= (others => '0');
            v_cnt <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (en25 = '1') then
                if (h_cnt < 799) then
                    h_cnt <= h_cnt + 1;
                else
                    h_cnt <= (others => '0');
                    if (v_cnt < 520) then
                        v_cnt <= v_cnt + 1;
                    else
                        v_cnt <= (others => '0');
                    end if;
                end if;
            
            end if;
        end if;
    end process counters;
    
    -- Assign VGA Horizontal and Vertical Syncs
    VGA_HS <= '1' when ((h_cnt >= 656) and (h_cnt < 752)) else '0'; -- 640+front porch, 800-back porch
    VGA_VS <= '1' when ((v_cnt >= 490) and (v_cnt < 492)) else '0'; -- 480+front porch, 525-back porch
    
    -- Process to move the red square
    square : process (CLK, RST)
    begin
        if (RST = '1') then
            x_square <= x_default;
            y_square <= y_default;
        elsif (rising_edge(CLK)) then
            if (btnu_db = '1') then
                if (y_square = "00000000") then
                    y_square <= "00001101";
                else y_square <= y_square - 1;
                end if;
            elsif (btnd_db = '1') then
                if (y_square = "00001101") then
                    y_square <= "00000000";
                else y_square <= y_square + 1;
                end if;
            elsif (btnl_db = '1') then
                if (x_square = "00000000") then
                    x_square <= "00010011";
                else x_square <= x_square - 1;
                end if;
            elsif (btnr_db = '1') then
                if (x_square = "00010011") then
                    x_square <= "00000000";
                else x_square <= x_square + 1;
                end if;
            end if;
        end if;
    end process square;
    
    
    -- Process for red
    process (h_cnt, v_cnt)
    begin
        if ((h_cnt >= 0) and (h_cnt < 640) and (v_cnt >= 0) and (v_cnt < 480)) then
            if ((h_cnt(5) = '1') xor (v_cnt(5) = '1')) then
                vgaBlueT <= '1';
                vgaRedT <= '0';
                vgaGreenT <= '0';
            else
                vgaBlueT <= '0';
                vgaRedT <= '0';
                vgaGreenT <= '1';
            end if;
        else 
            vgaRedT <= '0';
            vgaBlueT <= '0';
            vgaGreenT <= '0';
        end if;
    end process;
    
    -- Assign color outputs
    VGA_R <= (others => vgaRedT);
    VGA_B <= (others => vgaBlueT);
    VGA_G <= (others => vgaGreenT);

end Behavioral;
