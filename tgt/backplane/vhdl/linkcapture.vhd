library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;
use work.all;

entity linkcapture is
  generic (
    JTAG_CHAIN : integer := 4);
  port (
    CLK : in std_logic;
    GLOBALEN : in std_logic; 
    ECYCLE : in std_logic; 
    KIN : in std_logic;
    DIN : in std_logic_vector(7 downto 0)
    ); 
end linkcapture;

architecture Behavioral of linkcapture is

  signal inaddr  : std_logic_vector(9 downto 0)  := (others => '0');
  signal outaddr : std_logic_vector(63 downto 0) := (others => '0');

  signal bitcnt : integer range 0 to 63 := 0;

  signal otdi : std_logic := '0';

  signal odrck, osel, oshift, oupdate, otdo : std_logic := '0';

  signal dob : std_logic_vector(63 downto 0) := (others => '0');

  signal jtagbufdump_din  : std_logic_vector(15 downto 0) := (others => '0');
  signal jtagbufdump_dinen : std_logic := '0';
  
  signal jtagbufdump_out : std_logic_vector(17 downto 0) := (others => '0');

  signal jtagbufdump_readaddr : std_logic_vector(12 downto 0) := (others => '0');
  signal oupdatel, oupdatell  : std_logic                     := '0';

  signal sell, selll : std_logic := '0';

  signal nextbufen : std_logic := '0';

  signal nextbuf_int : std_logic := '0';

  signal received_k : std_logic := '0';
  
  component jtagbufdump16
    port (
      CLKA     : in  std_logic;
      DIN      : in  std_logic_vector(15 downto 0);
      DINEN    : in  std_logic;
      NEXTBUF  : in  std_logic;
      -- readout side
      CLKB     : in  std_logic;
      READADDR : in  std_logic_vector(12 downto 0);
      DOUT     : out std_logic_vector(17 downto 0)
      );
  end component;
  
begin  -- Beh

  jtagbufdump_inst : jtagbufdump16
    port map (
      CLKA     => CLK,
      DIN      => jtagbufdump_din,
      DINEN    => jtagbufdump_dinen,
      NEXTBUF  => nextbuf_int,
      CLKB     => CLK,
      READADDR => jtagbufdump_readaddr,
      DOUT     => jtagbufdump_out); 

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

  process(CLK)
  begin
    if rising_edge(CLK) then

      -- our default policy is, always capture, and then
      -- each ecycle, if we received ANY k bits on the pervious one,
      -- nextbuf it.

      if ECYCLE = '1' then
        received_k <= '0'; 
      else
        if KIN = '1' then
          received_k <= '1';
        end if;
      end if; 

      if ECYCLE = '1' and received_k = '1' and GLOBALEN = '1'  then
        nextbuf_int <= '1';
      else
        nextbuf_int <= '0'; 
      end if;

      jtagbufdump_din <= ECYCLE & "000" &
                         KIN & "000" &
                         DIN; 

      jtagbufdump_dinen <= '1';
      
      sell  <= osel;
      selll <= sell;

      oupdatel  <= oupdate;
      oupdatell <= oupdatel;

      if selll = '1' and oupdatell = '1' and oupdatel = '0' then
        jtagbufdump_readaddr <= outaddr(12 downto 0);
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

  dob(17 downto 0) <= jtagbufdump_out; 

  otdo <= dob(bitcnt);

  
end Behavioral;
