----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2016 08:27:05 AM
-- Design Name: 
-- Module Name: note_generate - note_bhv
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity note_generate is
  Port ( KEY    :   in  std_logic_vector (7 downto 0);
         CLK    :   in  std_logic;
         FREQ   :   out std_logic);
end note_generate;

architecture note_bhv of note_generate is
    
    -- keyboard codes and note they correspond to
    constant A_NOTE  : std_logic_vector (7 downto 0) := x"1C";
    constant B_NOTE  : std_logic_vector (7 downto 0) := x"1B";
    constant C_NOTE  : std_logic_vector (7 downto 0) := x"23";
    constant D_NOTE  : std_logic_vector (7 downto 0) := x"2B";
    constant E_NOTE  : std_logic_vector (7 downto 0) := x"34";
    constant F_NOTE  : std_logic_vector (7 downto 0) := x"33";
    constant G_NOTE  : std_logic_vector (7 downto 0) := x"3B";
    
    signal frequency : std_logic := '0';
begin

note_pick: process (KEY, CLK)
    variable counter : integer := 0;
    begin
        if (rising_edge(CLK)) then
            if (KEY = A_NOTE) then
                if (counter > 45455) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = B_NOTE) then
                if (counter > 40496) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = C_NOTE) then
                if (counter > 38222) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = D_NOTE) then
                if (counter > 34053) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = E_NOTE) then
                if (counter > 30337) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = F_NOTE) then
                if (counter > 28634) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            elsif (KEY = G_NOTE) then
                if (counter > 25510) then
                    counter := counter + 1;
                else
                    frequency <= not frequency;
                    counter := 0;
                end if;
            else    
                frequency <= '0';
            end if;
        end if;
    end process;

    FREQ <= frequency;
end note_bhv;
