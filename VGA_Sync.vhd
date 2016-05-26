----------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: Ryan Rumsey
-- 
-- Create Date: 04/15/2016 01:47:38 PM
-- Design Name: 
-- Module Name: VGA_Sync - Behavioral
-- Project Name: Bufferless VGA Driver
-- Target Devices: 
-- Tool Versions: 2014.2
-- Description: VGA Synchronozation circuit
--      Drives VGA Horizontal Sync, Vertical Sync and Video On timing signals
--        for 640x480 60Hz refresh specs.
--      Divides screen into 8x8 pixel blocks of 80x60 resolution. These "Mega Pixels"
--        are output on X_PIXEL and Y_PIXEL for other modules to use.
-- Dependencies: 
--      Must receive 25MHz input CLK
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--      /!\ DO NOT MODIFY THIS MODULE UNLESS YOU KNOW WHAT YOU'RE DOING /!\
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--expect 25MHz input clock
entity VGA_Sync is
    Port ( VGACLK, RESET : in STD_LOGIC;
           H_SYNC : out STD_LOGIC;
           V_SYNC : out STD_LOGIC;
           X_PIXEL : out STD_LOGIC_VECTOR (6 downto 0);
           Y_PIXEL : out STD_LOGIC_VECTOR (6 downto 0);
           VIDEO_ON : out STD_LOGIC);
end VGA_Sync;

architecture Behavioral of VGA_Sync is

    -- VGA 640 x 480 sync params
    constant HD : integer := 640;   --horizontal display area
    constant HF : integer := 16;    --horizontal front porch
    constant HB : integer := 48;    --horizontal back porch
    constant HR : integer := 96;    --horizontal retrace
    constant VD : integer := 480;   --vertical display area
    constant VF : integer := 10;    --vertical front porch
    constant VB : integer := 33;    --vertical back porch
    constant VR : integer := 2;     --vertical retrace
    -- sync counters
    signal v_count_reg, h_count_reg : std_logic_vector (9 downto 0) := (others => '0');
    -- status
    signal h_end : std_logic := '0';
begin
    -- horizontal sync counter
    process (VGACLK) begin
        if (rising_edge(VGACLK)) then
            if (h_count_reg = (HD+HF+HB+HR-1)) then
                h_count_reg <= (others => '0');
                h_end <= '1';
            else
                h_count_reg <= h_count_reg + '1';
                h_end <= '0';
            end if;
        end if;
    end process;
    -- vertical sync counter
    process (VGACLK, h_end) begin
        if (rising_edge(VGACLK) and h_end = '1') then
            if (v_count_reg = (VD+VF+VB+VR-1)) then
                v_count_reg <= (others => '0');
            else
                v_count_reg <= v_count_reg + '1';
            end if;
        end if;
    end process;
    -- horizontal and verticle sync
    H_SYNC <= '0' when (h_count_reg >= (HD+HF) and h_count_reg <= (HD+HF+HR-1)) else --656 to 751
                   '1';
    V_SYNC <= '0' when (v_count_reg >= (VD+VF) and v_count_reg <= (VD+VF+VR-1)) else --490 to 491
                   '1';
    -- video enable
    VIDEO_ON <= '1' when (h_count_reg<HD and v_count_reg<VD) else
                '0';
    -- outputs
    -- h_count_reg and v_count_reg range to 640 and 480 pixels, respectively.
    -- The final screen pixels shall range to 80 and 60 8x8 pixel squares, respectively.
    -- Divide the count_reg's by 8 to get the final 80x60 block resolution.
    -- Logical Shift Right by 3 = Divide by 8
    X_PIXEL <= h_count_reg(9 downto 3); --Shifted left 3
    Y_PIXEL <= v_count_reg(9 downto 3); --Shifted left 3
    
end Behavioral;
