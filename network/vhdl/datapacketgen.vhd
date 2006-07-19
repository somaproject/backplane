library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity datapacketgen is

  port (
    CLK       : in  std_logic;
    ECYCLE    : in  std_logic;
    MYMAC     : in  std_logic_vector(47 downto 0);
    MYIP      : in  std_logic_vector(31 downto 0);
    MYBCAST   : in  std_logic_vector(31 downto 0);
    ADDRA     : out std_logic_vector(8 downto 0);
    LENA      : in  std_logic_vector(9 downto 0);
    DIA       : in  std_logic_vector(15 downto 0);
    ADDRB     : out std_logic_vector(8 downto 0);
    LENB      : in  std_logic_vector(9 downto 0);
    DIB       : in  std_logic_vector(15 downto 0);
    -- output interface at 100 MHz
    MEMCLK    : in  std_logic;
    DOUT      : out std_logic_vector(15 downto 0);
    ADDROUT   : in  std_logic_vector(8 downto 0);
    FIFOVALID : out std_logic;
    FIFONEXT  : in  std_logic
    );

end datapacketgen;

architecture Behavioral of datapacketgen is

  -- input signals
  signal addr, addrl : std_logic_vector(8 downto 0) := (others => '0');

  signal dsel : integer range 0 to 3 := 0;

  signal bsel, nbsel : std_logic := '0';

  signal addrinc : std_logic := '0';

  signal datawe : std_logic := '0';


  type states is (none, datachk, nextdata, datas,
                  dataw, datadone, headers, headerw, idwl, idwh, nextfifo);

  signal cs, ns : states := none;

  -- header-related signals
  signal len     : std_logic_vector(9 downto 0)  := (others => '0');
  signal hdraddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal hdrwe   : std_logic                     := '0';
  signal hdrdout : std_logic_vector(15 downto 0) := (others => '0');

  signal hdrstart, hdrdone : std_logic := '0';


  signal di  : std_logic_vector(15 downto 0) := (others => '0');
  signal src : std_logic_vector(5 downto 0)  := (others => '0');
  signal typ : std_logic_vector(1 downto 0)  := (others => '0');

  signal ida : std_logic_vector(8 downto 0) := (others => '0');

  signal idwe : std_logic := '0';

  signal destport : std_logic_vector(15 downto 0) := (others => '0');

  -- fifo signals
  signal fwe   : std_logic                     := '0';
  signal fdin  : std_logic_vector(15 downto 0) := (others => '0');
  signal faddr : std_logic_vector(10 downto 0) := (others => '0');

  signal iddo, iddi : std_logic_vector(31 downto 0) := (others => '0');

  -- output signals
  signal addroutint : std_logic_vector(10 downto 0) := (others => '0');
  signal fifonum    : std_logic_vector(1 downto 0)  := (others => '0');


  -- components
  component udpheaderwriter
    port (
      CLK      : in  std_logic;
      MYMAC    : in  std_logic_vector(47 downto 0);
      MYIP     : in  std_logic_vector(31 downto 0);
      MYBCAST  : in  std_logic_vector(31 downto 0);
      DESTPORT : in  std_logic_vector(15 downto 0);
      START    : in  std_logic;
      WLEN     : in  std_logic_vector(9 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      WEOUT    : out std_logic;
      ADDR     : out std_logic_vector(9 downto 0);
      DONE     : out std_logic);
  end component;


begin  -- Behavioral

  udpheaderwriter_inst : udpheaderwriter
    port map (
      CLK      => CLK,
      MYMAC    => MYMAC,
      MYIP     => MYIP,
      MYBCAST  => MYBCAST,
      DESTPORT => destport,
      START    => hdrstart,
      WLEN     => len,
      DOUT     => hdrdout,
      WEOUT    => hdrwe,
      ADDR     => hdraddr,
      DONE     => hdrdone);

  -- input muxes
  len <= LENA when bsel = '0' else LENB;
  di  <= DIA  when bsel = '0' else DIB;

  nbsel <= bsel;

  faddr(8 downto 0) <= addrl       when dsel = 0 else
                       hdraddr     when dsel = 1 else
                       "000010110" when dsel = 2 else
                       "000010111";

  ADDRA <= addr;
  ADDRB <= addr;

  fwe <= datawe when dsel = 0 else
         hdrwe  when dsel = 1 else
         '1';

  fdin <= di                 when dsel = 0 else
          hdrdout            when dsel = 1 else
          iddo(31 downto 16) when dsel = 2 else
          iddo(15 downto 0);

  iddo <= iddi + 1;

  idwe <= '1' when cs = nextfifo else '0';

  hdrstart <= '1' when cs = headers else '0';

  ida <= "0" & typ & src;

  destport <= X"0fa0" + ("000000" & ida);
  ID_buffer : RAMB16_S36
    port map (
      DO   => iddo,
      ADDR => ida,
      CLK  => CLK,
      DI   => iddi,
      DIP  => "0000",
      EN   => '1',
      SSR  => '0',
      WE   => idwe
      );

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

      if cs = nextdata then
        bsel <= nbsel;
      end if;

      if cs = datachk then
        addr   <= (others => '0');
      else
        if addrinc = '1' then
          addr <= addr + 1;
        end if;
      end if;

      addrl <= addr + X"0018";

      if addrl = "000011000" then
        src <= di(5 downto 0);
        typ <= di(9 downto 8);
      end if;

      if cs = nextfifo then
        faddr(10 downto 9) <= faddr(10 downto 9) + 1;
      end if;

    end if;
  end process main;

  FIFOVALID <= '1' when addroutint /= fifonum else '0';

  -- memory output clock
  memproc : process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then
      fifonum <= faddr(10 downto 9);

      if FIFONEXT = '1' then
        addroutint(10 downto 9) <= addroutint(10 downto 9) + 1;
      end if;

    end if;

  end process memproc;


  FIFO_BufferA_inst : RAMB16_S9_S9
    port map (
      DOA   => open,
      DOB   => DOUT(15 downto 8),
      ADDRA => faddr,
      ADDRB => addroutint,
      CLKA  => CLK,
      CLKB  => MEMCLK,
      DIA   => fdin(15 downto 8),
      DIB   => X"00",
      DIPA  => "0",
      DIPB  => "0",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => fwe,
      WEB   => '0'
      );
  FIFO_BufferB_inst : RAMB16_S9_S9
    port map (
      DOA   => open,
      DOB   => DOUT(7 downto 0),
      ADDRA => faddr,
      ADDRB => addroutint,
      CLKA  => CLK,
      CLKB  => MEMCLK,
      DIA   => fdin(7 downto 0),
      DIB   => X"00",
      DIPA  => "0",
      DIPB  => "0",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => fwe,
      WEB   => '0'
      );

  fsm : process(cs, ECYCLE, len, addr, hdrdone)
  begin
    case cs is
      when none =>
        dsel    <= 0;
        addrinc <= '0';
        datawe  <= '0';
        if ecycle = '1' then
          ns    <= datachk;
        else
          ns    <= none;
        end if;

      when datachk =>
        dsel    <= 0;
        addrinc <= '0';
        datawe  <= '0';
        if len = "0000000000" then
          ns    <= nextdata;
        else
          ns    <= datas;
        end if;

      when nextdata =>
        dsel    <= 0;
        addrinc <= '0';
        datawe  <= '0';
        if bsel = '1' then
          ns    <= none;
        else
          ns    <= datachk;
        end if;

      when datas =>
        dsel    <= 0;
        addrinc <= '1';
        datawe  <= '0';
        ns      <= dataw;

      when dataw =>
        dsel    <= 0;
        addrinc <= '1';
        datawe  <= '1';
        if len(9 downto 1) = addr then
          ns    <= datadone;
        else
          ns    <= dataw;
        end if;

      when datadone =>
        dsel    <= 0;
        addrinc <= '0';
        datawe  <= '1';
        ns      <= headers;

      when headers =>
        dsel    <= 1;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= headerw;

      when headerw =>
        dsel    <= 1;
        addrinc <= '0';
        datawe  <= '0';
        if hdrdone = '1' then
          ns    <= idwl;
        end if;

      when idwl =>
        dsel    <= 2;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= idwh;

      when idwh =>
        dsel    <= 3;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= nextfifo;

      when nextfifo =>
        dsel    <= 3;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= nextdata;
      when others   =>
        dsel    <= 0;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= none;
    end case;

  end process;
end Behavioral;
