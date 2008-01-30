library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;

entity netcontroltest is

end netcontroltest;

architecture Behavioral of netcontroltest is



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


  signal TXPKTLENEN   : std_logic                     := '0';
  signal TXPKTLEN     : std_logic_vector(15 downto 0) := (others => '0');
  signal TXCHAN       : std_logic_vector(2 downto 0)  := (others => '0');
  -- other counters
  signal RXIOCRCERR   : std_logic                     := '0';
  signal UNKNOWNETHER : std_logic                     := '0';
  signal UNKNOWNIP    : std_logic                     := '0';
  signal UNKNOWNARP   : std_logic                     := '0';
  signal UNKNOWNUDP   : std_logic                     := '0';

  -- output network control settings
  signal MYMAC   : std_logic_vector(47 downto 0);
  signal MYBCAST : std_logic_vector(31 downto 0);
  signal MYIP    : std_logic_vector(31 downto 0);


  signal pos : integer range 0 to 999 := 980;

  signal NICSOUT, NICSIN, NICSCLK, NICSCS : std_logic := '0';


  type settings is (none, noop, noopdone,
                    writemac, writemacdone,
                    writeip, writeipdone,
                    writebcast, writebcastdone,
                    rxiocrccnt, rxiocrccntdone,
                    txiocnt6, txiocnt6done);

  signal state : settings := none;


  constant DEVICE : std_logic_vector(7 downto 0) := X"01";
  constant MYDEVICE : std_logic_vector(7 downto 0) := X"17";


  signal receivedcntid : std_logic_vector(15 downto 0) := (others => '0');
  signal receivedcnt   : std_logic_vector(31 downto 0) := (others => '0');

  signal clkstate : integer   := 0;
  signal mainclk  : std_logic := '0';

  signal serialregin : std_logic_vector(39 downto 0) := (others => '0');
  signal serialbcnt : integer := 0;
  signal outword : std_logic_vector(31 downto 0) := X"1234ABCD";


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


  netcontrol_uut : entity soma.netcontrol
    generic map (
      DEVICE       => DEVICE,
      RAM_INIT_00 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_00,
      RAM_INIT_01 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_01,
      RAM_INIT_02 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_02,
      RAM_INIT_03 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_03,
      RAM_INIT_04 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_04,
      RAM_INIT_05 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_05,
      RAM_INIT_06 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_06,
      RAM_INIT_07 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_07,
      RAM_INIT_08 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_08,
      RAM_INIT_09 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_09,
      RAM_INIT_0A => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0A,
      RAM_INIT_0B => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0B,
      RAM_INIT_0C => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0C,
      RAM_INIT_0D => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0D,
      RAM_INIT_0E => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0E,
      RAM_INIT_0F => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_0F,

      RAM_INIT_10 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_10,
      RAM_INIT_11 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_11,
      RAM_INIT_12 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_12,
      RAM_INIT_13 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_13,
      RAM_INIT_14 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_14,
      RAM_INIT_15 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_15,
      RAM_INIT_16 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_16,
      RAM_INIT_17 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_17,
      RAM_INIT_18 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_18,
      RAM_INIT_19 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_19,
      RAM_INIT_1A => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1A,
      RAM_INIT_1B => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1B,
      RAM_INIT_1C => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1C,
      RAM_INIT_1D => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1D,
      RAM_INIT_1E => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1E,
      RAM_INIT_1F => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_1F,

      RAM_INIT_20 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_20,
      RAM_INIT_21 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_21,
      RAM_INIT_22 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_22,
      RAM_INIT_23 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_23,
      RAM_INIT_24 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_24,
      RAM_INIT_25 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_25,
      RAM_INIT_26 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_26,
      RAM_INIT_27 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_27,
      RAM_INIT_28 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_28,
      RAM_INIT_29 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_29,
      RAM_INIT_2A => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2A,
      RAM_INIT_2B => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2B,
      RAM_INIT_2C => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2C,
      RAM_INIT_2D => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2D,
      RAM_INIT_2E => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2E,
      RAM_INIT_2F => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_2F,

      RAM_INIT_30 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_30,
      RAM_INIT_31 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_31,
      RAM_INIT_32 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_32,
      RAM_INIT_33 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_33,
      RAM_INIT_34 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_34,
      RAM_INIT_35 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_35,
      RAM_INIT_36 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_36,
      RAM_INIT_37 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_37,
      RAM_INIT_38 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_38,
      RAM_INIT_39 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_39,
      RAM_INIT_3A => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3A,
      RAM_INIT_3B => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3B,
      RAM_INIT_3C => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3C,
      RAM_INIT_3D => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3D,
      RAM_INIT_3E => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3E,
      RAM_INIT_3F => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INIT_3F,

      RAM_INITP_00 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_00,
      RAM_INITP_01 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_01,
      RAM_INITP_02 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_02,
      RAM_INITP_03 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_03,
      RAM_INITP_04 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_04,
      RAM_INITP_05 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_05,
      RAM_INITP_06 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_06,
      RAM_INITP_07 => work.netcontroltest_mem_pkg.netcontrol_inst_ram_INITP_07 )
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
      -- tx counter input
      TXPKTLENEN   => TXPKTLENEN,
      TXPKTLEN     => TXPKTLEN,
      TXCHAN       => TXCHAN,
      -- other counters
      RXIOCRCERR   => RXIOCRCERR,
      UNKNOWNETHER => UNKNOWNETHER,
      UNKNOWNIP    => UNKNOWNIP,
      UNKNOWNARP   => UNKNOWNARP,
      UNKNOWNUDP   => UNKNOWNUDP,
      EVTRXSUC => '0',
      EVTFIFOFULL => '0',
      -- settings
      MYMAC        => MYMAC,
      MYBCAST      => MYBCAST,
      MYIP         => MYIP,
      -- NIC interface
      NICSOUT      => NICSOUT,
      NICSIN       => NICSIN,
      NICSCLK      => NICSCLK,
      NICSCS       => NICSCS);

  ecycle_generation : process(CLK)
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


  serialin: process (NICSCLK, NICSCS)
  begin  -- process serialin
    if falling_edge(NICSCS) then
      serialbcnt <= 0;
    else
      if falling_edge(NICSCLK) then
        serialbcnt <= serialbcnt + 1; 
      end if;
    end if;
    if rising_edge(NICSCLK) then
      if NICSCS = '0' then
        serialregin <= serialregin(38 downto 0) & NICSOUT; 
      end if;
      if serialbcnt >= 7  and serialbcnt < 39 then
        NICSIN <= outword(39 - serialbcnt - 1); 
      end if;
    end if;
    
  end process serialin;
  
  
  process
    begin
  -- send test events
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= X"30" & MYDEVICE;
    eventinputs(0)(1) <= X"0000";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"1234";
    eventinputs(0)(4) <= X"5678";
    eventinputs(0)(5) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '0';
    wait until rising_edge(CLK) and ECYCLE = '1';
  -- now verify we got the handle!
    wait;
    
   end process; 
end Behavioral;
