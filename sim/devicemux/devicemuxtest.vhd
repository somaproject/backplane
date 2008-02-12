library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;

entity devicemuxtest is

end devicemuxtest;


architecture Behavioral of devicemuxtest is

  component devicemux
    port (
      CLK      : in  std_logic;
      ECYCLE   : in  std_logic;
      -- port A
      DOUTA    : out std_logic_vector(7 downto 0);
      DOENA    : out std_logic;
      DGRANTA  : in  std_logic;
      EARXA    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXA    : out std_logic_vector(7 downto 0);
      EDSELRXA : in  std_logic_vector(3 downto 0);
      EATXA    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXA    : in  std_logic_vector(7 downto 0);
      -- port B
      DOUTB    : out std_logic_vector(7 downto 0);
      DOENB    : out std_logic;
      DGRANTB  : in  std_logic;
      EARXB    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXB    : out std_logic_vector(7 downto 0);
      EDSELRXB : in  std_logic_vector(3 downto 0);
      EATXB    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXB    : in  std_logic_vector(7 downto 0);
      -- port C
      DOUTC    : out std_logic_vector(7 downto 0);
      DOENC    : out std_logic;
      DGRANTC  : in  std_logic;
      EARXC    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXC    : out std_logic_vector(7 downto 0);
      EDSELRXC : in  std_logic_vector(3 downto 0);
      EATXC    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXC    : in  std_logic_vector(7 downto 0);
      -- port D
      DOUTD    : out std_logic_vector(7 downto 0);
      DOEND    : out std_logic;
      DGRANTD  : in  std_logic;
      EARXD    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXD    : out std_logic_vector(7 downto 0);
      EDSELRXD : in  std_logic_vector(3 downto 0);
      EATXD    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXD    : in  std_logic_vector(7 downto 0);
      -- IO 
      TXDOUT   : out std_logic_vector(7 downto 0);
      TXKOUT   : out std_logic;
      RXDIN    : in  std_logic_vector(7 downto 0);
      RXKIN    : in  std_logic;
      LOCKED   : in  std_logic );
  end component;

  signal CLK    : std_logic := '0';
  signal ECYCLE : std_logic := '0';

  -- port A
  signal DOUTA   : std_logic_vector(7 downto 0) := (others => '0');
  signal DOENA   : std_logic                    := '0';
  signal DGRANTA : std_logic                    := '0';

  signal EARXA    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXA    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXA : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXA    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXA    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port B
  signal DOUTB   : std_logic_vector(7 downto 0) := (others => '0');
  signal DOENB   : std_logic                    := '0';
  signal DGRANTB : std_logic                    := '0';

  signal EARXB    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXB    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXB : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXB    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXB    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port C
  signal DOUTC   : std_logic_vector(7 downto 0) := (others => '0');
  signal DOENC   : std_logic                    := '0';
  signal DGRANTC : std_logic                    := '0';

  signal EARXC    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXC    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXC : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXC    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXC    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port D
  signal DOUTD   : std_logic_vector(7 downto 0) := (others => '0');
  signal DOEND   : std_logic                    := '0';
  signal DGRANTD : std_logic                    := '0';

  signal EARXD    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXD    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXD : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXD    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXD    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- IO 
  signal TXDOUT : std_logic_vector(7 downto 0) := (others => '0');
  signal TXKOUT : std_logic                    := '0';
  signal RXDIN  : std_logic_vector(7 downto 0) := (others => '0');
  signal RXKIN  : std_logic                    := '0';
  signal LOCKED : std_logic                    := '1';


  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- DEBUG
  ---------------------------------------------------------------------------

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal pos : integer range 0 to 999 := 0;

  constant K28_0 : std_logic_vector(7 downto 0) := X"1C";
  constant K28_1 : std_logic_vector(7 downto 0) := X"3C";
  constant K28_2 : std_logic_vector(7 downto 0) := X"5C";
  constant K28_3 : std_logic_vector(7 downto 0) := X"7C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"DC";



