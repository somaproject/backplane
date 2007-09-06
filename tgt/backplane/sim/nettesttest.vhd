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
      CLKIN        : in    std_logic;
      SERIALBOOT   : out   std_logic_vector(19 downto 0);
      SDOUT        : out   std_logic;
      SDIN         : in    std_logic;
      SCLK         : out   std_logic;
      SCS          : out   std_logic;
      LEDPOWER     : out   std_logic;
      LEDEVENT     : out   std_logic;
      NICFCLK      : out   std_logic;
      NICFDIN      : out   std_logic;
      NICFPROG     : out   std_logic;
      NICSCLK      : out   std_logic;
      NICSIN       : in    std_logic;
      NICSOUT      : out   std_logic;
      NICSCS       : out   std_logic;
      NICDOUT      : out   std_logic_vector(15 downto 0);
      NICNEWFRAME  : out   std_logic;
      NICDIN       : in    std_logic_vector(15 downto 0);
      NICNEXTFRAME : out   std_logic;
      NICDINEN     : in    std_logic;
      NICIOCLK     : out   std_logic;
      RAMCLKOUT_P  : out   std_logic;
      RAMCLKOUT_N  : out   std_logic;
      RAMCKE       : out   std_logic := '0';
      RAMCAS       : out   std_logic;
      RAMRAS       : out   std_logic;
      RAMCS        : out   std_logic;
      RAMWE        : out   std_logic;
      RAMADDR      : out   std_logic_vector(12 downto 0);
      RAMBA        : out   std_logic_vector(1 downto 0);
      RAMDQSH      : inout std_logic;
      RAMDQSL      : inout std_logic;
      RAMDQ        : inout std_logic_vector(15 downto 0)

      );
  end component;

  signal CLKIN, CLK : std_logic                     := '0';
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

  signal NICSCLK      : std_logic                     := '0';
  signal NICSIN       : std_logic                     := '0';
  signal NICSOUT      : std_logic                     := '0';
  signal NICSCS       : std_logic                     := '0';
  signal NICDOUT      : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEWFRAME  : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICIOCLK     : std_logic                     := '0';
  signal RAMCLKOUT_P  : std_logic                     := '0';
  signal RAMCLKOUT_N  : std_logic                     := '0';
  signal RAMCKE       : std_logic                     := '0';
  signal RAMCAS       : std_logic                     := '0';
  signal RAMRAS       : std_logic                     := '0';
  signal RAMCS        : std_logic                     := '0';
  signal RAMWE        : std_logic                     := '0';
  signal RAMADDR      : std_logic_vector(12 downto 0) := (others => '0');
  signal RAMBA        : std_logic_vector(1 downto 0)  := (others => '0');
  signal RAMDQSH      : std_logic                     := '0';
  signal RAMDQSL      : std_logic                     := '0';
  signal RAMDQ        : std_logic_vector(15 downto 0) := (others => '0');

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

-- component bootdeserialize
-- port (
-- CLK : in std_logic;
-- DIN : in std_logic;
-- FPROG : out std_logic;
-- FDIN : out std_logic;
-- FCLK : out std_logic);
-- end component;


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
      CLKIN      => CLKIN,
      SERIALBOOT => SERIALBOOT,
      SDOUT      => SDOUT,
      SDIN       => SDIN,
      SCLK       => SCLK,
      SCS        => SCS,
      LEDPOWER   => LEDPOWER,
      LEDEVENT   => LEDEVENT,
      NICFCLK    => NICFCLK,
      NICFDIN    => NICFDIN,
      NICFPROG   => NICFPROG,
      -- NIC SERIAL INTERFACE
      NICSCLK    => NICSCLK,
      NICSIN     => NICSIN,
      NICSOUT    => NICSOUT,
      NICSCS     => NICSCS,
      -- NIC DATA INTERFACE

      NICDOUT      => NICDOUT,
      NICNEWFRAME  => NICNEWFRAME,
      NICDIN       => NICDIN,
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => NICDINEN,
      NICIOCLK     => NICIOCLK,
      -- RAM INTERFACE
      RAMCLKOUT_P  => RAMCLKOUT_P,
      RAMCLKOUT_N  => RAMCLKOUT_N,
      RAMCKE       => RAMCKE,
      RAMCAS       => RAMCAS,
      RAMRAS       => RAMRAS,
      RAMCS        => RAMCS,
      RAMWE        => RAMWE,
      RAMADDR      => RAMADDR,
      RAMBA        => RAMBA,
      RAMDQSH      => RAMDQSH,
      RAMDQSL      => RAMDQSL,
      RAMDQ        => RAMDQ);


  CLKIN <= not CLKIN after 10 ns; 
  CLK   <= CLKIN;

  mmc_inst : mmc
    generic map (
      mode  => 1)
    port map (
      RESET => '0',
      SCLK  => SCLK,
      SDIN  => SDOUT,
      SDOUT => SDIN,
      SCS   => SCS);

  nicfpga : simplefpga
    port map (
      START     => nicfpgastart,
      bootaddr  => X"2000",
      BOOTLEN   => X"0002",
      FCLK      => NICFCLK,
      FDIN      => NICFDIN,
      FPROG     => NICFPROG,
      VALIDBOOT => nicvalidboot);

  main : process
  begin
    nicfpgastart <= '1';
    wait for 100 ns;
    nicfpgastart <= '0';
    wait until rising_edge(CLK) and nicvalidboot = '1';
    assert false report "End of Simulation" severity failure;


    wait;

  end process;

end Behavioral;
