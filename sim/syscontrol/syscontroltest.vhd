library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;



entity syscontroltest is

end syscontroltest;


architecture Behavioral of syscontroltest is

  component syscontrol
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0)
      );
  end component;

  signal CLK   : std_logic := '0';
  signal RESET : std_logic := '1';

  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');

  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal ECYCLE : std_logic := '0';
  signal EARX   : std_logic_vector(somabackplane.N - 1 downto 0)
                            := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');


  signal epos : integer range 0 to 999 := 950;
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');


begin  -- Behavioral

  syscontrol_uut: syscontrol
    port map (
      CLK     => CLK,
      RESET   => RESET,
      EDTX    => EDTX,
      EATX    => EATX,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX); 
     
  CLK   <= not CLK after 10 ns;
  RESET <= '0';

  -- ecycle generation
  ecycle_gen : process(CLK)
  begin
    if rising_edge(CLK) then
      if epos = 999 then
        epos <= 0;
      else
        epos <= epos + 1;
      end if;

      if epos = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;
    end if;
  end process;

  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and epos = 47;
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

  main : process
  begin

    wait until rising_edge(CLK) and ECYCLE = '1' and EARX(2) = '1';
    wait until rising_edge(CLK);

    EDSELRX <= X"0";
    wait until rising_edge(CLK);
    assert EDRX = X"20" report "incorrect boot command" severity error;

    EDSELRX <= X"1";
    wait until rising_edge(CLK);
    assert EDRX = X"01" report "incorrect source device" severity error;

    EDSELRX <= X"5";
    wait until rising_edge(CLK);
    assert EDRX = X"01" report "incorrect boot target" severity error;

    -- we don't actually check word/data here
    
    wait for 100 us;                    -- delay for booting
    wait until rising_edge(CLK) and  ECYCLE = '1' ;
    -- send response
    eventinputs(2)(0) <= X"2002";
    eventinputs(2)(1) <= X"0002";
    EATX(2) <= '1';  
    wait until rising_edge(CLK) and  ECYCLE = '1' ;
    eventinputs <= (others => (others => (others => '0')));
    EATX <= (others => '0'); 

    wait; 

  end process main;

end Behavioral;
