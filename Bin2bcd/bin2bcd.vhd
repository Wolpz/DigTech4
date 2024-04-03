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
--USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY bin2bcd IS
  generic(
    bin_width :    integer := 6
  ); 
  port(
    clk_in:           in        std_logic;
    rst_in:           in        std_logic;
    start_conv_in:    in        std_logic;
    bin_in:           in        std_logic_vector((bin_width-1) downto 0);
    
    conv_rdy_out:     out       std_logic;
    bcd_out:          out       std_logic_vector(7 downto 0)
  );
END ENTITY bin2bcd;

--
ARCHITECTURE bin2bcd_arch OF bin2bcd IS
  -- Component declarations
   COMPONENT counter
      GENERIC (
         ctr_width : integer := 3
      );
      PORT (
        clk_in:           in        std_logic;
        rst_in:           in        std_logic;
        enable_in:        in        std_logic;
        adjust_in:        in        std_logic;
        ctr_val_in:       in        std_logic_vector(ctr_width-1 downto 0); 
        ctr_comp_val_in:  in        std_logic_vector(ctr_width-1 downto 0);
        
        ctr_val_out:      out       std_logic_vector(ctr_width-1 downto 0); 
        ctr_match_out:    out       std_logic
      );
   END COMPONENT;

  -- Signal declarations
  signal ctr_enable:      std_logic;
  signal ctr_match:       std_logic;
  signal ctr_rst:         std_logic;
  signal buf:             std_logic_vector((bin_width + 7) downto 0);
  signal bcd:             std_logic_vector(7 downto 0);
BEGIN
  -- Component instantiations
           BIN2BCD_CTR_0 : counter
            GENERIC MAP (
               ctr_width => 4
            )
            PORT MAP (
               clk_in          => clk_in,
               rst_in          => ctr_rst,
               enable_in       => ctr_enable,
               adjust_in       => '0',
               ctr_val_in      => std_logic_vector(to_unsigned(0, 4)),
               ctr_comp_val_in => std_logic_vector(to_unsigned(bin_width-1, 4)),
               
               ctr_match_out   => ctr_match
            );
  
  PROCESS(clk_in)
  BEGIN
    -- Double dabble algorithm, 6 bits for mins/hrs, 8 bits for bcd result 
    if(clk_in'event and clk_in = '1') then
      bcd <=  bcd; 
      
      if(rst_in = '1') then
        conv_rdy_out <= '0';
        bcd <= std_logic_vector(to_unsigned(0, bcd'length));
        buf <= std_logic_vector(to_unsigned(0, buf'length));
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
          if(buf((bin_width+3) downto bin_width) > std_logic_vector(to_unsigned(4, 4))) then
            --buf <= (buf((bin_width+6) downto bin_width) + "00000011") & buf((bin_width-1) downto 0) & '0';
            --buf <= (buf((bin_width+6) downto 0) + std_logic_vector(to_unsigned(3, 2) sll bin_width)) & '0';
            --buf((bin_width+7) downto bin_width) <= (buf((bin_width+7) downto bin_width) + "00000011");
            --buf <= buf(bin_width+6 downto 0) & '0';
            buf((bin_width+7) downto (bin_width+1)) <= buf((bin_width+6) downto bin_width) + std_logic_vector(to_unsigned(3, 8));
            buf(bin_width downto 0) <= buf((bin_width-1) downto 0) & '0';
            conv_rdy_out <= '1';
          else 
            -- shift left 1, throwing away MSB
            buf <= buf((bin_width+6) downto 0) & '0';
          end if;
        end if;
      end if;
    end if;     
  END PROCESS;
  
  ctr_rst <= not ctr_enable;
  bcd_out <= bcd;
END ARCHITECTURE bin2bcd_arch;

