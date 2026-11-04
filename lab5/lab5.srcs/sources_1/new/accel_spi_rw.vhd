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
signal timerMax : unsigned(26 downto 0); -- Max value for counter for timer
signal timerCntr : unsigned(26 downto 0); -- Counter for the timer
signal timerStart : STD_LOGIC; -- Logic signal to start counters
signal timerDone : STD_LOGIC; -- Logic signal to signify completed counters
signal sClkCntr : unsigned(4 downto 0); -- Counter for SCLK to be high for 24 periods

-- Signals for parallel and serial shift registers
signal parallel_sr : STD_LOGIC_VECTOR(23 downto 0);
signal serial_sr : STD_LOGIC_VECTOR(23 downto 0);

-- Signals for Command FSM
type CMD_FSM_STATE is (IDLE, WRITE_ADDR2D, DONE_STARTUP, READ_ADDR00, 
                       CAPTURE_ID_AD, READ_ADDR01, CAPTURE_ID_1D, READ_ADDR08, 
                       CAPTURE_X, READ_ADDR09, CAPTURE_Y, READ_ADDR0A, CAPTURE_Z);
signal cmd_state_D, cmd_state_Q : CMD_FSM_STATE; 

-- Signals for SPI FSM
type SPI_FSM_STATE is (IDLE, SET_CS_LOW, S_CLK_HI, S_CLK_LO, 
                       INC_SCLK_CNTR, CHECK_SCLK_CNTR, SET_CS_HI, WAIT_100MS);
signal spi_state_D, spi_state_Q : SPI_FSM_STATE;

