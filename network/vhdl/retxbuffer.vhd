library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity retxbuffer is
  port (
    CLK   : in std_logic;
    CLKHI : in std_logic;

    -- buffer set A input (write) interface
    WIDA   : in std_logic_vector(13 downto 0);
    WDINA  : in std_logic_vector(15 downto 0);
    WADDRA : in std_logic_vector(8 downto 0);
    WRA    : in std_logic;
    WDONEA : in std_logic;

    -- output buffer A set B (reads) interface
    RIDA   : in  std_logic_vector (13 downto 0);
    RREQA  : in  std_logic;
    RDOUTA : out std_logic_vector(15 downto 0);
    RADDRA : out std_logic_vector(8 downto 0);
    RDONEA : out std_logic;

--buffer set B input (write) interfafe
    WIDB   : in std_logic_vector(13 downto 0);
    WDINB  : in std_logic_vector(15 downto 0);
    WADDRB : in std_logic_vector(8 downto 0);
    WRB    : in std_logic;
    WDONEB : in std_logic;

    -- output buffer B set Rad (reads) interface
    RIDB   : in  std_logic_vector (13 downto 0);
    RREQB  : in  std_logic;
    RDOUTB : out std_logic_vector(15 downto 0);
    RADDRB : out std_logic_vector(8 downto 0);
    RDONEB : out std_logic;

    -- memory output interface
    MEMSTART  : out std_logic;
    MEMRW     : out std_logic;
    MEMDONE   : in  std_logic;
    MEMWRADDR : in  std_logic_vector(7 downto 0);
    MEMWRDATA : out std_logic_vector(31 downto 0);
    MEMROWTGT : out std_logic_vector(14 downto 0);
    MEMRDDATA : in  std_logic_vector(31 downto 0);
    MEMRDADDR : in  std_logic_vector(7 downto 0);
    MEMRDWE   : in  std_logic
    );
end retxbuffer;

architecture Behavioral of retxbuffer is

-- write A signals
  signal waddraint : std_logic_vector(9 downto 0) := (others => '0');

  signal widal   : std_logic_vector(13 downto 0) := (others => '0');
  signal wdoneal : std_logic                     := '0';
  signal wda     : std_logic_vector(31 downto 0) := (others => '0');

  signal rena : std_logic := '0';

-- write B signals
  signal waddrbint : std_logic_vector(9 downto 0) := (others => '0');

  signal widbl   : std_logic_vector(13 downto 0) := (others => '0');
  signal wdonebl : std_logic                     := '0';
  signal wdb     : std_logic_vector(31 downto 0) := (others => '0');

-- read A signals
  signal ridal   : std_logic_vector(13 downto 0) := (others => '0');
  signal rreqal  : std_logic                     := '0';
  signal lraddra : std_logic_vector(9 downto 0)  := "0100000000";
  signal rfwea   : std_logic                     := '0';

-- read B signals
  signal ridbl   : std_logic_vector(13 downto 0) := (others => '0');
  signal rreqbl  : std_logic                     := '0';
  signal lraddrb : std_logic_vector(9 downto 0)  := "0100000000";
  signal rfweb   : std_logic                     := '0';
  signal renb    : std_logic                     := '0';

  signal crsta, crstb : std_logic := '0';

  
-- control signals
  signal asel, rw     : std_logic := '0';
  signal wrtgt, rdtgt : std_logic_vector(13 downto 0);

  signal memwraddrint : std_logic_vector(8 downto 0) := (others => '0');
  signal memrdaddrint : std_logic_vector(8 downto 0) := (others => '0');

  type states is (wrachk, wrast, wrawait, wradone,
                  wrbchk, wrbst, wrbwait, wrbdone,
                  rdachk, rdast, rdawait, rdadone,
                  rdbchk, rdbst, rdbwait, rdbdone);

  signal cs, ns : states := wrachk;

