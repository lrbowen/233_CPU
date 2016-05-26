----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016
-- Current as of 5/26

-- Description: Stack Pointer 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Stk_Pointer is
  Port ( RST, SP_LD, SP_INCR, SP_DECR : in std_logic;
         DATA_IN : std_logic_vector(7 downto 0);
         CLK : in std_logic;
         DATA_OUT : out std_logic_vector(7 downto 0));
end Stk_Pointer;

architecture Stk_dtfl of Stk_Pointer is

begin
CLOCK: process (CLK, DATA_IN, RST, SP_LD, SP_INCR, SP_DECR)
    variable data : std_logic_vector(7 downto 0) := x"00";
    begin
        if (RST = '1') then
            data := x"00";
        elsif (rising_edge(CLK)) then
            if (SP_LD = '1') then
                data := DATA_IN;
            elsif (SP_INCR = '1') then
                data := data + 1;
            elsif (SP_DECR = '1') then
                data := data - 1;
            end if;
        end if;
        
        DATA_OUT <= data;
    end process CLOCK;

end Stk_dtfl;