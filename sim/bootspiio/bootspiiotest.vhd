library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity bootspiiotest is

end bootspiiotest;

architecture Behavioral of bootspiiotest is

  component bootspiio
    port (
      CLK     : in  std_logic;
      CURBYTE : out std_logic_vector(10 downto 0);
      DOUT    : out std_logic_vector(15 downto 0);
      DIN     : in  std_logic_vector(15 downto 0);
      ADDR    : in  std_logic_vector(9 downto 0);
      WE      : in  std_logic;
      CMDDONE : out std_logic;
      CMDREQ  : in  std_logic;
      -- SPI INTERFACE
      CLKHI   : in  std_logic;
      SPIMOSI : in  std_logic;
      SPIMISO : out std_logic;
      SPICS   : in  std_logic;
      SPICLK  : in  std_logic);
  end component;

  signal CLK : std_logic := '0';

  signal CURBYTE : std_logic_vector(10 downto 0) := (others => '0');
  signal DOUT    : std_logic_vector(15 downto 0) := (others => '0');
  signal DIN     : std_logic_vector(15 downto 0) := (others => '0');
  signal ADDR    : std_logic_vector(9 downto 0)  := (others => '0');

  signal WE      : std_logic := '0';
  signal CMDDONE : std_logic := '0';
  signal CMDREQ  : std_logic := '0';
  -- SPI INTERFACE
  signal CLKHI   : std_logic := '0';
  signal SPIMOSI : std_logic := '0';
  signal SPIMISO : std_logic := '0';
  signal SPICS   : std_logic := '1';
  signal SPICLK  : std_logic := '0';

  signal mainclk : integer range 0 to 5 := 0;
  signal wordinAsig : std_logic_vector(63 downto 0) := (others => '0');
  signal wordinBsig : std_logic_vector(95 downto 0) := (others => '0');
  
begin
  bootspiio_uut: bootspiio
    port map (
      CLK     => CLK,
      CURBYTE => CURBYTE,
      DOUT    => DOUT,
      DIN     => DIN,
      ADDR    => ADDR,
      WE      => WE,
      CMDDONE => CMDDONE,
      CMDREQ  => CMDREQ,
      CLKHI   => CLKHI,
      SPIMOSI => SPIMOSI,
      SPIMISO => SPIMISO,
      SPICS   => SPICS,
      SPICLK  => SPICLK);

  mainclk <= (mainclk + 1) mod 6 after 3.333333333333 ns;
  CLKHI <= '1' when mainclk = 0 or mainclk = 2 or mainclk = 4 else '0';
  CLK <= '1' when mainclk = 0 or mainclk = 1 or mainclk = 2 else '0';
  

  -- fake spi if
  process
    variable wordinA : std_logic_vector(63 downto 0) := (others => '0');
    variable wordinB : std_logic_vector(95 downto 0) := (others => '0');
    variable wordoutC : std_logic_vector(127 downto 0) := X"012332104567765489abba98cdeffedc";
    
    begin
      wait until rising_edge(SPIMISO);
      wait for 100 ns;
      wait until rising_edge(CLK);
      SPICS <= '0'; 
       wait until rising_edge(CLK);
       wait until rising_edge(CLK);
       wait until rising_edge(CLK);
      for i in 0 to 63 loop
        wordina(63 - i) := SPIMISO;
        wordinAsig(63 - i) <= SPIMISO; 
        wait until rising_edge(CLK);
        SPICLK <= '1';
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        SPICLK <= '0';
      end loop;  -- i
                           
      SPICS <= '1';
      -- we've now read the first one!
      wait for 20 ns;
      
      assert wordinA = X"1111222233334444"
        report "error reading wordinA" severity Error;


      wait until rising_edge(SPIMISO);
      wait for 100 ns;
      wait until rising_edge(CLK);
      SPICS <= '0'; 
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for i in 0 to 95 loop
        wordinb(95 - i) := SPIMISO;
        wordinbsig(95 - i) <= SPIMISO; 
        wait until rising_edge(CLK);
        SPICLK <= '1';
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        SPICLK <= '0';
      end loop;  -- i
                           
      SPICS <= '1';
      -- we've now read the first one!
      wait for 20 ns;

      assert wordinB = X"0123456789ABCDEF11223344"
        report "error reading wordinB" severity Error;

      -- now the output
      wait until rising_edge(SPIMISO);
      wait for 100 ns;
      wait until rising_edge(CLK);
      SPICS <= '0'; 
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for i in 0 to 127 loop
        SPIMOSI <= wordoutc(127 -i );
        wait until rising_edge(CLK);
        SPICLK <= '1';
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        SPICLK <= '0';
      end loop;  -- i
      SPICS <= '1';
      
      wait; 
    end process; 
  

    -- fake output control
    process
      begin
        wait for 100 ns;
        wait until rising_edge(CLK);
        DIN <= X"1111";
        ADDR <= "0000000000";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"2222";
        ADDR <= "0000000001";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"3333";
        ADDR <= "0000000010";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"4444";
        ADDR <= "0000000011";
        WE <= '1';
        wait until rising_edge(CLK);
        WE <= '0';
        CMDREQ <= '1';
        wait until rising_edge(CLK);
        CMDREQ <= '0';
        wait until rising_edge(CMDDONE);

        
        wait for 100 ns;
        wait until rising_edge(CLK);
        DIN <= X"0123";
        ADDR <= "0000000000";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"4567";
        ADDR <= "0000000001";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"89AB";
        ADDR <= "0000000010";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"CDEF";
        ADDR <= "0000000011";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"1122";
        ADDR <= "0000000100";
        WE <= '1';
        wait until rising_edge(CLK);
        DIN <= X"3344";
        ADDR <= "0000000101";
        WE <= '1';
        wait until rising_edge(CLK);
        WE <= '0';
        CMDREQ <= '1';
        wait until rising_edge(CLK);
        CMDREQ <= '0';
        wait until rising_edge(CMDDONE);

        wait for 100 ns;
        wait until rising_edge(CLK);
        WE <= '0';
        CMDREQ <= '1';
        wait until rising_edge(CLK);
        CMDREQ <= '0';
        wait until rising_edge(CMDDONE);
        wait until rising_edge(CLK);
        ADDR <= "0000000000";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"0123" report "Error reading addr 0" severity Error;

        ADDR <= "0000000001";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"3210" report "Error reading addr 1" severity Error;

        ADDR <= "0000000010";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"4567" report "Error reading addr 2" severity Error;

        ADDR <= "0000000011";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"7654" report "Error reading addr 3" severity Error;

        ADDR <= "0000000100";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"89AB" report "Error reading addr 4" severity Error;
        
        ADDR <= "0000000101";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"BA98" report "Error reading addr 5" severity Error;
        
        ADDR <= "0000000110";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"CDEF" report "Error reading addr 6" severity Error;
        
        ADDR <= "0000000111";
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);
        assert DOUT = X"FEDC" report "Error reading addr 7" severity Error;

        report "End of Simulation" severity Failure;
        
        wait;
        
      end process; 
end Behavioral;
