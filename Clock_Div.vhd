----------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: Ryan Rumsey
-- 
-- Create Date: 04/27/2016 05:04:41 PM
-- Design Name: 
-- Module Name: Clock_Div - Behavioral
-- Project Name: Bufferless VGA Controller
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--      Divides the input clock by 4
-- Dependencies: 
--      Expect input system clock of 100 MHz
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
--Clock divider to provide 25MHz
--Basys3 Board has 100MHz external clock, so this will div by N = 4
entity Clock_Div is
    Port (  CLK_IN, RESET : in  STD_LOGIC;
            CLK_OUT       : out STD_LOGIC);
end Clock_Div;

architecture arch of Clock_Div is
    signal temp_clk : std_logic := '0';
    --COUNT_LIMIT = (N/2 - 1) where N is the divider count
    constant COUNT_LIMIT : integer := 1;
begin
    divider_proc : process (RESET, CLK_IN, temp_clk) 
        variable counter : integer := 0;
    begin
        if(RESET = '1') then
            temp_clk <= '0';
            counter := 0;
        elsif(rising_edge(CLK_IN)) then
            if(counter = COUNT_LIMIT) then
                temp_clk <= not temp_clk;
                counter := 0;
            else
                counter := counter + 1;
            end if;
        end if;
        CLK_OUT <= temp_clk;
    end process divider_proc;
end arch;
