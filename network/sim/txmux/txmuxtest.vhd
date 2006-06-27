library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;


entity txmuxtest is

end txmuxtest;

architecture Behavioral of txmuxtest is


  component txmux
    port (
      CLK      : in  std_logic;
      DEN      : in  std_logic_vector(networkstack.N-1 downto 0);
      DIN      : in  networkstack.dataarray;
      GRANT    : out std_logic_vector(networkstack.N-1 downto 0);
      ARM      : in  std_logic_vector(networkstack.N-1 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic
      );
  end component;


  signal CLK : std_logic := '0';

  signal DEN   : std_logic_vector(networkstack.N-1 downto 0)
                                        := (others => '0');
  signal DIN   : networkstack.dataarray := (others => (others => '0'));
  signal GRANT : std_logic_vector(networkstack.N-1 downto 0)
                                        := (others => '0');

  signal ARM      : std_logic_vector(networkstack.N-1 downto 0)
                              := (others => '0');
  signal DOUT     : std_logic_vector(15 downto 0)
                              := (others => '0');
  signal NEWFRAME : std_logic := '0';

begin  -- Behavioral


  txmux_uut : txmux
    port map (
      CLK      => CLK,
      DEN      => DEN,
      DIN      => DIN,
      GRANT    => GRANT,
      ARM      => ARM,
      DOUT     => DOUT,
      NEWFRAME => NEWFRAME);

  CLK <= not CLK after 10 ns;

  main: process
  begin  -- process ain

    -- port 0
    wait for 1 us;
    wait until rising_edge(CLK);
    ARM(0) <= '1'; 
    wait until rising_edge(CLK);
    ARM(0) <= '0';
    wait until rising_edge(CLK) and GRANT(0) = '1';
    -- now test if we really have it
    wait until rising_edge(CLK);
    DEN(0) <= '1';
    DIN(0) <= X"1234";
    wait until rising_edge(CLK);
    DEN(0) <= '1';
    DIN(0) <= X"5678";
    wait until rising_edge(CLK);

    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"1234" report "" severity Error;
 
    wait until rising_edge(CLK);
    DEN(0) <= '0';
    DIN(0) <= X"9ABC";
    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"5678" report "" severity Error;

    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    assert NEWFRAME = '0' report "" severity error;

    wait; 
   
    
    
    
  end process main;

end Behavioral;


