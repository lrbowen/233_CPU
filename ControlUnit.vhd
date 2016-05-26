----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016
-- Current

-- Description: Control Unit for RAT_CPU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CONTROL_UNIT is
    Port ( CLK           : in   STD_LOGIC;
           C             : in   STD_LOGIC;
           Z             : in   STD_LOGIC;
           RESET         : in   STD_LOGIC;
           OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
           OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
           INT           : in   STD_LOGIC;
              
           FLG_I_SET     : out  STD_LOGIC;
           FLG_I_CLR     : out  STD_LOGIC;
           
           PC_LD         : out  STD_LOGIC;
           PC_INC        : out  STD_LOGIC;
           PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);
           
           RF_WR         : out  STD_LOGIC;
           RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);
          
           SP_LD         : out  STD_LOGIC;
           SP_INCR       : out  STD_LOGIC;
           SP_DECR       : out  STD_LOGIC;
           
           SCR_WE        : out  STD_LOGIC;
           SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);
           SCR_DATA_SEL  : out  STD_LOGIC;
          
           ALU_OPY_SEL   : out  STD_LOGIC;
           ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

           FLG_C_LD      : out  STD_LOGIC;
           FLG_C_SET     : out  STD_LOGIC;
           FLG_C_CLR     : out  STD_LOGIC;
           FLG_Z_CLR     : out  STD_LOGIC;
           FLG_Z_LD      : out  STD_LOGIC;
           FLG_LD_SEL    : out  STD_LOGIC;
           FLG_SHAD_LD   : out  STD_LOGIC;
              
           RST           : out  STD_LOGIC;
           
           IO_STRB       : out  STD_LOGIC);          
end CONTROL_UNIT;

architecture Behavioral of CONTROL_UNIT is

   type state_type is (ST_init, ST_fetch, ST_exec, ST_int);
   
			signal PS,NS : state_type;
			signal sig_OPCODE_7: std_logic_vector (6 downto 0);
			
