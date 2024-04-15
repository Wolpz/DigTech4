--
-- VHDL Architecture DigTech4_lib.wekker.wekker_arch
--
-- Created:
--          by - laure.UNKNOWN (CRAPTOP)
--          at - 14:12:31 03/04/2024
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY DigTech4_lib;
USE DigTech4_lib.ALL;

ENTITY wekker IS
  generic (
    SW_ADJ_RUN:          std_logic_vector(1 downto 0)              := "00"; -- TODO use of these in CASE statement gives warnings
    SW_ADJ_TIME:         std_logic_vector(1 downto 0)              := "10";
    SW_ADJ_ALARM:        std_logic_vector(1 downto 0)              := "01";

    DB_SAMPLES:          integer                                   := 20
  );
  port(
    clock_in:         in        std_logic;
    alarm_in:         in        std_logic;
    adjust_in:        in        std_logic_vector(1 downto 0);
    snooze_in:        in        std_logic;
    minute_in:        in        std_logic;
    hour_in:          in        std_logic;
    d_select_in:      in        std_logic;
    
    buzz_out:           out       std_logic;
    display_data_out:   out       unsigned(3 downto 0);
    display_select_out: out       std_logic_vector(3 downto 0);
    led_out:            out       std_logic
  );
END ENTITY wekker;

-- Additonal modules:
-- seconds, minutes, hours: counters
-- counter that goes off every 10mins for snooze
-- bin2bcd -> display mux
-- debouncers for all inputs
-- put wekker control logic in separate wekker_controller module for better overview

