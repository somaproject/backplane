library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity fiberdebugtest is

end fiberdebugtest;

architecture Behavioral of fiberdebugtest is

  component fiberdebug
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

  end component;


  signal CLK     : std_logic                    := '0';
  signal TXCLK   : std_logic                    := '0';
  signal RESET   : std_logic                    := '1';
  -- Event bus interface
  signal ECYCLE  : std_logic                    := '0';
  signal EARXA   : std_logic_vector(somabackplane.N - 1 downto 0)
                                                := (others => '0');
  signal EDRXA   : std_logic_vector(7 downto 0) := (others => '0');
  signal EARXB   : std_logic_vector(somabackplane.N - 1 downto 0)
                                                := (others => '0');
  signal EDRXB   : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                := (others => '0');
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');

  -- Fiber interfaces
  signal FIBERIN  : std_logic := '0';
  signal FIBEROUT : std_logic := '0';


begin  -- Behavioral

  CLK   <= not CLK   after 10 ns;
  TXCLK <= not TXCLK after 6.25 ns;

  RESET <= '0' after 100 ns;

  fiberdebug_uut: fiberdebug
    generic map (
      DEVICE => X"01")
    port map (
      CLK      => CLK,
      TXCLK    => TXCLK,
      RESET    => RESET,
      ECYCLE   => ECYCLE,
      EARXA    => EARXA,
      EDRXA    => EDRXA,
      EARXB    => EARXB,
      EDRXB    => EDRXB,
      EDSELRX  => EDSELRX,
      EATX     => EATX,
      EDTX     => EDTX,
      FIBERIN  => FIBERIN,
      FIBEROUT => FIBEROUT);
    
end Behavioral;
