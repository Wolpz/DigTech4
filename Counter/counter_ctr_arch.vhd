--
-- VHDL Architecture DigTech4_lib.counter.ctr_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 11:37:16 26/03/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use IEEE.numeric_std.all;
---USE ieee.std_logic_unsigned.all;

ENTITY counter IS
  generic(
    ctr_width :    integer := 6
  ); 
    port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    enable_in:        in        std_logic;
    adjust_in:        in        std_logic;
    ctr_val_in:       in        std_logic_vector(ctr_width-1 downto 0);
    ctr_comp_val_in:  in        std_logic_vector(ctr_width-1 downto 0);
    
    ctr_val_out:      out       std_logic_vector(ctr_width-1 downto 0);
    ctr_match_out:    out       std_logic
  );
END ENTITY counter;

--
ARCHITECTURE ctr_arch OF counter IS
  signal    value:    std_logic_vector(ctr_width-1 downto 0);
BEGIN
  PROCESS(clk_in) is
  BEGIN 
    if(clk_in'event and clk_in='1') then
      if(rst_in = '1') then
        ctr_match_out <= '0';
        value <= std_logic_vector(to_unsigned(0, ctr_width));
      elsif(enable_in = '1') then
        value <= value;
        ctr_match_out <= '0';
        if(adjust_in = '1') then -- adjusting counter value
          value <= ctr_val_in;
        else                     -- normal counter operation
          if(value = ctr_comp_val_in) then
            value <= std_logic_vector(to_unsigned(0, ctr_width));
            ctr_match_out <= '1';
          else
            value <= value + std_logic_vector(to_unsigned(1, ctr_width));
          end if;
        end if;
      end if;
    end if;
  END PROCESS;
  ctr_val_out <= value;
END ARCHITECTURE ctr_arch;

