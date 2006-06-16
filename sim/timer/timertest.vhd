library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;


library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity timertest is

end timertest;


architecture Behavioral of timertest is

  component timer
    port (
      CLK     : in  std_logic;
      ECYCLE  : out std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0)
      );
  end component;


  signal CLK    : std_logic := '0';
  signal ECYCLE : std_logic := '0';

  signal EARX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');


  signal tickcnt : integer                       := 0;
  signal timecnt : std_logic_vector(47 downto 0) := (others => '0');

  signal expectedEARX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '1');

begin  -- Behavioral

  timer_uut : timer
    port map (
      CLK     => CLK,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      EATX    => EATX,
      EDTX    => EDTX);


  CLK <= not CLK after 10 ns;

  -- ecycle count
  process(CLK)
    variable prevecycle : boolean := false;

  begin
    if rising_edge(CLK) then
      if not prevecycle then
        -- this is run the first time we see an ecycle
        if ECYCLE = '1' then
          tickcnt <= 0;
          prevecycle := true;
        end if;
      else
        -- we have seen an ecycle
        if ECYCLE = '1' then
          assert tickcnt = 999 report "Incorrect ecycle length" severity error;
          tickcnt <= 0;
        else
          tickcnt <= tickcnt + 1;
        end if;
      end if;
    end if;
  end process;


  -- EADDR output
  process (CLK)
  begin
    if rising_edge(CLK) then
      assert EARX = expectedEARX
        report "EARX not all ones" severity error;
    end if;

  end process;

  -- the actual address check
  process
  begin
    while true loop
      wait until falling_edge(ECYCLE);
      wait for 5 us;

      wait until rising_edge(CLK);
      EDSELRX <= X"0";
      wait for 2 ns;
      assert EDRX = X"10" report "Incorrect command byte" severity error;

      wait until rising_edge(CLK);
      EDSELRX <= X"1";
      wait for 2 ns;
      assert EDRX = X"00" report "Incorrect source byte" severity error;

      for i in 0 to 5 loop
        wait until rising_edge(CLK);
        EDSELRX <= std_logic_vector(TO_UNSIGNED(i + 2, 4));
        wait for 2 ns;

        assert EDRX = timecnt(47 - i*8 downto 40 -i*8)
          report "Incorrect time byte" severity error;


        wait until rising_edge(ECYCLE);
        timecnt <= timecnt + 1;

      end loop;  -- i

    end loop;
  end process;

  process
  begin
    wait for 40 ms;
    assert false report "End of Simulation" severity failure;

  end process;
  
end Behavioral;
