library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity devicemux is
  port (
    CLK  : in std_logic;
    ECYCLE : in std_logic;
    -- port A
    DOUTA : out std_logic_vector(7 downto 0);
    DOENA : out std_logic; 
    DGRANTA : in std_logic;
    EARXA : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXA : out std_logic_vector(7 downto 0);
    EDSELRXA : in std_logic_vector(3 downto 0);
    EATXA   : in std_logic_vector(somabackplane.N-1 downto 0);
    EDTXA   : in std_logic_vector(7 downto 0);
    -- port B
    DOUTB : out std_logic_vector(7 downto 0);
    DOENB : out std_logic; 
    DGRANTB : in std_logic;
    EARXB : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXB : out std_logic_vector(7 downto 0);
    EDSELRXB : in std_logic_vector(3 downto 0);
    EATXB   : in std_logic_vector(somabackplane.N-1 downto 0);
    EDTXB   : in std_logic_vector(7 downto 0);
    -- port C
    DOUTC : out std_logic_vector(7 downto 0);
    DOENC : out std_logic; 
    DGRANTC : in std_logic;
    EARXC : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXC : out std_logic_vector(7 downto 0);
    EDSELRXC : in std_logic_vector(3 downto 0);
    EATXC   : in std_logic_vector(somabackplane.N-1 downto 0);
    EDTXC   : in std_logic_vector(7 downto 0);
    -- port D
    DOUTD : out std_logic_vector(7 downto 0);
    DOEND : out std_logic; 
    DGRANTD : in std_logic;
    EARXD : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXD : out std_logic_vector(7 downto 0);
    EDSELRXD : in std_logic_vector(3 downto 0);
    EATXD   : in std_logic_vector(somabackplane.N-1 downto 0);
    EDTXD   : in std_logic_vector(7 downto 0);
    -- IO 
    TXDOUT : out std_logic_vector(7 downto 0);
    TXKOUT : out std_logic;
    RXDIN : in std_logic_vector(7 downto 0);
    RXKIN : in std_logic;
    LOCKED : in std_logic );
end devicemux;

architecture Behavioral of devicemux is

begin

  tx_inst: entity devicemuxtx
    port map (
      CLK     => CLK,
      EDTX    => EDTXA,
      ECYCLE => ECYCLE, 
      DGRANTA => DGRANTA,
      EATXA   => EATXA,
      DGRANTB => DGRANTB,
      EATXB   => EATXB,
      DGRANTC => DGRANTC,
      EATXC   => EATXC,
      DGRANTD => DGRANTD,
      EATXD   => EATXD,
      TXDOUT  => TXDOUT,
      TXKOUT  => TXKOUT);

  rx_inst: entity devicemuxrx
    port map (
      CLK => CLK,
      ECYCLE => ECYCLE,
      LOCKED => LOCKED,

      DOUTA => DOUTA,
      DOENA => DOENA,
      EARXA => EARXA,
      EDRXA => EDRXA,
      EDSELRXA => EDSELRXA,
      
      DOUTB => DOUTB,
      DOENB => DOENB,
      EARXB => EARXB,
      EDRXB => EDRXB,
      EDSELRXB => EDSELRXB,
      
      DOUTC => DOUTC,
      DOENC => DOENC,
      EARXC => EARXC,
      EDRXC => EDRXC,
      EDSELRXC => EDSELRXC,
      
      DOUTD => DOUTD,
      DOEND => DOEND,
      EARXD => EARXD,
      EDRXD => EDRXD,
      EDSELRXD => EDSELRXD,

      RXDIN => RXDIN,
      RXKIN => RXKIN);
  
end Behavioral;
