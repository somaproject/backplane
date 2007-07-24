library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity fiberdebug is
  generic (
    DEVICE  :     std_logic_vector(7 downto 0) := X"01"
    );
  port (
    CLK     : in  std_logic;
    TXCLK   : in  std_logic;
    RESET   : in  std_logic;
    -- Event bus interface
    ECYCLE  : in  std_logic;
    EARXA   : out std_logic_vector(somabackplane.N - 1 downto 0)
                                               := (others => '0');
    EDRXA   : out std_logic_vector(7 downto 0);
    EARXB   : out std_logic_vector(somabackplane.N - 1 downto 0)
                                               := (others => '0');
    EDRXB   : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N - 1 downto 0);
    EDTX    : in  std_logic_vector(7 downto 0);

    -- Fiber interfaces
    FIBERIN  : in  std_logic;
    FIBEROUT : out std_logic
    );

end fiberdebug;

architecture Behavioral of fiberdebug is


  component fiberdebugtx
    generic (
      DEVICE   :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK      : in  std_logic;
      TXCLK    : in  std_logic;
      RESET    : in  std_logic;
      -- Event bus interface
      ECYCLE   : in  std_logic;
      EATX     : in  std_logic_vector(somabackplane.N - 1 downto 0);
      EDTX     : in  std_logic_vector(7 downto 0);
      -- Fiber interfaces
      FIBEROUT : out std_logic
      );
  end component;



  component fiberdebugrx
    generic (
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      -- Event bus interface
      ECYCLE  : in  std_logic;
      EARXA   : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRXA   : out std_logic_vector(7 downto 0);
      EARXB   : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRXB   : out std_logic_vector(7 downto 0);
      EDSELRX : in std_logic_vector(3 downto 0);
      -- Fiber interfaces
      FIBERIN : in std_logic
      );

  end component;

begin  -- Behavioral

  fiberdebugtx_inst : fiberdebugtx
    generic map (
      DEVICE   => DEVICE)
    port map (
      CLK      => CLK,
      TXCLK    => TXCLK,
      RESET    => RESET,
      ECYCLE   => ECYCLE,
      EATX     => EATX,
      EDTX     => EDTX,
      FIBEROUT => FIBEROUT);

  fiberdebugrx_inst: fiberdebugrx
    generic map (
      DEVICE => DEVICE)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      ECYCLE  => ECYCLE,
      EARXA   => EARXA,
      EDRXA   => EDRXA,
      EARXB   => EARXB,
      EDRXB   => EDRXB,
      EDSELRX => EDSELRX,
      FIBERIN => FIBERIN); 
    



end Behavioral;
