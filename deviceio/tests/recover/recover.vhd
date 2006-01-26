library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity recover is
  port ( CLKIN  : in  std_logic;
         RESET  : in  std_logic;
         DIN    : in  std_logic;
         DOUT   : out std_logic;
         DOEN : out std_logic;
         RXCLKOUT : out std_logic
         );

end recover;

architecture Behavioral of recover is
-- this is a simple attempt to impelmenet the data recovery engine and test if
-- it can meet timing constraints

  signal clk, txclk, rxclk, rxclkfb, rxclk90, rxclk90fb : std_logic := '0';

  signal samps : std_logic_vector(3 downto 0) := (others => '0');
  signal ldout, ldoen : std_logic := '0';

  
  
  component sample is
  port ( CLK   : in  std_logic;
         CLK90 : in  std_logic;
         DIN   : in  std_logic;
         DOUT  : out std_logic_vector(3 downto 0)
         );

end component;

component datamux is
  port ( CLK  : in  std_logic;
         BIN  : in  std_logic_vector(3 downto 0);
         DOEN : out std_logic;
         DOUT : out std_logic
         );

end component; 


begin

  RXCLKOUT <= rxclk;
  
  bigclk : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLK_FEEDBACK       => "2X",
    CLKFX_MULTIPLY     => 31,
    CLKFX_DIVIDE       => 16,
    CLKIN_PERIOD       => 10.0,
    DFS_FREQUENCY_MODE => "HIGH")
    port map (
      CLKIN            => CLKIN,
      CLKFB            => rxclk,
      RST              => RESET,
      PSEN             => '0',
      CLK2X            => rxclkfb,
      clkfx            => txclk);

  txphaseclk : dcm generic map (
    DLL_FREQUENCY_MODE => "LOW",
    CLK_FEEDBACK       => "2X",
    CLKIN_PERIOD       => 10.0,
    CLKOUT_PHASE_SHIFT => "FIXED", 
    PHASE_SHIFT => 32)
    port map (
      CLKIN            => CLKIN,
      CLKFB            => rxclk90,
      RST              => RESET,
      PSEN             => '0',
      CLK2X            => rxclk90fb);

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

    
  bufg_2inst : BUFG port map (
    O => rxclk,
    I => rxclkfb);

  bufg_3inst : BUFG port map (
    O => rxclk90,
    I => rxclk90fb);

  process (RXCLK)
    begin
    if rising_edge(RXCLK) then
      DOUT <= ldout;
      DOEN <= ldoen; 
    end if;

    end process; 
    
end Behavioral;
