library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


entity nicserialiotest is

end nicserialiotest;

architecture Behavioral of nicserialiotest is

  component nicserialio
    port (
      CLK   : in  std_logic;
      START : in  std_logic;
      RW    : in  std_logic;
      ADDR  : in  std_logic_vector(5 downto 0);
      DIN   : in  std_logic_vector(31 downto 0);
      DOUT  : out std_logic_vector(31 downto 0);
      DONE  : out std_logic;
      SCLK  : out std_logic;
      SOUT  : out std_logic;
      SCS   : out std_logic;
      SIN   : in  std_logic);
  end component;


  signal CLK   : std_logic                     := '0';
  signal START : std_logic                     := '0';
  signal RW    : std_logic                     := '0';
  signal ADDR  : std_logic_vector(5 downto 0)  := (others => '0');
  signal DIN   : std_logic_vector(31 downto 0) := (others => '0');
  signal DOUT  : std_logic_vector(31 downto 0) := (others => '0');
  signal DONE  : std_logic                     := '0';
  signal SCLK  : std_logic                     := '0';
  signal SOUT  : std_logic                     := '0';
  signal SCS   : std_logic                     := '0';
  signal SIN   : std_logic                     := '0'; 

  signal serialregin : std_logic_vector(39 downto 0) := (others => '0');
  signal serialbcnt : integer := 0;
  signal outword : std_logic_vector(31 downto 0) := X"12AB34CD";
  
begin  -- Behavioral

  
  nicserialio_uut: nicserialio
    port map (
      CLK => CLK,
      START => START,
      RW => RW,
      ADDR => ADDR,
      DIN => DIN,
      DOUT => DOUT,
      DONE => DONE,
      SCLK => SCLK,
      SOUT => SOUT,
      SCS => SCS,
      SIN => SIN);

  
  CLK <= not CLK after 10 ns;

  serialin: process (sclk, SCS)
  begin  -- process serialin
    if falling_edge(SCS) then
      serialbcnt <= 0;
    else
      if falling_edge(SCLK) then
        serialbcnt <= serialbcnt + 1; 
      end if;
    end if;
    if rising_edge(SCLK) then
      if scs = '0' then
        serialregin <= serialregin(38 downto 0) & SOUT; 
      end if;
      if serialbcnt >= 8 then
        SIN <= outword(39 - serialbcnt); 
      end if;
    end if;
    
  end process serialin;
  

  maintest: process
    begin
      wait for 1 us;
      ADDR <= "100010";
      RW <= '1';
      DIN <= X"12345678";
      wait until rising_edge(CLK);
      START <= '1';
      wait until rising_edge(CLK);
      START <= '0';
      wait until rising_edge(CLK) and DONE = '1';

      assert serialregin = X"A212345678" report "Error in reading serial data output" severity Error;
      assert dout = X"12AB34CD" report "Error in reading serial data input" severity Error;

      assert false report "End of Simulation" severity failure;
      
      
      wait; 
      
        
    end process maintest; 
end Behavioral;
