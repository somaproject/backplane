library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library soma;
use soma.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;

entity eproc is
  port (
    CLK         : in  std_logic;
    RESET       : in  std_logic;
    -- Event Interface, CLK rate
    EDTX        : in  std_logic_vector(7 downto 0);
    EATX        : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE      : in  std_logic;
    EARX        : out std_logic_vector(somabackplane.N - 1 downto 0)
 := (others => '0');
    EDRX        : out std_logic_vector(7 downto 0);
    EDSELRX     : in  std_logic_vector(3 downto 0);
    -- High-speed interface
    CLKHI       : in  std_logic;
    -- instruction interface
    IADDR       : out std_logic_vector(9 downto 0);
    IDATA       : in  std_logic_vector(17 downto 0);
    --outport signals
    OPORTADDR   : out std_logic_vector(7 downto 0);
    OPORTDATA   : out std_logic_vector(15 downto 0);
    OPORTSTROBE : out std_logic;
    DEVICE : in std_logic_vector(7 downto 0)
    );

end eproc;

architecture Behavioral of eproc is

  -- event tracking and counting
  signal estart : std_logic                              := '0';
  signal epos   : integer range 0 to somabackplane.N - 1 := 0;
  signal bcnt   : integer range 0 to 23                  := 0;
  signal elb    : std_logic                              := '0';

  signal etxbit : std_logic := '0';

  -- force jumping
  signal jumpsel              : std_logic                    := '0';
  signal forceaddr            : std_logic_vector(9 downto 0) := (others => '0');
  signal evtjumpaddr, eddaddr : std_logic_vector(9 downto 0)
                                                             := (others => '0');

  signal evtjump   : std_logic := '0';
  signal forcejump : std_logic := '0';

  -- event latching
  signal ecyclel : std_logic                    := '0';
  signal edtxl   : std_logic_vector(7 downto 0) := (others => '0');

  -- data acq
  signal dlen, dhen, dsel : std_logic                     := '0';
  signal ebufdata         : std_logic_vector(15 downto 0) := (others => '0');
  signal ebufaddr         : std_logic_vector(3 downto 0)  := (others => '0');

  signal ebufwe   : std_logic := '0';
  signal ebufswap : std_logic := '0';
  signal bufsel   : std_logic := '0';

  -- event core interface
  signal ecea : std_logic_vector(3 downto 0)  := (others => '0');
  signal eced : std_logic_vector(15 downto 0) := (others => '0');

  signal ostrobe : std_logic                     := '0';
  signal oaddr   : std_logic_vector(7 downto 0)  := (others => '0');
  signal odata   : std_logic_vector(15 downto 0) := (others => '0');

  signal eddstart, eddone, eddmatch : std_logic := '0';

  signal evtjumpenable : std_logic := '0';

  signal tgtwe : std_logic := '0';

  signal src, cmd     : std_logic_vector(7 downto 0) := (others => '0');
  signal srcen, cmden : std_logic                    := '0';

  signal cphase : std_logic := '0';

  -- event output
  signal etxne : std_logic := '0';
  signal etxwe : std_logic := '0';

  signal etxdaddr : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal etxddata, etxdataendian : std_logic_vector(95 downto 0) := (others => '0');



  component regfile
    generic (
      BITS  :     integer := 16);
    port (
      CLK   : in  std_logic;
      DIA   : in  std_logic_vector(BITS-1 downto 0);
      DOA   : out std_logic_vector(BITS -1 downto 0);
      ADDRA : in  std_logic_vector(3 downto 0);
      WEA   : in  std_logic;
      DOB   : out std_logic_vector(BITS -1 downto 0);
      ADDRB : in  std_logic_vector(3 downto 0)
      );
  end component;

  component evtdnd
    port (
      CLK     : in  std_logic;
      CMD     : in  std_logic_vector(7 downto 0);
      SRC     : in  std_logic_vector(7 downto 0);
      ADDR    : out std_logic_vector(9 downto 0);
      MATCH   : out std_logic;
      START   : in  std_logic;
      DONE    : out std_logic;
      -- interface
      TGTDIN  : in  std_logic_vector(15 downto 0);
      TGTWE   : in  std_logic;
      TGTADDR : in  std_logic_vector(5 downto 0)
      );
  end component;


  component ecore
    port (
      CLK         : in  std_logic;
      CPHASEOUT   : out std_logic;
      RESET       : in  std_logic;
      -- instruction interface
      IADDR       : out std_logic_vector(9 downto 0);
      IDATA       : in  std_logic_vector(17 downto 0);
      -- event interface
      EADDR       : out std_logic_vector(2 downto 0);
      EDATA       : in  std_logic_vector(15 downto 0);
      -- io ports
      OPORTADDR   : out std_logic_vector(7 downto 0);
      OPORTDATA   : out std_logic_vector(15 downto 0);
      OPORTSTROBE : out std_logic;

      IPORTADDR   : out std_logic_vector(7 downto 0);
      IPORTDATA   : in  std_logic_vector(15 downto 0);
      IPORTSTROBE : out std_logic;
      -- interrupt interface ports
      FORCEJUMP   : in  std_logic;
      FORCEADDR   : in  std_logic_vector(9 downto 0)
      );

  end component;

  component txeventbuffer
    port (
      CLK      : in  std_logic;
      EVENTIN  : in  std_logic_vector(95 downto 0);
      EADDRIN  : in  std_logic_vector(somabackplane.N -1 downto 0);
      NEWEVENT : in  std_logic;
      ECYCLE   : in  std_logic;
      -- outputs
      EDRX     : out std_logic_vector(7 downto 0);
      EDRXSEL  : in  std_logic_vector(3 downto 0);
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
  end component;


  type states is (none, ejumprun1, ejumprun2, ewait, evtstartrst,
                  ebody);
  signal cs, ns : states := none;


begin  -- Behavioral

  evtbuffer : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLKHI,
      DIA   => ebufdata,
      DOA   => open,
      ADDRA => ebufaddr,
      WEA   => ebufwe,
      DOB   => eced,
      ADDRB => ecea);

  evtdnd_inst : evtdnd
    port map (
      ClK     => CLKHI,
      CMD     => cmd,
      SRC     => src,
      TGTDIN  => odata,
      TGTWE   => tgtwe,
      TGTADDR => oaddr(5 downto 0),
      ADDR    => eddaddr,
      MATCH   => eddmatch,
      DONE    => eddone,
      START   => eddstart);

  etxdataendian(15 downto 0) <= etxddata(15 downto 0);

  -- swap the byte order
  etxdataendian(31 downto 24) <= etxddata(23 downto 16);
  etxdataendian(23 downto 16) <= etxddata(31 downto 24);
  
  etxdataendian(47 downto 40) <= etxddata(39 downto 32);
  etxdataendian(39 downto 32) <= etxddata(47 downto 40);
  
  etxdataendian(63 downto 56) <= etxddata(55 downto 48);
  etxdataendian(55 downto 48) <= etxddata(63 downto 56);
  
  etxdataendian(71 downto 64) <= etxddata(79 downto 72);
  etxdataendian(79 downto 72) <= etxddata(71 downto 64);
  
  etxdataendian(87 downto 80) <= etxddata(95 downto 88);
  etxdataendian(95 downto 88) <= etxddata(87 downto 80);
  
  

  txeventbuffer_inst: txeventbuffer
    port map (
      CLK      => CLK,
      EVENTIN  => etxdataendian,
      EADDRIN  => etxdaddr,
      NEWEVENT => etxne,
      ECYCLE   => ECYCLE,
      EDRX     => EDRX,
      EDRXSEL  => EDSELRX,
      EARX     => EARX);
  
  ecore_inst : ecore
    port map (
      CLK         => CLKHI,
      CPHASEOUT   => cphase,
      RESET       => RESET,
      IADDR       => iaddr,
      IDATA       => idata,
      EADDR       => ecea(2 downto 0),
      EDATA       => eced,
      OPORTADDR   => oaddr,
      OPORTDATA   => odata,
      OPORTSTROBE => ostrobe,
      IPORTADDR   => open,
      IPORTDATA   => X"0000",
      IPORTSTROBE => open,
      FORCEJUMP   => forcejump,
      FORCEADDR   => forceaddr);


  eventtx_inst : entity work.eventtx
    port map (
      CLK      => CLKHI,
      EIND     => ODATA,
      EINADDR  => OADDR(2 downto 0),
      EINWE    => etxwe,
      SRC      => DEVICE,
      EDATA    => etxddata,
      EADDR    => etxdaddr,
      NEWEVENT => etxne);

  main : process(CLKHI)
  begin
    if rising_edge(CLKHI) then
      cs <= ns;

      ecyclel <= ECYCLE;
      edtxl   <= EDTX;

      if estart = '1' then
        epos     <= 0;
      else
        if elb = '1' then
          if epos = somabackplane.N - 1 then
            epos <= 0;
          else
            epos <= epos + 1;
          end if;
        end if;
      end if;

      if elb = '1' or estart = '1' then
        bcnt <= 0;
      else
        bcnt <= bcnt + 1;
      end if;

      if dlen = '1' then
        ebufdata(7 downto 0) <= edtxl;

      end if;

      if dhen = '1' then
        if dsel = '0' then
          ebufdata(15 downto 8) <= edtxl;
        else
          ebufdata(15 downto 8) <= (others => '0');
        end if;

      end if;

      if ebufswap = '1' then
        bufsel <= not bufsel;
      end if;

      if ostrobe = '1' and oaddr = "10001000" then
        evtjumpaddr <= odata(9 downto 0);
      end if;

      if ostrobe = '1' and oaddr = "10001001" then
        evtjumpenable <= odata(0);
      end if;

      if cmden = '1' then
        cmd <= edtxl;
      end if;

      if srcen = '1' then
        src <= edtxl;
      end if;

    end if;
  end process main;


  dsel <= '1' when bcnt = 0 or bcnt = 2          else '0';
  dlen <= '1' when bcnt = 0 or bcnt = 2 or bcnt = 6 or bcnt = 10
          or bcnt = 14 or bcnt = 18 or bcnt = 22 else '0';

  dhen <= '1' when bcnt = 0 or bcnt = 2 or bcnt = 4 or bcnt = 8
          or bcnt = 12 or bcnt = 16 or bcnt = 20 else '0';

  ebufwe <= '1' when cs = ebody
            and (bcnt = 2 or bcnt = 4 or bcnt = 8
                 or bcnt = 12 or bcnt = 16 or bcnt = 20 or bcnt = 23)
            else '0';

  ebufaddr(2 downto 0) <= "000" when bcnt = 2  else
                          "001" when bcnt = 4  else
                          "010" when bcnt = 8  else
                          "011" when bcnt = 12 else
                          "100" when bcnt = 16 else
                          "101" when bcnt = 20 else
                          "110" when bcnt = 23 else
                          "000";

  ebufswap <= '1' when bcnt = 23 and cs = ebody else '0';

  ebufaddr(3) <= bufsel;


  etxbit <= '1' when eatx(epos) = '1' else '0';

  forcejump <= '1' when evtjump = '1' or
               (cs = ebody and etxbit = '1' and eddmatch = '1'
                and (bcnt = 22 or bcnt = 23))
               else '0';

  cmden <= '1' when cs = ebody and bcnt = 0 else '0';
  srcen <= '1' when cs = ebody and bcnt = 2 else '0';


  elb      <= '1' when bcnt = 23 else '0';
  eddstart <= '1' when bcnt = 3  else '0';

  ecea(3)   <= not bufsel;
  forceaddr <= evtjumpaddr when jumpsel = '0' else eddaddr;

  etxwe <= '1' when oaddr(7 downto 3) = "10000" else '0';

  tgtwe <= '1' when oaddr(7 downto 6) = "01" and ostrobe = '1' else '0';

  OPORTADDR     <= oaddr;
  OPORTDATA     <= odata;
  OPORTSTROBE   <= ostrobe;
  fsm : process(cs, ecyclel, epos, bcnt)
  begin
    case cs is
      when none =>
        estart  <= '1';
        jumpsel <= '0';
        evtjump <= '0';
        if ecyclel = '1' and evtjumpenable = '1' then
          ns    <= ejumprun1;
        else
          ns    <= none;
        end if;

      when ejumprun1 =>
        estart  <= '0';
        jumpsel <= '0';
        evtjump <= '1';
        ns      <= ejumprun2;

      when ejumprun2 =>
        estart  <= '0';
        jumpsel <= '0';
        evtjump <= '1';
        ns      <= ewait;

      when ewait =>
        estart  <= '0';
        jumpsel <= '0';
        evtjump <= '0';
        if epos = 3 and bcnt = 21 then
          ns    <= evtstartrst;
        else
          ns    <= ewait;
        end if;

      when evtstartrst =>
        estart  <= '1';
        jumpsel <= '0';
        evtjump <= '0';
        ns      <= ebody;

      when ebody =>
        estart  <= '0';
        jumpsel <= '1';
        evtjump <= '0';
        if epos = 77 and bcnt = 23 then
          ns    <= none;
        else
          ns    <= ebody;
        end if;

      when others =>
        estart  <= '0';
        jumpsel <= '0';
        evtjump <= '0';
        ns      <= none;

    end case;

  end process fsm;


end Behavioral;

