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
use IEEE.numeric_std.all;

ENTITY counter IS
  generic(
    CTR_WIDTH :           integer     := 6;
    CTR_OVERFLOW_VALUE :  integer     := ((2**6)-1)
  ); 
    port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    enable_in:        in        std_logic;
    updown_in:        in        std_logic;                        -- 1: DOWN   0: UP
    adjust_in:        in        std_logic;
    ctr_val_in:       in        unsigned(CTR_WIDTH-1 downto 0);
    ctr_comp_val_in:  in        unsigned(CTR_WIDTH-1 downto 0);
    
    ctr_val_out:      out       unsigned(CTR_WIDTH-1 downto 0);
    ctr_match_out:    out       std_logic;
    ctr_overfl_out:   out       std_logic
  );
END ENTITY counter;

--
ARCHITECTURE ctr_arch OF counter IS
  signal    value:    unsigned(CTR_WIDTH-1 downto 0);
BEGIN
  PROCESS(clk_in) is
  BEGIN 
    if(clk_in'event and clk_in='1') then
      if(rst_in = '1') then
        ctr_match_out <= '0';
        ctr_overfl_out <= '0';
        value <= to_unsigned(0, CTR_WIDTH);
      elsif(enable_in = '1') then
        value <= value;
        ctr_match_out <= '0';
        ctr_overfl_out <= '0';

        if(adjust_in = '1') then -- adjusting counter value
          value <= ctr_val_in;
        else                     -- normal counter operation
          if(value = to_unsigned(CTR_OVERFLOW_VALUE, CTR_WIDTH) and updown_in = '0') then
            ctr_overfl_out <= '1';
            value <= to_unsigned(0, CTR_WIDTH);
          elsif(value = to_unsigned(0, CTR_WIDTH) and updown_in = '1') then
            ctr_overfl_out <= '1';
            value <= to_unsigned(CTR_OVERFLOW_VALUE, CTR_WIDTH);
          else
            ctr_overfl_out <= '0';
            if(updown_in = '1') then
              value <= value - 1;
            else
              value <= value + 1;
            end if;

            if(value = ctr_comp_val_in) then
              ctr_match_out <= '1';
            else
              ctr_match_out <= '0';
            end if;
          end if;
        end if;
      end if;
    end if;
  END PROCESS;
  ctr_val_out <= value;
END ARCHITECTURE ctr_arch;

