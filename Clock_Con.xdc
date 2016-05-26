# These constraints define the clocks of this project
# They are only used during implementation

#Main system clock. 
# Replace CLK with the top-level clock input of the RAT Wrapper, if applicable.
# This clock assumes a 100MHz input clock.
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK]

#Slow clock that's fed to the RAT modules
# Replace CLK with the top-level clock input of the RAT Wrapper, if applicable.
# Replace 2 with the frequency divider integer, if applicable.
# Replace MCU/cd/tmp_clks_reg_0 with the synthesized pin name on the output of the MCU clock divider, if applicable.
create_generated_clock -name slow_clock -source [get_ports CLK] -divide_by 2 [get_pins clk50M/sclk]

#Slow clock that's used in the VGA Controller
# Replace CLK with the top-level clock input of the RAT Wrapper, if applicable.
# Replace 4 with the frequency divider integer, if applicable.
# Replace VGA/clock_div_inst0/temp_clk_reg_0 with the synthesized pin name on the output of the VGA clock divider, if applicable.
create_generated_clock -name vga_clock -source [get_ports CLK] -divide_by 4 [get_pins VGA/clock_div_inst0/CLK_OUT]