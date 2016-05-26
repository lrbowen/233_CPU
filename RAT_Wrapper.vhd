----------------------------------------------------------------------------------
-- Name: Lucy Bowen and Conor Murphy 
-- Date: 5/10/2016

-- Description: Wrapper for RAT CPU. This model provides a template to interface 
--    the RAT CPU to the Basys 3 development board. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
		Port (  led     : out   STD_LOGIC_VECTOR (7 downto 0);
				sw      : in    STD_LOGIC_VECTOR (7 downto 0);
				btnC    : in    STD_LOGIC;  --to serve as system reset
				CLK     : in    STD_LOGIC);
		end RAT_wrapper;


architecture Behavioral of RAT_wrapper is

   -------------------------------------------------------------------------------
   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT LEDS_ID     : STD_LOGIC_VECTOR (7 downto 0) := X"40";
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Declare RAT_MCU ------------------------------------------------------------
   component RAT_CPU 
		Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT  : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID   : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB   : out STD_LOGIC;
              RESET     : in  STD_LOGIC;              
              CLK       : in  STD_LOGIC);
   end component RAT_CPU;
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Declare clock divider-------------------------------------------------------
    component clk_div2 is
        Port ( clk 		: in std_logic;
               sclk 	: out std_logic);
    end component;

   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0);
   signal s_load, clk50 : std_logic;

    
   -- Register definitions for output devices ------------------------------------
   signal r_LEDS        : std_logic_vector (7 downto 0); 
   -------------------------------------------------------------------------------

begin

   -- Instantiate RAT_MCU --------------------------------------------------------
   CPU: RAT_CPU
   port map(  IN_PORT  => s_input_port,
              OUT_PORT => s_output_port,
              PORT_ID  => s_port_id,
              RESET    => btnC,  
              IO_STRB  => s_load,              
              CLK      => clk50);         
   -------------------------------------------------------------------------------

    -- Instantiate clock divider---------------------------------------------------
    newClk: clk_div2 
    port map  (  clk   => clk, 
                 sclk  => clk50);  


   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read ---------------------------------------
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, sw)
   begin
      if (s_port_id = SWITCHES_ID) then
         s_input_port <= sw;
      else
         s_input_port <= x"00";
      end if;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   outputs: process(clk50, s_load, s_port_id) 
   begin   
      if (rising_edge(clk50)) then
         if (s_load = '1') then         
            -- the register definition for the LEDS
            if (s_port_id = LEDS_ID) then
               r_LEDS <= s_output_port;
            end if;
           
         end if; 
      end if;
   end process outputs;      
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   led <= r_LEDS; 

end Behavioral;
