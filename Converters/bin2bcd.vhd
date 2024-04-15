--
-- VHDL Architecture DigTech4_lib.multiplexer.mux_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 12:09:48 26/03/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY DigTech4_lib;
USE DigTech4_lib.ALL;

ENTITY bin2bcd IS
  generic(
    bin_width :    integer := 6
  ); 
  port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    start_conv_in:    in        std_logic;
    bin_in:           in        unsigned(bin_width-1 downto 0);--std_logic_vector((bin_width-1) downto 0);
    
    conv_rdy_out:     out       std_logic;
    bcd_out:          out       unsigned(7 downto 0)--std_logic_vector(7 downto 0)
  );
END ENTITY bin2bcd;

--
ARCHITECTURE bin2bcd_arch OF bin2bcd IS
  -- Component declarations
   COMPONENT counter
      GENERIC (
         CTR_WIDTH :            integer     := 4;
         CTR_OVERFLOW_VALUE :   integer     := ((2**4)-1)
      );
      PORT (
        clk_in:           in        std_logic;
        rst_in:           in        std_logic;
        enable_in:        in        std_logic;
        updown_in:        in        std_logic;     
        adjust_in:        in        std_logic;
        ctr_val_in:       in        unsigned(ctr_width-1 downto 0);
        ctr_comp_val_in:  in        unsigned(ctr_width-1 downto 0);
        
        ctr_val_out:      out       unsigned(ctr_width-1 downto 0);
        ctr_match_out:    out       std_logic;
        ctr_overfl_out:   out       std_logic
      );
   END COMPONENT;

  -- Signal declarations
  signal ctr_enable:      std_logic;
  signal ctr_match:       std_logic;
  signal ctr_rst:         std_logic;
  signal buf:             unsigned(bin_width+7 downto 0);--std_logic_vector((bin_width + 7) downto 0);
  signal bcd:             unsigned(7 downto 0);--std_logic_vector(7 downto 0);
BEGIN
  -- Component instantiations
           BIN2BCD_CTR_0 : counter
            GENERIC MAP (
               CTR_WIDTH          =>    4,
               CTR_OVERFLOW_VALUE =>    ((2**4)-1)
            )
            PORT MAP (
               clk_in          => clk_in,
               rst_in          => ctr_rst,
               enable_in       => ctr_enable,
               updown_in       => '0',   
               adjust_in       => '0',
               ctr_val_in      => to_unsigned(0, 4),
               ctr_comp_val_in => to_unsigned(bin_width-1, 4),
               
               --ctr_val_out   => ,
               ctr_match_out   => ctr_match
               --ctr_overfl_out => 
            );
  
  PROCESS(clk_in)
  BEGIN
    -- Double dabble algorithm, 6 bits for mins/hrs, 8 bits for bcd result 
    if(clk_in'event and clk_in = '1') then
      bcd <=  bcd; 
      
      if(rst_in = '1') then
        conv_rdy_out <= '0';
        bcd <= to_unsigned(0, bcd'length);--std_logic_vector(to_unsigned(0, bcd'length));
        buf <= to_unsigned(0, buf'length);--std_logic_vector(to_unsigned(0, buf'length));
        ctr_enable <= '0';
      else
        if(start_conv_in = '1') then
          conv_rdy_out <= '0';
          ctr_enable <= '1';
          buf <= (others => '0');
          buf((bin_width-1) downto 0) <= bin_in;
        end if;
          
        if(ctr_match = '1') then
          -- Conversion compete
          conv_rdy_out <= '1';
          ctr_enable <= '0';
          bcd <= buf((bin_width+7) downto bin_width);
        elsif(ctr_enable = '1') then    
          --keep looping this until done (bin_width num of iterations) 
          if(buf((bin_width+3) downto bin_width) > to_unsigned(4, 4)) then
            -- add 3 and shift left 1
            buf(bin_width+7 downto bin_width+1) <= buf(bin_width+6 downto bin_width) + 3;
            buf(bin_width downto 0) <= buf(bin_width-1 downto 0) & '0';
            conv_rdy_out <= '1';
          else 
            -- shift left 1
            buf <= buf sll 1;
          end if;

        end if;
      end if;
    end if;     
  END PROCESS;
  
  ctr_rst <= not ctr_enable;
  bcd_out <= bcd;
END ARCHITECTURE bin2bcd_arch;

