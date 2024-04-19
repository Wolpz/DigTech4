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
-- TODO change this module so that it locks on enable, spits out data, then returns to inactive until enable is low again
--
ARCHITECTURE muxctrl_arch OF mux_control IS
  signal      out_select:    std_logic_vector(3 downto 0);
  signal      data:          unsigned(data_width-1 downto 0);
  signal      ctr:           unsigned(1 downto 0);
  signal      data_buf:      unsigned(data_width*3-1 downto 0);
  signal      mux_rdy   :    std_logic;

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
            data_buf <= data_2_in & data_3_in & data_4_in;
            out_select <= "1110";
            ctr <= "01";
          when "01" => 
            data <= data_buf(data_width*3-1 downto data_width*2);
            out_select <= "1101";
            ctr <= "10";
          when "10" => 
            data <= data_buf(data_width*2-1 downto data_width*1);
            out_select <= "1011";
            ctr <= "11";
          when "11" => 
            data <= data_buf(data_width-1 downto 0); 
            out_select <= "0111";        
            ctr <= "00";  
          when others => data <= to_unsigned(0, data_width);
        end case;
      end if;
    end if;
  END PROCESS;
  outp_sel_out <= out_select;
  data_out <= data;
END ARCHITECTURE muxctrl_arch;