begin
   
   -- concatenate the all opcodes into a 7-bit complete opcode for
	-- easy instruction decoding.
   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RESET)
   begin
    if (RESET = '1') then
	   PS <= ST_init;
	elsif (rising_edge(CLK)) then 
       PS <= NS;
 	end if;
   end process sync_p;


   comb_p: process (sig_OPCODE_7, PS, NS, C, Z)
   begin
   
    	-- preset everything to zero --------------------------
		
	  FLG_I_SET     <= '0';
	  FLG_I_CLR     <= '0';
		
      PC_LD 		<= '0';   
	  PC_INC     	<= '0';
	  PC_MUX_SEL 	<= "00";   	     				
      
	  ALU_OPY_SEL 	<= '0';  
	  ALU_SEL 		<= "0000"; 
	  
      RF_WR 		<= '0';   
	  RF_WR_SEL  	<= "00";   
  
      SP_LD 		<= '0';
	  SP_INCR 		<= '0';
	  SP_DECR 		<= '0'; 

	  SCR_DATA_SEL 	<= '0';
	  SCR_ADDR_SEL 	<= "00";
	  SCR_WE 		<= '0';	  

      FLG_C_SET  	<= '0';   
	  FLG_C_CLR   	<= '0'; 
      FLG_C_LD   	<= '0';   
	  FLG_Z_LD    	<= '0';     
	  FLG_Z_CLR  	<= '0';
	  FLG_LD_SEL    <= '0';
	  FLG_SHAD_LD   <= '0';
	  
      RST 			<= '0';
	  
      IO_STRB 		<= '0';
            
   case PS is
      
      -- STATE: the init cycle ------------------------------------
    when ST_init =>
	   RST 		 <= '1';
	   FLG_Z_CLR <= '1';
	   FLG_C_CLR <= '1';
	   NS 		 <= ST_fetch;
						 	
				
      -- STATE: the fetch cycle -----------------------------------
      when ST_fetch => 
         NS 	<= ST_exec;
         PC_INC <= '1';  -- increment PC
            
            
      -- STATE: the execute cycle ---------------------------------
      when ST_exec => 
           if (INT = '1') then
                NS <= ST_int;
           else
                NS <= ST_fetch;    
           end if;
				
	     case sig_OPCODE_7 is	
        -- ADD reg reg -------------------  	
            when "0000100" =>
                   RF_WR 		<= '1';
                   FLG_C_LD 	<= '1';
                   FLG_Z_LD 	<= '1';
                   ALU_SEL  	<= "0000";
                      
          -- ADD reg imm -------------------
            when "1010000" | "1010001" | "1010010" | "1010011" =>
                   RF_WR 		<= '1';
                   FLG_C_LD 	<= '1';
                   FLG_Z_LD 	<= '1';
                   ALU_OPY_SEL 	<= '1';
                   ALU_SEL 		<= "0000";
                  
         -- ADDC reg reg -------------------
            when "0000101" =>
                   RF_WR 		<= '1';
                   FLG_C_LD 	<= '1';
                   FLG_Z_LD 	<= '1';
                   ALU_SEL 		<= "0001";
                  
         -- ADDC reg imm -------------------
            when "1010100" | "1010101" | "1010110" | "1010111" =>
                   RF_WR 		<= '1';
                   FLG_C_LD 	<= '1';
                   FLG_Z_LD 	<= '1';
                   ALU_OPY_SEL 	<= '1';
                   ALU_SEL 		<= "0001";	     
	     -- AND reg reg -------------------  
	        when "0000000" =>
	               RF_WR 		<= '1';
	               FLG_C_CLR	<= '1';
	               FLG_Z_LD 	<= '1';
	               ALU_SEL 		<= "0101";
	     -- AND reg imm -------------------  
	     	when "1000000" | "1000001" | "1000010" | "1000011" =>
	     	       RF_WR 		<= '1';
                   FLG_C_CLR 	<= '1';
                   FLG_Z_LD 	<= '1';
                   ALU_OPY_SEL 	<= '1';
                   ALU_SEL 		<= "0101";
	     
                   
	     -- ASR -------------------
	        when "0100100" =>
	               ALU_SEL 		<= "1101";
                   RF_WR 		<= '1';
                   FLG_C_LD 	<= '1';
                   FLG_Z_LD 	<= '1';
	     
	     -- BRCC -------------------
	        when "0010101" =>
	               if (C = '0') then
	                   PC_LD 	<= '1';
	               else
	                   PC_LD 	<= '0';
	               end if;
	                   
	     -- BRCS -------------------
	        when "0010100" =>
                    if (C = '1') then
                       PC_LD 	<= '1';
                    else
                       PC_LD 	<= '0';
                    end if;
	     -- BREQ -------------------
            when "0010010" =>
                      if (Z = '1') then
                        PC_LD 	<= '1';
                      else
                        PC_LD 	<= '0';
                      end if;
		  -- BRN -------------------
            when "0010000" =>   
                    PC_LD 		<= '1';
                    
          -- BRNE -------------------
            when "0010011" =>
                   if (Z = '0') then
                      PC_LD 	<= '1';
                   else
                      PC_LD 	<= '0';
                   end if;
          -- CALL -------------------
            when "0010001" =>
                    PC_LD 		<= '1';
                    SP_DECR 	<= '1';
                    SCR_ADDR_SEL <= "11";
                    SCR_DATA_SEL <= '1';
                    SCR_WE 		<= '1';
          
          -- CLC -------------------
            when "0110000" =>
                    FLG_C_CLR 	<= '1';
                    
          -- CLI -------------------
            when "0110101" =>
                    FLG_I_CLR       <= '1';
          -- CMP reg reg -------------------
            when "0001000" =>
                    ALU_SEL 	<= "0100";
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
                    
          -- CMP reg imm -------------------
            when "1100000" | "1100001" | "1100010" | "1100011" =>
                    ALU_SEL 	<= "0100";
                    ALU_OPY_SEL <= '1';
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
                    
          -- EXOR reg reg -------------------
            when "0000010" =>
                    RF_WR 		<= '1';
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_SEL 	<= "0111";
                    
          -- EXOR reg-immed  ------
            when "1001000" | "1001001" | "1001010" | "1001011" =>
                    RF_WR 		<= '1';
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_OPY_SEL	<= '1';
                    ALU_SEL 	<= "0111";
                    
          -- IN reg-immed  ------
            when "1100100" | "1100101" | "1100110" | "1100111" =>                                     
                    RF_WR 		<= '1';
                    RF_WR_SEL 	<= "11";
          
          -- LSL -------------------
            when "0100000" =>
                    ALU_SEL 	<= "1001";
                    RF_WR 		<= '1';
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
                    
          -- LSR -------------------
                when "0100001" =>
                    ALU_SEL 	<= "1010";
                    RF_WR 		<= '1';
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
          
          -- LD reg reg -------------------
                 when "0001010" => 
                    RF_WR 		<= '1';
                    RF_WR_SEL 	<= "01";
          
          -- LD reg imm-------------------
                when "1110000" | "1110001" | "1110010" | "1110011" => 
                    RF_WR 		<= '1';
                    RF_WR_SEL 	<= "01";
                    SCR_ADDR_SEL <= "01";
          -- MOV reg reg  ------
                when "0001001" =>
                     ALU_SEL 	<= "1110";
                     RF_WR 		<= '1';
                     
          -- MOV reg imm  ------
                when "1101100" | "1101101" | "1101110" | "1101111" =>                       
                     ALU_OPY_SEL <= '1';
                     ALU_SEL 	<= "1110";
                     RF_WR 		<= '1';
                     
           -- OR reg reg -------------------   
                when "0000001" =>
                    RF_WR 		<= '1';
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_SEL 	<= "0110";
                    
           -- OR reg imm -------------------
                when "1000100" | "1000101" | "1000110" | "1000111" =>
                    RF_WR 		<= '1';
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_OPY_SEL <= '1';
                    ALU_SEL 	<= "0110";
         
          -- OUT reg-immed  ------
                 when "1101000" | "1101001" | "1101010" | "1101011" =>                       
                      IO_STRB 	<= '1';                  
          
           -- POP -------------------
                when "0100110" =>
                    RF_WR 		<= '1';
                    RF_WR_SEL 	<= "01";
                    SP_INCR 	<= '1';
                    SCR_ADDR_SEL <= "10";
           -- PUSH -------------------
                when "0100101" =>
                     SP_DECR 	<= '1';
                     SCR_ADDR_SEL <= "11";
                     SCR_WE 	<= '1';
           -- RET -------------------
                when "0110010" =>
                    PC_LD 		<= '1';
                    PC_MUX_SEL 	<= "01";
                    SP_INCR 	<= '1';
                    SCR_ADDR_SEL <= "10";
                    
           -- RETID -------------------
                when "0110110" =>
                    PC_LD       <= '1';
                    PC_MUX_SEL  <= "01";
                    SCR_ADDR_SEL <= "10";
                    
                    SP_INCR     <= '1';
                    FLG_SHAD_LD <= '1';
                    FLG_Z_LD    <= '1';
                    FLG_C_LD    <= '1';
                    
           -- RETIE -------------------
                when "0110111" =>
                    PC_LD       <= '1';
                    SP_INCR     <= '1';
                    PC_MUX_SEL  <= "01";
                    SCR_ADDR_SEL <= "10";
                    
                    FLG_SHAD_LD <= '1';
                    FLG_I_SET   <= '1';
                    FLG_Z_LD    <= '1';
                    FLG_C_LD    <= '1';
                    
           -- ROL -------------------
                when "0100010" =>
                    ALU_SEL 	<= "1011";
                    RF_WR 		<= '1';
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
                    
           -- ROR -------------------
                when "0100011" =>
                    ALU_SEL 	<= "1100";
                    RF_WR 		<= '1';
                    FLG_C_LD 	<= '1';
                    FLG_Z_LD 	<= '1';
                    
           -- SEC -------------------
                when "0110001" =>
                    FLG_C_SET 	<= '1';
           -- SEI -------------------
                when "0110100" =>
                    FLG_I_SET  <= '1';
           -- ST reg reg-------------------
                when "0001011" =>
                    SCR_WE 		<= '1';
           -- ST reg imm-------------------
                when "1110100" | "1110101" | "1110110" | "1110111" =>
                    SCR_WE 		<= '1';
                    SCR_ADDR_SEL <= "01";
           -- SUB reg-reg  --------
                when "0000110" =>                    
                     ALU_SEL 	<= "0010";
                     RF_WR 		<= '1';
                     FLG_C_LD 	<= '1';
                     FLG_Z_LD 	<= '1';
                     
           --SUB reg imm -------------------
                when "1011000" | "1011001" | "1011010" | "1011011" =>
                     ALU_SEL 	<= "0010";
                     ALU_OPY_SEL <= '1';
                     RF_WR 		<= '1';
                     FLG_C_LD 	<= '1';
                     FLG_Z_LD 	<= '1';
                     
           --SUBC reg imm-------------------
                when "0000111" =>
                     ALU_SEL 	<= "0011";
                     RF_WR 		<= '1';
                     FLG_C_LD 	<= '1';
                     FLG_Z_LD 	<= '1';
                     
           -- SUBC reg imm -------------------
                when "1011100" | "1011101" | "1011110" | "1011111" =>
                     ALU_SEL 	<= "0011";
                     ALU_OPY_SEL <= '1';
                     RF_WR 		<= '1';
                     FLG_C_LD 	<= '1';
                     FLG_Z_LD 	<= '1';
           
           -- TEST reg reg -------------------
                when "0000011" =>
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_SEL 	<= "1000";
                    
            -- TEST reg imm -------------------   
                when "1001100" | "1001101" | "1001110" | "1001111" =>
                    FLG_C_CLR 	<= '1';
                    FLG_Z_LD 	<= '1';
                    ALU_SEL 	<= "1000";
                    ALU_OPY_SEL <= '1';
                    
            -- WSP -------------------   
		          when "0101000" => 
		              SP_LD 	<= '1';
		  
		 
		  
              when others =>		-- for inner case
                  --everything was preset to zero, so that should be the default
                      

            end case; -- inner execute case statement


          when ST_int =>
               NS <= ST_fetch;
               
               FLG_I_CLR <= '1';
               FLG_C_CLR <= '1';
               FLG_Z_CLR <= '1';
               FLG_SHAD_LD <= '1';
               
               PC_LD <= '1';
               PC_MUX_SEL <= "10";
               
               SCR_WE       <= '1';
               SP_DECR      <= '1';
               SCR_ADDR_SEL <= "11";
               SCR_DATA_SEL <= '1';
          
          when others =>    -- for outer case
               NS <= ST_fetch; 
				 
	    end case;  -- outer init/fetch/execute case
       
   end process comb_p;
   
   
end Behavioral;




