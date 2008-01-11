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

  signal SEROUT : std_logic_vector(19 downto 0) := (others => '0');
  signal ASEL   : std_logic_vector(19 downto 0) := (others => '0');

  component bootdeserialize
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic;
      FPROG : out std_logic;
      FDIN  : out std_logic;
      FCLK  : out std_logic);
  end component;

  component bootserperipheral
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      ADDRIN : in  std_logic_vector(2 downto 0);
      WEIN   : in  std_logic;
      SEROUT : out std_logic_vector(19 downto 0));
  end component;


  signal fprogout : std_logic_vector(19 downto 0) := (others => '1');
  signal fdinout  : std_logic_vector(19 downto 0) := (others => '1');
  signal fclkout  : std_logic_vector(19 downto 0) := (others => '1');

  signal DIN    : std_logic_vector(15 downto 0) := (others => '0');
  signal ADDRIN : std_logic_vector(2 downto 0)  := (others => '0');
  signal WEIN   : std_logic                     := '0';

  signal clk : std_logic := '0';

  signal inbits1 : std_logic_vector(47 downto 0) := X"0123456789AB";

begin  -- Behavioral

  bootserperipheral_uut : bootserperipheral
    port map (
      CLK    => CLK,
      DIN    => DIN,
      ADDRIN => ADDRIN,
      WEIN   => WEIN,
      SEROUT => SEROUT);

  deser       : for i in 0 to 19 generate
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
    DIN    <= X"00FF";
    ADDRIN <= "000";
    wait until rising_edge(CLK);
    WEIN   <= '1';
    wait until rising_edge(CLK);
    WEIN   <= '0';
    for i in 0 to 19 loop
      assert fprogout(i) = '1' report
        "Error with initial fprog" severity error;
    end loop;  -- i


    -- try setting FPROG
    ADDRIN <= "011";
    wait until rising_edge(CLK);
    WEIN   <= '1';
    wait until rising_edge(CLK);
    WEIN   <= '0';

    wait until falling_edge(fprogout(0));
    for i in 0 to 7 loop
      assert fprogout(i) = '0' report "Error in fprog" severity error;
    end loop;
    wait until rising_edge(fprogout(0));
    for i in 0 to 7 loop
      assert fprogout(i) = '1' report "Error in fprog" severity error;
    end loop;

    -- set the bits
    for dword in 0 to 2 loop
      ADDRIN <= "010";
      DIN    <= inbits1(dword * 16 + 15 downto dword * 16);
      wait until rising_edge(CLK);
      WEIN   <= '1';
      wait until rising_edge(CLK);
      WEIN   <= '0';
    end loop;  -- dword

    -- send the bits
    ADDRIN <= "100";
    wait until rising_edge(CLK);
    WEIN   <= '1';
    wait until rising_edge(CLK);
    WEIN   <= '0';

    -- verify the bits
    for dword in 0 to 2 loop
      for bn in 0 to 15 loop
        wait until rising_edge(fclkout(0));
        assert fdinout(0) = inbits1(dword * 16 + bn)
          report "Error in din" severity Error;

      end loop;  -- bn
    end loop;  -- dword



    assert false report "End of Simulation" severity failure;


  end process;



end Behavioral;
