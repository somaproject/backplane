library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity mmciotest is
end mmciotest;

architecture Behavioral of mmciotest is

  component mmcio
    port ( CLK    : in  std_logic;
           RESET  : in  std_logic;
           SCS    : out std_logic;
           SDIN   : in  std_logic;
           SDOUT  : out std_logic;
           SCLK   : out std_logic;
           DOUT   : out std_logic_vector(7 downto 0);
           DSTART : in  std_logic;
           ADDR   : in  std_logic_vector(15 downto 0);
           DVALID : out std_logic;
           DDONE  : out std_logic
           );
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

  signal DOUT   : std_logic_vector(7 downto 0)  := (others => '0');
  signal DSTART : std_logic := '0';
  signal ADDR   : std_logic_vector(15 downto 0) := (others => '0');
  signal DVALID : std_logic                     := '0';
  signal DDONE  : std_logic                     := '0';


begin
  mmcio_uut : mmcio
    port map (
      CLK    => CLK,
      RESET  => RESET,
      SCS    => SCS,
      SDIN   => SDOUT,
      SDOUT  => SDIN,
      SCLK   => SCLK,
      DOUT   => DOUT,
      DSTART => DSTART,
      ADDR   => ADDR,
      DVALID => DVALID,
      DDONE  => DDONE);


  mmc_inst : mmc
    port map (
      RESET => RESET,
      SCLK  => SCLK,
      SDIn  => SDIN,
      SDOUT => SDOUT,
      SCS   => SCS);

  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 50 ns;


  process
    begin
      wait until rising_edge(CLK) and DDONE = '1';
      report "beginning read request" severity note;

      

      ADDR <= X"0000";
      DSTART <= '1';
      wait until rising_edge(CLK);
      DSTART <= '0'; 

      for i in 0 to 1 loop
        for byte in 0 to 255 loop
          wait until rising_edge(CLK) and DVALID = '1';
        end loop;  -- byte
        
      end loop;  -- i

      wait until rising_edge(CLK) and DDONE = '1';

      assert false report "End of Simulation" severity failure;
      
      wait; 

    end process;
end Behavioral;

