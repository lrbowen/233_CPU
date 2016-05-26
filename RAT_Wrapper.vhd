-------------------------------------------------------------------------------
-- Company:  RAT Technologies
-- Engineer:  Various RAT rats
-- 
-- Create Date:    1/31/2012
-- Design Name: 
-- Module Name:    RAT_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Wrapper for RAT MCU. This model provides a template to 
--    interface the RAT MCU to a development board. 
--
-- Dependencies: 
--
-- Revision: 0.02
-- Revision 0.01 - File Created
-- Revision 0.02 - Added Bufferless VGA Controller 5/5/2016 by Ryan Rumsey
-- Additional Comments: 
--      This wrapper includes a Bufferless VGA Controller and interrupt signals
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
           SEGMENTS : out   STD_LOGIC_VECTOR (7 downto 0); 
           DISP_EN  : out   STD_LOGIC_VECTOR (3 downto 0); 
           VGA_RGB  : out   STD_LOGIC_VECTOR (7 downto 0);
           VGA_HS   : out   STD_LOGIC;
           VGA_VS   : out   STD_LOGIC;
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           BUTTONS  : in    STD_LOGIC_VECTOR (3 downto 0); 
           RESET    : in    STD_LOGIC;
           PS2C     : inout STD_LOGIC;
           PS2D     : inout STD_LOGIC;
           CLK      : in    STD_LOGIC);
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

    -------------------------------------------------------------------------------
    -- INPUT PORT IDS -------------------------------------------------------------
    CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
    CONSTANT BUTTONS_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"24";
    CONSTANT PS2_KEY_CODE_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"30";
    CONSTANT PS2_STATUS_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"31";
    -------------------------------------------------------------------------------
    
    -------------------------------------------------------------------------------
    -- OUTPUT PORT IDS ------------------------------------------------------------
    CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"40";
    CONSTANT SEGMENTS_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"80";   
    CONSTANT X_POS_EN_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"A1"; --VGA Enable and X Position ID
    CONSTANT Y_POS_ID      : STD_LOGIC_VECTOR (7 downto 0) := X"A2"; --VGA Y Position ID
    CONSTANT RGB_ID        : STD_LOGIC_VECTOR (7 downto 0) := X"A3"; --VGA RGB Color ID
    CONSTANT OBJ_ADDR_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"A4"; --VGA Object Address ID
    CONSTANT PS2_CONTROL_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"32";
    -------------------------------------------------------------------------------


    -------------------------------------------------------------------------------
    -- Declare RAT_CPU ------------------------------------------------------------
    component RAT_CPU 
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB  : out STD_LOGIC;
              RESET    : in  STD_LOGIC;
              INT      : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
    end component RAT_CPU;
    -------------------------------------------------------------------------------
 
    -------------------------------------------------------------------------------
    -- Keyboard Controllers--------------------------------------------------------       
    component PS2_REGISTER is
       PORT (
            PS2_DATA_READY,
            PS2_ERROR            : out STD_LOGIC;  --will go high once data is served
            PS2_KEY_CODE         : out STD_LOGIC_VECTOR(7 downto 0);   --the byte from keyboard
            PS2_CLK              : inout STD_LOGIC;  --THE KEYBOARD ALWAYS drives the clock
            PS2_DATA             : in STD_LOGIC;
            PS2_CLEAR_DATA_READY : in STD_LOGIC  --active high, high makes a reset            
       );
    end component PS2_REGISTER;
   
    component clk_div2 is
        Port (  clk : in std_logic;
               sclk : out std_logic);
    end component clk_div2;
   
    component sseg_dec is
        Port (      ALU_VAL : in std_logic_vector(7 downto 0); 
                       SIGN : in std_logic;
                      VALID : in std_logic;
                        CLK : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(7 downto 0));
    end component sseg_dec;
   
   
    -------------------------------------------------------------------------------
    -- Declare VGA_Controller ------------------------------------------------------
    component VGA_Controller 
      Port ( CLK, RESET   : in  STD_LOGIC;
             X_POS_EN     : in  STD_LOGIC_VECTOR (7 downto 0); --7 bits of x pos, 1 bit enable
             Y_POS        : in  STD_LOGIC_VECTOR (6 downto 0); --bottom 6 bits of y pos
             RGB_DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0); --8 bits of color
             OBJ_ADDR     : in  STD_LOGIC_VECTOR (7 downto 0); --8 bit object address
             RGB_DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0); --8 bit RGB color out
             H_SYNC       : out STD_LOGIC;
             V_SYNC       : out STD_LOGIC);
    end component VGA_Controller;
    -------------------------------------------------------------------------------

    -- Signals for connecting RAT_MCU to RAT_wrapper -------------------------------
    signal s_input_port  : std_logic_vector (7 downto 0);
    signal s_output_port : std_logic_vector (7 downto 0);
    signal s_port_id     : std_logic_vector (7 downto 0);
    signal s_load        : std_logic;
    signal s_interrupt   : std_logic;
    signal CLK50         : std_logic;
    signal ps2KeyCode, ps2Status : std_logic_vector (7 downto 0);
   
    -- Register definitions for output devices ------------------------------------
    signal r_LEDS        : std_logic_vector (7 downto 0) := (others => '0'); 
    signal r_PS2CONTROL : std_logic_vector (7 downto 0) := (others => '0'); 
    signal r_SEGMENTS   : std_logic_vector (7 downto 0) := (others => '0');   
    signal r_X_POS_EN    : std_logic_vector (7 downto 0) := (others => '0');
    signal r_Y_POS       : std_logic_vector (6 downto 0) := (others => '0');
    signal r_RGB_DATA    : std_logic_vector (7 downto 0) := (others => '0');
    signal r_OBJ_ADDR    : std_logic_vector (7 downto 0) := (others => '0');
    -------------------------------------------------------------------------------

