library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity jtagmemif is
  port (
    CLK         : in  std_logic;
    MEMSTART    : out std_logic;
    MEMRW       : out std_logic;
    MEMDONE     : in  std_logic;
    ROWTGT      : out std_logic_vector(14 downto 0);
    WRADDR      : in  std_logic_vector(7 downto 0);
    WRDATA      : out std_logic_vector(31 downto 0);
    RDADDR      : in  std_logic_vector(7 downto 0);
    RDDATA      : in  std_logic_vector(31 downto 0);
    RDWE        : in  std_logic;
    READOFFSET  : out std_logic_vector(1 downto 0);
    WRITEOFFSET : out std_logic_vector(1 downto 0);
    READSTART   : in  std_logic
    );
end jtagmemif;

architecture Behavioral of jtagmemif is

  signal wdrck, wsel, wshift, wupdate, wtdo, wtdi : std_logic := '0';

  signal wrsreg   : std_logic_vector(39 downto 0) := (others => '0');
  signal wraddrin : std_logic_vector(8 downto 0)  := (others => '0');
  signal wraddrf  : std_logic_vector(8 downto 0)  := (others => '0');

  signal lwrdata : std_logic_vector(31 downto 0) := (others => '0');

  signal wrdatain : std_logic_vector(31 downto 0) := (others => '0');

  signal rdrck, rsel, rshift, rupdate, rtdo, rtdi : std_logic := '0';

  signal rdsreg   : std_logic_vector(63 downto 0) := (others => '0');
  signal rdaddrin : std_logic_vector(8 downto 0)  := (others => '0');
  signal rddatain : std_logic_vector(63 downto 0) := (others => '0');

  signal rdaddrf : std_logic_vector(8 downto 0) := (others => '0');

  signal cdrck, csel, cshift, cupdate, cupdatel, cupdatell, csell,
    ctdo, ctdi : std_logic := '0';

  signal csreg : std_logic_vector(39 downto 0) := (others => '0');
  signal dones : std_logic                     := '0';


  signal readaddr : std_logic_vector(8 downto 0)  := (others => '0');
  signal readdata : std_logic_vector(63 downto 0) := (others => '0');
  signal readwen  : std_logic                     := '0';


  signal readstartl : std_logic                      := '0';
  signal coutreg    : std_logic_vector(143 downto 0) := (others => '0');

  signal lmemstart : std_logic := '0';
  signal lmemdone : std_logic := '0';
  
