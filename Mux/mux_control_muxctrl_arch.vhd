--
-- VHDL Architecture DigTech4_lib.mux_control.muxctrl_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 14:03:56 26/03/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY mux_control IS
  generic(
    data_width :    integer :=  4
  ); 
  port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    data_1_in:        in        std_logic_vector(data_width-1 downto 0);
    data_2_in:        in        std_logic_vector(data_width-1 downto 0);
    data_3_in:        in        std_logic_vector(data_width-1 downto 0);
    data_4_in:        in        std_logic_vector(data_width-1 downto 0);
    
    data_out:         out       std_logic_vector(data_width-1 downto 0);
    outp_sel_out:     out       std_logic_vector(3 downto 0)
  );
END ENTITY mux_control;

--
ARCHITECTURE muxctrl_arch OF mux_control IS
  

  
  signal    out_select:    std_logic_vector(3 downto 0);
BEGIN
    PROCESS(clk_in) is
  BEGIN 
    if(clk_in'event and clk_in='1') then
      if(rst_in = '1') then
        data_out <= 0;
        out_select <= "1110";
        out_sel_out <= "1110";
      else
        -- Outputting data
        out_select <= out_select(3) & out_select(2 downto 0); -- ROL operation
        outp_sel_out <= out_select;
        case(out_select) is
          when "1110" => data_out <= data_1_in;
          when "1101" => data_out <= data_2_in;
          when "1011" => data_out <= data_3_in;
          when "0111" => data_out <= data_4_in;        
          when others => data_out <= 0;
        end case;
      end if;
    end if;
  END PROCESS;
END ARCHITECTURE muxctrl_arch;

