----------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: Ryan Rumsey
-- 
-- Create Date: 04/30/2016 04:35:38 PM
-- Design Name: 
-- Module Name: Sprite_Object - Behavioral
-- Project Name: Bufferless VGA Controller
-- Target Devices: 
-- Tool Versions: 
-- Description: Sprite
-- 
-- Dependencies: 
--      Has width and height boundary constants, and a fill bitmap.
--      Asserts when it is on when the X and Y pixel inputs are inside of its bounds,
--        and the current position in the fill bitmap is enabled.
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sprite_Object is
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
end Sprite_Object;

architecture Behavioral of Sprite_Object is
    --Sprite is bounded by a rectangle that is defined by top-left point, width and height
    --Note: All coordinates are in the 80x60 resolution scale
    constant OBJ_W : integer := 5;
    constant OBJ_H : integer := 5;
    signal obj_x_reg   : std_logic_vector (6 downto 0) := (others => '0');
    signal obj_y_reg   : std_logic_vector (6 downto 0) := (others => '0');
    signal obj_rgb_reg : std_logic_vector (7 downto 0) := (others => '0');
    signal obj_en_reg  : std_logic := '0';
    
    --Sprite Bitmap: Defines which Mega Pixels inside the bounds are enabled
    type rom_type is array (0 to OBJ_H-1) of std_logic_vector (OBJ_W-1 downto 0);
    constant SPRITE_ROM : rom_type :=
    (
        "00100",
        "01110",
        "00100",
        "01010",
        "01010"
    );
    signal rom_addr : unsigned(6 downto 0); -- y 
    signal rom_col : unsigned(6 downto 0); -- x
    signal rom_data : std_logic_vector(OBJ_W-1 downto 0);
    signal rom_bit : std_logic;
    signal sprite_on : std_logic;
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
    
    --Object Visible Conditions
    sprite_on <=
        '1' when (X_PIXEL >= obj_x_reg) and (X_PIXEL < obj_x_reg+OBJ_W) and
                 (Y_PIXEL >= obj_y_reg) and (Y_PIXEL < obj_y_reg+OBJ_H) and
                 obj_en_reg = '1'       else
        '0';
    --Map sprite pixels to ROM addr/col
    rom_addr <= unsigned(Y_PIXEL) - unsigned(obj_y_reg);
    rom_col <= unsigned(X_PIXEL) - unsigned(obj_x_reg);
    rom_data <= 
        SPRITE_ROM(to_integer(rom_addr)) when (sprite_on = '1') else
        (others => '0');
    rom_bit <= 
        rom_data(to_integer(rom_col)) when (sprite_on = '1') else
        '0';
    ON_OBJ <=
        '1' when (sprite_on = '1') and (rom_bit = '1') else
        '0';
    --Object color
    RGB_OBJ <= obj_rgb_reg;

end Behavioral;