begin
    -- Process for setting clock and reset condition
    clocking : process (clk, reset)
    begin
      if (reset = '1') then
        -- Restart FSMs
        cmd_state_Q <= IDLE;
        spi_state_Q <= IDLE;
        sClkCntr <= "00000";

        -- Reset variables
        timerDone <= '0';

      elsif (rising_edge(clk)) then

      end if;

    end process clocking;
    
    -- Command FSM implementation
    command_fsm : process (cmd_state_Q, SPIdone)
    begin
        -- Assign state logic and default values
        cmd_state_D <= cmd_state_Q;
        SPIstart <= '0';
        toSPIbytes <= x"000000";

        -- Begin case statement for Command FSM
        case (cmd_state_Q) is
          when IDLE =>
            toSPIbytes <= x"0A2D02"; --write "02" to register 2D to power ADXL362
            SPIstart <= '1';
            cmd_state_D <= WRITE_ADDR2D;

          when WRITE_ADDR2D =>
            if SPIdone = '1' then
              cmd_state_D <= DONE_STARTUP;
            elsif SPIdone = '0' then
              cmd_state_D <= WRITE_ADDR2D;
            end if;

          when DONE_STARTUP =>
            toSPIbytes <= x"0B0000"; --read value at register 00
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR00;

          when READ_ADDR00 =>
            if SPIdone = '1' then
              cmd_state_D <= CAPTURE_ID_AD;
            elsif SPIdone = '0' then
              cmd_state_D <= READ_ADDR00;
            end if;

          when CAPTURE_ID_AD =>
            toSPIbytes <= x"0B0100"; --read value at register 01
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR01;

          when READ_ADDR01 =>
            if SPIdone = '1' then
              cmd_state_D <= CAPTURE_ID_1D;
            elsif SPIdone = '0' then
              cmd_state_D <= READ_ADDR01;
            end if;

          when CAPTURE_ID_1D =>
            toSPIbytes <= x"0B0800"; --read value at register 08 (x-val)
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR08;

          when READ_ADDR08 =>
            if SPIdone = '1' then
              cmd_state_D <= CAPTURE_X;
            elsif SPIdone = '0' then
              cmd_state_D <= READ_ADDR08;
            end if;

          when CAPTURE_X =>
            toSPIbytes <= x"0B0900"; --read value at register 09 (y-val)
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR09;

          when READ_ADDR09 =>
            if SPIdone = '1' then
              cmd_state_D <= CAPTURE_Y;
            elsif SPIdone = '0' then
              cmd_state_D <= READ_ADDR09;
            end if;

          when CAPTURE_Y =>
            toSPIbytes <= x"0B0A00"; --read value at register 0A (z-val)
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR0A;

          when READ_ADDR0A =>
            if SPIdone = '1' then
              cmd_state_D <= CAPTURE_Z;
            elsif SPIdone = '0' then
              cmd_state_D <= READ_ADDR0A;
            end if;

          when CAPTURE_Z =>
            toSPIbytes <= x"0B0000"; -- read value at register 00 (restart cycle)
            SPIstart <= '1';
            cmd_state_D <= READ_ADDR00;
    
        end case;
    end process command_fsm;

    -- SPI FSM implementation
    spi_fsm : process (spi_state_Q, SPIstart)
    begin
      -- Assign state logic and default values
        spi_state_D <= spi_state_Q;
        SPIdone <= '0';
        timerStart <= '0';
        timerMax <= (others => '0');
        SCLK <= '0';
        CSb <= '0';

        case (spi_state_Q) is
          when IDLE =>
            CSb <= '1';
            if (SPIstart = '1') then
              spi_state_D <= SET_CS_LOW;
            elsif (SPIstart = '0') then
              spi_state_D <= IDLE;
            end if;

          when SET_CS_LOW =>
            timerStart <= '1';
            timerMax <= "000000000000000000000010011";
            if (timerDone = '1') then
              spi_state_D <= SET_CS_HI;
            elsif (timerDone = '0') then
              spi_state_D <= SET_CS_LOW;
            end if;

          when S_CLK_HI =>
            timerStart <= '1';
            timerMax <= "000000000000000000000010011";
            SCLK <= '1';
            if (timerDone = '1') then
              spi_state_D <= S_CLK_LO;
            elsif (timerDone = '0') then
              spi_state_D <= S_CLK_HI;
            end if;

          when S_CLK_LO =>
            timerStart <= '1';
            timerMax <= "000000000000000000000010011";
            if (timerDone = '1') then
              spi_state_D <= INC_SCLK_CNTR;
            elsif (timerDone = '0') then
              spi_state_D <= S_CLK_LO;
            end if;

          when INC_SCLK_CNTR =>
            sClkCntr <= sClkCntr + 1;
            spi_state_D <= CHECK_SCLK_CNTR;

          when CHECK_SCLK_CNTR =>
            if (sClkCntr = 24) then
              sClkCntr <= "00000";
              spi_state_D <= SET_CS_HI;
            elsif (sClkCntr < 24) then
              spi_state_D <= S_CLK_HI;
            end if;

          when SET_CS_HI =>
            CSb <= '1';
            spi_state_D <= WAIT_100MS;

          when WAIT_100MS =>
            timerStart <= '1';
            timerMax <= "101111101011110000100000000"; --100 million
            if (timerDone = '1') then
              SPIdone <= '1';
              spi_state_D <= IDLE;
            elsif (timerDone <= '0') then
              spi_state_D <= WAIT_100MS;
            end if;

        end case;

    end process spi_fsm;


    TimerForFSM: process(reset,clk)
    begin
      if(reset = '1') then
        timerCntr <= (others => '0');
      elsif(rising_edge(clk)) then
        if(timerStart = '1') then
          if(timerCntr < timerMax) then
            timerCntr <= timerCntr + 1;
          else timerCntr <= (others => '0');
          end if;
          else timerCntr <= (others => '0');
        end if;
      end if;
    end process TimerForFSM;

    timerDone <= '1' when timerCntr = timerMax else '0';


    ParallelToSerial : process (clk, reset)
    begin
        if (reset = '1') then
            parallel_sr <= (others => '0');
        elsif (rising_edge(clk)) then
            if(SPIstart = '1') then
                parallel_sr <= toSPIbytes;
            elsif(spi_state_Q = S_CLK_HI and timerDone = '1') then
                parallel_sr <= parallel_sr(22 downto 0) & '0';
            end if;
        end if;
    end process ParallelToSerial;
    
    MOSI <= parallel_sr(23); -- Assign SR MSB to the MOSI port
    
    SerialToParallel : process (clk, reset)
    begin
        if (reset = '1') then
            serial_sr <= (others => '0');
        elsif (rising_edge(clk)) then
            if(spi_state_Q = CHECK_SCLK_CNTR and sClkCntr < 24) then
                serial_sr <= serial_sr(22 downto 0) & MISO;
            end if;
        end if;
    end process SerialtoParallel;
    
    ID_AD <= serial_sr(7 downto 0) when (cmd_state_Q = CAPTURE_ID_AD) else (others => '0');
    ID_1D <= serial_sr(7 downto 0) when (cmd_state_Q = CAPTURE_ID_1D) else (others => '0');
    DATA_X <= serial_sr(7 downto 0) when (cmd_state_Q = CAPTURE_X) else (others => '0');
    DATA_Y <= serial_sr(7 downto 0) when (cmd_state_Q = CAPTURE_Y) else (others => '0');
    DATA_Z <= serial_sr(7 downto 0) when (cmd_state_Q = CAPTURE_Z) else (others => '0');

end Behavioral;
