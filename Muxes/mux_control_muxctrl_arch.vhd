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
USE ieee.numeric_std.all;

ENTITY mux_control IS
  generic(
    data_width :    integer :=  4
  );
  port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    en_in:            in        std_logic;
      
    data_1_in:        in        unsigned(data_width-1 downto 0);--std_logic_vector(data_width-1 downto 0);
    data_2_in:        in        unsigned(data_width-1 downto 0);--std_logic_vector(data_width-1 downto 0);
    data_3_in:        in        unsigned(data_width-1 downto 0);--std_logic_vector(data_width-1 downto 0);
    data_4_in:        in        unsigned(data_width-1 downto 0);--std_logic_vector(data_width-1 downto 0);
    
    data_out:         out       unsigned(data_width-1 downto 0);--std_logic_vector(data_width-1 downto 0);
    outp_sel_out:     out       std_logic_vector(3 downto 0)
  );
END ENTITY mux_control;

--
ARCHITECTURE muxctrl_arch OF mux_control IS
  signal      out_select:    std_logic_vector(3 downto 0);
  signal      data:          unsigned(data_width-1 downto 0);
  signal      ctr:           unsigned(1 downto 0);
BEGIN
    PROCESS(clk_in) is
  BEGIN 
    if(clk_in'event and clk_in='1') then
      if(rst_in = '1') then
        data <= to_unsigned(0, data_width);
        out_select <= "1110";
        ctr <= "00";
      elsif(en_in = '1') then
        case(ctr) is
          when "00" => 
            data <= data_1_in;
            out_select <= "1110";
          when "01" => 
            data <= data_2_in;
            out_select <= "1101";
          when "10" => 
            data <= data_3_in;
            out_select <= "1011";
          when "11" => 
            data <= data_4_in; 
            out_select <= "0111";      
          when others => data <= to_unsigned(0, data_width);
        end case;
        ctr <= ctr + 1;
      else
        out_select <= out_select;
        data <= data;
        ctr <= ctr;
      end if;
    end if;
  END PROCESS;
  outp_sel_out <= out_select;
  data_out <= data;
END ARCHITECTURE muxctrl_arch;

