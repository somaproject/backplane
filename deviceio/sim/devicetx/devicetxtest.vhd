library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity devicetxtest is
end devicetxtest;

architecture behavior of devicetxtest is



  component devicetx

    port (
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      DIN       : in  std_logic_vector(7 downto 0);
      DDONE     : in  std_logic;
      DWE       : in  std_logic;
      ECYCLE    : in  std_logic;
      EINA      : in  std_logic_vector(7 downto 0);
      EWEA      : in  std_logic;
      SVALIDA   : out std_logic;
      EINB      : in  std_logic_vector(7 downto 0);
      EWEB      : in  std_logic;
      SVALIDB   : out std_logic;
      TXBYTECLK : in  std_logic;
      DOUT      : out std_logic_vector(7 downto 0);
      KOUT      : out std_logic
      );

  end component;


  signal CLK   : std_logic := '0';
  signal RESET : std_logic := '1';

  signal DIN       : std_logic_vector(7 downto 0) := (others => '0');
  signal DDONE     : std_logic                    := '0';
  signal DWE       : std_logic                    := '0';
  signal ECYCLE    : std_logic                    := '0';
  signal EINA      : std_logic_vector(7 downto 0) := (others => '0');
  signal EWEA      : std_logic                    := '0';
  signal SVALIDA   : std_logic                    := '0';
  signal EINB      : std_logic_vector(7 downto 0) := (others => '0');
  signal EWEB      : std_logic                    := '0';
  signal SVALIDB   : std_logic                    := '0';
  signal TXBYTECLK : std_logic                    := '0';
  signal DOUT      : std_logic_vector(7 downto 0) := (others => '0');

  signal KOUT     : std_logic := '0';
  signal ECYCLEGO : std_logic := '0';



  constant clkperiod       : time := 8 ns;
  constant txbyteclkperiod : time := 40 ns;

  signal received_eventa : std_logic_vector(135 downto 0) := (others => '0');
  signal received_eventb : std_logic_vector(135 downto 0) := (others => '0');

  signal expected_eventa, expected_eventb : std_logic_vector(135 downto 0) := (others => '0');

  constant K28_0 : std_logic_vector(7 downto 0) := "00011100";
  constant K28_1 : std_logic_vector(7 downto 0) := "00111100";
  constant K28_2 : std_logic_vector(7 downto 0) := "01011100";
  constant K28_3 : std_logic_vector(7 downto 0) := "01111100";
  constant K28_4 : std_logic_vector(7 downto 0) := "10011100";
  constant K28_5 : std_logic_vector(7 downto 0) := "10111100";

  signal eventloop : integer := 0;


  signal event_string :
    std_logic_vector(135 downto 0) := X"0123456789ABCDEF0123456789ABCDEF01";

  procedure writeEvent (
    signal indata : in  std_logic_vector(135 downto 0);
    signal CLK    : in  std_logic;
    signal EDOUT  : out std_logic_vector(7 downto 0);
    signal EWE    : out std_logic
    ) is
  begin

    wait until rising_edge(CLK);
    for i in 0 to 16 loop
      EDOUT <= indata((i+1)*8-1 downto (i*8));
      EWE   <= '1';
      wait until rising_edge(CLK);
      wait for 1 ns;
    end loop;  -- i
    EWE     <= '0' after 1 ns;

  end procedure writeEvent;

  procedure writeData (
    constant len         : in integer;
    constant burstlength : in integer;
    constant gaplength   : in integer;

    signal CLK   : in  std_logic;
    signal DIN   : out std_logic_vector(7 downto 0);
    signal DWE   : out std_logic;
    signal DDONE : out std_logic
    ) is

    variable bytepos, burstpos, gappos : integer := 0;
  begin

    wait until rising_edge(CLK);
    while bytepos < len loop
      if burstpos < burstlength then
        DIN <= std_logic_vector(TO_SIGNED(bytepos, 8));
        DWE <= '1';
        wait until rising_edge(CLK);
        burstpos := burstpos + 1;
        bytepos  := bytepos + 1;
      elsif gappos < gaplength then
        DWE <= '0';
        wait until rising_edge(CLK);
        gappos   := gappos + 1;
      else
        gappos   := 0;
        burstpos := 0;
      end if;
    end loop;
    DWE     <= '0';
    wait until rising_edge(CLK);
    DDONE   <= '1';
    wait until rising_edge(CLK);
    DDONE   <= '0';
  end procedure writeData;

  procedure verifyData (
    constant len        : in integer;
    signal   TXBYTECLK  : in std_logic;
    signal   DOUT       : in std_logic_vector(7 downto 0);
    signal   KOUT       : in std_logic) is
    variable datamode   :    boolean := false;
    variable currentpos :    integer := 0;
    variable done       :    boolean := false;

  begin
    while not done loop

      wait until rising_edge(TXBYTECLK);
      if KOUT = '1' and DOUT = K28_2 then
        datamode := true;
      elsif KOUT = '1' and DOUT = K28_3 then
        datamode   := false;
      elsif datamode then
        assert dout = std_logic_vector(TO_UNSIGNED(currentpos, 8))
          report "Error with data reading" severity error;
        currentpos := currentpos + 1;
      elsif KOUT = '1' and DOUT = K28_4 then
        done       := true;
        assert currentpos = len report "Data packet too short"
          severity error;

      end if;

    end loop;

  end procedure verifyData;