begin  -- Behavioral

  -- main muxes
  rdtgt     <= ridal       when asel = '1' else ridbl;
  wrtgt     <= widal       when asel = '1' else widbl;
  MEMROWTGT <= "1" & wrtgt when rw = '1'   else "0" & rdtgt;

  MEMWRDATA <= wda when asel = '1' else wdb;

  MEMRW <= rw;

  -- write combinational
  rfwea <= asel and MEMRDWE;
  rfweb <= (not asel) and MEMRDWE;

  himain : process(CLKHI)
  begin
    if rising_edge(clkhi) then

      cs <= ns;


      -- input A

      if WDONEA = '1' then
        widal <= WIDA;
      end if;

      if cs = wradone then
        wdoneal   <= '0';
      else
        if wdonea = '1' then
          wdoneal <= '1';
        end if;
      end if;


      -- input B

      if WDONEB = '1' then
        widbl <= WIDB;
      end if;

      if cs = wrbdone then
        wdonebl   <= '0';
      else
        if wdoneb = '1' then
          wdonebl <= '1';
        end if;
      end if;

      --output A
      if rreqa = '1' then
        ridal <= RIDA;
      end if;

      if cs = rdadone then
        rreqal   <= '0';
      else
        if RREQA = '1' then
          rreqal <= '1';
        end if;
      end if;

      if rena = '1' then
        crsta   <= '0';
      else
        if cs = rdadone then
          crsta <= '1';
        end if;
      end if;


      --output B
      if rreqb = '1' then
        ridbl <= RIDB;
      end if;

      if cs = rdbdone then
        rreqbl   <= '0';
      else
        if RREQB = '1' then
          rreqbl <= '1';
        end if;
      end if;

      if renb = '1' then
        crstb   <= '0';
      else
        if cs = rdbdone then
          crstb <= '1';
        end if;
      end if;
    end if;
  end process himain;

  rena <= '1' when lraddra <= "1000000000" else '0';
  renb <= '1' when lraddrb <= "1000000000" else '0';


  main : process(CLK)
  begin
    if rising_edge(CLK) then

      -- output A
      if crsta = '1' then
        lraddra   <= (others => '0');
      else
        if rena = '1' then
          lraddra <= lraddra + 1;
        end if;
      end if;

      RADDRA <= lraddra(8 downto 0);

      -- output B
      if crstB = '1' then
        lraddrb   <= (others => '0');
      else
        if renb = '1' then
          lraddrb <= lraddrb + 1;
        end if;
      end if;

      RADDRB <= lraddrb(8 downto 0);

    end if;
  end process main;
  waddraint    <= "0" & WADDRA;
  waddrbint    <= "0" & WADDRB;
  memwraddrint <= "0" & MEMWRADDR;
  memrdaddrint <= '0' & MEMRDADDR;

  WriteFifoA : RAMB16_S18_S36
    port map (
      WEA   => wra,
      ENA   => '1',
      SSRA  => '0',
      CLKA  => clk,
      ADDRA => waddraint,
      DIA   => wdina,
      dipa  => "00",
      DOPA  => open,
      DOA   => open,
      WEB   => '0',
      ENB   => '1',
      SSRB  => '0',
      CLKB  => clkhi,
      ADDRB => memwraddrint,
      DIB   => X"00000000",
      DIPB  => "0000",
      DOPB  => open,
      DOB   => wda);

  WriteFifoB : RAMB16_S18_S36
    port map (
      WEA   => wrb,
      ENA   => '1',
      SSRA  => '0',
      CLKA  => clk,
      ADDRA => waddrbint,
      DIA   => wdinb,
      dipa  => "00",
      DOPA  => open,
      DOA   => open,
      WEB   => '0',
      ENB   => '1',
      SSRB  => '0',
      CLKB  => clkhi,
      ADDRB => memwraddrint,
      DIB   => X"00000000",
      DIPB  => "0000",
      DOPB  => open,
      DOB   => wdb);

  ReadFifoA : RAMB16_S18_S36
    port map (
      WEA   => '0',
      ENA   => '1',
      SSRA  => '0',
      CLKA  => clk,
      ADDRA => lraddra,
      DIA   => X"0000",
      dipa  => "00",
      DOPA  => open,
      DOA   => RDOUTA,
      WEB   => rfwea,
      ENB   => '1',
      SSRB  => '0',
      CLKB  => clkhi,
      ADDRB => memrdaddrint,
      DIB   => MEMRDDATA,
      DIPB  => "0000",
      DOPB  => open,
      DOB   => open);

  ReadFifoB : RAMB16_S18_S36
    port map (
      WEA   => '0',
      ENA   => '1',
      SSRA  => '0',
      CLKA  => clk,
      ADDRA => lraddrb,
      DIA   => X"0000",
      dipa  => "00",
      DOPA  => open,
      DOA   => RDOUTB,
      WEB   => rfweb,
      ENB   => '1',
      SSRB  => '0',
      CLKB  => clkhi,
      ADDRB => memrdaddrint,
      DIB   => MEMRDDATA,
      DIPB  => "0000",
      DOPB  => open,
      DOB   => open);

  fsm : process(cs, wdoneal, wdonebl, rreqal, rreqbl, memdone)
  begin
    case cs is
      when wrachk =>
        rw       <= '1';
        asel     <= '1';
        memstart <= '0';
        if wdoneal = '1' then
          ns     <= wrast;
        else
          ns     <= wrbchk;
        end if;

      when wrast =>
        rw       <= '1';
        asel     <= '1';
        memstart <= '1';
        ns       <= wrawait;

      when wrawait =>
        rw       <= '1';
        asel     <= '1';
        memstart <= '0';
        if MEMDONE = '1' then
          ns     <= wradone;
        else
          ns     <= wrawait;
        end if;

      when wradone =>
        rw       <= '1';
        asel     <= '1';
        memstart <= '0';
        ns       <= wrbchk;

      when wrbchk =>
        rw       <= '1';
        asel     <= '0';
        memstart <= '0';
        if wdonebl = '1' then
          ns     <= wrbst;
        else
          ns     <= rdachk;
        end if;

      when wrbst =>
        rw       <= '1';
        asel     <= '0';
        memstart <= '1';
        ns       <= wrbwait;

      when wrbwait =>
        rw       <= '1';
        asel     <= '0';
        memstart <= '0';
        if MEMDONE = '1' then
          ns     <= wrbdone;
        else
          ns     <= wrbwait;
        end if;

      when wrbdone =>
        rw       <= '1';
        asel     <= '0';
        memstart <= '0';
        ns       <= rdachk;


      when rdachk =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        if rreqal = '1' then
          ns     <= rdast;
        else
          ns     <= rdbchk;
        end if;

      when rdast =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '1';
        ns       <= rdawait;

      when rdawait =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        if MEMDONE = '1' then
          ns     <= rdadone;
        else
          ns     <= rdawait;
        end if;

      when rdadone =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        ns       <= rdbchk;


      when rdbchk =>
        rw       <= '0';
        asel     <= '0';
        memstart <= '0';
        if rreqal = '1' then
          ns     <= rdbst;
        else
          ns     <= wrachk;
        end if;

      when rdbst =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '1';
        ns       <= rdbwait;

      when rdbwait =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        if MEMDONE = '1' then
          ns     <= rdbdone;
        else
          ns     <= rdbwait;
        end if;

      when rdbdone =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        ns       <= wrachk;

      when others =>
        rw       <= '0';
        asel     <= '1';
        memstart <= '0';
        ns       <= wrachk;
    end case;

  end process fsm;

end Behavioral;
