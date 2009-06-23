library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;
use work.all;

entity dincapture is
  generic (
    JTAG_CHAIN : integer := 4);
  port (
    CLK     : in std_logic;
    DINEN   : in std_logic;
    DIN     : in std_logic_vector(31 downto 0);
    IMMDIN : in std_logic_vector(31 downto 0) ;  -- current value just gets
                                                 -- passed through
                                                 --
    IMMDOUT : out std_logic_vector(31 downto 0);  -- immediate value gets
                                                  -- passed out
    NEXTBUF : in std_logic
    ); 
end dincapture;

architecture Behavioral of dincapture is

  signal inaddr  : std_logic_vector(9 downto 0)  := (others => '0');
  signal outaddr : std_logic_vector(63 downto 0) := (others => '0');

  signal bitcnt : integer range 0 to 63 := 0;

  signal otdi : std_logic := '0';

  signal odrck, osel, oshift, oupdate, otdo : std_logic := '0';

  signal dob : std_logic_vector(63 downto 0) := (others => '0');

  component jtagbufdump
    port (
      CLKA     : in  std_logic;
      DIN      : in  std_logic_vector(31 downto 0);
      DINEN    : in  std_logic;
      NEXTBUF  : in  std_logic;
      -- readout side
      CLKB     : in  std_logic;
      READADDR : in  std_logic_vector(11 downto 0);
      DOUT     : out std_logic_vector(31 downto 0)
      );
  end component;

  signal readaddr            : std_logic_vector(11 downto 0) := (others => '0');
  signal oupdatel, oupdatell : std_logic                     := '0';

  signal sell, selll : std_logic := '0';

  signal nextbufen : std_logic := '0';

  signal nextbuf_int : std_logic := '0';
  
begin  -- Beh

  jtagbufdump_inst : jtagbufdump
    port map (
      CLKA     => CLK,
      DIN      => DIN,
      DINEN    => DINEN,
      NEXTBUF  => nextbuf_int,
      CLKB     => CLK,
      READADDR => readaddr,
      DOUT     => dob(31 downto 0));

  BSCAN_OUT_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => JTAG_CHAIN)
    port map (
      CAPTURE => open,
      DRCK    => odrck,
      reset   => open,
      SEL     => osel,
      SHIFT   => oshift,
      TDI     => otdi,
      UPDATE  => oupdate,
      TDO     => otdo);

  nextbuf_int <= nextbufen and NEXTBUF;
  
  process(CLK)
  begin
    if rising_edge(CLK) then
      sell  <= osel;
      selll <= sell;

      oupdatel  <= oupdate;
      oupdatell <= oupdatel;

      if selll = '1' and oupdatell = '1' and oupdatel = '0' then
        readaddr <= outaddr(11 downto 0);
        if outaddr(31) = '1'  then
          nextbufen <= '1'; 
        end if;
        IMMDOUT <= outaddr(63 downto 32); 
      end if;

    end if;

  end process;

  -- output jtag proces
  jtagin : process(ODRCK, OUPDATE)
  begin
    if OUPDATE = '1' then
      bitcnt <= 0;
    else
      if rising_edge(ODRCK) then
        if osel = '1' and oshift = '1' then
          bitcnt  <= bitcnt + 1;
          outaddr <= otdi & outaddr(63 downto 1);
        end if;
      end if;
    end if;
  end process jtagin;

  dob(63 downto 32) <= IMMDIN;
  
  otdo <= dob(bitcnt);

  
end Behavioral;
