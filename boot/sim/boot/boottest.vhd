library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity boottest is
end boottest;

architecture Behavioral of boottest is

component boot 
  port (
    CLK    : in  std_logic;
    SCS    : out std_logic;
    SDIN   : in  std_logic;
    SDOUT  : out std_logic;
    SCLK   : out std_logic;
    FSDOUT : in  std_logic;
    FSCS   : in  std_logic; 
    FSCLK  : in  std_logic;
    FPROG : out std_logic;
    FCLK : out std_logic;
    FDIN : out std_logic    );

end component;


  component mmc
    port (
      RESET : in  std_logic;
      SCLK  : in  std_logic;
      SDIN  : in  std_logic;
      SDOUT : out std_logic;
      SCS   : in  std_logic
      );
  end component;

  signal CLK : std_logic := '0';
  signal RESET : std_logic := '1';
  
  signal SCLK, SDIN, SDOUT, SCS : std_logic := '0';

  signal FSDIN, FSDOUT, FSCS, FSCLK : std_logic := '0';

  signal FPROG, FCLK, FDIN : std_logic := '0';

  

begin
  boot_uut : boot
    port map (
      CLK    => CLK,
      SCS    => SCS,
      SDIN   => SDOUT,
      SDOUT  => SDIN,
      SCLK   => SCLK,
      FSDOUT => FSDOUT,
      FSCS => FSCS,
      FPROG => FPROG,
      FSCLK => FSCLK, 
      FCLK => FCLK,
      FDIN => FDIN);
  
  mmc_inst : mmc
    port map (
      RESET => RESET,
      SCLK  => SCLK,
      SDIn  => SDIN,
      SDOUT => SDOUT,
      SCS   => SCS);

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 200 ns;


  process
    begin
      wait;
    end process;
    
end Behavioral;

