----------------------------------------------------------------------------------
-- Name: Conor Murphy and Lucy Bowen
-- Date:  4/21/2015
-- Current
-- 
-- Description: RAT Architecture equivalent of its ALU
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( CIN 		: in  STD_LOGIC;
           SEL 		: in  STD_LOGIC_VECTOR (3 downto 0);
           A 		: in  STD_LOGIC_VECTOR (7 downto 0);
           B 		: in  STD_LOGIC_VECTOR (7 downto 0);
           RESULT 	: out STD_LOGIC_VECTOR (7 downto 0);
           C 		: out STD_LOGIC;
           Z 		: out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

begin

    ALU_op: process(A, B, SEL, CIN)
    
    variable tempResult :  std_logic_vector(8 downto 0) := (others =>'0');
    
	begin     
      
      case (SEL) is
      
        --ADD
        when "0000" =>
            tempResult := ('0' & A) + ('0' & B);
            
        --ADDC    
        when "0001" =>
            tempResult := ('0' & A) + ('0' & B) + (x"00" & CIN);
            
        --SUB   
        when "0010" =>
            tempResult := ('0' & A) - ('0' & B);
            
        --SUBC
        when "0011" =>
            tempResult := ('0' & A) - ('0' & B) - (x"00" & CIN);

        --CMP
        when "0100" =>
            tempResult := ('0' & A) - ('0' & B);
            
        --AND
        when "0101" =>
            tempResult := ('0' & A) and ('0' & B);
        
        --OR
        when "0110" => 
            tempResult := ('0' & A) or ('0' & B);
        
        --EXOR
        when "0111" =>
            tempResult := ('0' & A) xor ('0' & B);
            
        --TEST
        when "1000" =>
            tempResult := ('0' & A) and ('0' & B);
            
        --LSL
        when "1001" =>
            tempResult := A(7 downto 0) & CIN;
            
        --LSR
        when "1010" =>
            tempResult := A(0) & CIN & A(7 downto 1);
            
        --ROL
        when "1011" =>
            tempResult := A & A (7);
        
        --ROR
        when "1100" =>
            tempResult := A(0) & A(0) & A(7 downto 1);
            
        --ASR
        when "1101" =>
            tempResult := A(0) & A(7) & A(7 downto 1);
        
        --MOV
        when "1110" =>
            tempResult := ('0' & B);
            
        --catch all case            
        when others => 
            tempResult := (others => '0');
        end case;
        
        --assign Z and C flags
        C <= tempResult (8);
        
		if (tempResult(7 downto 0) = x"00") then
            Z <= '1';
        else
            Z <= '0';
        end if;
        
            RESULT <= tempResult(7 downto 0);
        
    end process ALU_op;


end Behavioral;