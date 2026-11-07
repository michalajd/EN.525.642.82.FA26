----------------------------------------------------------------------------------
-- 
-- Accelerometer Testbench to verify Accel Controller for Lab 5
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;
use work.all;

entity accel_spi_rw_tb is
end entity accel_spi_rw_tb;

architecture sim of accel_spi_rw_tb is

	signal clk : std_logic;
	signal reset : std_logic;
	
	--SPI Control Signals
	signal ACL_CSN, ACL_MOSI, ACL_SCLK, ACL_MISO : std_logic;
	
	--Output from Model which denotes if Accel is enabled/powered up
	signal acl_enabled : std_logic;
	
	signal ID_AD, ID_1D, DATA_X, DATA_Y, DATA_Z  : STD_LOGIC_VECTOR(7 downto 0);

begin

	--100MHz clock
	process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;
	
	--Main testbench process
	process
	begin
		reset <= '1';
		wait for 1 ns;
		
		assert  ACL_CSN = '1'
		report "Error: Reset condition should have ACL_CSN = '1'"
		severity failure;
		
		assert  ACL_SCLK = '0'
        report "Error: Reset condition should have ACL_SCLK = '0'"
        severity failure;
		
		wait for 100 ns;
		reset <= '0';
		
		--TODO: Verify acl_enabled goes high after initial write
		wait for 50 us;
		
		assert acl_enabled = '1'
		report "Error: Accelerometer was not successfully enabled."
		severity failure;
		
		--TODO: Add Verification for DATA_X, Y, Z, and ID_AD/1D
		wait for 200 us;
		
		assert ID_AD = x"AD"
		report "Error: ID_AD expected 0xAD"
		severity failure;
		
		assert ID_1D = x"1D"
		report "Error: ID_1D expected 0x1D"
		severity failure;
		
		assert DATA_X = x"12"
		report "Error: DATA_X expected 0x12"
		severity failure;
		
		assert DATA_Y = x"34"
		report "Error: DATA_Y expected 0x34"
		severity failure;
		
		assert DATA_Z = x"56"
		report "Error: DATA_Z expected 0x56"
		severity failure;
	   
	   -- Report if everything passed
	   report "The accel_spi_rw testbench has passed" severity note;
		wait;
	end process;
	
	--ACL Model
	ACL_DUMMY : entity acl_model port map (
		rst => reset,
		ACL_CSN => ACL_CSN, 
		ACL_MOSI => ACL_MOSI,
		ACL_SCLK => ACL_SCLK,
		ACL_MISO => ACL_MISO,
		--- ACCEL VALUES ---
		X_VAL => x"12",
		Y_VAL => x"34",
		Z_VAL => x"56",
		acl_enabled => acl_enabled);
	
	--Unit under test
	ACEL_DUT : entity accel_spi_rw port map (
		clk => clk,
		reset =>  reset,
		--Values from Accel
		DATA_X => DATA_X,
		DATA_Y => DATA_Y,
		DATA_Z => DATA_Z,
		ID_AD => ID_AD,
		ID_1D => ID_1D,
		--SPI Signals
		CSb => ACL_CSN,
		MOSI => ACL_MOSI,
		SCLK => ACL_SCLK,
		MISO => ACL_MISO);

end sim;