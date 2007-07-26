library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity fiberdebugtest is

end fiberdebugtest;

architecture Behavioral of fiberdebugtest is

  component fiberdebug
    generic (
      DEVICE   :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK      : in  std_logic;
      TXCLK    : in  std_logic;
      RESET    : in  std_logic;
      -- Event bus interface
      ECYCLE   : in  std_logic;
      EARXA    : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                  := (others => '0');
      EDRXA    : out std_logic_vector(7 downto 0);
      EARXB    : out std_logic_vector(somabackplane.N - 1 downto 0)
                                                  := (others => '0');
      EDRXB    : out std_logic_vector(7 downto 0);
      EDSELRXA : in  std_logic_vector(3 downto 0);
      EDSELRXB : in  std_logic_vector(3 downto 0);
      EATX     : in  std_logic_vector(somabackplane.N - 1 downto 0);
      EDTX     : in  std_logic_vector(7 downto 0);

      -- Fiber interfaces
      FIBERIN  : in  std_logic;
      FIBEROUT : out std_logic
      );

  end component;


  signal CLK      : std_logic                    := '0';
  signal TXCLK    : std_logic                    := '0';
  signal RESET    : std_logic                    := '1';
  -- Event bus interface
  signal ECYCLE   : std_logic                    := '0';
  signal EARXA    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                 := (others => '0');
  signal EDRXA    : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXB    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                 := (others => '0');
  signal EDRXB    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRXA : std_logic_vector(3 downto 0) := (others => '0');
  signal EDSELRXB : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX     : std_logic_vector(somabackplane.N - 1 downto 0)
                                                 := (others => '0');
  signal EDTX     : std_logic_vector(7 downto 0) := (others => '0');

  -- Fiber interfaces
  signal FIBERIN  : std_logic := '0';
  signal FIBEROUT : std_logic := '0';

  ---------------------------------------------------------------------------
  -- DEBUG
  ---------------------------------------------------------------------------

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal pos : integer range 0 to 999 := 0;

  type debugsettings is (none, noop);

  signal state : debugsettings := none;

  component AcqboardFiberRX
    port ( CLK     : in  std_logic;
           FIBERIN : in  std_logic;
           RESET   : in  std_logic;
           DATA    : out std_logic_vector(31 downto 0) := (others => '0');
           CMD     : out std_logic_vector(3 downto 0);
           NEWCMD  : out std_logic;
           PENDING : in  std_logic;
           CMDID   : out std_logic_vector(3 downto 0);
           CHKSUM  : out std_logic_vector(7 downto 0));
  end component;

  signal acq_CLK : std_logic := '0';

  signal acq_DATA    : std_logic_vector(31 downto 0) := (others => '0');
  signal acq_CMD     : std_logic_vector(3 downto 0)  := (others => '0');
  signal acq_NEWCMD  : std_logic                     := '0';
  signal acq_PENDING : std_logic                     := '0';
  signal acq_CMDID   : std_logic_vector(3 downto 0)  := (others => '0');
  signal acq_CHKSUM  : std_logic_vector(7 downto 0)  := (others => '0');


  component serialize
    generic (filename    :     string    := "input.dat");
    port ( START         : in  std_logic;
           DOUT          : out std_logic;
           DONE          : out std_logic);
  end component;
  signal serialize_START :     std_logic := '0';
  signal serialize_DONE  :     std_logic := '0';


