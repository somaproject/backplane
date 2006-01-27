-------------------------------------------------------------------------------
-- Title      : serialize
-- Project    : 
-------------------------------------------------------------------------------
-- File       : serialtx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/27
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Transmission of 8b/10b data
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

entity serialtx is
  port ( TXBYTECLK : in  std_logic;
         TXCLK     : in  std_logic;
         DIN       : in  std_logic_vector(7 downto 0);
         K         : in  std_logic;
         DOUT      : out std_logic
         );

end serialtx;

architecture Behavioral of serialtx is

  component serialize
    port ( TXBYTECLK : in  std_logic;
           TXCLK     : in  std_logic;
           DIN       : in  std_logic_vector(9 downto 0);
           DOUT      : out std_logic
           );

  end component;

  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0));
  end component;

  signal sout : std_logic_vector(9 downto 0) := (others => '0');

begin  -- Behavioral

  encoder : encode8b10b
    port map (
      DIN  => DIN,
      kin  => K,
      CLK  => TXBYTECLK,
      DOUT => sout);

  serializer : serialize
    port map (
      TXBYTECLK => TXBYTECLK,
      TXCLK     => TXCLK,
      DIN       => sout,
      DOUT => DOUT); 

end Behavioral;
