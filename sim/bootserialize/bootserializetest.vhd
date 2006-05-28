library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity bootserializetest is
end bootserializetest;

architecture Behavioral of bootserializetest is

  component bootserialize
    generic (
      M      :     integer := 20);
    port (
      CLK    : in  std_logic;
      FPROG  : in  std_logic;
      FCLK   : in  std_logic;
      FDIN   : in  std_logic;
      FSET   : in  std_logic;
      FDONE  : out std_logic;
      SEROUT : out std_logic_vector(M-1 downto 0);
      ASEL   : in  std_logic_vector(M-1 downto 0));
  end component;

  constant M     : integer   := 20;
  signal   CLK   : std_logic := '0';
  signal   FPROG : std_logic := '0';
  signal   FCLK  : std_logic := '0';
  signal   FDIN  : std_logic := '0';
  signal   FSET  : std_logic := '0';
  signal   FDONE : std_logic := '0';

  signal SEROUT : std_logic_vector(M-1 downto 0) := (others => '0');
  signal ASEL   : std_logic_vector(M-1 downto 0) := (others => '0');


  component bootdeserialize

    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic;
      FPROG : out std_logic;
      FDIN  : out std_logic;
      FCLK  : out std_logic);

  end component;

  signal fprogout : std_logic_vector(M-1 downto 0) := (others => '1');
  signal fdinout  : std_logic_vector(M-1 downto 0) := (others => '1');
  signal fclkout  : std_logic_vector(M-1 downto 0) := (others => '1');


begin  -- Behavioral

  bootserialize_uut : bootserialize
    generic map (
      M      => M)
    port map (
      CLK    => CLK,
      FPROG  => FPROG,
      FCLK   => FCLK,
      FDIN   => FDIN,
      FSET   => FSET,
      FDONE  => FDONE,
      SEROUT => SEROUT,
      ASEL   => ASEL);

  deser       : for i in 0 to M-1 generate
    bootdeser : bootdeserialize
      port map (
        CLK   => CLK,
        DIN   => SEROUT(i),
        FPROG => fprogout(i),
        FDIN  => fdinout(i),
        FCLK  => fclkout(i));
  end generate deser;


  CLK <= not CLK after 10 ns;

  process
  begin
    wait for 100 ns;

    wait until rising_edge(CLK);
    asel  <= X"11111";
    fclk  <= '1';
    fprog <= '0';
    fdin  <= '0';
    fset  <= '1';
    wait until rising_edge(CLK);
    fset  <= '0';
    wait until rising_edge(CLK) and fdone = '1';
    wait for 50 ns;


    -- check
    for i in 0 to M - 1 loop
      if asel(i) = '1' then
        assert fprogout(i) = fprog report "Error in setting FPROG"
          severity error;
        assert fclkout(i) = fclk report "Error in setting FCLK"
          severity error;
        assert fdinout(i) = fdin report "Error in setting FDIN"
          severity error;
      end if;
    end loop;  -- i

    wait for 50 ns;



    wait until rising_edge(CLK);
    asel  <= X"22222";
    fclk  <= '0';
    fprog <= '1';
    fdin  <= '1';
    fset  <= '1';
    wait until rising_edge(CLK);
    fset  <= '0';
    wait until rising_edge(CLK) and fdone = '1';
    wait for 50 ns;


    -- check
    for i in 0 to M - 1 loop
      if asel(i) = '1' then
        assert fprogout(i) = fprog report "Error in setting FPROG"
          severity error;
        assert fclkout(i) = fclk report "Error in setting FCLK"
          severity error;
        assert fdinout(i) = fdin report "Error in setting FDIN"
          severity error;
      end if;
    end loop;  -- i

    -- check to make sure non-selected outputs were not modified
    for i in 1 to M - 1 loop
      if asel(i) = '1' then
        assert fprogout(i-1) = '0' report "Error in not setting FPROG"
          severity error;
        assert fclkout(i-1) = '1' report "Error in not setting FCLK"
          severity error;
        assert fdinout(i-1) = '0' report "Error in not  setting FDIN"
          severity error;
      end if;
    end loop;  -- i




    assert false report "End of Simulation" severity failure;


  end process;
end Behavioral;