begin  -- Behavioral

  CLK     <= not CLK     after 10 ns;
  TXCLK   <= not TXCLK   after 6.25 ns;
  acq_CLK <= not acq_CLK after 6.94 ns;  -- 72 MHz

  RESET <= '0' after 100 ns;

  fiberdebug_uut : fiberdebug
    generic map (
      DEVICE   => X"01")
    port map (
      CLK      => CLK,
      TXCLK    => TXCLK,
      RESET    => RESET,
      ECYCLE   => ECYCLE,
      EARXA    => EARXA,
      EDRXA    => EDRXA,
      EARXB    => EARXB,
      EDRXB    => EDRXB,
      EDSELRXA => EDSELRXA,
      EDSELRXB => EDSELRXB,
      EATX     => EATX,
      EDTX     => EDTX,
      FIBERIN  => FIBERIN,
      FIBEROUT => FIBEROUT);

  acqboardRX : acqboardFiberRX
    port map (
      CLK     => TXCLK,
      FIBERIN => FIBEROUT,
      RESET   => RESET,
      DATA    => acq_DATA,
      CMD     => acq_CMD,
      NEWCMD  => acq_NEWCMD,
      PENDING => acq_PENDING,
      CMDID   => acq_cmdid,
      CHKSUM  => acq_CHKSUM);

  serialize_inst : serialize
    generic map (
      filename => "serialdata.dat")
    port map (
      START    => serialize_START,
      DOUT     => FIBERIN,
      DONE     => serialize_DONE);


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


  SEND_EVENT : process
    --generate the commands, read the outputs
    --
  begin
    -- first, we send no-op and get the necessary remote lock
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (1      => '1', others => '0');
    eventinputs(1)(0) <= X"8200";
    eventinputs(1)(1) <= X"0000";
    eventinputs(1)(2) <= X"0000";
    eventinputs(1)(3) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');

    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and ECYCLE = '1';

    EATX              <= (1      => '1', others => '0');
    eventinputs(1)(0) <= X"8200";
    eventinputs(1)(1) <= X"0000";
    eventinputs(1)(2) <= X"0000";
    eventinputs(1)(3) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');


    -------------------------------------------------------------------------
    -- write generic word
    -------------------------------------------------------------------------
    -- send the event
    wait until rising_edge(CLK) and ECYCLE = '1';

    eventinputs(1)(0) <= X"8204";
    eventinputs(1)(1) <= X"0102";       -- ID = 1, CMD = 2
    eventinputs(1)(2) <= X"AABB";
    eventinputs(1)(3) <= X"CCDD";
    eventinputs(1)(4) <= X"0000";
    EATX(1)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(acq_CLK) and acq_NEWCMD = '1';
    acq_pending       <= '1';
    assert acq_cmdid = "0001" report "Error setting Acq CMDID" severity error;
    assert acq_cmd = "0010" report "Error setting Acq CMD" severity error;
    assert acq_data = X"aabbccdd"
      report "Error setting acq data" severity error;
    wait for 1 us;
    acq_pending       <= '0';

    wait;
  end process;

  RECEIVE_EVENT_A : process
  begin
    wait until falling_edge(RESET);

    serialize_start <= '1';
    wait for 10 ns;
    serialize_start <= '0';


    -- now, capture events; we should get a cmd event followed by 10 data
    for cmdid in 0 to 9 loop
      wait until rising_edge(ECYCLE);
      wait until rising_edge(CLK);      -- wait an extra tick to check
      wait until rising_edge(CLK) and EARXA(7) = '1';
      edselrxA <= "0000";
      assert EDRXA = X"82" report "Event Port A : Error reading CMDIN packet cmd"
        severity error;

      -- now get cmd id
      wait until rising_edge(CLK);
      EDSELRXA <= "0110";
      assert EDRXA = std_logic_vector(TO_UNSIGNED(cmdid, 8))
        report "Event Port A : Error reading set cmdid" severity error;


      -- now get cmd status
      -- NOT IMPLEMENTED
--         wait until rising_edge(CLK);
--         EDSELRXA <= "101";
--         assert EDRXA = std_logic_vector(TO_UNSIGNED(cmdid, 8))
--           report "Event Port A: Error reading set cmdid" severity Error;

      --------------------------------------------------------------------
      -- NOW GET THE DATA-CONTAINING EVENTS
      --------------------------------------------------------------------

      for j in 0 to 9 loop
        wait until rising_edge(CLK) and ECYCLE = '1';
        wait until rising_edge(CLK) and EARXA(7) = '1';
        -- verify CMDID
        edselrxA <= "0000";
        assert EDRXA = X"80"
          report "Event Port A : Error reading data packet cmd"
          severity error;


      end loop;  -- j


    end loop;  -- cmdid

    wait;
  end process RECEIVE_EVENT_A;

end Behavioral;
