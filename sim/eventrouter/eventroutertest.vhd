library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity eventroutertest is

end eventroutertest;

architecture Behavioral of eventroutertest is


  component eventrouter
    port (
      CLK     : in  std_logic;
      ECYCLE  : in  std_logic;
      EARX    : in  somabackplane.addrarray;
      EDSELRX : out std_logic_vector(3 downto 0);
      EATX    : out somabackplane.addrarray;
      EDRX    : in  somabackplane.dataarray;
      EDTX    : out std_logic_vector(7 downto 0)

      );
  end component;

  signal CLK     : std_logic                    := '0';
  signal RESET   : std_logic                    := '1';
  signal ECYCLE  : std_logic                    := '0';
  signal EARX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EATX    : somabackplane.addrarray      := (others => (others => '0'));
  signal EDRX    : somabackplane.dataarray;
  signal EDTX    : std_logic_vector(7 downto 0);

  signal ecnt : integer range 0 to 999 := 990;

begin  -- Behavioral
  eventrouter_uut : eventrouter
    port map (
      CLK     => CLK,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDSELRX => EDSELRX,
      EDRX    => EDRX,
      EATX    => EATX,
      EDTX    => EDTX);

  clk   <= not clk after 10 ns;         -- 50 MHz
  RESET <= '0'     after 30 ns;

  ecyclegen : process (CLK)
  begin  -- process ecyclegen
    if rising_edge(clk) then
      if ecnt = 999 then
        ecnt <= 0;
      else
        ecnt <= ecnt + 1;
      end if;

      if ecnt = 999 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process ecyclegen;

  -- set input address array

  eaddrsetter : process(CLK, RESET)
  begin
    if RESET = '1' then
      EARX(0)                 <= (others => '1');  -- the always on case
      for i in 7 to somabackplane.N-1 loop
        EARX(i)(i downto i-7) <= X"94";
      end loop;

      for i in 15 to 61 loop
        EARX(i)(i+16 downto i+1) <= X"4601";
      end loop;

    else
      if rising_edge(CLK) then
        if ECYCLE = '1' then
          for i in 0 to somabackplane.N - 1 loop
            EARX(i) <= EARX(i)(somabackplane.N -2 downto 0) & EARX(i)(somabackplane.N -1);
          end loop;  -- i 
        end if;
      end if;
    end if;

  end process eaddrsetter;

  -- send data
  edatasetter : process(CLK, EDSELRX)
  begin
    if RESET = '0' then


      for i in 0 to somabackplane.N - 1 loop
        EDRX(i) <= std_logic_vector(TO_UNSIGNED(
          (TO_INTEGER(unsigned(EDSELRX)) + i*12 ) mod 256, 8));
      end loop;  -- i 
    end if;
  end process edatasetter;


  -- check data
  edata_verify : process(CLK, RESET)
  begin
    if RESET = '0' then
      if rising_edge(CLK) then
        if ecnt > 47 and ecnt < 984 then
          assert edtx = std_logic_vector(TO_UNSIGNED(((ecnt - 48) mod 256), 8))
            report "ERROR IN DATA" severity error;

        end if;
      end if;
    end if;
  end process edata_verify;

  -- check addresses
  eaddr_verify : process
    
  begin
    while true loop

      wait until rising_edge(CLK) and ECYCLE = '1';
      wait until rising_edge(CLK);      -- wait an extra tick
      for i in 0 to somabackplane.N -1 loop
        for j in 0 to somabackplane.N - 1 loop
          assert EATX(i)(j) = EARX(j)(i)
            report "error in EATX" severity error;
        end loop;  -- j 
      end loop;  -- i 

    end loop;
  end process;

  process
    begin
      for i in 1 to 100 loop
        wait until rising_edge(ECYCLE);
        
      end loop;  -- i
      assert false report "End of Simulation" severity Failure;
      
    end process; 
end Behavioral;
