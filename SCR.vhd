----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016
-- Current

-- Description: Scratch Ram
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 256 x 10 RAM
entity SCR is
  Port ( CLK : in std_logic;
         WE : in std_logic;
         DATA_IN : in std_logic_vector(9 downto 0);
         ADDR : in std_logic_vector (7 downto 0);
         DATA_OUT : out std_logic_vector(9 downto 0)
         );
end SCR;

architecture Scr_dtfl of SCR is
    type ram_type is array (0 to 255) of std_logic_vector(9 downto 0);
    signal ram : ram_type := (others => (others => '0'));
begin
WRITE: process (CLK, WE)
    begin
        if (rising_edge(CLK)) then
            if (WE = '1') then
                ram(conv_integer(ADDR)) <= DATA_IN;
            end if;
        end if;
    end process WRITE;
    
    DATA_OUT <= ram(conv_integer(ADDR));
end Scr_dtfl;