begin  -- Behavioral

  --------------------------------------------------------------------------
  -- Write interface
  --------------------------------------------------------------------------

  BSCAN_write_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 3)
    port map (
      CAPTURE    => open,
      DRCK       => wdrck,
      reset      => open,
      SEL        => wsel,
      SHIFT      => wshift,
      TDI        => wtdi,
      UPDATE     => wupdate,
      TDO        => wtdo);

  process(wdrck)
  begin
    if rising_edge(wdrck) then
      wrsreg <= wtdi & wrsreg(39 downto 1);
    end if;
  end process;

  wraddrin(7 downto 0) <= wrsreg(7 downto 0);
  wrdatain             <= wrsreg(39 downto 8);

  wraddrf(7 downto 0) <= WRADDR;

  process(CLK)
  begin
    if rising_edge(CLK) then
      WRDATA <= lWRDATA;
    end if;
  end process;

  RAMB16_S36_S36_inst : RAMB16_S36_S36
    port map (
      DOA   => open,                    -- Port A 32-bit Data Output
      DOB   => lWRDATA,                 -- Port B 32-bit Data Output
      ADDRA => wraddrin,                -- Port A 9-bit Address Input
      ADDRB => wraddrf,                 -- Port B 9-bit Address Input
      CLKA  => wupdate,                 -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => wrdatain,                -- Port A 32-bit Data Input
      DIB   => X"00000000",             -- Port B 32-bit Data Input
      DIPA  => "0000",                  -- Port A 4-bit parity Input
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => wsel,                    -- Port A RAM Enable Input
      ENB   => '1',                     -- PortB RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => '1',                     -- Port A Write Enable Input
      WEB   => '0'                      -- Port B Write Enable Input
      );


  BSCAN_read_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 2)
    port map (
      CAPTURE    => open,
      DRCK       => rdrck,
      reset      => open,
      SEL        => rsel,
      SHIFT      => rshift,
      TDI        => rtdi,
      UPDATE     => rupdate,
      TDO        => rtdo);



  --------------------------------------------------------------------------
  -- CONTROL INTERFACE
  --------------------------------------------------------------------------
  BSCAN_control_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE    => open,
      DRCK       => cdrck,
      reset      => open,
      SEL        => csel,
      SHIFT      => cshift,
      TDI        => ctdi,
      UPDATE     => cupdate,
      TDO        => ctdo);


  process(cdrck, cupdate)
    variable pos : integer range 0 to 143 := 0;
  begin
    if cupdate = '1' then
      pos                                 := 0;
      coutreg <= X"ABCD" & wrsreg & rdsreg & csreg(16) & csreg(14 downto 0)
                  & X"A" &  "000" & dones;
    else
      if rising_edge(cdrck) then
        csreg <= ctdi & csreg(39 downto 1);
        ctdo  <= coutreg(pos);
        pos                               := pos + 1;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if rising_edge(clk) then
      cupdatel <= cupdate;
      cupdatell <= cupdatel;
      csell <= csel; 

      if cupdatell = '0' and cupdatel = '1'
        and csell = '1' and
        csreg(24) = '1' then

        MEMRW    <= csreg(16);
        ROWTGT   <= csreg(14 downto 0);
        lmemstart <= '1';
      else
        lmemstart <= '0';
      end if;

      MEMSTART <= lmemstart;
      
      lmemdone <= MEMDONE;
      
      if MEMDONE = '1' and lmemdone = '0' then
        dones <= '1';
      else

        if cupdatell = '0' and cupdatel = '1'
          and csell = '1' and

                  -- query operation resets done bit
        
          csreg(24) = '0' and csreg(25) = '1' then
          dones <= '0';
        end if;
      end if;
    end if;
  end process;


  --------------------------------------------------------------------------
  -- READ INTERFACE
  --------------------------------------------------------------------------


  process(rdrck, rupdate)
    variable pos : integer range 0 to 63 := 0;

  begin
    if rupdate = '1' then
      pos   := 0;
    else
      if rising_edge(rdrck) then
        rdsreg <= rtdi & rdsreg(63 downto 1);
        rtdo   <= rddatain(pos);
        pos := pos + 1;
      end if;
    end if;
  end process;

  readclk : process (CLK)
  begin
    if rising_edge(CLK) then
      readstartl <= readstart;
      if readstart = '1' and readstartl = '0' then
        readaddr <= (others => '0');
      else
        readaddr <= readaddr + 1;
      end if;

      if readstart = '1' and readstartl = '0' then
        readwen   <= '1';
      else
        if readaddr = "111111111" then
          readwen <= '0';
        end if;
      end if;
    end if;

  end process;

  readdata <= RDWE & "0000000" & X"00" & RDADDR & X"00" & RDDATA;


  rdaddrin <= rdsreg(8 downto 0);

  readbuffer_inst : RAMB16_S36_S36
    generic map (
      INIT_00 => X"000000000000000000000000000000008877665544332211FEDCBA9876543210")
    port map (
      DOA     => rddatain(31 downto 0),  -- Port A 32-bit Data Output
      DOB     => open,                   -- Port B 32-bit Data Output
      ADDRA   => rdaddrin,               -- Port A 9-bit Address Input
      ADDRB   => readaddr,               -- Port B 9-bit Address Input
      CLKA    => rupdate,                -- Port A Clock
      CLKB    => CLK,                    -- Port B Clock
      DIA     => X"00000000",            -- Port A 32-bit Data Input
      DIB     => readdata(31 downto 0),  -- Port B 32-bit Data Input
      DIPA    => "0000",                 -- Port A 4-bit parity Input
      DIPB    => "0000",                 -- Port-B 4-bit parity Input
      ENA     => rsel,                   -- Port A RAM Enable Input
      ENB     => '1',                    -- PortB RAM Enable Input
      SSRA    => '0',                    -- Port A Synchronous Set/Reset Input
      SSRB    => '0',                    -- Port B Synchronous Set/Reset Input
      WEA     => '0',                    -- Port A Write Enable Input
      WEB     => readwen                 -- Port B Write Enable Input
      );

  readbuffer_inst_high : RAMB16_S36_S36
    generic map (
      INIT_00 => X"000000000000000000000000000000008877665544332211FEDCBA9876543210")
    port map (
      DOA     => rddatain(63 downto 32),  -- Port A 32-bit Data Output
      DOB     => open,                    -- Port B 32-bit Data Output
      ADDRA   => rdaddrin,                -- Port A 9-bit Address Input
      ADDRB   => readaddr,                -- Port B 9-bit Address Input
      CLKA    => rupdate,                 -- Port A Clock
      CLKB    => CLK,                     -- Port B Clock
      DIA     => X"00000000",             -- Port A 32-bit Data Input
      DIB     => readdata(63 downto 32),  -- Port B 32-bit Data Input
      DIPA    => "0000",                  -- Port A 4-bit parity Input
      DIPB    => "0000",                  -- Port-B 4-bit parity Input
      ENA     => rsel,                    -- Port A RAM Enable Input
      ENB     => '1',                     -- PortB RAM Enable Input
      SSRA    => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB    => '0',                     -- Port B Synchronous Set/Reset Input
      WEA     => '0',                     -- Port A Write Enable Input
      WEB     => readwen                  -- Port B Write Enable Input
      );



end Behavioral;
