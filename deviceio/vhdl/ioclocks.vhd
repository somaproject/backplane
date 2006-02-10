library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ioclocks is
  port ( CLKIN    : in  std_logic;
         RESET    : in  std_logic;
         TXCLK : out std_logic;
         TXBYTECLK: out std_logic;
         RXCLK : out std_logic;
         RXBYTECLK : out std_logic;
         RXCLK90: out std_logic;
         LOCKED : out std_logic
         );

end ioclocks;

architecture Behavioral of ioclocks is

  signal txclkint, txclkfb,
    rxclkdiv2int, rxclkdiv2,
    rxclkint, rxclkfb,
    rxclkdiv2fb, rxbyteclkn,
    rxbyteclknfb, rxclk90int, rxclk90fb : std_logic := '0';

  signal rxclkdiv2inta : std_logic := '0';
  
  signal txclklocked, txclknotlocked, txclkmullocked, txclkmulnotlocked : std_logic := '0';
  
  signal rsttick : std_logic_vector(7 downto 0) := (others => '1');

  signal rxclklocked, rxclk90locked : std_logic := '0';

  
begin


  txclkdcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
  --  CLK_FEEDBACK       => "2X",
    CLKIN_PERIOD       => 8.0,
    CLKDV_DIVIDE       => 5.0,
    CLKFX_DIVIDE       => 30,
    CLKFX_MULTIPLY     => 29)
    port map (
      CLKIN            => CLKIN,
      CLKFB            => txclkint,
      RST              => RESET,
      PSEN             => '0',
      CLK0            => txclkfb,
      CLKDV            => TXBYTECLK,
      CLKFX            => rxclkdiv2inta,
      LOCKED => txclklocked);

  txclknotlocked <= not txclklocked; 
  txclk_bufg : BUFG port map (
    O => txclkint,
    I => txclkfb);

  TXCLK <= txclkint;


  txclkmuldcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
  --  CLK_FEEDBACK       => "2X",
    CLKIN_PERIOD       => 8.0,
    --CLKDV_DIVIDE       => 5.0,
    CLK_FEEDBACK => "NONE", 
    CLKFX_DIVIDE       => 14,
    CLKFX_MULTIPLY     => 15)
    port map (
      CLKIN            => rxclkdiv2inta,
      --CLKFB            => txclkint,
      RST              => rsttick(5),
      PSEN             => '0',
      --CLK0            => ,
      --CLKDV            => TXBYTECLK,
      CLKFX            => rxclkdiv2int,
      LOCKED => txclkmullocked);

  txclknotlocked <= not txclklocked;
  txclkmulnotlocked <= not txclkmullocked;
  
  rxclkdiv2_bufg : BUFG port map (
    O => rxclkdiv2,
    I => rxclkdiv2int);

  rxclkdcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLKIN_PERIOD       => 8.0,
    CLKOUT_PHASE_SHIFT => "NONE",
--    CLK_FEEDBACK       => "2x",
    CLKDV_DIVIDE       => 5.0
    --PHASE_SHIFT        => 0
    ) port map (
      CLKIN            => rxclkdiv2,
      CLKFB            => rxclkint,
      RST              => txclkmulnotlocked,
      PSEN             => '0',
      CLK0            => rxclkfb,
      CLKDV            => RXBYTECLK,
      LOCKED => rxclklocked);


  rxclk_bufg : BUFG port map (
    O => rxclkint,
    I => rxclkfb);

  RXCLK <= rxclkint;
  
  rxclk90dcm : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLKIN_PERIOD       => 8.0,
    CLKOUT_PHASE_SHIFT => "FIXED",
    PHASE_SHIFT        => 64)
    port map (
      CLKIN            => rxclkdiv2,
      CLKFB            => rxclk90int,
      RST              => txclkmulnotlocked, 
      PSEN             => '0',
      CLK0            => rxclk90fb,
      LOCKED => rxclk90locked);

  LOCKED <=  rxclklocked and rxclk90locked;
  
  rxclk90_bufg : BUFG port map (
    O => rxclk90int,
    I => rxclk90fb);

  -- delay
  process(txclkint)
    begin
      if rising_edge(txclkint) then
        rsttick(7) <= rsttick(6);
        rsttick(6) <= rsttick(5);
        rsttick(5) <= rsttick(4);
        rsttick(4) <= rsttick(3);
        rsttick(3) <= rsttick(2);
        rsttick(2) <= rsttick(1);
        rsttick(1) <= rsttick(0);
        rsttick(0) <= txclknotlocked;
        
        
      end if;

    end process; 
  RXCLK90 <= rxclk90int; 



end Behavioral;
