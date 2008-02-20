library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;


entity syscontroltest is

end syscontroltest;


architecture Behavioral of syscontroltest is

  signal CLK   : std_logic := '0';
  signal CLK2X : std_logic := '0';

  signal RESET  : std_logic := '1';
  signal ECYCLE : std_logic := '0';


  signal EARX : std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0)  := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)  := (others => '0');
  signal EOUTD   : std_logic_vector(15 downto 0) := (others => '0');
  signal EOUTA   : std_logic_vector(2 downto 0)  := (others => '0');

  signal EVALID : std_logic := '0';
  signal ENEXT  : std_logic := '0';

  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDTX : std_logic_vector(7 downto 0)                  := (others => '0');

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');


  signal pos : integer range 0 to 999 := 980;


  constant DEVICE   : std_logic_vector(7 downto 0) := X"01";


  constant MYDEVICE : std_logic_vector(7 downto 0) := X"17";
  constant MYDEVICEint : integer := 23;

  signal receivedcntid : std_logic_vector(15 downto 0) := (others => '0');
  signal receivedcnt   : std_logic_vector(31 downto 0) := (others => '0');

  signal clkstate : integer   := 0;
  signal mainclk  : std_logic := '0';

  signal serialregin : std_logic_vector(39 downto 0) := (others => '0');
  signal serialbcnt  : integer                       := 0;
  signal outword     : std_logic_vector(31 downto 0) := X"1234ABCD";

  signal serout  : std_logic_vector(19 downto 0) := (others => '0');
  signal dlinkup : std_logic_vector(31 downto 0) := X"11223344"; 


  signal recoveredevent     : eventarray := (others => (others => '0'));
  signal recoveredeventdone : std_logic  := '0';

