--
-- VHDL Test Bench DigTech4_lib.mux_control_tb.mux_control_tester
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 13:51:40 03/04/2024
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY mux_control_tb IS
   GENERIC (
      data_width : integer := 4
   );
END mux_control_tb;


LIBRARY DigTech4_lib;
USE DigTech4_lib.ALL;


ARCHITECTURE rtl OF mux_control_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL clk_in       : std_logic;
   SIGNAL rst_in       : std_logic;
   SIGNAL en_in        : std_logic;
   SIGNAL data_1_in    : unsigned(data_width-1 downto 0);
   SIGNAL data_2_in    : unsigned(data_width-1 downto 0);
   SIGNAL data_3_in    : unsigned(data_width-1 downto 0);
   SIGNAL data_4_in    : unsigned(data_width-1 downto 0);
   SIGNAL data_out     : unsigned(data_width-1 downto 0);
   SIGNAL outp_sel_out : std_logic_vector(3 downto 0);


   -- Component declarations
   COMPONENT mux_control
      GENERIC (
         data_width : integer := 4
      );
      PORT (
         clk_in       : IN     std_logic;
         rst_in       : IN     std_logic;
         en_in        : IN     std_logic;
         data_1_in    : IN     unsigned(data_width-1 downto 0);
         data_2_in    : IN     unsigned(data_width-1 downto 0);
         data_3_in    : IN     unsigned(data_width-1 downto 0);
         data_4_in    : IN     unsigned(data_width-1 downto 0);
         data_out     : OUT    unsigned(data_width-1 downto 0);
         outp_sel_out : OUT    std_logic_vector(3 downto 0)
      );
   END COMPONENT;

   COMPONENT mux_control_tester
      GENERIC (
         data_width : integer := 4
      );
      PORT (
         clk_in       : OUT    std_logic;
         rst_in       : OUT    std_logic;
         en_in        : OUT    std_logic;
         data_1_in    : OUT    unsigned(data_width-1 downto 0);
         data_2_in    : OUT    unsigned(data_width-1 downto 0);
         data_3_in    : OUT    unsigned(data_width-1 downto 0);
         data_4_in    : OUT    unsigned(data_width-1 downto 0);
         data_out     : IN     unsigned(data_width-1 downto 0);
         outp_sel_out : IN     std_logic_vector(3 downto 0)
      );
   END COMPONENT;

   -- embedded configurations
   -- pragma synthesis_off
   FOR U_0 : mux_control USE ENTITY DigTech4_lib.mux_control;
   FOR U_1 : mux_control_tester USE ENTITY DigTech4_lib.mux_control_tester;
   -- pragma synthesis_on

BEGIN

         U_0 : mux_control
            GENERIC MAP (
               data_width => data_width
            )
            PORT MAP (
               clk_in       => clk_in,
               rst_in       => rst_in,
               en_in        => en_in,
               data_1_in    => data_1_in,
               data_2_in    => data_2_in,
               data_3_in    => data_3_in,
               data_4_in    => data_4_in,
               data_out     => data_out,
               outp_sel_out => outp_sel_out
            );

         U_1 : mux_control_tester
            GENERIC MAP (
               data_width => data_width
            )
            PORT MAP (
               clk_in       => clk_in,
               rst_in       => rst_in,
               en_in        => en_in,
               data_1_in    => data_1_in,
               data_2_in    => data_2_in,
               data_3_in    => data_3_in,
               data_4_in    => data_4_in,
               data_out     => data_out,
               outp_sel_out => outp_sel_out
            );


END rtl;