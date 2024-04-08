--
-- VHDL Architecture DigTech4_lib.debouncer.debouncer_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 14:54:25 08/04/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY debouncer IS
  GENERIC (  
    samples:               integer := 20;
  );
  PORT (
    clk_in:          in        std_logic;
    rst_in:          in        std_logic;
    s_in:            in        std_logic;
    
    db_out:          out       std_logic;
  );
END ENTITY debouncer;

--
ARCHITECTURE debouncer_arch OF debouncer IS
    signal buf:         std_logic_vector(samples-1 downto 0);
    signal compval:     std_logic_vector(samples-1 downto 0) := (others => '1');
BEGIN
    PROCESS(clk_in) is
        if(clk_in'event and  clk_in='1') then
            if(rst_in = '1') then
                db_out <= '0';
                buf <= (others => '0');
                compval <= (others => '1');
            else
                buf(0) <= s_in;
                buf(samples-1 downto 1) <= buf(samples-2 downto 0);
                if(buf = compval) then
                    db_out <= '1';
                else
                    db_out <= '0';
                end if;
        end if;
    END PROCESS
END ARCHITECTURE debouncer_arch;