begin  -- Behavioral


  mainclk <= not mainclk after 2.5 ns;
  reset   <= '0'         after 100 ns;

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkstate = 3 then
        clkstate <= 0;
      else
        clkstate <= clkstate + 1;
      end if;

      if clkstate = 0 or clkstate = 2 then
        CLK2X <= '0';
      else
        CLK2X <= '1';
      end if;

      if clkstate = 1 then
        CLK <= '0';
      elsif clkstate = 3 then
        CLK <= '1';
      end if;
    end if;
  end process;


  RESET <= '0' after 100 ns;


  syscontrol_uut : entity soma.syscontrol
    generic map (
      DEVICE      => DEVICE,
      RAM_INIT_00 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_00,
      RAM_INIT_01 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_01,
      RAM_INIT_02 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_02,
      RAM_INIT_03 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_03,
      RAM_INIT_04 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_04,
      RAM_INIT_05 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_05,
      RAM_INIT_06 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_06,
      RAM_INIT_07 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_07,
      RAM_INIT_08 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_08,
      RAM_INIT_09 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_09,
      RAM_INIT_0A => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0A,
      RAM_INIT_0B => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0B,
      RAM_INIT_0C => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0C,
      RAM_INIT_0D => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0D,
      RAM_INIT_0E => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0E,
      RAM_INIT_0F => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_0F,

      RAM_INIT_10 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_10,
      RAM_INIT_11 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_11,
      RAM_INIT_12 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_12,
      RAM_INIT_13 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_13,
      RAM_INIT_14 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_14,
      RAM_INIT_15 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_15,
      RAM_INIT_16 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_16,
      RAM_INIT_17 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_17,
      RAM_INIT_18 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_18,
      RAM_INIT_19 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_19,
      RAM_INIT_1A => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1A,
      RAM_INIT_1B => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1B,
      RAM_INIT_1C => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1C,
      RAM_INIT_1D => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1D,
      RAM_INIT_1E => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1E,
      RAM_INIT_1F => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_1F,

      RAM_INIT_20 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_20,
      RAM_INIT_21 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_21,
      RAM_INIT_22 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_22,
      RAM_INIT_23 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_23,
      RAM_INIT_24 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_24,
      RAM_INIT_25 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_25,
      RAM_INIT_26 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_26,
      RAM_INIT_27 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_27,
      RAM_INIT_28 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_28,
      RAM_INIT_29 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_29,
      RAM_INIT_2A => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2A,
      RAM_INIT_2B => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2B,
      RAM_INIT_2C => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2C,
      RAM_INIT_2D => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2D,
      RAM_INIT_2E => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2E,
      RAM_INIT_2F => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_2F,

      RAM_INIT_30 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_30,
      RAM_INIT_31 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_31,
      RAM_INIT_32 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_32,
      RAM_INIT_33 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_33,
      RAM_INIT_34 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_34,
      RAM_INIT_35 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_35,
      RAM_INIT_36 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_36,
      RAM_INIT_37 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_37,
      RAM_INIT_38 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_38,
      RAM_INIT_39 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_39,
      RAM_INIT_3A => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3A,
      RAM_INIT_3B => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3B,
      RAM_INIT_3C => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3C,
      RAM_INIT_3D => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3D,
      RAM_INIT_3E => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3E,
      RAM_INIT_3F => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INIT_3F,

      RAM_INITP_00 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_00,
      RAM_INITP_01 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_01,
      RAM_INITP_02 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_02,
      RAM_INITP_03 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_03,
      RAM_INITP_04 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_04,
      RAM_INITP_05 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_05,
      RAM_INITP_06 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_06,
      RAM_INITP_07 => work.syscontroltest_mem_pkg.syscontrol_inst_ram_INITP_07 )
    port map (
      CLK          => CLK,
      CLK2X        => CLK2X,
      RESET        => RESET,
      ECYCLE       => ECYCLE,
      EDTX         => EDTX,
      EATX         => EATX,
      EARX         => EARX,
      EDRX         => EDRX,
      EDSELRX      => EDSELRX,
      SEROUT       => SEROUT,
      DLINKUP      => DLINKUP);

  ecycle_generation: process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;


  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and pos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;


  process
  begin
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    -- extract out the event
    for i in 0 to 5 loop
      EDSELRX                        <= std_logic_vector(TO_UNSIGNED(i*2 + 0, 4));
      wait until rising_edge(CLK);
      recoveredevent(i)(15 downto 8) <= EDRX;
      EDSELRX                        <= std_logic_vector(TO_UNSIGNED(i*2 + 1, 4));
      wait until rising_edge(CLK);
      recoveredevent(i)(7 downto 0)  <= EDRX;
    end loop;  -- i
    EDSELRX                          <= X"0";
    recoveredEventDone               <= '1';
    wait until rising_edge(CLK);
    recoveredEventDone               <= '0';

  end process;

  process
  begin
    -- send test events
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(MYDEVICEint)           <= '1';
    eventinputs(MYDEVICEint)(0) <= X"20" & MYDEVICE;
    eventinputs(MYDEVICEint)(1) <= X"0000";
    eventinputs(MYDEVICEint)(2) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(MYDEVICEint)           <= '0';
    wait until rising_edge(recoveredEventDone) and EARX(MYDEVICEint) ='1';
    assert recoveredevent(0) = X"20" & DEVICE
      report "Error reading devincelink" severity Error;
    assert recoveredevent(1) = X"1122"
      report "Error reading devincelink" severity Error;
    assert recoveredevent(2) = X"3344"
      report "Error reading devincelink" severity Error;
    wait until rising_edge(CLK) and ECYCLE = '1';

    ------------------------------------------------------------------------
    -- Now the the raw boot serial
    ------------------------------------------------------------------------
     wait until rising_edge(CLK) and ECYCLE = '1';
     EATX(MYDEVICEint)           <= '1';
     eventinputs(MYDEVICEint)(0) <= X"82" & MYDEVICE;
     eventinputs(MYDEVICEint)(1) <= X"0000";
     eventinputs(MYDEVICEint)(2) <= X"0000";
     wait until rising_edge(CLK) and ECYCLE = '1';
     EATX(MYDEVICEint)           <= '0';
    
    
    wait;

  end process;
end Behavioral;
