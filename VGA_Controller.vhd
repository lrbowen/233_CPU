----------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: Ryan Rumsey
-- 
-- Create Date: 04/15/2016 01:47:38 PM
-- Design Name: 
-- Module Name: VGA_Controller - Behavioral
-- Project Name: Buferless VGA Controller
-- Target Devices: xc7a35t, xc7a100t
-- Tool Versions: Vivado 2015.4
-- Description: Drives a VGA monitor with color data. Contains addressable object circuits.
--      X_POS_EN, Y_POS and RGB_DATA_IN should be driven before driving OBJ_ADDR.
--      Once OBJ_ADDR is driven, the respective object will latch in the data on
--        X_POS_EN, Y_POS and RGB_DATA_IN.
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
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
    Port ( CLK, RESET   : in  STD_LOGIC;
           X_POS_EN     : in  STD_LOGIC_VECTOR (7 downto 0); --7 bits of x pos, 1 bit enable
           Y_POS        : in  STD_LOGIC_VECTOR (6 downto 0); --6 bits of y pos
           RGB_DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0); --8 bits of color
           OBJ_ADDR     : in  STD_LOGIC_VECTOR (7 downto 0); --object address
           RGB_DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           H_SYNC       : out STD_LOGIC;
           V_SYNC       : out STD_LOGIC);
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    signal video_on, s_vga_clk : std_logic;
    signal rgb_next: std_logic_vector (7 downto 0);
    signal x_pixel : std_logic_vector (6 downto 0);
    signal y_pixel : std_logic_vector (6 downto 0);
    --VGA Sync Component
    component VGA_Sync
        port (
            VGACLK, RESET  : in  STD_LOGIC;
            H_SYNC, V_SYNC : out STD_LOGIC;
            X_PIXEL        : out STD_LOGIC_VECTOR (6 downto 0);
            Y_PIXEL        : out STD_LOGIC_VECTOR (6 downto 0);
            VIDEO_ON       : out STD_LOGIC
        );
    end component;
    --Pixel Generator Component
    component Pixel_Generator
        port (
            VGACLK       : in STD_LOGIC;
            VIDEO_ON     : in STD_LOGIC;
            X_POS_EN     : in STD_LOGIC_VECTOR (7 downto 0); --7 bits of x pos, 1 bit enable
            Y_POS        : in STD_LOGIC_VECTOR (6 downto 0); --6 bits of 7 pos
            RGB_DATA_IN  : in STD_LOGIC_VECTOR (7 downto 0); --8 bits of color
            OBJ_ADDR     : in STD_LOGIC_VECTOR (7 downto 0); --object address
            X_PIXEL      : in STD_LOGIC_VECTOR (6 downto 0); --7 bits of x
            Y_PIXEL      : in STD_LOGIC_VECTOR (6 downto 0); --6 bits of y
            RGB_DATA_OUT : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    --Clock Divider Component
    component Clock_Div
        port (
            CLK_IN, RESET : in  STD_LOGIC;
            CLK_OUT       : out STD_LOGIC
        );
    end component;
    
begin

    --VGA Sync Circuit
    vga_sync_inst0 : VGA_Sync
    port map (
        VGACLK   => s_vga_clk,
        RESET    => RESET,
        H_SYNC   => H_SYNC,
        V_SYNC   => V_SYNC,
        X_PIXEL  => x_pixel,
        Y_PIXEL  => y_pixel,
        VIDEO_ON => video_on
    );
    --Clock Divider Circuit
    clock_div_inst0 : Clock_Div
    port map (
        CLK_IN  => CLK,
        RESET   => RESET,
        CLK_OUT => s_vga_clk
    );
    --Pixel Generator Circuit
    pixel_gen_inst0 : Pixel_Generator
    port map (
        VGACLK      => s_vga_clk,
        VIDEO_ON    => video_on,
        X_POS_EN    => X_POS_EN,
        Y_POS       => Y_POS,
        RGB_DATA_IN => RGB_DATA_IN,
        OBJ_ADDR    => OBJ_ADDR,
        X_PIXEL     => x_pixel,
        Y_PIXEL     => y_pixel,
        RGB_DATA_OUT => rgb_next
    );
    
    RGB_DATA_OUT <= rgb_next when video_on = '1' else
                (others => '0');

end Behavioral;
