library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;


entity bootstore is
  generic (
    DEVICE  :     std_logic_vector(7 downto 0)                   := X"01"
    );
  port (
    CLK     : in  std_logic;
    CLKHI   : in  std_logic;
    RESET   : in  std_logic;
    -- event interface
    EDTX    : in  std_logic_vector(7 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);

    -- SPI INTERFACE
    SPIMOSI : in  std_logic;
    SPIMISO : out std_logic;
    SPICS   : in  std_logic;
    SPICLK  : in  std_logic
    );
end bootstore;

architecture Behavioral of bootstore is

  component bootspiio
    port (
      CLK     : in  std_logic;
      CURBYTE : out std_logic_vector(10 downto 0);
      DOUT    : out std_logic_vector(15 downto 0);
      DIN     : in  std_logic_vector(15 downto 0);
      ADDR    : in  std_logic_vector(9 downto 0);
      WE      : in  std_logic;
      CMDDONE : out std_logic;
      CMDREQ  : in  std_logic;
      -- SPI INTERFACE
      CLKHI   : in  std_logic;
      SPIMOSI : in  std_logic;
      SPIMISO : out std_logic;
      SPICS   : in  std_logic;
      SPICLK  : in  std_logic);
  end component;

  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;

  component singleeventdesttx
    port (
      CLK     : in  std_logic;
      EAIN    : in  std_logic_vector(2 downto 0);
      EDIN    : in  std_logic_vector(15 downto 0);
      EWE     : in  std_logic;
      EDEST   : in  std_logic_vector(6 downto 0);
      ESEND   : in  std_logic;
      PENDING : out std_logic;
      ECYCLE  : in  std_logic;
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EARX    : out std_logic_vector(somabackplane.N-1 downto 0));
  end component;


  -- event input signals
  signal enext  : std_logic                     := '0';
  signal eouta  : std_logic_vector(2 downto 0)  := (others => '0');
  signal evalid : std_logic                     := '0';
  signal eoutd  : std_logic_vector(15 downto 0) := (others => '0');

  -- event transmission
  signal setxain     : std_logic_vector(2 downto 0)  := (others => '0');
  signal setxdin     : std_logic_vector(15 downto 0) := (others => '0');
  signal setxwe      : std_logic                     := '0';
  signal setxsend    : std_logic                     := '0';
  signal setxsel     : integer range 0 to 4          := 0;
  signal setxpending : std_logic                     := '0';


  -- source/cmd recovery
  signal src, cursrc, pendsrc : std_logic_vector(7 downto 0) := (others => '0');
  signal ssel                 : integer range 0 to 1         := 0;
  signal curcmd               : std_logic_vector(7 downto 0) := (others => '0');

  -- pending
  signal pendsrcen : std_logic := '0';
  signal penden    : std_logic := '0';

  signal pending : std_logic_vector(1 downto 0) := (others => '0');
  signal pendset : std_logic_vector(1 downto 0) := (others => '0');

  -- handle
  signal handle     : std_logic_vector(7 downto 0) := (others => '0');
  signal handleheld : std_logic                    := '0';


  -- tx settings
  signal txcmd : std_logic_vector(7 downto 0) := (others => '0');

  -- packet counting
  signal pktcnt     : std_logic_vector(15 downto 0) := (others => '0');
  signal pendpktcnt : std_logic_vector(15 downto 0) := (others => '0');


  -- boot spi interface
  signal offset : std_logic_vector(7 downto 0)  := (others => '0');
  signal dconst : std_logic_vector(15 downto 0) := (others => '0');
  signal aconst : std_logic_vector(9 downto 0)  := (others => '0');

  signal spicnt : std_logic_vector(9 downto 0) := (others => '0');

  signal spidsel : integer range 0 to 1 := 0;
  signal spiasel : integer range 0 to 2 := 0;

  signal incspicnt : std_logic := '0';

  signal spidout, spidin : std_logic_vector(15 downto 0) := (others => '0');
  signal spiwe           : std_logic                     := '0';
  signal spiaddr         : std_logic_vector(9 downto 0 ) := (others => '0');


  signal cmdreq, cmddone : std_logic := '0';

  -- state machine
  type states is (none, rdevt, chkcmd, nextevt,
                  chkpnd, chkhand, handerr, penderr,
                  txwait,
                  sendacq, shandsuc, shandval, shandne,
                  fnlos, fname01, fname23, fname45, fname67,
                  fopens, fopencmd,
                  fopenrsp1, forspstat, forsplen1, forsplen2, forsnd,
                  freadcmd, fread0, fread1, fread2, fread3, fsend,
                  freadresp, frblockn, frw1, frw2, frw3, frw4,
                  frdone, frespwait,
                  etxsend,
                  hyields);

  signal cs, ns : states := none;


  -- EVENT CONSTANTS
  constant GETHAND   : std_logic_vector(7 downto 0) := X"90";
  constant SETFNAME  : std_logic_vector(7 downto 0) := X"91";
  constant FOPEN     : std_logic_vector(7 downto 0) := X"92";
  constant FREAD     : std_logic_vector(7 downto 0) := X"93";
  constant YIELDHAND : std_logic_vector(7 downto 0) := X"94";


  -- SPI CONSTANTS
  constant SPIFOCMD : std_logic_vector(15 downto 0) := X"0001";
  constant SPIFRCMD : std_logic_vector(15 downto 0) := X"0002";



