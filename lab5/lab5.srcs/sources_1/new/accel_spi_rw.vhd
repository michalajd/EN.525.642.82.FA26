----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2026 01:53:09 AM
-- Design Name: 
-- Module Name: accel_spi_rw - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity accel_spi_rw is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
            --Values from accelerometer used for movement and display
           DATA_X : out STD_LOGIC_VECTOR(7 downto 0);
           DATA_Y : out STD_LOGIC_VECTOR(7 downto 0);
           DATA_Z : out STD_LOGIC_VECTOR(7 downto 0);
           ID_AD : out STD_LOGIC_VECTOR(7 downto 0);
           ID_1D : out STD_LOGIC_VECTOR(7 downto 0);
           --SPI Signals between FPGA and accelerometer
           CSb : out STD_LOGIC;
           MOSI : out STD_LOGIC;
           SCLK : out STD_LOGIC;
           MISO : in STD_LOGIC);
end accel_spi_rw;

architecture Behavioral of accel_spi_rw is
-- Signals that interact between FSMs
signal SPIstart : STD_LOGIC; 
signal SPIdone : STD_LOGIC;

-- Signals needed for SPI interface
signal toSPIbytes : STD_LOGIC_VECTOR(23 downto 0);

-- Signals for Command FSM
type CMD_FSM_STATE is (IDLE, WRITE_ADDR2D, DONE_STARTUP, READ_ADDR00, 
                       CAPTURE_ID_AD, READ_ADDR01, CAPTURE_ID_1D, READ_ADDR08, 
                       CAPTURE_X, READ_ADDR09, CAPTURE_Y, READ_ADDR0A, CAPTURE_Z);
signal cmd_state_D, cmd_state_Q : CMD_FSM_STATE; 

-- Signals for SPI FSM
type SPI_FSM_STATE is (IDLE, SET_C_SLOW, S_CLK_HI, S_CLK_LO, 
                       INC_SCLK_CNTR, SET_CS_HI, WAIT_100MS);
signal spi_state_D, spi_state_Q : SPI_FSM_STATE;

begin

    
    -- Command FSM implementation
    command_fsm : process (cmd_state_Q, SPIdone)
    begin
        cmd_state_D <= cmd_state_Q;
        
    
    
    end process command_fsm;


end Behavioral;
