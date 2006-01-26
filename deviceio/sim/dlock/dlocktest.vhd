library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity dlocktest is
end dlocktest;

architecture behavior of dlocktest is

  component dlock
    port ( RXCLK     : in  std_logic;
           RXBYTECLK : in  std_logic;
           RESET     : in  std_logic;
           DEN       : in  std_logic;
           DIN       : in  std_logic;
           DOUT      : out std_logic_vector(9 downto 0);
           DOEN      : out std_logic
           );

  end component;

  signal RXCLK     : std_logic := '0';
  signal RXBYTECLK : std_logic := '0';
  signal RESET     : std_logic := '1';
  signal DEN       : std_logic := '0';


  signal DIN  : std_logic                    := '0';
  signal DOUT : std_logic_vector(9 downto 0) := (others => '0');
  signal DOEN : std_logic                    := '0';

  constant rxclkperiod : time := 8 ns;

  signal pendingword : std_logic_vector(9 downto 0) := (others => '0');

  
begin

  dlock_uut : dlock port map (
    RXCLK     => RXCLK,
    RXBYTECLK => RXBYTECLK,
    RESET     => RESET,
    DEN       => DEN,
    DOUT      => DOUT,
    DIN       => DIN,
    DOEN      => DOEN);

  RXCLK <= not RXCLK after rxclkperiod / 2;
  RESET <= '0'       after 20 ns;

  RXBYTECLK <= not RXBYTECLK after rxclkperiod/2*10;

  inputdata         : process
    file infile     : text;
    variable L      : line;
    variable i1, i2 : integer;

  begin
    wait until falling_edge(RESET);
    file_open(infile, "input.dat", read_mode);

    while not endfile(infile) loop
      wait until rising_edge(RXCLK);
      readline(infile, L);
      read(L, i1);
      read(L, i2);

      if i1 = 1 then
        DIN <= '1';
      else
        DIN <= '0';
      end if;

      if i2 = 1 then
        DEN <= '1';
      else
        DEN <= '0';
      end if;



    end loop;

  end process;


  -- verify
  verifydata    : process
    file infile : text;
    variable L  : line;
    variable word : bit_vector(9 downto 0);
    
  begin
    file_open(infile, "output.dat", read_mode); 

    while not endfile(infile) loop 
      readline(infile, L);

      for i in 0 to 39 loop
        read(L, word);
        pendingword <= to_stdlogicvector(word); 
        while not (to_stdlogicvector(word) = DOUT and DOEN = '1')  loop
          wait until rising_edge(RXBYTECLK);
        
        end loop;
      end loop;  -- i
      
    end loop;

    report "End of Simulation" severity FAILURE;

    
  end process; 


end;
