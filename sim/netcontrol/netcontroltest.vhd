library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity netcontroltest is

end netcontroltest;

architecture Behavioral of netcontroltest is

  component netcontrol
    generic (
      DEVICE       :     std_logic_vector(7 downto 0) := X"01";
      CMDCNTQUERY  :     std_logic_vector(7 downto 0) := X"40";
      CMDCNTRST    :     std_logic_vector(7 downto 0) := X"41";
      CMDNETWRITE  :     std_logic_vector(7 downto 0) := X"42";
      CMDNETQUERY  :     std_logic_vector(7 downto 0) := X"43";
      CMDNETRESP   :     std_logic_vector(7 downto 0) := X"50";
      CMDCNTRESP   :     std_logic_vector(7 downto 0) := X"51"
      );
    port (
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      -- standard event-bus interface
      ECYCLE       : in  std_logic;
      EARX         : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX         : out std_logic_vector(7 downto 0);
      EDSELRX      : in  std_logic_vector(3 downto 0);
      EDTX         : in  std_logic_vector(7 downto 0);
      EATX         : in  std_logic_vector(somabackplane.N - 1 downto 0);
      -- tx counter inputdtx
      TXPKTLENEN   : in  std_logic;
      TXPKTLEN     : in  std_logic_vector(15 downto 0);
      TXCHAN       : in  std_logic_vector(2 downto 0);
      -- other counters
      RXIOCRCERR   : in  std_logic;
      UNKNOWNETHER : in  std_logic;
      UNKNOWNIP    : in  std_logic;
      UNKNOWNARP   : in  std_logic;
      UNKNOWNUDP   : in  std_logic;
      -- output network control settings
      MYMAC        : out std_logic_vector(47 downto 0);
      MYBCAST      : out std_logic_vector(31 downto 0);
      MYIP         : out std_logic_vector(31 downto 0)

      );

  end component;

  signal CLK    : std_logic := '0';
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


  type settings is (none, noop, noopdone,
                    writemac, writemacdone,
                    writeip, writeipdone,
                    writebcast, writebcastdone,
                    rxiocrccnt, rxiocrccntdone,
                    txiocnt6, txiocnt6done);

  signal state : settings := none;


  constant DEVICE      : std_logic_vector(7 downto 0) := X"01";
  constant CMDCNTQUERY : std_logic_vector(7 downto 0) := X"40";
  constant CMDCNTRST   : std_logic_vector(7 downto 0) := X"41";
  constant CMDNETWRITE : std_logic_vector(7 downto 0) := X"42";
  constant CMDNETQUERY : std_logic_vector(7 downto 0) := X"43";
  constant CMDNETRESP  : std_logic_vector(7 downto 0) := X"50";
  constant CMDCNTRESP  : std_logic_vector(7 downto 0) := X"51";

  signal receivedcntid : std_logic_vector(15 downto 0) := (others => '0');
  signal receivedcnt   : std_logic_vector(31 downto 0) := (others => '0');