begin

    -- Instantiate RAT_MCU --------------------------------------------------------
    CPU: RAT_CPU
    port map(   IN_PORT  => s_input_port,
                OUT_PORT => s_output_port,
                PORT_ID  => s_port_id,
                RESET    => RESET,  
                IO_STRB  => s_load,
                INT      => s_interrupt,
                CLK      => CLK50);         
    -------------------------------------------------------------------------------
    
    clk50M: clk_div2 
    Port map  (  clk => clk,
                sclk => CLK50); 
   
    
    sevenseg: sseg_dec 
    Port map (  ALU_VAL => r_SEGMENTS,
                   SIGN => '0', 
                  VALID => '1',
                    CLK => CLK, 
                DISP_EN => DISP_EN,
               SEGMENTS => SEGMENTS);       
    
    keyboard: PS2_REGISTER 
    Port map (
           PS2_DATA_READY       => ps2Status(1),
           PS2_ERROR            => ps2Status(0),
           PS2_KEY_CODE         => ps2KeyCode,
           PS2_CLK              => PS2C,
           PS2_DATA             => PS2D, 
           PS2_CLEAR_DATA_READY => r_PS2CONTROL(0)                          
      );
   
    
    
    -- Instantiate RAT_MCU --------------------------------------------------------
    VGA: VGA_Controller
    port map(   CLK          => CLK,
                RESET        => RESET,
                X_POS_EN     => r_X_POS_EN,
                Y_POS        => r_Y_POS,
                RGB_DATA_IN  => r_RGB_DATA,
                OBJ_ADDR     => r_OBJ_ADDR,
                RGB_DATA_OUT => VGA_RGB,
                H_SYNC       => VGA_HS,
                V_SYNC       => VGA_VS);         
    -------------------------------------------------------------------------------

   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read 
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, SWITCHES, BUTTONS)
   begin
      if (s_port_id = SWITCHES_ID) then
         s_input_port <= SWITCHES;
      elsif (s_port_id = BUTTONS_ID) then 
         s_input_port <= "0000" & BUTTONS;
      elsif (s_port_id = PS2_KEY_CODE_ID) then
         s_input_port <= ps2KeyCode;
       elsif (s_port_id = PS2_STATUS_ID) then
         s_input_port <= ps2Status;   
      --Add more elsif's here to support more inputs 
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Decoder for updating output registers
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   outputs: process(CLK, s_load, s_port_id) 
   begin   
      if (rising_edge(CLK)) then
         if (s_load = '1') then 
            if (s_port_id = LEDS_ID) then
               r_LEDS <= s_output_port;
            elsif (s_port_id = SEGMENTS_ID) then
               r_SEGMENTS <= s_output_port;    
            elsif (s_port_id = PS2_CONTROL_ID)  then
               r_PS2CONTROL <= s_output_port;           
            elsif (s_port_id = X_POS_EN_ID) then
               r_X_POS_EN <= s_output_port;
            elsif (s_port_id = Y_POS_ID) then
               r_Y_POS <= s_output_port(6 downto 0);
            elsif (s_port_id = RGB_ID) then
               r_RGB_DATA <= s_output_port;
            elsif (s_port_id = OBJ_ADDR_ID) then
               r_OBJ_ADDR <= s_output_port;
            --Add more elsif's here to support more outputs
            end if;
         end if; 
      end if;
   end process outputs;      
   -------------------------------------------------------------------------------

   -- Output assignments not assigned in port maps--------------------------------
   LEDS <= r_LEDS;    
   s_interrupt <= ps2Status(1);
   -------------------------------------------------------------------------------
   
end Behavioral;
