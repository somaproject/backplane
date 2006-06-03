library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity nettesttest is

end nettesttest;


architecture Behavioral of nettesttest is

  component nettest
    port (
      CLKIN        : in  std_logic;
      SERIALBOOT : out std_logic_vector(19 downto 0);
      SDOUT      : out std_logic;
      SDIN       : in  std_logic;
      SCLK       : out std_logic;
      SCS        : out std_logic;
      NICFCLK    : out std_logic;
      NICFDIN    : out std_logic;
      NICFPROG   : out std_logic;

      LEDPOWER : out std_logic;
      LEDEVENT : out std_logic
      );

  end component;

  signal CLKIN, CLK        : std_logic                     := '0';
  signal SERIALBOOT : std_logic_vector(19 downto 0) := (others => '0');

  signal SDOUT    : std_logic := '0';
  signal SDIN     : std_logic := '0';
  signal SCLK     : std_logic := '0';
  signal SCS      : std_logic := '0';
  signal LEDPOWER : std_logic := '0';
  signal LEDEVENT : std_logic := '0';

  signal NICFCLK  : std_logic := '0';
  signal NICFDIN  : std_logic := '0';
  signal NICFPROG : std_logic := '0';

  component mmc
    generic (
      mode  :     integer := 0);
    port (
      RESET : in  std_logic;
      SCLK  : in  std_logic;
      SDIN  : in  std_logic;
      SDOUT : out std_logic;
      SCS   : in  std_logic );
  end component;

--   component bootdeserialize
--     port (
--       CLK   : in  std_logic;
--       DIN   : in  std_logic;
--       FPROG : out std_logic;
--       FDIN  : out std_logic;
--       FCLK  : out std_logic);
--   end component;

  
component simplefpga

  port (
    START     : in  std_logic;
    BOOTADDR  : in  std_logic_vector(15 downto 0);
    BOOTLEN   : in  std_logic_vector(15 downto 0);
    FCLK      : in  std_logic;
    FDIN      : in  std_logic;
    FPROG     : in  std_logic;
    VALIDBOOT : out std_logic
    );

end component;

signal nicfpgastart, nicvalidboot : std_logic := '0';

  
begin  -- Behavioral

  nettest_uut : nettest
    port map (
      CLKIN        => CLKIN,
      SERIALBOOT => SERIALBOOT,
      SDOUT      => SDOUT,
      SDIN       => SDIN,
      SCLK       => SCLK,
      SCS        => SCS,
      NICFCLK    => NICFCLK,
      NICFDIN    => NICFDIN,
      NICFPROG   => NICFPROG,
      LEDPOWER   => LEDPOWER,
      LEDEVENT   => LEDEVENT);

  CLKIN <= not CLKIN after 16.666666  ns;
  CLK <= CLKIN; 

  mmc_inst : mmc
    generic map (
      mode  => 1)
    port map (
      RESET => '0',
      SCLK  => SCLK,
      SDIN  => SDOUT,
      SDOUT => SDIN,
      SCS   => SCS);

  nicfpga: simplefpga
    port map (
      START     => nicfpgastart,
      bootaddr  => X"2000",
      BOOTLEN   => X"0002",
      FCLK      => NICFCLK,
      FDIN      => NICFDIN,
      FPROG     => NICFPROG,
      VALIDBOOT => nicvalidboot);

  main: process
    begin
      nicfpgastart <= '1';
      wait for 100 ns;
      nicfpgastart <= '0';
      wait until rising_edge(CLK) and nicvalidboot = '1';
      assert False report "End of Simulation" severity failure;

      
      wait;
      
    end process; 
    
end Behavioral;
