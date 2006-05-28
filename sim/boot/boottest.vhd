library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity boottest is

end boottest;

architecture Behavioral of boottest is


  component boot

    generic (
      M       :     integer                      := 20;
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SDOUT   : out std_logic;
      SDIN    : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic;
      SEROUT  : out std_logic_vector(M-1 downto 0));

  end component;

  constant M : integer := 20;

  signal CLK   : std_logic                    := '0';
  signal RESET : std_logic                    := '0';
  signal EDTX  : std_logic_vector(7 downto 0) := (others => '0');

  signal EATX    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal ECYCLE  : std_logic                                     := '0';
  signal EARX    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                                 := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0)
                                                                 := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)
                                                                 := (others => '0');

  signal SDIN  : std_logic := '0';
  signal SDOUT : std_logic := '0';
  signal SCLK  : std_logic := '0';
  signal SCS   : std_logic := '0';

  signal SEROUT : std_logic_vector(M-1 downto 0) := (others => '0');


  signal epos : integer range 0 to 999 := 950;

  component mmc
    port (
      RESET : in  std_logic;
      SCLK  : in  std_logic;
      SDIN  : in  std_logic;
      SDOUT : out std_logic;
      SCS   : in  std_logic

      );
  end component;

begin


   boot_uut : boot
     generic map (
       M       => 20,
       DEVICE  => X"01")
     port map (
       CLK     => CLK,
       RESET   => RESET,
       EDTX    => EDTX,
       EATX    => EATX,
       ECYCLE  => ECYCLE,
       EARX    => EARX,
       EDRX    => EDRX,
       EDSELRX => EDSELRX,
       SDOUT   => SDOUT,
       SDIN    => SDIN,
       SCLK    => SCLK,
       SCS     => SCS,
       SEROUT  => SEROUT);


   mmc_inst : mmc
     port map (
       RESET => RESET,
       SCLK  => SCLK,
       SDIN  => SDIN,
       SDOUT => SDOUT,
       SCS   => SCS);

  -- basic clocking
  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  -- ecycle generation
  ecycle_gen : process(CLK)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        epos <= 0;
      else
        epos <= epos + 1;

      end if;

      if epos = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process;

  
end Behavioral;
