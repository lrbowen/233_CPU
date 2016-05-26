----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2016 08:25:32 AM
-- Design Name: 
-- Module Name: speaker - speaker_bhv
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity speaker is
  Port (    KEY    : in    std_logic_vector (7 downto 0);
            CLK_IN : in    std_logic;
            NOTE   : out   std_logic);
end speaker;

architecture speaker_bhv of speaker is
    
    component note_generate is
        Port (  KEY    :   in  std_logic_vector (7 downto 0);
                CLK    :   in  std_logic;
                FREQ   :   out std_logic);
    end component;
begin

KEY_MAKE: note_generate port map (
            KEY => KEY,
            CLK => CLK_IN,
            FREQ => NOTE);

end speaker_bhv;
