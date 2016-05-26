
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
  USE ieee.numeric_std.all;

ENTITY debounce IS
   PORT( 
      input     : IN     std_ulogic;
      debounced : OUT    std_ulogic;
      clock     : IN     std_ulogic;
      reset     : IN     std_ulogic
   );
END debounce ;


ARCHITECTURE rtl OF debounce IS
  CONSTANT counterBitNb : positive := 8;
  signal mode : integer := 0;
  signal cnt : unsigned(counterBitNb -1 downto 0);
  signal debounced_m0 : std_ulogic;
  signal debounced_m1 : std_ulogic;

BEGIN

  counter: process(reset, clock)
  begin
    if reset = '1' then
      cnt <= (others => '0');
    elsif rising_edge(clock) then
      if mode = 0 then
        if input = '1' then
          cnt <= (others => '1');
        else
          if cnt /= 0 then
            cnt <= cnt - 1;
          end if;
        end if;
      else
        if input = '0' then
          cnt <= (others => '1');
        else
          if cnt /= 0 then
            cnt <= cnt - 1;
          end if;
        end if;
      end if;
    end if;
  end process counter;
  
  -- Output
  debounced_m0 <= '1' when cnt /= 0
             else '0';
  debounced_m1 <= '1' when cnt = 0
             else '0';	
  debounced <= debounced_m0 when mode = 0
          else debounced_m1;

END ARCHITECTURE rtl;
