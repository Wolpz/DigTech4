--
-- VHDL Architecture DigTech4_lib.counter.counter_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 11:09:51 26/03/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY wekker IS
  port(
    clock_in:         in        std_logic;
    alarm_in:         in        std_logic;
    adjust_in:        in        std_logic_vector(1 downto 0);
    snooze_in:        in        std_logic;
    minute_in:        in        std_logic;
    hour_in:          in        std_logic;
    d_select_in:      in        std_logic;
    
    buzz_out:         out       std_logic;
    display_data_out: out       std_logic_vector(3 downto 0);
    display_select:   out       std_logic_vector(3 downto 0);
    led_out:          out       std_logic
  );
END ENTITY wekker;