begin  -- Behavioral

  CLK   <= not clk after 10 ns;
  RESET <= '0'     after 100 ns;

  netcontrol_uut : netcontrol
    generic map (
      DEVICE      => DEVICE,
      CMDCNTQUERY => CMDCNTQUERY,
      CMDCNTRST   => CMDCNTRST,
      CMDNETWRITE => CMDNETWRITE,
      CMDNETQUERY => CMDNETQUERY,
      CMDNETRESP  => CMDNETRESP,
      CMDCNTRESP  => CMDCNTRESP )
    port map (
      CLK         => CLK,
      RESET       => RESET,
      ECYCLE      => ECYCLE,
      EARx        => EARX,
      EDRX        => EDRX,
      EDSELRX     => EDSELRX,
      EDTX        => EDTX,
      EATX        => EATX,
      TXPKTLENEN  => TXPKTLENEN,
      TXPKTLEN    => TXPKTLEN,
      TXCHAN      => TXCHAN,
      RXIOCRCERR  => RXIOCRCERR,
      UNKNOWNETHER => UNKNOWNETHER,
      UNKNOWNIP => UNKNOWNIP,
      UNKNOWNARP => UNKNOWNARP,
      UNKNOWNUDP => UNKNOWNUDP,
      MYMAC       => MYMAC,
      MYBCAST     => MYBCAST,
      MYIP        => MYIP);


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



  main : process
    --generate the commands, read the outputs
    --
  begin
    -- first, we send no-op and make sure we have no reaction
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= noop;

    eventinputs(0)(0) <= (others => '1');
    EATX              <= (others => '1');
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;


    -- now, verify they don't do anything

    wait until rising_edge(CLK) and ECYCLE = '1';
    assert EARX'stable(20 us) report "EARX registered an event" severity
      error;
    state <= noopdone;

    -------------------------------------------------------------------------
    -- write MAC
    -------------------------------------------------------------------------
    -- send the event
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= writemac;
    eventinputs(4)(0) <= CMDNETWRITE & X"04";
    eventinputs(4)(1) <= X"0003";
    eventinputs(4)(2) <= X"ABCD";
    eventinputs(4)(3) <= X"EF89";
    eventinputs(4)(4) <= X"1234";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';


    -- now try and acquire the event
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
      wait until rising_edge(CLK);


    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = CMDNETRESP
      report "1 : error receiving net response" severity error;

    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"03"
      report "1 : error receiving mac addr response" severity error;

    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"AB"
      report "1 : error receiving mac byte 0 response" severity error;

    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"CD"
      report "1 : error receiving mac byte 1 response" severity error;

    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"EF"
      report "1 : error receiving mac byte 2 response" severity error;



    assert MYMAC = X"ABCDEF891234" report
      "Error setting MYMAC output value" severity error;

    state <= writemacdone;

    -------------------------------------------------------------------------
    -- write IP
    -------------------------------------------------------------------------
    -- send the event
    --wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= writeip;
    eventinputs(4)(0) <= CMDNETWRITE & X"04";
    eventinputs(4)(1) <= X"0001";
    eventinputs(4)(2) <= X"AABB";
    eventinputs(4)(3) <= X"CCDD";
    eventinputs(4)(4) <= X"0000";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    -- now try and acquire the event
    wait until rising_edge(CLK);
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
      wait until rising_edge(CLK);


    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = CMDNETRESP
      report "2 : error receiving net response" severity error;

    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "2 : error receiving ip addr response" severity error;

    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"AA"
      report "2 : error receiving ip byte 0 response" severity error;

    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"BB"
      report "2 : error receiving io byte 1 response" severity error;

    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"CC"
      report "1 : error receiving io byte 2 response" severity error;




    assert MYIP = X"AABBCCDD" report "Error setting MYIP output value" severity error;

    state <= writeipdone;


    -------------------------------------------------------------------------
    -- write BCAST IP
    -------------------------------------------------------------------------
    -- send the event
    --wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= writebcast;
    eventinputs(4)(0) <= CMDNETWRITE & X"04";
    eventinputs(4)(1) <= X"0002";
    eventinputs(4)(2) <= X"1122";
    eventinputs(4)(3) <= X"3456";
    eventinputs(4)(4) <= X"0000";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    -- now try and acquire the event
    wait until rising_edge(CLK);
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
      wait until rising_edge(CLK);


    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = CMDNETRESP
      report "3 : error receiving net response" severity error;

    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"02"
      report "3 : error receiving ip bcast addr response" severity error;

    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"11"
      report "3 : error receiving ip bcast byte 0 response" severity error;

    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"22"
      report "3 : error receiving io bcast byte 1 response" severity error;

    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"34"
      report "3 : error receiving io bcast byte 2 response" severity error;


    assert MYBCAST = X"11223456"
      report "Error setting MYBCAST output value" severity error;

    state <= writebcastdone;

    ---------------------------------------------------------------------------
    -- counter writing and reading
    ---------------------------------------------------------------------------
    for j in 0 to 19 loop
      for i in 0 to 7 loop
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        txchan     <= std_logic_vector(TO_UNSIGNED(i, 3));
        wait until rising_edge(CLK);
        txpktlen   <= std_logic_vector(to_unsigned(i, 8)) & X"17";
        wait until rising_edge(CLK);
        txpktlenen <= '1';
        wait until rising_edge(CLK);
        txpktlenen <= '0';
        wait until rising_edge(CLK);
      end loop;  -- i
    end loop;  -- j

    -- two rx fifo errors
    wait until rising_edge(CLK);
    RXIOCRCERR <= '1';
    wait until rising_edge(CLK);
    RXIOCRCERR <= '0';
    wait until rising_edge(CLK);
    RXIOCRCERR <= '1';
    wait until rising_edge(CLK);
    RXIOCRCERR <= '0';
    wait until rising_edge(CLK);
    RXIOCRCERR <= '1';
    wait until rising_edge(CLK);
    RXIOCRCERR <= '0';

    -- now, we explicitly query two of the counters

    -------------------------------------------------------------------------
    -- query RXIOCRCERRCNT 
    -------------------------------------------------------------------------
    -- send the event
    --wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= rxiocrccnt;
    eventinputs(4)(0) <= CMDCNTQUERY& X"04";
    eventinputs(4)(1) <= X"0001";
    eventinputs(4)(2) <= X"0000";
    eventinputs(4)(3) <= X"0000";
    eventinputs(4)(4) <= X"0000";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    -- now try and acquire the event
    wait until rising_edge(CLK);
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
      wait until rising_edge(CLK);
    end loop;

    wait for 1 ns;
    EDSELRX <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "4 : invalid received command" severity error;

    wait for 1 ns;
    EDSELRX <= "1001";
    wait until rising_edge(CLK);
    assert EDRX = X"03"
      report "4 : invalid value in rxiocrcerr count" severity error;
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    state   <= rxiocrccntdone;


    -------------------------------------------------------------------------
    -- query TXERRCNT 6
    -------------------------------------------------------------------------
    -- send the event
    --wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= txiocnt6;

    eventinputs(4)(0) <= CMDCNTQUERY & X"04";
    eventinputs(4)(1) <= X"001C";
    eventinputs(4)(2) <= X"0000";
    eventinputs(4)(3) <= X"0000";
    eventinputs(4)(4) <= X"0000";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    -- now try and acquire the event
    wait until rising_edge(CLK);
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
      wait until rising_edge(CLK);
    end loop;

    wait for 1 ns;
    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"1C"
      report "4 : invalid received command" severity error;

    wait for 1 ns;
    EDSELRX <= "1000";                  -- 8 
    wait until rising_edge(CLK);
    assert EDRX = X"79"
      report "4 : invalid value in txiolen 06" severity error;
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);

    wait for 1 ns;
    EDSELRX <= "1001";                  -- 9 
    wait until rising_edge(CLK);
    assert EDRX = X"CC"
      report "4 : invalid value in txiolen 06" severity error;
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    state   <= txiocnt6done;



    -------------------------------------------------------------------------
    -- broadcast values
    -------------------------------------------------------------------------

    for i in 0 to 2 loop

      wait until rising_edge(CLK) and ECYCLE = '1';

      wait until rising_edge(CLK);
      while EARX(4) /= '1' loop
        wait until rising_edge(CLK) and ECYCLE = '1';
        EATX <= eazeros;
        wait until rising_edge(CLK);
      end loop;

      wait for 3 ns;
      EDSELRX <= "0000";
      wait until rising_edge(CLK);
      assert EDRX = CMDCNTRESP
        report "5 : error receiving net response" severity error;

      wait for 1 ns;
      EDSELRX                    <= "0010";
      wait until rising_edge(CLK);
      receivedcntid(15 downto 8) <= EDRX;

      wait for 1 ns;
      EDSELRX                   <= "0011";
      wait until rising_edge(CLK);
      receivedcntid(7 downto 0) <= EDRX;

      -- read the first 32 bits of the count
      wait for 1 ns;
      EDSELRX                   <= "0110";
      wait until rising_edge(CLK);
      receivedcnt(31 downto 24) <= EDRX;
      EDSELRX                   <= "0111";
      wait until rising_edge(CLK);
      receivedcnt(23 downto 16) <= EDRX;
      EDSELRX                   <= "1000";
      wait until rising_edge(CLK);
      receivedcnt(15 downto 8)  <= EDRX;
      EDSELRX                   <= "1001";
      wait until rising_edge(CLK);
      receivedcnt(7 downto 0)   <= EDRX;

      if receivedcntid = X"0000" then
        assert receivedcnt = X"456789AB"
          report "Error reading counter 0" severity error;
      elsif receivedcntid = X"0001" then
        assert receivedcnt = X"000079cc"
          report "Error reading counter 1" severity error;
      elsif receivedcntid = X"0002" then
        assert receivedcnt = X"00000000"
          report "Error reading counter 2" severity error;
      end if;

    end loop;  -- i


    assert false report "End of Simulation" severity failure;


  end process main;

end Behavioral;
