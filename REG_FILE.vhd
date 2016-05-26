----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016
-- Current

-- Description: Register File 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32 x 8
entity REG_FILE is
    Port ( WR 		: in std_logic;
           CLK 		: in std_logic;
           ADRX 	: in std_logic_vector(4 downto 0);
		   ADRY 	: in std_logic_vector(4 downto 0);
           DIN 		: in std_logic_vector(7 downto 0);
           DX_OUT 	: out std_logic_vector(7 downto 0);
		   DY_OUT 	: out std_logic_vector(7 downto 0)
		   );
end REG_FILE;

architecture Reg_dtfl of REG_FILE is
    type reg is array(0 to 31) of std_logic_vector(7 downto 0);
    signal registers : reg := (others => (others => '0'));
begin

process(CLK, WR)
    begin
        if (rising_edge(CLK)) then
            if (WR = '1') then
                registers(conv_integer(ADRX)) <= DIN;
            end if;
        end if;
    end process;

	DX_OUT <= registers(conv_integer(ADRX));
	DY_OUT <= registers(conv_integer(ADRY));

end Reg_dtfl;