begin  -- Behavioral

  rxeventfifo_inst : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      EOUTD  => eoutd,
      EOUTA  => eouta,
      EVALID => evalid,
      ENEXT  => enext);

  bootspiio_inst : bootspiio
    port map (
      CLK     => CLK,
      CURBYTE => open,
      DOUT    => spidout,
      DIN     => spidin,
      ADDR    => spiaddr,
      WE      => spiwe,
      CMDDONE => cmddone,
      CMDREQ  => cmdreq,
      CLKHI   => CLKHI,
      SPIMOSI => SPIMOSI,
      SPIMISO => SPIMISO,
      SPICLK  => SPICLK,
      SPICS   => SPICS);

  singleeventdesttx_inst : singleeventdesttx
    port map (
      CLK     => CLK,
      EAIN    => setxain,
      EDIN    => setxdin,
      EWE     => setxwe,
      EDEST   => src(6 downto 0),
      ESEND   => setxsend,
      PENDING => setxpending,
      ECYCLE  => ECYCLE,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EARX    => EARX);

  -- primary mutexes
  setxdin <= txcmd & DEVICE                         when setxsel = 0 else
             X"00" & handle                         when setxsel = 1 else
             pktcnt                                 when setxsel = 2 else
             "0000000000000" & handleheld & pending when setxsel = 3 else
             spidout;


  spidin <= dconst when spidsel = 0 else
            eoutd;

  spiaddr <= (offset + aconst) when spiasel = 0 else
             aconst            when spiasel = 1 else
             spicnt;

  src <= cursrc when ssel = 0 else pendsrc;


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = rdevt then
        curcmd <= eoutd(15 downto 8);
        cursrc <= eoutd(7 downto 0);
      end if;

      if pendsrcen = '1' then
        pendsrc <= cursrc;
      end if;

      if cs = fopencmd then
        pending <= "01";
      elsif cs = forsnd or cs = frdone then
        pending <= "00";
      elsif cs = fsend then
        pending <= "10";
      end if;

      if cs = fread3 then
        pendpktcnt(12 downto 0)  <= eoutd(15 downto 3);
      elsif cs = fread2 then
        pendpktcnt(15 downto 13) <= eoutd(2 downto 0);
      end if;

      if cs = fsend then
        pktcnt   <= (others => '0');
      else
        if cs = frw4 then
          pktcnt <= pktcnt + 1;
        end if;
      end if;

      if cs = fnlos then
        offset <= eoutd(8 downto 1);
      end if;

      if cs = fsend then
        spicnt   <= "0000000110";
      else
        if incspicnt = '1' then
          spicnt <= spicnt + 1;
        end if;
      end if;

      if cs = shandsuc then
        handleheld <= '1';
      elsif cs = hyields then
        handleheld <= '0';
        handle     <= handle + 1;
      end if;

    end if;
  end process main;


  fsm : process(cs, evalid, eoutd, handle, curcmd, cmddone, setxpending)
  begin
    case cs is
      when none =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        if evalid = '1' then
          ns      <= rdevt;
        else
          if pending = "01" and cmddone = '1' then
            ns    <= fopenrsp1;
          elsif pending = "10" and cmddone = '1' then
            ns    <= freadresp;
          else
            ns    <= none;
          end if;

        end if;

      when rdevt =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= chkcmd;

      when chkcmd =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        if curcmd = GETHAND or
          curcmd = SETFNAME or
          curcmd = FOPEN or curcmd = FREAD or curcmd = YIELDHAND then
          ns      <= chkpnd;
        else
          ns      <= nextevt;
        end if;

      when nextevt =>
        enext     <= '1';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= none;

      when chkpnd =>
        enext     <= '0';
        eouta     <= "001";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        if curcmd = GETHAND then
          ns      <= sendacq;
        else
          if pending = "00" then
            ns    <= chkhand;
          else
            ns    <= penderr;
          end if;
        end if;
        -------------------------------------------------------------------------
        -- Acquire HAndle
        -------------------------------------------------------------------------

      when sendacq =>
        enext     <= '0';
        eouta     <= "001";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= GETHAND;
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= shandsuc;

      when shandsuc =>
        enext     <= '0';
        eouta     <= "001";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 3;
        txcmd     <= GETHAND;
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "001";
        setxsend  <= '0';
        ns        <= shandval;

      when shandval =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 1;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "010";
        setxsend  <= '0';
        if setxpending = '1' then
          ns      <= shandval;
        else
          ns      <= shandne;
        end if;

      when shandne =>
        enext     <= '1';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 1;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '1';

        ns <= none;

      when chkhand =>
        enext     <= '0';
        eouta     <= "001";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        if eoutd(15 downto 8) = handle then
          if curcmd = SETFNAME then
            ns    <= fnlos;
          elsif curcmd = FOPEN then
            ns    <= fopens;
          elsif curcmd = FREAD then

            ns <= freadcmd;
          elsif curcmd = YIELDHAND then
            ns <= hyields;
          else
            report "FIXME NOT IMPLEMENTED" severity error;
          end if;
        else
          ns   <= handerr;
        end if;

     -------------------------------------------------------------------------
     -- Yield Handle
     -------------------------------------------------------------------------

      when hyields =>
        enext     <= '0';
        eouta     <= "001";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= GETHAND;
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= nextevt;


     -------------------------------------------------------------------------
     -- Handle Error                    -- invalid handle
     -------------------------------------------------------------------------

     -------------------------------------------------------------------------
     -- set filename
     -------------------------------------------------------------------------
      when fnlos =>
        enext     <= '0';
        eouta     <= "010";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000010";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fname01;

      when fname01 =>
        enext     <= '0';
        eouta     <= "011";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000011";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fname23;


      when fname23 =>
        enext     <= '0';
        eouta     <= "100";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000100";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fname45;


      when fname45 =>
        enext     <= '0';
        eouta     <= "101";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000101";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fname67;

      when fname67 =>
        enext     <= '0';
        eouta     <= "101";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000110";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= nextevt;

        -------------------------------------------------------------------------
        -- fopen 
        -------------------------------------------------------------------------
      when fopens =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= SPIFOCMD;
        aconst    <= "0000000001";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fopencmd;

      when fopencmd  =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '1';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000001";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '1';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= nextevt;
        -------------------------------------------------------------------------
        -- fopen response
        -------------------------------------------------------------------------
      when fopenrsp1 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 1;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000010010";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= FOPEN;
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= forspstat;

      when forspstat =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 1;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000010011";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= FOPEN;
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "001";
        setxsend  <= '0';
        ns        <= forsplen1;


      when forsplen1 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 1;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000010100";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= FOPEN;
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "010";
        setxsend  <= '0';
        ns        <= forsplen2;


      when forsplen2 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 1;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000010101";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= FOPEN;
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "011";
        setxsend  <= '0';
        if setxpending = '0' then
          ns      <= forsnd;
        else
          ns      <= forsplen2;
        end if;

      when forsnd   =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 1;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= FOPEN;
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "100";
        setxsend  <= '1';
        ns        <= none;
        -------------------------------------------------------------------------
        -- fread
        -------------------------------------------------------------------------
      when freadcmd =>
        enext     <= '0';
        eouta     <= "010";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fread0;

      when fread0 =>
        enext     <= '0';
        eouta     <= "011";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000010";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fread1;

      when fread1 =>
        enext     <= '0';
        eouta     <= "100";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000011";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fread2;

      when fread2 =>
        enext     <= '0';
        eouta     <= "101";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000100";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fread3;

      when fread3 =>
        enext     <= '0';
        eouta     <= "101";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000101";
        setxsel   <= 0;
        spiwe     <= '1';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= fsend;

      when fsend     =>
        enext     <= '0';
        eouta     <= "011";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 1;
        spiasel   <= 1;
        dconst    <= X"0000";
        aconst    <= "0000000010";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '1';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= nextevt;
        -------------------------------------------------------------------------
        -- freadresp
        -------------------------------------------------------------------------
      when freadresp =>
        enext     <= '0';
        eouta     <= "010";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"94";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= frblockn;

      when frblockn =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 2;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '1';
        setxwe    <= '1';
        setxain   <= "001";
        setxsend  <= '0';
        ns        <= frw1;

      when frw1 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '1';
        setxwe    <= '1';
        setxain   <= "010";
        setxsend  <= '0';
        ns        <= frw2;


      when frw2 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '1';
        setxwe    <= '1';
        setxain   <= "011";
        setxsend  <= '0';
        ns        <= frw3;


      when frw3 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '1';
        setxwe    <= '1';
        setxain   <= "100";
        setxsend  <= '0';
        ns        <= frw4;

      when frw4 =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '1';
        setxain   <= "101";
        setxsend  <= '1';
        if pendpktcnt = pktcnt then
          ns      <= frdone;
        else
          ns      <= frespwait;
        end if;

      when frdone =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 2;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 4;
        spiwe     <= '0';
        txcmd     <= X"00";
        cmdreq    <= '0';
        incspicnt <= '1';
        setxwe    <= '0';
        setxain   <= "101";
        setxsend  <= '0';
        ns        <= frespwait;

      when frespwait =>
        enext     <= '0';
        eouta     <= "010";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 1;
        dconst    <= SPIFRCMD;
        aconst    <= "0000000001";
        setxsel   <= 0;
        spiwe     <= '0';
        txcmd     <= X"94";
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        if setxpending = '1' then
          ns      <= frespwait;
        else
          ns      <= none;
        end if;

      when others =>
        enext     <= '0';
        eouta     <= "000";
        ssel      <= 0;
        pendsrcen <= '0';
        penden    <= '0';
        spidsel   <= 0;
        spiasel   <= 0;
        dconst    <= X"0000";
        aconst    <= "0000000000";
        setxsel   <= 0;
        txcmd     <= X"00";
        spiwe     <= '0';
        cmdreq    <= '0';
        incspicnt <= '0';
        setxwe    <= '0';
        setxain   <= "000";
        setxsend  <= '0';
        ns        <= none;
    end case;

  end process;
end Behavioral;
