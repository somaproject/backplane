library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity linktest is
  port ( CLKIN    : in  std_logic;
         RESET    : in  std_logic;
         DIN      : in  std_logic;
         DOUT     : out std_logic_vector(9 downto 0);
         DOEN     : out std_logic;
         RXCLKOUT : out std_logic
         );

end linktest;

architecture Behavioral of linktest is
-- this is a simple attempt to impelmenet the data linktesty engine and test if
-- it can meet timing constraints

  signal clk, txclk, txclkfb, rxclk, rxclkn, rxclknfb, rxclk90, rxclk90n, rxclk90nfb, rxbyteclk, rxclkin, rxclkdiv2, rxclkdiv2in, rxclkfb, rxclkdiv2fb, rxbyteclkn, rxbyteclknfb, rxclk90fb, txbyteclk : std_logic := '0';

  signal samps        : std_logic_vector(3 downto 0) := (others => '0');
  signal ldout, ldoen : std_logic                    := '0';



  component sample
    port ( CLK   : in  std_logic;
           CLK90 : in  std_logic;
           DIN   : in  std_logic;
           DOUT  : out std_logic_vector(3 downto 0)
           );

  end component;

  component datamux
    port ( CLK  : in  std_logic;
           BIN  : in  std_logic_vector(3 downto 0);
           DOEN : out std_logic;
           DOUT : out std_logic
           );

  end component;

  component dlock
    port ( RXCLK     : in  std_logic;
           RXBYTECLK : in  std_logic;
           RESET     : in  std_logic;
           DEN       : in  std_logic;
           DIN       : in  std_logic;
           DOUT      : out std_logic_vector(9 downto 0);
           DOEN      : out std_logic
           );

  end component;


begin

  RXCLKOUT <= rxclk;

  txclkdcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLK_FEEDBACK       => "2X",
    CLKIN_PERIOD       => 8.0,
    CLKDV_DIVIDE       => 5.0,
    CLKFX_DIVIDE       => 31,
    CLKFX_MULTIPLY     => 32)
    port map (
      CLKIN            => CLKIN,
      CLKFB            => txclk,
      RST              => RESET,
      PSEN             => '0',
      CLK2X            => txclkfb,
      CLKDV            => txbyteclk,
      CLKFX            => rxclkdiv2in);

  bufg_1inst : BUFG port map (
    O => txclk,
    I => txclkfb);

  bufg_6inst : BUFG port map (
    O => rxclkdiv2,
    I => rxclkdiv2in);




  rxclkdcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLKIN_PERIOD       => 8.0,
    CLKOUT_PHASE_SHIFT => "NONE",
    CLK_FEEDBACK       => "2x",
    CLKDV_DIVIDE       => 5.0
    --PHASE_SHIFT        => 0
    ) port map (
      CLKIN            => rxclkdiv2,
      CLKFB            => rxclk,
      RST              => RESET,
      PSEN             => '0',
      CLK2x            => rxclkfb,
      CLKFX            => rxclkin,
      CLKDV            => rxbyteclk);


  bufg_4inst : BUFG port map (
    O => rxclk,
    I => rxclkfb);

  rxclk90dcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLKIN_PERIOD       => 8.0,
    CLKOUT_PHASE_SHIFT => "FIXED",
    PHASE_SHIFT        => 32)
    port map (
      CLKIN            => rxclkdiv2,
      CLKFB            => rxclk90,
      RST              => RESET,
      PSEN             => '0',
      CLK2x            => rxclk90fb);

  bufg_3inst : BUFG port map (
    O => rxclk90,
    I => rxclk90fb);



  samp : sample port map (
    CLK   => rxclk,
    CLK90 => rxclk90,
    DIN   => DIN,
    DOUT  => samps);

  dmux : datamux port map (
    CLK  => rxclk,
    bin  => samps,
    DOEN => ldoen,
    DOUT => ldout);

  dl : dlock port map (
    RXCLK     => rxclk,
    RXBYTECLK => rxbyteclk,
    RESET     => RESET,
    DIN       => ldout,
    DEN       => ldoen,
    DOUT      => DOUT,
    DOEN      => DOEN);


  process (RXCLK)
  begin
    if rising_edge(RXCLK) then
      --DOUT <= ldout;
      --DOEN <= ldoen;
    end if;

  end process;

end Behavioral;
