
-- VHDL Test Bench Created from source file input.vhd  -- 12:34:13 04/04/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity recovertest is
end recovertest;

architecture behavior of recovertest is

  component recover
    port ( CLKIN    : in  std_logic;
           RESET    : in  std_logic;
           DIN      : in  std_logic;
           DOUT     : out std_logic;
           DOEN     : out std_logic;
           RXCLKOUT : out std_logic
           );

  end component;



  signal CLK      : std_logic                    := '0';
  signal TXCLK    : std_logic                    := '0';
  signal DIN      : std_logic                    := '0';
  signal BIN      : std_logic_vector(3 downto 0) := (others => '0');
  signal DOUT     : std_logic                    := '0';
  signal DOEN     : std_logic                    := '0';
  signal RXCLKOUT : std_logic                    := '0';
  signal RESET : std_logic := '0';
  
  signal EQ : std_logic := '0';

  signal   sendarray          : std_logic_vector(63 downto 0) := (others => '0');
  signal   rxarray, allbits   : std_logic_vector(63 downto 0) := (others => '0');
  signal   dataendeq, dataeq  : std_logic                     := '0';
  signal   txperiod, rxperiod : time                          := 4.1666 ns;
  signal   sendcycle          : std_logic                     := '0';
  constant clkinperiod       : time                          := 8  ns;


begin

  recover_uut : recover port map (
    CLKIN    => CLK,
    RESET    => RESET,
    DIN      => DIN,
    DOUT     => DOUT,
    DOEN     => DOEN,
    RXCLKOUT => RXCLKOUT);



  CLK <= not CLK after clkinperiod / 2; 
  RESET <= '0' after 20 ns;
  
  TXCLK     <= not TXCLK after txperiod/2;
  sendarray <= X"ad548aC7D1241A9C";

  dataendeq <= '1' when rxarray(63 downto 7) = sendarray(63 downto 7) else '0';
  dataeq    <= '1' when rxarray = sendarray                           else '0';


  process (TXCLK)
    variable pos : integer := 0;
  begin
    if rising_edge(TXCLK) then
      if pos = 0 then
        sendcycle <= '1';
      else
        sendcycle <= '0';
      end if;
      if pos = 63 then
        pos                := 0;
      else
        pos                := pos + 1;

      end if;

      din <= sendarray(pos);
    end if;
  end process;

  recoverdata : process (RXCLKOUT)
  begin
    if rising_edge(RXCLKOUT) then
      if DOEN = '1' then
        rxarray <= DOUT & rxarray(63 downto 1);

      end if;
      allbits <= DOUT & allbits(63 downto 1);
    end if;

  end process recoverdata;


  verify : process
  begin
    for i in -10 to 10 loop

      txperiod <= clkinperiod * 16.0/31*(1+i/20); 
      rxperiod <= clkinperiod / 2;
      wait until rising_edge(dataeq);

    end loop;  -- i
    report "End Of Simulation" severity failure;


  end process;

end;
