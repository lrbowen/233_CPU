----------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: Ryan Rumsey
-- 
-- Create Date: 04/28/2016 03:43:45 PM
-- Design Name: 
-- Module Name: Rectangle_Object - Behavioral
-- Project Name: Bufferless VGA Controller
-- Target Devices: 
-- Tool Versions: 
-- Description: Rectangle
--      Has width and height boundary constants.
--      Asserts when it is on when the X and Y pixel inputs are inside of its bounds.
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
use IEEE.NUMERIC_STD.ALL;

entity Piano_Key is
    Port ( 
        VGACLK   : in STD_LOGIC;
        X_POS_EN : in STD_LOGIC_VECTOR (7 downto 0); --7 bits of x pos, 1 bit enable
        Y_POS    : in STD_LOGIC_VECTOR (6 downto 0); --6 bits of y pos
        RGB_DATA : in STD_LOGIC_VECTOR (7 downto 0); --8 bits of color
        WE       : in STD_LOGIC;                     --write enable
        X_PIXEL  : in STD_LOGIC_VECTOR (6 downto 0); --7 bits of x
        Y_PIXEL  : in STD_LOGIC_VECTOR (6 downto 0); --6 bits of y
        RGB_OBJ  : out STD_LOGIC_VECTOR (7 downto 0); --output color data
        ON_OBJ   : out STD_LOGIC                      --output active
    );
end Piano_Key;

architecture Behavioral of Piano_Key is
    --Rectangle is defined by top-left point, width and height
    --Note: All coordinates are in the 80x60 resolution scale
    constant OBJ_W : integer := 5;
    constant OBJ_H : integer := 5;
    signal obj_x_reg   : std_logic_vector (6 downto 0) := (others => '0');
    signal obj_y_reg   : std_logic_vector (6 downto 0) := (others => '0');
    signal obj_rgb_reg : std_logic_vector (7 downto 0) := (others => '0');
    signal obj_en_reg  : std_logic := '0';
    
begin

    --State Registers
    process (VGACLK, WE) begin
        if(rising_edge(VGACLK) and WE = '1') then
            obj_x_reg <= X_POS_EN (6 downto 0);
            obj_y_reg <= Y_POS;
            obj_rgb_reg <= RGB_DATA;
            obj_en_reg <= X_POS_EN (7);
        end if;
    end process;

    ON_OBJ <=
        '1' when (X_PIXEL >= obj_x_reg) and (X_PIXEL < obj_x_reg+OBJ_W) and
                 (Y_PIXEL >= obj_y_reg) and (Y_PIXEL < obj_y_reg+OBJ_H) and
                 obj_en_reg = '1'       else
        '0';
    RGB_OBJ <= obj_rgb_reg;

end Behavioral;
