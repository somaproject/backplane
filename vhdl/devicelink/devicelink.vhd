
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity devicelink is

  port (
    CLK       : in  std_logic;
    RXBITCLK  : in  std_logic;
    TXHBITCLK : in  std_logic;
    TXDIN     : in  std_logic_vector(7 downto 0);
    TXKIN     : in  std_logic;
    TXIO_P    : out std_logic;
    TXIO_N    : out std_logic;

    RXIO_P : in  std_logic;
    RXIO_N : in  std_logic;
    RXDOUT : out std_logic_vector(7 downto 0);
    RXKOUT : out std_logic
    );

end devicelink;


architecture Behavioral of devicelink is
  component deserialize

    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      CLKBIT  : in  std_logic;
      DIN     : in  std_logic;
      DOUT    : out std_logic_vector(9 downto 0);
      DLYRST  : in  std_logic;
      DLYCE   : in  std_logic;
      DLYINC  : in  std_logic;
      BITSLIP : in  std_logic);

  end component;

component encode8b10b 
	port (
	din: IN std_logic_VECTOR(7 downto 0);
	kin: IN std_logic;
	clk: IN std_logic;
	dout: OUT std_logic_VECTOR(9 downto 0));
END component;


component decode8b10b 
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(9 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	kout: OUT std_logic;
	code_err: OUT std_logic;
	disp_err: OUT std_logic);
END component;

  signal dframe     : std_logic_vector(9 downto 0) := (others => '0');
  signal oframe, ol : std_logic_vector(9 downto 0) := (others => '0');

  signal omux : integer range 0 to 2 := 0;

  signal dcntrst : std_logic                := '0';
  signal dcnt    : integer range 0 to 65535 := 0;

  signal rxio : std_logic := '0';

  signal rxword   : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordl  : std_logic_vector(9 downto 0) := (others => '0');
  signal rxwordll : std_logic_vector(9 downto 0) := (others => '0');


  signal dlyrst  : std_logic := '0';
  signal dlyce   : std_logic := '0';
  signal dlyinc  : std_logic := '0';
  signal bitslip : std_logic := '0';

  signal lrxkout : std_logic                    := '0';
  signal lrxdout : std_logic_vector(7 downto 0) := (others => '0');

  signal cerr, derr : std_logic := '0';

  signal llocked : std_logic := '0';

  signal sout : std_logic_vector(9 downto 0) := (others => '0');

  signal txio : std_logic := '0';




begin  -- Behavioral


  deser_inst: deserialize
    port map (
      CLK => CLK,
      RESET => RESET,
      CLKBIT => RXBITCLK,
      DIN => rxio,
      DOUt => rxword,
      DLYRST => DLYRST,
      DLYCE => DLYCE,
      DLYINC => DLYINC,
      BITSLIP => BITSLIP);

  encoder: encode8b10b
    port map (
      DIN  => TXDIN,
      KIN  => TXKIN,
      DOUT => dframe(8 downto 1),
      CLK  => CLK);

  decoder : decode8b10b
    port map (
      CLK      => CLK,
      DIN      => rxword,
      DOUT     => lrxdout,
      KOUT     => lrxkout,
      CODE_ERR => cerr,
      DISP_ERR => derr);


  
end Behavioral;

