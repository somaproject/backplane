library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity jtagmemif is
  port (
    CLK      : in  std_logic;
    MEMSTART : out std_logic;
    MEMRW    : out std_logic;
    MEMDONE  : in  std_logic;
    ROWTGT   : out std_logic_vector(14 downto 0);
    WRADDR   : in  std_logic_vector(7 downto 0);
    WRDATA   : out std_logic_vector(31 downto 0);
    RDADDR   : in  std_logic_vector(7 downto 0);
    RDDATA   : in  std_logic_vector(31 downto 0);
    RDWE     : in  std_logic );
end jtagmemif;

architecture Behavioral of jtagmemif is

  signal wdrck, wsel, wshift, wupdate, wtdo, wtdi : std_logic := '0';

  signal wrsreg   : std_logic_vector(39 downto 0) := (others => '0');
  signal wraddrin : std_logic_vector(8 downto 0)  := (others => '0');
  signal wraddrf  : std_logic_vector(8 downto 0)  := (others => '0');

  signal lwrdata : std_logic_vector(31 downto 0) := (others => '0');

  signal wrdatain : std_logic_vector(31 downto 0) := (others => '0');

  signal rdrck, rsel, rshift, rupdate, rtdo, rtdi : std_logic := '0';

  signal rdsreg   : std_logic_vector(39 downto 0) := (others => '0');
  signal rdaddrin : std_logic_vector(8 downto 0)  := (others => '0');
  signal rddatain : std_logic_vector(31 downto 0) := (others => '0');

  signal rdaddrf : std_logic_vector(8 downto 0) := (others => '0');

  signal cdrck, csel, cshift, cupdate, cupdatel,
    ctdo, ctdi : std_logic := '0';

  signal csreg : std_logic_vector(39 downto 0) := (others => '0');



begin  -- Behavioral

  -- input write


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
      WRDATA          <= lWRDATA;
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


  process(rdrck, rupdate)
    variable pos : integer range 0 to 39 := 0;

  begin
    if rupdate = '1' then
      pos   := 0;
    else
      if rising_edge(rdrck) then
        rdsreg <= rtdi & rdsreg(39 downto 1);
        rtdo   <= rddatain(pos);
        pos := pos + 1;
      end if;
    end if;
  end process;

  rdaddrin <= rdsreg(8 downto 0);

  rdaddrf(7 downto 0) <= RDADDR;
  readbuffer_inst : RAMB16_S36_S36
    generic map (
      INIT_00 => X"000000000000000000000000000000008877665544332211FEDCBA9876543210")
    port map (
      DOA     => rddatain(31 downto 0),  -- Port A 32-bit Data Output
      DOB     => open,                   -- Port B 32-bit Data Output
      ADDRA   => rdaddrin,               -- Port A 9-bit Address Input
      ADDRB   => RDADDRf,                -- Port B 9-bit Address Input
      CLKA    => rupdate,                -- Port A Clock
      CLKB    => CLK,                    -- Port B Clock
      DIA     => X"00000000",            -- Port A 32-bit Data Input
      DIB     => RDDATA,                 -- Port B 32-bit Data Input
      DIPA    => "0000",                 -- Port A 4-bit parity Input
      DIPB    => "0000",                 -- Port-B 4-bit parity Input
      ENA     => rsel,                   -- Port A RAM Enable Input
      ENB     => '1',                    -- PortB RAM Enable Input
      SSRA    => '0',                    -- Port A Synchronous Set/Reset Input
      SSRB    => '0',                    -- Port B Synchronous Set/Reset Input
      WEA     => '0',                    -- Port A Write Enable Input
      WEB     => RDWE                    -- Port B Write Enable Input
      );


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


  process(cdrck)

  begin
      if rising_edge(cdrck) then
        csreg <= ctdi & csreg(39 downto 1);
    end if;
  end process;

  process(CLK)
  begin
    if rising_edge(clk) then
      cupdatel <= cupdate;
      
      if cupdatel = '0' and cupdate = '1' and csel = '1' then

        MEMRW    <= csreg(16);
        ROWTGT   <= csreg(14 downto 0);
        MEMSTART <= '1';
      else
        MEMSTART <= '0';
      end if;
    end if;
  end process;


end Behavioral;
