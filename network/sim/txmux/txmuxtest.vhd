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
      DEN      : in  std_logic_vector(6 downto 0);
      DIN0 : in std_logic_vector(15 downto 0); 
      DIN1 : in std_logic_vector(15 downto 0); 
      DIN2 : in std_logic_vector(15 downto 0); 
      DIN3 : in std_logic_vector(15 downto 0); 
      DIN4 : in std_logic_vector(15 downto 0);
      DIN5 : in std_logic_vector(15 downto 0);
      DIN6 : in std_Logic_vector(15 downto 0); 
      GRANT    : out std_logic_vector(6 downto 0);
      ARM      : in  std_logic_vector(6 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic
      );
  end component;


  signal CLK : std_logic := '0';

  signal DEN   : std_logic_vector(6 downto 0)
                                        := (others => '0');

  signal DIN0 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN1 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN2 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN3 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN4 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN5 : std_logic_vector(15 downto 0) := (others => '0'); 
  signal DIN6 : std_logic_vector(15 downto 0) := (others => '0'); 

  signal GRANT : std_logic_vector(6 downto 0)
                                        := (others => '0');

  signal ARM      : std_logic_vector(6 downto 0)
                              := (others => '0');
  signal DOUT     : std_logic_vector(15 downto 0)
                              := (others => '0');
  
  signal NEWFRAME : std_logic := '0';

begin  -- Behavioral


  txmux_uut : txmux
    port map (
      CLK      => CLK,
      DEN      => DEN,
      DIN0 => DIN0,
      DIN1 => DIN1,
      DIN2 => DIN2,
      DIN3 => DIN3,
      DIN4 => DIN4,
      DIN5 => DIN5,
      DIN6 => DIN6, 
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
    DIN0 <= X"1234";
    wait until rising_edge(CLK);
    DEN(0) <= '1';
    DIN0 <= X"5678";
    wait until rising_edge(CLK);

    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"1234" report "" severity Error;
    
    wait until rising_edge(CLK);
    DEN(0) <= '0';
    DIN0 <= X"9ABC";
    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"5678" report "" severity Error;

    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    assert NEWFRAME = '0' report "" severity error;

    wait for 10 us;

    
    ---------------------------------------------------------------------------
    -- Now test priority
    ---------------------------------------------------------------------------

    wait until rising_edge(CLK);
    ARM <= (others => '1'); 
    wait until rising_edge(CLK);

    -- port 0 
    wait until rising_edge(CLK) and GRANT(0) = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    ARM(0) <= '0';
    DEN(0) <= '1';
    DIN0 <= X"0011";
    wait until rising_edge(CLK);
    DEN(0) <= '1';
    DIN0 <= X"2233";
    wait until rising_edge(CLK);

    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"0011" report "" severity Error;


    DEN(0) <= '0';
    DIN0 <= X"0000";
    wait until rising_edge(CLK);
    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"2233" report "" severity Error;
    
    -- port 1
    wait until rising_edge(CLK) and GRANT(1) = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    ARM(1) <= '0';
    DEN(1) <= '1';
    DIN1 <= X"4455";
    wait until rising_edge(CLK);
    DEN(1) <= '1';
    DIN1 <= X"6677";
    wait until rising_edge(CLK);
    DEN(1) <= '0';
    DIN1 <= X"0000";
    wait until rising_edge(CLK);

    -- port 2
    wait until rising_edge(CLK) and GRANT(2) = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    ARM(2) <= '0';
    DEN(2) <= '1';
    DIN2 <= X"4455";
    wait until rising_edge(CLK);
    DEN(2) <= '1';
    DIN2 <= X"6677";
    -- arm port 0
    ARM(0) <= '1'; 
    wait until rising_edge(CLK);
    DEN(2) <= '0';
    DIN2 <= X"0000";
    wait until rising_edge(CLK);

    
    -- port 0 
    wait until rising_edge(CLK) and GRANT(0) = '1';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);
    ARM(0) <= '0';
    DEN(0) <= '1';
    DIN0 <= X"0011";
    wait until rising_edge(CLK);
    DEN(0) <= '1';
    DIN0 <= X"2233";
    wait until rising_edge(CLK);

    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"0011" report "" severity Error;


    DEN(0) <= '0';
    DIN0 <= X"0000";
    wait until rising_edge(CLK);
    assert NEWFRAME = '1' report "" severity Error;
    assert DOUT = X"2233" report "" severity Error;
    

    wait for 10 us;
    
    assert False report "End of Simulation" severity Failure;

        
  end process main;

end Behavioral;


