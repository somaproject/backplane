
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity serialize is

  port (
    CLKA   : in  std_logic;
    CLKB   : in  std_logic;
    RESET  : in  std_logic;
    BITCLK : in  std_logic;
    DIN    : in  std_logic_vector(9 downto 0);
    DOUT   : out std_logic;
    STOPTX : in  std_logic
    );

end serialize;


architecture Behavioral of serialize is

  signal dinl  : std_logic_vector(9 downto 0)  := (others => '0');
  signal dword, dwordl : std_logic_vector(49 downto 0) := (others => '0');
  signal ibcnt : integer range 0 to 4          := 0;
  signal obcnt : integer range 0 to 5          := 0;

  signal do    : std_logic_vector(49 downto 0) := (others => '0');
  signal serin, serinl : std_logic_vector(9 downto 0)  := (others => '0');

  signal seren : std_logic := '1';

  signal s1, s2 : std_logic := '0';

begin  -- Behavioral

  Oserdes_1 : OSERDES
    generic map (
      DATA_RATE_OQ => "DDR",
      DATA_RATE_TQ => "DDR", 
      DATA_WIDTH   => 10,
      TRISTATE_WIDTH => 2, 
      SERDES_MODE  => "MASTER")
    port map (
      OQ           => DOUT, 
      D1           => SERINl(0),
      D2           => SERINl(1),
      D3           => SERINl(2),
      D4           => SERINl(3),
      D5           => SERINl(4),
      D6           => SERINl(5),
      SHIFTIN1     => s1,
      SHIFTIN2     => s2,
      CLK          => BITCLK,
      CLKDIV       => CLKB,
      REV          => '0',
      SHIFTOUT1    => open,
      SHIFTOUT2    => open,
      OCE          => seren,
      TCE          => '0',
      T1           => '0',
      T2           => '0',
      T3           => '0',
      T4           => '0',
      SR           => RESET);

  Oserdes_2 : OSERDES
    generic map (
      DATA_RATE_OQ => "DDR",
      DATA_RATE_TQ => "DDR", 
      DATA_WIDTH   => 10,
      TRISTATE_WIDTH => 2, 
      SERDES_MODE  => "SLAVE")
    port map (
      --OQ           => op,
      D1           => '0',
      D2           => '0',
      D3           => SERINl(6),
      D4           => SERINl(7),
      D5           => SERINl(8),
      D6           => SERINl(9),
      SHIFTOUT1    => s1,
      SHIFTOUT2    => s2,

      CLK      => BITCLK,
      CLKDIV   => CLKB,
      REV      => '0',
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      OCE      => seren,
      TCE      => '0',
      T1       => '0',
      T2       => '0',
      T3       => '0',
      T4       => '0',
      SR       => RESET);

  seren <= not STOPTX;

  inputclk : process(CLKA)
  begin
    if rising_edge(CLKA) then

      dinl <= DIN;

      if ibcnt = 4 then
        ibcnt <= 0;
      else
        ibcnt <= ibcnt + 1;
      end if;

      if ibcnt = 0 then
        dword(9 downto 0)   <= dinl;
      end if;
      if ibcnt = 1 then
        dword(19 downto 10) <= dinl;
      end if;
      if ibcnt = 2 then
        dword(29 downto 20) <= dinl;
      end if;
      if ibcnt = 3 then
        dword(39 downto 30) <= dinl;
      end if;
      if ibcnt = 4 then
        dword(49 downto 40) <= dinl;
      end if;

      if ibcnt = 0 then
        dwordl <= dword;
      end if;
    end if;
  end process inputclk;


   serin <= do(8 downto 0) & '1'                            when obcnt = 0 else
            do(16 downto 10) & '1' & '0' & do(9)            when obcnt = 1 else
            do(24 downto 20) & '1' & '0' & do(19 downto 17) when obcnt = 2 else
            do(32 downto 30) & '1' & '0' & do(29 downto 25) when obcnt = 3 else
            do(40) & '1' & '0' & do(39 downto 33)           when obcnt = 4 else
            '0' & do(49 downto 41);

  
  outputclk : process(CLKB)
  begin
    if rising_edge(CLKB) then
      serinl <= serin; 
      if obcnt = 5 then
        obcnt <= 0;
      else
        obcnt <= obcnt + 1;
      end if;

      if obcnt = 5 then
        do <= dwordl;
      end if;

    end if;
  end process outputclk;
end Behavioral;