--
ARCHITECTURE wekker_arch OF wekker IS
    --============================== TYPEDEFS ==============================--
      type T_STATE is
        (RESET, WEKKER, ADJUST_ALARM, ADJUST_TIME);
      type T_TIME is 
        record
          HOURS:    unsigned(4 downto 0);
          MINUTES:  unsigned(5 downto 0);
        end record;
      type T_BCD_TIME is 
        record
          HOURS_D0 :      unsigned(3 downto 0);
          HOURS_D1 :      unsigned(3 downto 0);
          MINUTES_D0 :    unsigned(3 downto 0);
          MINUTES_D1 :    unsigned(3 downto 0);
        end record;


  --============================== SIGNAL DEFINITIONS ==============================--
      signal GLOBAL_RESET:            std_logic;
      signal GLOBAL_TIME_ENABLE :     std_logic;
      signal GLOBAL_ENABLE_ALARM :    std_logic;
      signal GLOBAL_ADJUST_TIME  :  std_logic;

      signal CURRENT_STATE:       T_STATE;
      signal NEXT_STATE:          T_STATE;  
      signal CURRENT_TIME:        T_TIME;
      signal ALARM_TIME:          T_TIME;
      signal ADJUSTED_TIME:       T_TIME;   
      signal DISPLAY_VAL:         T_TIME;
      signal BCD_TIME:            T_BCD_TIME; 
      
      signal alarm_in_db:               std_logic;
      signal adjust_in_db:              std_logic_vector(1 downto 0);
      signal snooze_in_db:              std_logic;
      signal minute_in_db:              std_logic;
      signal hour_in_db:                std_logic;

      signal snooze_in_db_prev:         std_logic;
      signal minute_in_db_prev:         std_logic;
      signal hour_in_db_prev:           std_logic;
      
      signal seconds_ctr_match :    std_logic; 
      signal seconds_ctr_OVF :      std_logic;    
      signal minutes_ctr_match :    std_logic; 
      signal minutes_ctr_OVF :      std_logic; 
      signal hours_ctr_match :      std_logic; 
      signal hours_ctr_OVF :        std_logic; 

      signal bin2bcd_conv_start_mins :  std_logic;
      signal bin2bcd_conv_start_hrs :   std_logic;
      signal bin2bcd_conv_compl_mins :  std_logic;
      signal bin2bcd_conv_compl_hrs :   std_logic;

      signal alarm_state :         std_logic;

      signal snooze_ctr_enable :   std_logic;
      signal snooze_ctr_updown :   std_logic;
      signal snooze_ctr_adjust :   std_logic;
      signal snooze_ctr_adjustVal :unsigned(5 downto 0);
      signal snooze_ctr_compVal :  unsigned(5 downto 0);
      signal snooze_ctr_val :      unsigned(5 downto 0);
      signal snooze_ctr_match :    std_logic;
      signal snooze_ctr_OVF :      std_logic;

      signal ledState :               std_logic;

  --============================== COMPONENT DECLARATIONS ==============================--
    COMPONENT debouncer
      GENERIC (
          samples : integer := DB_SAMPLES
      );
      PORT (
          clk_in : IN     std_logic;
          rst_in : IN     std_logic;
          s_in   : IN     std_logic;
          db_out : OUT    std_logic
      );
      END COMPONENT;

    COMPONENT counter
      GENERIC (
        CTR_WIDTH :           integer     :=  6;
        CTR_OVERFLOW_VALUE :  integer     := 59
      );
      PORT (
        clk_in          : IN     std_logic;
        rst_in          : IN     std_logic;
        enable_in       : IN     std_logic;
        updown_in       : IN     std_logic;
        adjust_in       : IN     std_logic;
        ctr_val_in      : IN     unsigned(CTR_WIDTH-1 downto 0);
        ctr_comp_val_in : IN     unsigned(CTR_WIDTH-1 downto 0);
        ctr_val_out     : OUT    unsigned(CTR_WIDTH-1 downto 0);
        ctr_match_out   : OUT    std_logic;
        ctr_overfl_out  : OUT    std_logic
      );
      END COMPONENT;
    COMPONENT bin2bcd
      GENERIC (
         bin_width : integer := 8
      );
      PORT (
         clk_in        : IN     std_logic;
         rst_in        : IN     std_logic;
         start_conv_in : IN     std_logic;
         bin_in        : IN     unsigned(bin_width-1 downto 0);
         conv_rdy_out  : OUT    std_logic;
         bcd_out       : OUT    unsigned(7 downto 0)
      );
      END COMPONENT;

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
  
  --============================== COMPONENT INITIALISATIONS ==============================--
    FOR DB_ALARM_0 :        debouncer USE ENTITY DigTech4_lib.debouncer;
    FOR DB_ADJUST_0 :       debouncer USE ENTITY DigTech4_lib.debouncer;
    FOR DB_ADJUST_1 :       debouncer USE ENTITY DigTech4_lib.debouncer;
    FOR DB_SNOOZE_0 :       debouncer USE ENTITY DigTech4_lib.debouncer;
    FOR DB_MINUTE_0 :       debouncer USE ENTITY DigTech4_lib.debouncer;
    FOR DB_HOUR_0 :         debouncer USE ENTITY DigTech4_lib.debouncer;

    FOR SECONDS_CTR :       counter USE ENTITY DigTech4_lib.counter;
    FOR MINUTES_CTR :       counter USE ENTITY DigTech4_lib.counter;
    FOR HOURS_CTR :         counter USE ENTITY DigTech4_lib.counter;
    FOR snooze_ctr :     counter USE ENTITY DigTech4_lib.counter;

    FOR BIN2BCD_MINUTES :   bin2bcd USE ENTITY DigTech4_lib.bin2bcd;
    FOR BIN2BCD_HOURS :     bin2bcd USE ENTITY DigTech4_lib.bin2bcd;

    FOR DISPL_MUX_0: mux_control USE ENTITY DigTech4_lib.mux_control;
        
  --============================== FUNCTIONS ==============================--
  procedure relinkDisplay -- TODO Waarom mag ik geen signalen aansturen vanuit procedure??
    (
      signal source :             in    T_TIME
    ) is
    begin
      DISPLAY_VAL.HOURS <= source.HOURS;
      DISPLAY_VAL.MINUTES <= source.MINUTES;
      bin2bcd_conv_start_hrs <= '1';
      bin2bcd_conv_start_mins <= '1';
    end procedure;

  procedure setUnsigned
    (
      signal s :        inout   unsigned;
      constant q :        in    integer
    ) is 
    begin
      s <= to_unsigned(q,  s'length);
    end procedure;

  function detectPress(
      signal button : in std_logic;
      signal buttonPrev : in std_logic
    ) return boolean is 
    begin
      return ((button = '1') and (buttonPrev = '0'));
    end function;


BEGIN
    --============================== COMPONENT PORTMAPS ==============================--
      --==== DEBOUNCERS ====--
      DB_ALARM_0 : debouncer
         GENERIC MAP (
            samples => DB_SAMPLES
         )
         PORT MAP (
            clk_in => d_select_in,
            rst_in => GLOBAL_RESET,
            s_in   => alarm_in,
            db_out => alarm_in_db
         );

      DB_ADJUST_0 : debouncer
        GENERIC MAP (
          samples => DB_SAMPLES
        )
        PORT MAP (
          clk_in => d_select_in,
          rst_in => GLOBAL_RESET,
          s_in   => adjust_in(0),
          db_out => adjust_in_db(0)
        );
      
      DB_ADJUST_1 : debouncer
        GENERIC MAP (
          samples => DB_SAMPLES
        )
        PORT MAP (
          clk_in => d_select_in,
          rst_in => GLOBAL_RESET,
          s_in   => adjust_in(1),
          db_out => adjust_in_db(1)
        );

      DB_SNOOZE_0 : debouncer
        GENERIC MAP (
          samples => DB_SAMPLES
        )
        PORT MAP (
          clk_in => d_select_in,
          rst_in => GLOBAL_RESET,
          s_in   => snooze_in,
          db_out => snooze_in_db
        );

      DB_MINUTE_0 : debouncer
        GENERIC MAP (
          samples => DB_SAMPLES
        )
        PORT MAP (
          clk_in => d_select_in,
          rst_in => GLOBAL_RESET,
          s_in   => minute_in,
          db_out => minute_in_db
        );

      DB_HOUR_0 : debouncer
        GENERIC MAP (
          samples => DB_SAMPLES
        )
        PORT MAP (
          clk_in => d_select_in,
          rst_in => GLOBAL_RESET,
          s_in   => hour_in,
          db_out => hour_in_db
        );
      --==== COUNTERS ====--
      SECONDS_CTR : counter
        GENERIC MAP (
          CTR_WIDTH           =>      6,
          CTR_OVERFLOW_VALUE  =>      59
        )
        PORT MAP (
          clk_in          => clock_in,
          rst_in          => GLOBAL_RESET,
          enable_in       => GLOBAL_TIME_ENABLE,
          updown_in       => '0',
          adjust_in       => '0',
          ctr_val_in      => to_unsigned(0, 6),
          ctr_comp_val_in => to_unsigned(60, 6),
          --ctr_val_out     => ,
          --ctr_match_out   => ,
          ctr_overfl_out  =>  seconds_ctr_OVF
        );

      MINUTES_CTR : counter
        GENERIC MAP (
          CTR_WIDTH           =>      6,
          CTR_OVERFLOW_VALUE  =>      59
        )
        PORT MAP (
          clk_in          => clock_in,
          rst_in          => GLOBAL_RESET,
          enable_in       => GLOBAL_TIME_ENABLE,
          updown_in       => '0',
          adjust_in       => GLOBAL_ADJUST_TIME,
          ctr_val_in      => ADJUSTED_TIME.MINUTES,
          ctr_comp_val_in => ALARM_TIME.MINUTES,
          ctr_val_out     => CURRENT_TIME.MINUTES,
          ctr_match_out   => minutes_ctr_match,
          ctr_overfl_out  => minutes_ctr_OVF
        );

      HOURS_CTR : counter
        GENERIC MAP (
          CTR_WIDTH           =>      5,
          CTR_OVERFLOW_VALUE  =>      23
        )
        PORT MAP (
          clk_in          => clock_in,
          rst_in          => GLOBAL_RESET,
          enable_in       => GLOBAL_TIME_ENABLE,
          updown_in       => '0',
          adjust_in       => GLOBAL_ADJUST_TIME,
          ctr_val_in      => ADJUSTED_TIME.HOURS,
          ctr_comp_val_in => ALARM_TIME.HOURS,
          ctr_val_out     => CURRENT_TIME.HOURS,
          ctr_match_out   => hours_ctr_match,
          ctr_overfl_out  => hours_ctr_OVF
        );

      snooze_ctr : counter
        GENERIC MAP (
          CTR_WIDTH           =>      6,
          CTR_OVERFLOW_VALUE  =>      9
        )
        PORT MAP (
          clk_in          => seconds_ctr_OVF,
          rst_in          => (GLOBAL_RESET or not snooze_ctr_enable), -- TODO is this allowed??
          enable_in       => snooze_ctr_enable,
          updown_in       => '0',
          adjust_in       => '0',
          ctr_val_in      => to_unsigned(0, 6),
          ctr_comp_val_in => to_unsigned(10, 6),
          --ctr_val_out     => snooze_ctr_val,
          --ctr_match_out   => snooze_ctr_match,
          ctr_overfl_out  => snooze_ctr_OVF
        );

      --==== CONVERTERS ====--
      BIN2BCD_MINUTES : bin2bcd
        GENERIC MAP (
            bin_width => 6
        )
        PORT MAP (
            clk_in        => d_select_in,
            rst_in        => GLOBAL_RESET,
            start_conv_in => bin2bcd_conv_start_mins,
            bin_in        => DISPLAY_VAL.MINUTES,
            conv_rdy_out  => bin2bcd_conv_compl_mins,
            bcd_out       => (BCD_TIME.MINUTES_D1(3 downto 0), BCD_TIME.MINUTES_D0(3 downto 0)) -- TODO is this allowed??
        );

      BIN2BCD_HOURS : bin2bcd
        GENERIC MAP (
          bin_width => 5
        )
        PORT MAP (
          clk_in        => d_select_in,
          rst_in        => GLOBAL_RESET,
          start_conv_in => bin2bcd_conv_start_hrs,
          bin_in        => DISPLAY_VAL.HOURS,
          conv_rdy_out  => bin2bcd_conv_compl_hrs,
          bcd_out       => (BCD_TIME.HOURS_D1 & BCD_TIME.HOURS_D0) -- TODO is this allowed??
        );

      --==== MUXES ====--
      DISPL_MUX_0 : mux_control
        GENERIC MAP (
            data_width => 4
        )
        PORT MAP (
            clk_in       => d_select_in,
            rst_in       => GLOBAL_RESET,
            en_in        => (bin2bcd_conv_compl_mins and bin2bcd_conv_compl_hrs), -- TODO is this allowed??"not globally static"
            data_1_in    => BCD_TIME.MINUTES_D0,
            data_2_in    => BCD_TIME.MINUTES_D1,
            data_3_in    => BCD_TIME.HOURS_D0,
            data_4_in    => BCD_TIME.HOURS_D1,
            data_out     => display_data_out,
            outp_sel_out => display_select_out
        );
    
  PROCESS(clock_in)
    BEGIN
    if(clock_in'event and clock_in='1') then
      NEXT_STATE    <= CURRENT_STATE;
      CURRENT_STATE <= NEXT_STATE;

      GLOBAL_ADJUST_TIME <= GLOBAL_ADJUST_TIME;
      GLOBAL_RESET <= GLOBAL_RESET;
      GLOBAL_TIME_ENABLE <= GLOBAL_TIME_ENABLE;
      GLOBAL_ENABLE_ALARM <= GLOBAL_ENABLE_ALARM;

      bin2bcd_conv_start_mins <= '0';
      bin2bcd_conv_start_hrs <= '0';    

      snooze_in_db_prev <= snooze_in_db;
      minute_in_db_prev <= minute_in_db;
      hour_in_db_prev <= hour_in_db;

      led_out <= ledState;

      -- Alarm logic
      if((alarm_in = '1') and (GLOBAL_ENABLE_ALARM = '1')) then
        if(((hours_ctr_match = '1') and (minutes_ctr_match = '1')) and (alarm_state = '0')) then
          alarm_state <= '1';
          buzz_out <= '1';
        elsif(alarm_state = '1') then
          if(detectPress(snooze_in_db, snooze_in_db_prev)) then
            buzz_out <= '0';
            snooze_ctr_enable <= '1';
          end if;
          if(snooze_ctr_OVF = '1') then
            buzz_out <= '1';
            snooze_ctr_enable <= '0';
          end if;
        else 
          buzz_out <= '0';
          alarm_state <= '0';
          snooze_ctr_enable <= '0';
        end if;
      else
        buzz_out <= '0';
        alarm_state <= '0';
        snooze_ctr_enable <= '0';
      end if;

      CASE CURRENT_STATE IS
        when RESET =>
          -- State actions
          GLOBAL_RESET <= '1';
          GLOBAL_TIME_ENABLE <= '0';
          GLOBAL_ADJUST_TIME <= '0';
          GLOBAL_ENABLE_ALARM <= '0';

          setUnsigned(DISPLAY_VAL.MINUTES, 0);
          setUnsigned(DISPLAY_VAL.HOURS, 0);
          setUnsigned(ADJUSTED_TIME.MINUTES, 0);
          setUnsigned(ADJUSTED_TIME.HOURS, 0); 
          setUnsigned(ALARM_TIME.MINUTES, 0); 
          setUnsigned(ALARM_TIME.HOURS, 0); 
        
          bin2bcd_conv_start_mins <= '0';
          bin2bcd_conv_start_hrs <= '0';

          ledState <= '0';

          -- State transitions
          CASE adjust_in_db IS 
            when SW_ADJ_RUN =>
              NEXT_STATE <= WEKKER;
            when SW_ADJ_TIME =>
              NEXT_STATE <= ADJUST_TIME;
            when SW_ADJ_ALARM =>
              NEXT_STATE <= ADJUST_ALARM;
            when others =>
              NEXT_STATE <= RESET;
            END CASE;

        when WEKKER =>
          -- State actions
          GLOBAL_TIME_ENABLE <= '1';
          GLOBAL_ADJUST_TIME <= '0';
          GLOBAL_ENABLE_ALARM <= '1';

          relinkDisplay(CURRENT_TIME);

          ledState <= '1';

          -- State transitions
          CASE adjust_in_db IS 
            when SW_ADJ_RUN =>
              NEXT_STATE <= WEKKER;
            when SW_ADJ_TIME =>
              NEXT_STATE <= ADJUST_TIME;
            when SW_ADJ_ALARM =>
              NEXT_STATE <= ADJUST_ALARM;
            when others =>
              NEXT_STATE <= RESET;
            END CASE;

        when ADJUST_ALARM =>
          -- State actions
            GLOBAL_TIME_ENABLE <= '1';
            GLOBAL_ADJUST_TIME <= '0';
            GLOBAL_ENABLE_ALARM <= '0';

            relinkDisplay(ADJUSTED_TIME);  
            
            ledState <= not ledState;
         
            if(detectPress(hour_in_db, hour_in_db_prev)) then
                if(ADJUSTED_TIME.HOURS = to_unsigned(23, ADJUSTED_TIME.HOURS'length)) then
                  ADJUSTED_TIME.HOURS <= to_unsigned(0, ADJUSTED_TIME.HOURS'length);
                else
                  ADJUSTED_TIME.HOURS <= ADJUSTED_TIME.HOURS + 1;
                end if;
              end if;

            if(detectPress(minute_in_db, minute_in_db_prev)) then
              if(ADJUSTED_TIME.MINUTES = to_unsigned(59, ADJUSTED_TIME.MINUTES'length)) then
                ADJUSTED_TIME.MINUTES <= to_unsigned(0, ADJUSTED_TIME.MINUTES'length);
              else
                ADJUSTED_TIME.MINUTES <= ADJUSTED_TIME.MINUTES + 1;
              end if;
            end if;

          -- State transitions
            CASE adjust_in_db IS 
              when SW_ADJ_RUN =>
                NEXT_STATE <= WEKKER;
              when SW_ADJ_TIME =>
                NEXT_STATE <= ADJUST_TIME;
              when SW_ADJ_ALARM =>
                NEXT_STATE <= ADJUST_ALARM;
              when others =>
                NEXT_STATE <= RESET;
              END CASE;

        when ADJUST_TIME =>
          -- State actions
            GLOBAL_TIME_ENABLE <= '1';
            GLOBAL_ADJUST_TIME <= '1';
            GLOBAL_ENABLE_ALARM <= '1';

            relinkDisplay(ADJUSTED_TIME);

            ledState <= not ledState;
          
          if(detectPress(hour_in_db, hour_in_db_prev) and detectPress(minute_in_db, minute_in_db_prev)) then
            setUnsigned(ADJUSTED_TIME.HOURS, 0);
            setUnsigned(ADJUSTED_TIME.MINUTES, 0);

          elsif(detectPress(hour_in_db, hour_in_db_prev)) then
              if(ADJUSTED_TIME.HOURS = to_unsigned(23, ADJUSTED_TIME.HOURS'length)) then
                ADJUSTED_TIME.HOURS <= to_unsigned(0, ADJUSTED_TIME.HOURS'length);
              else
                ADJUSTED_TIME.HOURS <= ADJUSTED_TIME.HOURS + 1;
              end if;

          elsif(detectPress(minute_in_db, minute_in_db_prev)) then
            if(ADJUSTED_TIME.MINUTES = to_unsigned(59, ADJUSTED_TIME.MINUTES'length)) then
              ADJUSTED_TIME.MINUTES <= to_unsigned(0, ADJUSTED_TIME.MINUTES'length);
            else
              ADJUSTED_TIME.MINUTES <= ADJUSTED_TIME.MINUTES + 1;
              end if;
            end if;


          -- State transitions
            CASE adjust_in_db IS 
              when SW_ADJ_RUN =>
                NEXT_STATE <= WEKKER;
              when SW_ADJ_TIME =>
                NEXT_STATE <= ADJUST_TIME;
              when SW_ADJ_ALARM =>
                NEXT_STATE <= ADJUST_ALARM;
              when others =>
                NEXT_STATE <= RESET;
              END CASE;

        when others =>
          -- State actions


          -- State transitions
            CURRENT_STATE <= RESET;
            NEXT_STATE <= RESET;
      END CASE;

      -- State transition actions
      if(CURRENT_STATE /= NEXT_STATE) then
        -- State exit actions
          CASE CURRENT_STATE is 
            when RESET =>
              GLOBAL_RESET <= '0';
            when WEKKER =>

            when ADJUST_ALARM =>

            when ADJUST_TIME =>
              CURRENT_TIME <= ADJUSTED_TIME;
            END CASE;
        -- State enter actions
          CASE NEXT_STATE is 
            when RESET =>

            when WEKKER =>

            when ADJUST_ALARM =>

            when ADJUST_TIME =>
              -- Get current time
              ADJUSTED_TIME <= CURRENT_TIME;
            END CASE;
      end if;
    end if;
    END PROCESS;

END ARCHITECTURE wekker_arch;

