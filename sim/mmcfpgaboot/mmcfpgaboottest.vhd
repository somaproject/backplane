library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity mmcfpgaboottest is

end mmcfpgaboottest;


architecture Behavioral of mmcfpgaboottest is

  constant M : integer := 20;

  component mmcfpgaboot
    generic (
      M        :     integer := 20);
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      BOOTASEL : in  std_logic_vector(M-1 downto 0);
      SEROUT   : out std_logic_vector(M-1 downto 0);
      BOOTADDR : in  std_logic_vector(15 downto 0);
      BOOTLEN  : in  std_logic_vector(15 downto 0);
      START    : in  std_logic;
      DONE     : out std_logic;
      SDOUT    : out std_logic;
      SDIN     : in  std_logic;
      SCLK     : out std_logic;
      SCS      : out std_logic);
  end component;

  signal CLK      : std_logic                      := '0';
  signal RESET    : std_logic                      := '1';
  signal BOOTASEL : std_logic_vector(M-1 downto 0) := (others => '0');
  signal SEROUT   : std_logic_vector(M-1 downto 0) := (others => '0');
  signal BOOTADDR : std_logic_vector(15 downto 0)  := (others => '0');
  signal BOOTLEN  : std_logic_vector(15 downto 0)  := (others => '0');
  signal START    : std_logic                      := '0';
  signal DONE     : std_logic                      := '0';
  signal SDOUT    : std_logic                      := '0';
  signal SDIN     : std_logic                      := '0';
  signal SCLK     : std_logic                      := '0';
  signal SCS      : std_logic                      := '0';


  signal fprog, fclk, fdin : std_logic_vector(M-1 downto 0) := (others => '0');

  component mmc
    generic (
      mode : integer := 0);

    port (
      RESET : in  std_logic;
      SCLK  : in  std_logic;
      SDIN  : in  std_logic;
      SDOUT : out std_logic;
      SCS   : in  std_logic

      );
  end component;

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

  signal fpgavalidboot, fpgastart : std_logic_vector(M-1 downto 0) := (others => '0');


  component bootdeserialize
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic;
      FPROG : out std_logic;
      FDIN  : out std_logic;
      FCLK  : out std_logic);
  end component;


begin  -- Behavioral


  mmcfpgaboot_uut : mmcfpgaboot
    generic map (
      M        => M)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      BOOTASEL => BOOTASEl,
      SEROUT   => SEROUT,
      BOOTADDR => BOOTADDR,
      BOOTLEN  => BOOTLEN,
      START    => START,
      DONE     => DONE,
      SDOUT    => SDOUT,
      SDIN     => SDIN,
      SCLK     => SCLK,
      SCS      => SCS);

  mmc_inst : mmc
    generic map (
      mode  => 1)
    port map (
      RESET => RESET,
      SCLK  => SCLK,
      SDIN  => SDOUT,
      SDOUT => SDIN,
      SCS   => SCS);


  deserializers   : for i in 0 to M-1 generate
    deserializers : bootdeserialize
      port map (
        CLK   => CLK,
        DIN   => SEROUT(i),
        FPROG => fprog(i),
        FDIN  => fdin(i),
        FCLK  => fclk(i));

  end generate deserializers;

  fpgas      : for i in 0 to M-1 generate
    fpgatest : simplefpga
      port map (
        START     => fpgastart(i),
        BOOTADDR  => bootaddr,
        bootlen   => bootlen,
        FCLK      => fclk(i),
        FDIN      => fdin(i),
        FPROG     => fprog(i),
        VALIDBOOT => fpgavalidboot(i));

  end generate fpgas;


  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

  test : process
  begin

    wait until falling_edge(RESET);
    wait until rising_edge(CLK);

    -- a simple test of four blocks

    BOOTASEL <= X"00001";
    BOOTADDR <= X"0000";                -- first block
    BOOTLEN  <= X"0002";                -- two blocks
    wait until rising_edge(CLK);
    
    fpgastart <= BOOTASEL; 
    START    <= '1';
    wait until rising_edge(CLK);
    fpgastart <= (others => '0');
    
    START    <= '0';

    wait until rising_edge(CLK) and DONE = '1';
    wait until rising_edge(CLK) and fpgavalidboot(0) = '1'; 
    -- test if it actually works

    wait until rising_edge(CLK);


    -- a simple test of four blocks

    BOOTASEL <= X"00002";
    BOOTADDR <= X"0000";                -- first block
    BOOTLEN  <= X"0002";                -- two blocks
    wait until rising_edge(CLK);
    
    fpgastart <= BOOTASEL; 
    START    <= '1';
    wait until rising_edge(CLK);
    fpgastart <= (others => '0');
    
    START    <= '0';

    wait until rising_edge(CLK) and DONE = '1';
    wait until rising_edge(CLK) and fpgavalidboot(1) = '1'; 
    -- test if it actually works


    wait until rising_edge(CLK);


    -- a simple test of four blocks

    BOOTASEL <= X"11110";
    BOOTADDR <= X"1000";                -- first block
    BOOTLEN  <= X"0004";                -- two blocks
    wait until rising_edge(CLK);
    
    fpgastart <= BOOTASEL; 
    START    <= '1';
    wait until rising_edge(CLK);
    fpgastart <= (others => '0');
    
    START    <= '0';

    wait until rising_edge(CLK) and DONE = '1';
    wait until rising_edge(CLK) and fpgavalidboot(4) = '1'; 
    wait until rising_edge(CLK) and fpgavalidboot(8) = '1'; 
    wait until rising_edge(CLK) and fpgavalidboot(12) = '1'; 
    wait until rising_edge(CLK) and fpgavalidboot(16) = '1'; 


    assert false report "End of Simulation" severity failure;

    
  end process test;

  
end Behavioral;
