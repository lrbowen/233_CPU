----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy
-- Date: 5/10/16
-- 
-- Description: Top Level RAT CPU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_CPU is
		Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
			RESET    : in  STD_LOGIC;
			CLK      : in  STD_LOGIC;    
			INT      : in  STD_LOGIC;       
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID  : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB  : out  STD_LOGIC);
end RAT_CPU;



architecture Behavioral of RAT_CPU is

   --declare all of your components here
   --hint (just copy the entities and change the word entity to component
   --and end with end component
   component prog_rom  
      port ( ADDRESS            : in   std_logic_vector (9 downto 0); 
             INSTRUCTION        : out  std_logic_vector (17 downto 0); 
             CLK                : in   std_logic);  
   end component;

   component REG_FILE
      port (  WR                : in   std_logic;
              CLK               : in   std_logic;
              ADRX, ADRY        : in   std_logic_vector (4 downto 0);
              DIN               : in   std_logic_vector (7 downto 0);
              DX_OUT, DY_OUT    : out  std_logic_vector (7 downto 0));
   end component;
   
   component ALU
      port (  CIN               : in   STD_LOGIC;
              SEL               : in   STD_LOGIC_VECTOR (3 downto 0);
              A                 : in   STD_LOGIC_VECTOR (7 downto 0);
              B                 : in   STD_LOGIC_VECTOR (7 downto 0);
              RESULT            : out  STD_LOGIC_VECTOR (7 downto 0);
              C                 : out  STD_LOGIC;
              Z                 : out  STD_LOGIC);
   end component;
   
   component PC
      port (  CLK               : in   STD_LOGIC;
              RST               : in   STD_LOGIC;
              PC_LD             : in   STD_LOGIC;
              PC_INC            : in   STD_LOGIC;
              DIN               : in   std_logic_vector (9 downto 0);
              PC_COUNT          : out  std_logic_vector (9 downto 0));
   end component;
   
   component CONTROL_UNIT is
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
   end component;
    
    component Flags
       port ( LD                : in    std_logic;
              DATA_IN           : in    std_logic;
              DATA_OUT          : out   std_logic;
              CLK               : in    std_logic;
              SET               : in    std_logic;
              CLR               : in    std_logic);
    end component;
    
    component SCR is
      Port ( CLK                : in std_logic;
             WE                 : in std_logic;
             DATA_IN            : in std_logic_vector(9 downto 0);
             ADDR               : in std_logic_vector (7 downto 0);
             DATA_OUT           : out std_logic_vector(9 downto 0)
             );
    end component;
    
    component Stk_Pointer is
      Port ( RST, SP_LD, SP_INCR, SP_DECR : in std_logic;
             DATA_IN : std_logic_vector(7 downto 0);
             CLK : in std_logic;
             DATA_OUT : out std_logic_vector(7 downto 0));
    end component;
    
   -- declare intermediate signals here -----------
   -- these should match the signal names you hand drew on the diagram
      
   signal INTERRUPT         : std_logic;
   
   signal PC_INC            : std_logic;
   signal PC_LD             : std_logic;
   signal RST               : std_logic;
   signal PC_MUX_SEL        : std_logic_vector (1 downto 0);
   signal DIN               : std_logic_vector (9 downto 0);
   
   signal PC_COUNT          : std_logic_vector (9 downto 0);
         
   signal INSTRUCTION       : std_logic_vector (17 downto 0);
   
   signal DY_OUT            : std_logic_vector (7 downto 0);
   signal DX_OUT            : std_logic_vector (7 downto 0);
   signal ALU_SEL           : std_logic_vector (3 downto 0);
   signal ALU_OPY_SEL       : std_logic;
   signal B                 : std_logic_vector (7 downto 0);

   signal RESULT            : std_logic_vector (7 downto 0);
   signal C                 : std_logic;
   signal Z                 : std_logic;
   
   signal RF_WR             : std_logic;
   signal RF_WR_SEL         : std_logic_vector (1 downto 0);
   signal RF_DIN            : std_logic_vector (7 downto 0);
   
   signal FLG_C_SET         : std_logic;
   signal FLG_C_CLR         : std_logic;
   signal FLG_C_LD          : std_logic;
   signal FLG_Z_LD          : std_logic;
   signal FLG_Z_CLR         : std_logic;
   signal FLG_I_SET         : std_logic;
   signal FLG_I_CLR         : std_logic;
   signal FLG_SHAD_LD       : std_logic;
   signal C_FLAG            : std_logic;
   signal Z_FLAG            : std_logic;
   signal I_FLAG            : std_logic;
   
   signal SHAD_C_FLAG       : std_logic;
   signal SHAD_Z_FLAG       : std_logic;
   signal FLG_LD_SEL        : std_logic;
   signal ZIN               : std_logic;
   signal CIN               : std_logic;
   
   signal SP_LD             : std_logic;
   signal SP_INCR           : std_logic;
   signal SP_DECR           : std_logic;
   signal SP_DOUT           : std_logic_vector(7 downto 0);
   
   signal SCR_WE            : std_logic;
   signal SCR_DATA_SEL      : std_logic;
   signal SCR_ADDR_SEL      : std_logic_vector(1 downto 0);
   
   signal SCR_DIN           : std_logic_vector(9 downto 0);
   signal SCR_ADDR          : std_logic_vector(7 downto 0);
   signal SCR_DOUT          : std_logic_vector(9 downto 0);
   
   
begin

-- 4:10 Mux for PC DIN
with PC_MUX_SEL select
    DIN <=      INSTRUCTION(12 downto 3)     when "00",
                SCR_DOUT                     when "01",
                "11" & x"FF"                 when "10",
                "00" & x"00"                 when "11",
                "00" & x"00"                 when others;  

-- 4:8 Mux for RF_DIN
with RF_WR_SEL select
    RF_DIN <=   RESULT                       when "00",
                SCR_DOUT(7 downto 0)         when "01",
                SP_DOUT                      when "10",
                IN_PORT                      when "11",
                x"00"                        when others;
    
-- 2:8 Mux for ALU B
with ALU_OPY_SEL select
    B <=        DY_OUT                       when '0',
                INSTRUCTION(7 downto 0)      when '1',
                x"00"                        when others;
                
-- 2:10 Mux for SCR Data Select
with SCR_DATA_SEL select
    SCR_DIN <=  "00" & DX_OUT                when '0',
                PC_COUNT                     when '1',
                "00" & x"00"                 when others;
                
-- 4:8 Mux for SCR Address Select
with SCR_ADDR_SEL select
    SCR_ADDR <= DY_OUT                       when "00",
                INSTRUCTION(7 downto 0)      when "01",
                SP_DOUT                      when "10",
                (SP_DOUT - 1)                when "11",
                x"00"                        when others;
                
-- 2:1 Mux for Shadow Z Flag
with FLG_LD_SEL select
    ZIN <=        Z                          when '0',
                  SHAD_Z_FLAG                when '1',
                  Z                          when others;

-- 2:1 Mux for Shadow C Flag
with FLG_LD_SEL select
    CIN <=        C                          when '0',
                  SHAD_C_FLAG                when '1',
                  C                          when others;
                
-- Interrupt AND gate
INTERRUPT <= INT and I_FLAG;
    
PC_MAP: PC port map ( CLK => CLK,
                      RST => RST,
                      PC_LD => PC_LD,
                      PC_INC => PC_INC,
                      DIN => DIN,
                      PC_COUNT => PC_COUNT);

PROG_MAP: prog_rom port map ( ADDRESS => PC_COUNT,
                              INSTRUCTION => INSTRUCTION,
                              CLK => CLK);
                              
REG_MAP: REG_FILE port map ( WR => RF_WR,
                             CLK => CLK,
                             ADRX => INSTRUCTION (12 downto 8),
                             ADRY => INSTRUCTION (7 downto 3),
                             DIN => RF_DIN,
                             DX_OUT => DX_OUT,
                             DY_OUT => DY_OUT);
                             
ALU_MAP: ALU port map ( CIN => C_FLAG,
                        SEL => ALU_SEL,
                        A => DX_OUT,
                        B => B,
                        RESULT => RESULT,
                        C => C,
                        Z => Z);

C_MAP: Flags port map ( LD => FLG_C_LD,
                         DATA_IN => CIN,
                         DATA_OUT => C_FLAG,
                         CLK => CLK,
                         SET => FLG_C_SET,
                         CLR => FLG_C_CLR);
                         
Z_MAP: Flags port map ( LD => FLG_Z_LD,
                         DATA_IN => ZIN,
                         DATA_OUT => Z_FLAG,
                         CLK => CLK,
                         SET => '0',
                         CLR => FLG_Z_CLR);
                         
I_MAP: Flags port map (  LD => '0',
                         DATA_IN => '0',
                         DATA_OUT => I_FLAG,
                         CLK => CLK,
                         SET => FLG_I_SET,
                         CLR => FLG_I_CLR);

SHAD_C_MAP: Flags port map (  LD => FLG_SHAD_LD,
                              DATA_IN => C_FLAG,
                              DATA_OUT => SHAD_C_FLAG,
                              CLK => CLK,
                              SET => '0',
                              CLR => '0');
                              
SHAD_Z_MAP: Flags port map (  LD => FLG_SHAD_LD,
                              DATA_IN => Z_FLAG,
                              DATA_OUT => SHAD_Z_FLAG,
                              CLK => CLK,
                              SET => '0',
                              CLR => '0');

CU_MAP: CONTROL_UNIT port map (CLK => CLK,
                               C => C_FLAG,
                               Z => Z_FLAG,
                               RESET => RESET,
                               OPCODE_HI_5 => INSTRUCTION (17 downto 13),
                               OPCODE_LO_2 => INSTRUCTION (1 downto 0),
                               INT => INTERRUPT,
                               
                               FLG_I_SET => FLG_I_SET,
                               FLG_I_CLR => FLG_I_CLR,
                               
                               PC_LD => PC_LD,
                               PC_INC => PC_INC,
                               PC_MUX_SEL => PC_MUX_SEL,
                               
                               RF_WR => RF_WR,
                               RF_WR_SEL => RF_WR_SEL,
                               
                               SP_LD => SP_LD,
                               SP_INCR => SP_INCR,
                               SP_DECR   => SP_DECR,
                               
                               SCR_WE   => SCR_WE,
                               SCR_ADDR_SEL  => SCR_ADDR_SEL,
                               SCR_DATA_SEL  => SCR_DATA_SEL,
                               
                               ALU_OPY_SEL => ALU_OPY_SEL,
                               ALU_SEL => ALU_SEL,
                               
                               FLG_C_LD => FLG_C_LD,
                               FLG_C_SET => FLG_C_SET,
                               FLG_C_CLR => FLG_C_CLR,
                               FLG_Z_CLR => FLG_Z_CLR,
                               FLG_Z_LD => FLG_Z_LD,
                               FLG_LD_SEL => FLG_LD_SEL,
                               FLG_SHAD_LD => FLG_SHAD_LD,
                               
                               RST => RST,
                               
                               IO_STRB => IO_STRB);

                               
SCR_MAP: SCR port map 		( 	CLK => CLK,
								WE 	=> SCR_WE,
								DATA_IN => SCR_DIN,
								ADDR => SCR_ADDR,
								DATA_OUT => SCR_DOUT);
                        
SP_MAP: Stk_Pointer port map ( RST => RST, 
                               SP_LD => SP_LD, 
                               SP_INCR => SP_INCR, 
                               SP_DECR => SP_DECR,
                               DATA_IN => DX_OUT,
                               CLK => CLK,
                               DATA_OUT => SP_DOUT);
                               
           PORT_ID <= INSTRUCTION (7 downto 0);
           OUT_PORT <= DX_OUT;
end Behavioral;

