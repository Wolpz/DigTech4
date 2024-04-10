--
-- VHDL Test Bench DigTech4_lib.debouncer_tb.debouncer_tester
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 15:41:05 08/04/2024
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY debouncer_tb IS
   GENERIC (
      samples : integer := 20
   );
END debouncer_tb;


LIBRARY DigTech4_lib;
USE DigTech4_lib.ALL;


ARCHITECTURE rtl OF debouncer_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL clk_in : std_logic;
   SIGNAL rst_in : std_logic;
   SIGNAL s_in   : std_logic;
   SIGNAL db_out : std_logic;


   -- Component declarations
   COMPONENT debouncer
      GENERIC (
         samples : integer := 20
      );
      PORT (
         clk_in : IN     std_logic;
         rst_in : IN     std_logic;
         s_in   : IN     std_logic;
         db_out : OUT    std_logic
      );
   END COMPONENT;

   COMPONENT debouncer_tester
      GENERIC (
         samples : integer := 20
      );
      PORT (
         clk_in : OUT    std_logic;
         rst_in : OUT    std_logic;
         s_in   : OUT    std_logic;
         db_out : IN     std_logic
      );
   END COMPONENT;

   -- embedded configurations
   -- pragma synthesis_off
   FOR U_0 : debouncer USE ENTITY DigTech4_lib.debouncer;
   FOR U_1 : debouncer_tester USE ENTITY DigTech4_lib.debouncer_tester;
   -- pragma synthesis_on

BEGIN

         U_0 : debouncer
            GENERIC MAP (
               samples => samples
            )
            PORT MAP (
               clk_in => clk_in,
               rst_in => rst_in,
               s_in   => s_in,
               db_out => db_out
            );

         U_1 : debouncer_tester
            GENERIC MAP (
               samples => samples
            )
            PORT MAP (
               clk_in => clk_in,
               rst_in => rst_in,
               s_in   => s_in,
               db_out => db_out
            );


END rtl;