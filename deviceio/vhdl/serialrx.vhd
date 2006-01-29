-------------------------------------------------------------------------------
-- Title      : serialize
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serialrx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/27
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Recover and pass on 8b/10b data
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/27  1.0      jonas   Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity serialrx is
  port ( RXCLK     : in  std_logic;
         RXCLK90   : in  std_logic;
         RXBYTECLK : in  std_logic;
         RESET     : in  std_logic;
         DIN       : in  std_logic;
         DOUT      : out std_logic_vector(7 downto 0);
         KOUT      : out std_logic;
         ERR       : out std_logic;
         DOEN      : out std_logic
         );

end serialrx;

architecture Behavioral of serialrx is

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

  component decode8b10b
    port (
      clk      : in  std_logic;
      din      : in  std_logic_vector(9 downto 0);
      dout     : out std_logic_vector(7 downto 0);
      kout     : out std_logic;
      ce       : in  std_logic;
      code_err : out std_logic;
      disp_err : out std_logic);
  end component;

  signal sampledbits        : std_logic_vector(3 downto 0) := (others => '0');
  signal selbit, oe         : std_logic                    := '0';
  signal decdoenin          : std_logic                    := '0';
  signal decdin             : std_logic_vector(9 downto 0);
  signal code_err, disp_err : std_logic                    := '0';



begin  -- Behavioral

  sampler : sample
    port map (
      CLK   => RXCLK,
      CLK90 => RXCLK90,
      DIN   => DIN,
      DOUT  => sampledbits);

  datamuxer : datamux
    port map (
      CLK  => RXCLK,
      BIN  => sampledbits,
      DOEN => oe,
      DOUT => selbit);

  dlocker : dlock
    port map (
      RXCLK     => RXCLK,
      RXBYTECLK => RXBYTECLK,
      RESET     => RESET,
      DEN       => oe,
      DIN       => selbit,
      DOUT      => decdin,
      DOEN      => decdoenin);

  decoder : decode8b10b
    port map (
      CLK      => RXBYTECLK,
      DIN      => decdin,
      DOUT     => DOUT,
      KOUT     => KOUT,
      CE       => decdoenin,
      CODE_ERR => code_err,
      DISP_ERR => disp_err);

  ERR <= code_err or disp_err;

  -- OE 
  process(RXBYTECLK)
  begin
    if rising_edge(RXBYTECLK) then
      DOEN <= decdoenin;                -- one cycle latency
    end if;
  end process;
  
end Behavioral;