begin  -- Behavioral

  CLK <= not CLK after 10 ns;


  devicemux_uut : devicemux
    port map (
      clk      => CLK,
      ECYCLE   => ECYCLE,
      -- port A
      DOUTA    => DOUTA,
      DOENA    => DOENA,
      DGRANTA  => DGRANTA,
      EARXA    => EARXA,
      EDRXA    => EDRXA,
      EDSELRXA => EDSELRXA,
      EATXA    => EATXA(somabackplane.N -1 downto 0),
      EDTXA    => EDTXA,
      -- port B
      DOUTB    => DOUTB,
      DOENB    => DOENB,
      DGRANTB  => DGRANTB,
      EARXB    => EARXB,
      EDRXB    => EDRXB,
      EDSELRXB => EDSELRXB,
      EATXB    => EATXB(somabackplane.N -1 downto 0),
      EDTXB    => EDTXB,
      -- port C
      DOUTC    => DOUTC,
      DOENC    => DOENC,
      DGRANTC  => DGRANTC,
      EARXC    => EARXC,
      EDRXC    => EDRXC,
      EDSELRXC => EDSELRXC,
      EATXC    => EATXC(somabackplane.N -1 downto 0),
      EDTXC    => EDTXC,
      -- port D
      DOUTD    => DOUTD,
      DOEND    => DOEND,
      DGRANTD  => DGRANTD,
      EARXD    => EARXD,
      EDRXD    => EDRXD,
      EDSELRXD => EDSELRXD,
      EATXD    => EATXD(somabackplane.N -1 downto 0),
      EDTXD    => EDTXD,
      -- IO
      TXDOUT   => TXDOUT,
      TXKOUT   => TXKOUT,
      RXDIN    => RXDIN,
      RXKIN    => RXKIN,
      LOCKED   => LOCKED);


  EDTXA <= EDTX;
  EDTXB <= EDTX;
  EDTXC <= EDTX;
  EDTXD <= EDTX;

  EDSELRXA <= EDSELRX;
  EDSELRXB <= EDSELRX;
  EDSELRXC <= EDSELRX;
  EDSELRXD <= EDSELRX;


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

  txgenerate : process
  begin
    EATXA(79 downto 0) <= X"19181716151413121110";
    EATXB(79 downto 0) <= X"29282726252423222120";
    EATXC(79 downto 0) <= X"39383736353433323130";
    EATXD(79 downto 0) <= X"39484746454443424140";  -- note that the top two
                                                    -- bits must be 0
    eventinputs(0)(0)  <= X"0123";
    eventinputs(0)(1)  <= X"4567";
    eventinputs(0)(2)  <= X"89AB";
    eventinputs(0)(3)  <= X"CDEF";
    eventinputs(0)(4)  <= X"1122";
    eventinputs(0)(5)  <= X"3344";
    DGRANTA            <= '1';
    DGRANTC            <= '1';

    wait;

  end process txgenerate;


  txverify                  : process
    variable eaddr_current  : std_logic_vector(79 downto 0) := (others => '0');
    variable dgrant_current : std_logic                     := '0';

  begin
    wait until rising_edge(CLK) and TXDOUT = X"BC" and TXKOUT = '1';
    -- now the outputs
    for i in 0 to 3 loop
      -- load the relevant data
      case i is
        when 0 =>
          eaddr_current  := EATXA;
          dgrant_current := DGRANTA;

        when 1 =>
          eaddr_current  := EATXB;
          dgrant_current := DGRANTB;

        when 2 =>
          eaddr_current  := EATXC;
          dgrant_current := DGRANTC;

        when 3 =>
          eaddr_current  := EATXD;
          dgrant_current := DGRANTD;

        when others => null;
      end case;

      -- DGRANT status
      wait until rising_edge(CLK);
      assert TXDOUT(0) = dgrant_current report "Error on DGRANT " & integer'image(i) severity error;

      for ei in 0 to 9 loop
        wait until rising_edge(CLK);
        assert TXDOUT = eaddr_current(ei*8+7 downto ei*8)
          report "Error on eaddr for src" & integer'image(i) &
          " at eaddr pos " & integer'image(ei) severity error;
      end loop;  -- ei
    end loop;  -- i
    -- burn off extra ticks
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);

    for ea in 0 to 77 loop
      for eb in 0 to 5 loop
        wait until rising_edge(CLK);
        assert eventinputs(ea)(eb)(15 downto 8) = TXDOUT
          report "Error in txdout for event " & integer'image(ea) &
          " word " & integer'image(eb) & " high byte" severity error;

        wait until rising_edge(CLK);
        assert eventinputs(ea)(eb)(7 downto 0) = TXDOUT
          report "Error in txdout for event " & integer'image(ea) &
          " word " & integer'image(eb) & " low byte" severity error;

      end loop;  -- eb
    end loop;  -- ea



    wait;


  end process;

  rxtest : process
  begin
    wait until rising_edge(CLK) and ECYCLE = '1';
    -- now we send four events, one on each channel
    for dataset in 0 to 3 loop
      -- first send header word

      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      if dataset = 0 then
        RXDIN <= K28_0;
      elsif dataset = 1 then
        RXDIN <= K28_1;
      elsif dataset = 2 then
        RXDIN <= K28_2;
      elsif dataset = 3 then
        RXDIN <= K28_3;
      end if;

      RXKIN   <= '1';
      wait until rising_edge(CLK);
      RXKIN   <= '0';
      -- addresses
      for addr in 0 to 9 loop
        RXDIN <= std_logic_vector(TO_UNSIGNED((dataset*4 + addr), 8));
        wait until rising_edge(CLK);
      end loop;  -- addr

      -- data
      for data in 0 to 11 loop
        RXDIN <= std_logic_vector(TO_UNSIGNED((128 + dataset*4 + data), 8));
        wait until rising_edge(CLK);
      end loop;

    end loop;  -- dataset

    wait until rising_edge(CLK) and ECYCLE = '1';

    -- now try and readout
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    assert EARXA = X"09080706050403020100" report "Error reading EARXA"
      severity error;
    wait until rising_edge(CLK);
    for i in 0 to 11 loop
      EDSELRX <= std_logic_vector(TO_UNSIGNED(i, 4));
      wait until rising_edge(CLK);
      assert EDRXA = std_logic_vector(TO_UNSIGNED(128 + i, 8) )
        report "reading EDRXA" severity error;
      assert EDRXB = std_logic_vector(TO_UNSIGNED(128 + 4 + i, 8) )
        report "reading EDRXB" severity error;
      assert EDRXC = std_logic_vector(TO_UNSIGNED(128 + 8 + i, 8) )
        report "reading EDRXC" severity error;
      assert EDRXD = std_logic_vector(TO_UNSIGNED(128 + 12 + i, 8) )
        report "reading EDRXD" severity error;
    end loop;  -- i



    wait until rising_edge(CLK) and ECYCLE = '1';

    -- now try and readout
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    assert EARXA = X"00000000000000000000" report "Error reading EARXA"
      severity error;


    wait;
  end process rxtest;
end Behavioral;
