library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity ethercontroltest is

end ethercontroltest;

architecture Behavioral of ethercontroltest is

  component ethercontrol
    generic (
      DEVICE   :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      ECYCLE   : in  std_logic;
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX     : out std_logic_vector(7 downto 0);
      EDSELRX  : in  std_logic_vector(3 downto 0);
      EOUTD    : in  std_logic_vector(15 downto 0);
      EOUTA    : out std_logic_vector(2 downto 0);
      EVALID   : in  std_logic;
      ENEXT    : out std_logic;
      RW: out std_logic;
      ADDR : out std_logic_vector(5 downto 0); 
      DIN: out std_logic_vector(31 downto 0);
      DOUT : in std_logic_vector(31 downto 0);
      NICSTART : out std_logic;
      NICDONE : in std_logic
      );
  end component;

  signal CLK    : std_logic := '0';
  signal RESET  : std_logic := '1';
  signal ECYCLE : std_logic := '0';


  signal EARX : std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0)  := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)  := (others => '0');
  signal EOUTD   : std_logic_vector(15 downto 0) := (others => '0');
  signal EOUTA   : std_logic_vector(2 downto 0)  := (others => '0');

  signal EVALID : std_logic := '0';
  signal ENEXT  : std_logic := '0';

  signal RW : std_logic := '0';
  signal ADDR : std_logic_vector(5 downto 0) := (others => '0');

  signal DIN, DOUT : std_logic_vector(31 downto 0) := (others => '0');
  
  signal NICSTART : std_logic := '0';
  signal NICDONE  : std_logic := '0';

  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDTX : std_logic_vector(7 downto 0)                  := (others => '0');

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');


  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;

  signal pos : integer range 0 to 999 := 980;


  type settings is (none, noop, noopdone,
                    firstwrite, firstwritedone,
                    multiwrite, multiwriteerror, multiwritedone);
  signal state : settings := none;
  
begin  -- Behavioral

  CLK   <= not clk after 10 ns;
  RESET <= '0'     after 100 ns;

  ethercontrol_uut : ethercontrol
    generic map (
      DEVICE   => x"01")
    port map (
      CLK      => CLK,
      RESET    => RESET,
      ECYCLE   => ECYCLE,
      EARx     => EARX,
      EDRX     => EDRX,
      EDSELRX  => EDSELRX,
      EOUTD    => EOUTD,
      EOUTA    => EOUTA,
      EVALID   => EVALID,
      ENEXT    => ENEXT,
      RW => RW,
      ADDR => ADDR,
      DIN => DIN,
      DOUT => DOUT,
      NICSTART => NICSTART,
      NICDONE => NICDONE);

  rxeventfifo_inst : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      EOUTD  => EOUTD,
      EOUTA  => EOUTA,
      EVALID => EVALID,
      ENEXT  => ENEXT);

  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;


  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and pos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;



  nicserialio_sim : process
  begin
    while true loop

      wait until rising_edge(CLK) and NICSTART = '1';
      wait for 100 us;
      wait until rising_edge(CLK);
      wait for 4 ns;
      NICDONE <= '1';
      wait until rising_edge(CLK);
      wait for 4 ns;
      DOUT <= X"ABCDEF12"; 
      NICDONE <= '0';
    end loop;
  end process nicserialio_sim;

  main : process
    --generate the commands, read the outputs
    --
  begin
    -- first, we send no-op and make sure we have no reaction
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= noop; 

    eventinputs(0)(0) <= (others => '1');
    EATX(0)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;


    -- now, verify they don't do anything

    wait until rising_edge(CLK) and ECYCLE = '1';
    assert EARX'stable(20 us) report "EARX registered an event" severity
      error;
    state <= noopdone ;
    
    -- now try and send a correct event
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= firstwrite; 
    eventinputs(4)(0) <= X"3004";
    eventinputs(4)(1) <= X"0001";
    eventinputs(4)(2) <= X"0017";
    eventinputs(4)(3) <= X"1234";
    eventinputs(4)(4) <= X"5678";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    wait until rising_edge(CLK) and NICSTART = '1';
    assert rw = '1' report "Incorrect rw set for event write" severity error;
    assert addr = "010111" report "incorrect addr" severity error;
    assert din = X"12345678" report "incorrect din" severity error;


    -- now try and acquire the event
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = X"30"
      report "1 : invalid transmitted event : command ID" severity error;
 
    wait for 3 ns;
    EDSELRX <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "1 : invalid transmitted event : device" severity error;

   
    wait for 3 ns;
    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "1 : invalid transmitted event : success" severity error;

    wait for 3 ns;
    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"AB"
      report "1 : invalid transmitted event : response" severity error;

    wait for 3 ns;
    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"CD"
      report "1 : invalid transmitted event : response" severity error;
    
    wait for 3 ns;
    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"EF"
      report "1 : invalid transmitted event : response" severity error;

    wait for 3 ns;
    EDSELRX <= "0111";
    wait until rising_edge(CLK);
    assert EDRX = X"12"
      report "1 : invalid transmitted event : response" severity error;

    state <= firstwritedone; 


-------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- send a second event, while the first one is in progress
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------    
    -- now try and send a correct event
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= firstwrite; 
    eventinputs(4)(0) <= X"3004";
    eventinputs(4)(1) <= X"0001";
    eventinputs(4)(2) <= X"0017";
    eventinputs(4)(3) <= X"ABCD";
    eventinputs(4)(4) <= X"1234";
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';

    wait until rising_edge(CLK) and NICSTART = '1';
    assert rw = '1' report "Incorrect rw set for event write" severity error;
    assert addr = "010111" report "incorrect addr" severity error;
    assert din = X"ABCD1234" report "incorrect din" severity error;


    -- now try and acquire the event
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
    end loop;

    wait for 3 ns;
    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = X"30"
      report "1 : invalid transmitted event : command ID" severity error;
 
    wait for 3 ns;
    EDSELRX <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "1 : invalid transmitted event : device" severity error;

   
    wait for 3 ns;
    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "1 : invalid transmitted event : success" severity error;

    wait for 3 ns;
    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"AB"
      report "1 : invalid transmitted event : response" severity error;

    wait for 3 ns;
    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"CD"
      report "1 : invalid transmitted event : response" severity error;
    
    wait for 3 ns;
    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"EF"
      report "1 : invalid transmitted event : response" severity error;

    wait for 3 ns;
    EDSELRX <= "0111";
    wait until rising_edge(CLK);
    assert EDRX = X"12"
      report "1 : invalid transmitted event : response" severity error;

    state <= firstwritedone; 


    assert false report "End of Simulation" severity failure;





  end process main;

end Behavioral;
