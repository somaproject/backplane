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
                  dataw, datadone, headers, headerw, seqwl, seqwh, nextfifo);

  signal cs, ns : states := none;

  -- header-related signals
  signal len, tlen     : std_logic_vector(9 downto 0)  := (others => '0');
  signal hdraddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal hdrwe   : std_logic                     := '0';
  signal hdrdout : std_logic_vector(15 downto 0) := (others => '0');

  signal hdrstart, hdrdone : std_logic := '0';


  signal di  : std_logic_vector(15 downto 0) := (others => '0');
  signal src : std_logic_vector(5 downto 0)  := (others => '0');
  signal typ : std_logic_vector(1 downto 0)  := (others => '0');

  signal seqa : std_logic_vector(8 downto 0) := (others => '0');

  signal seqwe : std_logic := '0';

  signal destport : std_logic_vector(15 downto 0) := (others => '0');

  -- fifo signals
  signal fwe   : std_logic                     := '0';
  signal fdin  : std_logic_vector(15 downto 0) := (others => '0');
  signal faddr : std_logic_vector(10 downto 0) := (others => '0');

  signal seqdo, seqdi : std_logic_vector(31 downto 0) := (others => '0');

  -- output signals
  signal addroutint : std_logic_vector(10 downto 0) := (others => '0');
  signal fifonum    : std_logic_vector(1 downto 0)  := (others => '0');


  -- components
  component udpheaderwriter
    port (
      CLK      : in  std_logic;
      SRCMAC    : in  std_logic_vector(47 downto 0);
      SRCIP     : in  std_logic_vector(31 downto 0);
      DESTIP  : in  std_logic_vector(31 downto 0);
      DESTMAC : in std_logic_vector(47 downto 0); 
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
      SRCMAC    => MYMAC,
      SRCIP     => MYIP,
      DESTIP  => MYBCAST,
      DESTMAC => X"FFFFFFFFFFFF", 
      DESTPORT => destport,
      START    => hdrstart,
      WLEN     => tlen,
      DOUT     => hdrdout,
      WEOUT    => hdrwe,
      ADDR     => hdraddr,
      DONE     => hdrdone);

  -- input muxes
  tlen <= len + 2;
  
  len <= LENA(9 downto 0) when bsel = '0' else
         LENB(9 downto 0);
  di  <= DIA                      when bsel = '0' else DIB;

  nbsel <= not bsel;

  faddr(8 downto 0) <= addrl               when dsel = 0 else
                       hdraddr(8 downto 0) when dsel = 1 else
                       "000010110"         when dsel = 2 else
                       "000010111";

  ADDRA <= addr;
  ADDRB <= addr;

  fwe <= datawe when dsel = 0 else
         hdrwe  when dsel = 1 else
         '1';

  fdin <= di                 when dsel = 0 else
          hdrdout            when dsel = 1 else
          seqdo(31 downto 16) when dsel = 2 else
          seqdo(15 downto 0);

  seqdi <= seqdo + 1;

  seqwe <= '1' when cs = nextfifo else '0';

  hdrstart <= '1' when cs = headers else '0';

  seqa <= "0" & typ & src;

  destport <= X"0fa0" + ("000000" & seqa);
  
  SEQ_buffer : RAMB16_S36
    generic map (
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000"
      )
    port map (
      DO      => seqdo,
      ADDR    => seqa,
      CLK     => CLK,
      DI      => seqdi,
      DIP     => "0000",
      EN      => '1',
      SSR     => '0',
      WE      => seqwe
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

      addrl <= addr + "000011000";

      if addr = "000000001" then
        src <= di(5 downto 0);
        typ <= di(9 downto 8);
      end if;

      if cs = nextfifo then
        faddr(10 downto 9) <= faddr(10 downto 9) + 1;
      end if;

    end if;
  end process main;

  FIFOVALID <= '1' when addroutint(10 downto 9)  /= fifonum else '0';

  addroutint(8 downto 0) <= ADDROUT;

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
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",
      -- Address 0 to 255
      INIT_00             => X"000000000000000000000000009C0000080000400000004508000000FFFFFF00" ,       
      INIT_10             => X"000000000000000000000000009C0000080000400000004508000000FFFFFF00",        
      INIT_20             => X"000000000000000000000000009C0000080000400000004508000000FFFFFF00" ,       
      INIT_30             => X"000000000000000000000000009C0000080000400000004508000000FFFFFF00"        
      )

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
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",
      -- Address 0 to 255
      INIT_00             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      INIT_10             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      INIT_20             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00",
      INIT_30             => X"00000000000000000000000000400000000000110000000000000000FFFFFF00"
      )

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
        if len(8 downto 0) = addr then
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
          ns    <= seqwl;
        end if;

      when seqwl =>
        dsel    <= 2;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= seqwh;

      when seqwh =>
        dsel    <= 3;
        addrinc <= '0';
        datawe  <= '0';
        ns      <= nextfifo;

      when nextfifo =>
        dsel    <= 0;
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