begin

  devicetx_uut : devicetx
    port map
    (CLK       => CLK,
     RESET     => RESET,
     DIN       => DIN,
     DWE       => DWE,
     DDONE     => DDONE,
     ECYCLE    => ECYCLE,
     EINA      => EINA,
     EWEA      => EWEA,
     SVALIDA   => SVALIDA,
     EINB      => EINB,
     EWEB      => EWEB,
     SVALIDB   => SVALIDB,
     TXBYTECLK => TXBYTECLK,
     DOUT      => DOUT,
     KOUT      => KOUT);

  CLK       <= not CLK       after clkperiod / 2;
  TXBYTECLK <= not TXBYTECLK after txbyteclkperiod / 2;

  RESET <= '0' after 50 ns;

  -- ecycle timer
  ecycletimer : process
  begin
    while true loop

      wait until falling_edge(RESET);
      wait for 10 ns;
      while RESET = '0' loop
        ECYCLEGO <= '1';
        wait for 1 ns;
        ECYCLEGO <= '0';
        wait for (20 us - 1 ns);

      end loop;
    end loop;

  end process;


  clkecycle : process
  begin
    while true loop
      wait until rising_edge(ECYCLEGO);
      wait until rising_edge(CLK);
      ECYCLE <= '1';
      wait until rising_edge(CLK);
      ECYCLE <= '0';
    end loop;

  end process;

  testwrite : process
  begin
    wait until falling_edge(RESET);

    while eventloop < 4 loop

      -- test writing Event A
      wait until SVALIDA = '1';
      writeEvent(event_string, CLK, EINA, EWEA);
      expected_eventa <= event_string;
      expected_eventb <= (others => '0');
      wait until falling_edge(ECYCLE);

      -- test writing Event B
      wait until rising_edge(CLK) and SVALIDB = '1';

      event_string    <= event_string(0) & event_string(135 downto 1);
      writeEvent(event_string, CLK, EINB, EWEB);
      expected_eventa <= (others => '0');
      expected_eventb <= event_string;
      wait until falling_edge(ECYCLE);


      -- test writing both Event A and Event B

      wait until rising_edge(CLK) and SVALIDA = '1';

      event_string <= event_string(0) & event_string(135 downto 1);

      writeEvent(event_string, CLK, EINA, EWEA);
      expected_eventa <= event_string;

      wait until rising_edge(CLK) and SVALIDB = '1';

      event_string <= event_string(0) & event_string(135 downto 1);

      writeEvent(event_string, CLK, EINB, EWEB);
      expected_eventb <= event_string;

      wait until falling_edge(ECYCLE);

      -- test writing both Event B and Event A

      wait until rising_edge(CLK) and SVALIDB = '1';

      event_string <= event_string(0) & event_string(135 downto 1);

      writeEvent(event_string, CLK, EINB, EWEB);
      expected_eventb <= event_string;


      wait until rising_edge(CLK) and SVALIDA = '1';

      event_string <= event_string(0) & event_string(135 downto 1);

      writeEvent(event_string, CLK, EINA, EWEA);
      expected_eventa <= event_string;


      wait until falling_edge(ECYCLE);


      for i in 300 to 430 loop

        for j in 0 to i loop
          wait until rising_edge(TXBYTECLK);

        end loop;  -- j
        -- test writing both Event A and Event B
        expected_eventa <= (others => '0');

        expected_eventb <= (others => '0');

        wait until rising_edge(CLK) and SVALIDA = '1';

        event_string <= event_string(0) & event_string(135 downto 1);

        writeEvent(event_string, CLK, EINA, EWEA);
        expected_eventa <= event_string;

        wait until rising_edge(CLK) and SVALIDB = '1';

        event_string <= event_string(0) & event_string(135 downto 1);

        writeEvent(event_string, CLK, EINB, EWEB);
        expected_eventb <= event_string;

        wait until falling_edge(ECYCLE);

      end loop;  -- i

      -- end tests
      wait until rising_edge(CLK) and SVALIDA = '1';
      expected_eventa <= (others => '0');
      expected_eventb <= (others => '0');
      eventloop       <= eventloop + 1;
    end loop;



  end process;



  eventAreceiver     : process(TXBYTECLK)
    variable bytecnt : integer := 18;

  begin
    if rising_edge(TXBYTECLK) then
      if KOUT = '1' and DOUT = K28_0 then
        bytecnt := -1;
      else
        bytecnt := bytecnt + 1;
      end if;

      if KOUT = '1' and DOUT = K28_5 then
        received_eventa                                   <= (others => '0');
      elsif bytecnt < 17 and bytecnt > -1 then
        received_eventa((bytecnt+1)*8-1 downto bytecnt*8) <= dout;
      end if;

    end if;
  end process eventAreceiver;

  eventBreceiver     : process(TXBYTECLK)
    variable bytecnt : integer := 18;

  begin
    if rising_edge(TXBYTECLK) then
      if KOUT = '1' and DOUT = K28_1 then
        bytecnt := -1;
      else
        bytecnt := bytecnt + 1;
      end if;

      if KOUT = '1' and DOUT = K28_5 then
        received_eventb                                   <= (others => '0');
      elsif bytecnt < 17 and bytecnt > -1 then
        received_eventb((bytecnt+1)*8-1 downto bytecnt*8) <= dout;
      end if;

    end if;
  end process eventBreceiver;

  eventverify                     : process(TXBYTECLK, ECYCLE)
    variable eventA_write_occured : boolean := false;
    variable eventB_write_occured : boolean := false;
  begin

    if rising_edge(ECYCLE) then
      if eventA_write_occured then
        assert expected_eventa = received_eventa
          report "Error receiving event A" severity error;

      end if;
      if eventB_write_occured then
        assert expected_eventb = received_eventb
          report "Error receiving event B" severity error;

      end if;
      eventA_write_occured := false;
      eventB_write_occured := false;

    elsif rising_edge(TXBYTECLK) then
      if KOUT = '1' and DOUT = K28_0 then
        eventA_write_occured := true;
      end if;
      if KOUT = '1' and DOUT = K28_1 then
        eventB_write_occured := true;
      end if;

    end if;

  end process eventverify;



  datasend : process
  begin  -- process datasend
    wait until eventloop > 0;
    for i in 1 to 1023 loop

      writeData(i, 20, 4, CLK, DIN, DWE, DDONE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);
      wait until rising_edge(ECYCLE);

    end loop;  -- i

  end process datasend;

  dataverify : process
  begin

    wait until eventloop > 0;
    for i in 1 to 1023 loop

      verifyData(i, TXBYTECLK, DOUT, KOUT);

    end loop;  -- i

  end process dataverify;

end;
