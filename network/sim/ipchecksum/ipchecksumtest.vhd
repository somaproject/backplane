library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity ipchecksumtest is

end ipchecksumtest;


architecture Behavioral of ipchecksumtest is


  component ipchecksum
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      LD     : in  std_logic;
      EN     : in  std_logic;
      CHKOUT : out std_logic_vector(15 downto 0));
  end component;


  signal CLK    : std_logic := '0';
  signal DIN    : std_logic_vector(15 downto 0) := (others => '0');
  signal LD     : std_logic := '0';
  signal EN     : std_logic := '0';
  signal CHKOUT : std_logic_vector(15 downto 0) := (others => '0');



begin  -- Behavioral
  ipchecksum_uut: ipchecksum
    port map (
      CLK    => CLK,
      DIN    => DIN,
      LD     => LD,
      EN     => EN,
      CHKOUT => CHKOUT); 

    CLK <= not clk after 10 ns;
  
  test: process
    begin
      wait until rising_edge(CLK);
      DIN <= X"0000"; 
      LD <= '1';
      EN <= '1';
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0001"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"f203"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"f4f5"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"f6f7"; 
      wait until rising_edge(CLK);
      EN <= '0';
      wait until rising_edge(clk);
 
      assert CHKOUT = X"220d" report "Error in small checksum" severity Error;

      
      wait for 1 us;
      
    
      wait until rising_edge(CLK);
      DIN <= X"0000"; 
      LD <= '1';
      EN <= '1';
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"4500"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0054"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"28eb"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0000"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"4001"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0000"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"1204"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0e5b"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"1204"; 
      wait until rising_edge(CLK);
      LD <= '0'; 
      DIN <= X"0e6c";
       wait until rising_edge(clk);
      EN <= '0'; 
      wait until rising_edge(clk);
 
      assert CHKOUT = X"10F0" report "Error in longl checksum" severity Error;

      report "End of Simulation" severity Failure;
      
    end process test; 

end Behavioral;
