----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016
-- Current

-- Description: Flag Register
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Flags is
  Port ( LD 		: in std_logic;
         DATA_IN 	: in std_logic;
         DATA_OUT 	: out std_logic;
         CLK 		: in std_logic;
         SET 		: in std_logic;
         CLR 		: in std_logic);
end Flags;

architecture Flag_dtfl of Flags is
begin

CLOCK: process (CLK, SET, CLR, DATA_IN, LD)
    variable data : std_logic := '0';
    begin
        if (rising_edge(CLK)) then
            if (CLR = '1') then
                data := '0';
            elsif (SET = '1') then
                data := '1';
            else
                if (LD = '1') then
                    data := DATA_IN;
                end if;
            end if;
        end if;
        DATA_OUT <= data;
    end process CLOCK;

end Flag_dtfl;
