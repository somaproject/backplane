library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity datamempktinputtest is

end datamempktinputtest;

architecture Behavioral of datamempktinputtest is



  component datamempktinput
    port (
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      ADDROUT   : out std_logic_vector(8 downto 0);
      FIFOVALID : in  std_logic;
      FIFONEXT  : out std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      -- ram interface

      RAMWE   : out std_logic;
      RAMADDR : out std_logic_vector(16 downto 0);
      RAMDOUT : out std_logic_vector(15 downto 0);
      -- fifo properti
      SRC     : out std_logic_vector(5 downto 0);
      TYP     : out std_logic_vector(1 downto 0);
      ID      : out std_logic_vector(31 downto 0);
      IDWE    : out std_logic;
      BP      : out std_logic_vector(7 downto 0)
      );
  end component;

  signal CLK       : std_logic                     := '0';
  signal DIN       : std_logic_vector(15 downto 0) := (others => '0');
  signal ADDROUT   : std_logic_vector(8 downto 0)  := (others => '0');
  signal FIFOVALID : std_logic                     := '0';
  signal FIFONEXT  : std_logic                     := '0';
  signal START     : std_logic                     := '0';
  signal DONE      : std_logic                     := '0';
  -- ram interface

  signal RAMWE   : std_logic                     := '0';
  signal RAMADDR : std_logic_vector(16 downto 0) := (others => '0');
  signal RAMDOUT : std_logic_vector(15 downto 0) := (others => '0');
  -- fifo properti
  signal SRC     : std_logic_vector(5 downto 0)  := (others => '0');
  signal TYP     : std_logic_vector(1 downto 0)  := (others => '0');
  signal ID      : std_logic_vector(31 downto 0) := (others => '0');
  signal IDWE    : std_logic                     := '0';
  signal BP      : std_logic_vector(7 downto 0)  := (others => '0');

  signal RESET : std_logic := '1';

  -- latency ram validation
  signal ramwel, ramwell     : std_logic := '0';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                         := (others => '0');


begin  -- Behavioral


  datamempktinput_uut : datamempktinput
    port map (
      CLK       => CLK,
      DIN       => DIN,
      ADDROUT   => ADDROUT,
      FIFOVALID => FIFOVALID,
      FIFONEXT  => FIFONEXT,
      START     => START,
      DONE      => DONE,
      RAMWE     => RAMWE,
      RAMADDR   => RAMADDR,
      RAMDOUT   => RAMDOUT,
      SRC       => SRC,
      TYP       => TYP,
      ID        => ID,
      IDWE      => IDWE,
      BP        => BP);


  CLK <= not CLK after 5 ns;

  RESET <= '0' after 10 ns;

  testdata : process (RESET, CLK)
    type ramdata is array ( 0 to 1023)
      of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

    file datafile : text;

    variable L    : line;
    variable data : std_logic_vector(15 downto 0) := (others => '0');
    variable len  : integer                       := 0;

    variable intyp : std_logic_vector(7 downto 0)  := (others => '0');
    variable insrc : std_logic_vector(7 downto 0)  := (others => '0');
    variable inid  : std_logic_vector(31 downto 0) := (others => '0');

  begin  -- process testdata
    if rising_edge(CLK) then
      DIN <= memory(TO_INTEGER(unsigned(ADDROUT)));

      if RESET = '1' then
        file_open(datafile, "data.txt");

        readline(datafile, L);
        read(L, len);
        for i in 0 to len -1 loop
          hread(L, data);
          memory(i) := data;
        end loop;  -- i
      else
        if FIFONEXT = '1' then

          readline(datafile, L);
          read(L, len);
          for i in 0 to len -1 loop
            hread(L, data);
            memory(i) := data;
          end loop;  -- i

        end if;

      end if;

    end if;
  end process testdata;

  -- ram latency control
  ramlat : process(CLK)
  begin
    if rising_edge(CLK) then
      ramwel  <= RAMWE;
      ramwell <= ramwel;

      ramaddrl  <= RAMADDR;
      ramaddrll <= ramaddrl;

    end if;
  end process ramlat;


  control : process
  begin
    wait for 1 us;
    wait until rising_edge(CLK);
    FIFOVALID <= '1';
    START     <= '1';
    wait until rising_edge(CLK);
    START     <= '0';
    wait until rising_edge(CLK) and DONE = '1';

    -- example empty (fifo invalid) test
    FIFOVALID <= '0';
    wait until rising_edge(CLK);
    START     <= '1';
    wait until rising_edge(CLK);
    START     <= '0';
    wait until rising_edge(CLK) and DONE = '1';
    wait for 7 us;


-- another read
    wait for 1 us;
    wait until rising_edge(CLK);
    FIFOVALID <= '1';
    START     <= '1';
    wait until rising_edge(CLK);
    START     <= '0';
    wait until rising_edge(CLK) and DONE = '1';

    wait for 10 us;

    for i in 0 to 900 loop
      wait for 1 us;
      wait until rising_edge(CLK);
      FIFOVALID <= '1';
      START     <= '1';
      wait until rising_edge(CLK);
      START     <= '0';
      wait until rising_edge(CLK) and DONE = '1';

      
    end loop;  -- i

    assert False report "End of Simulation" severity Failure;

    
    
  end process control;

  -- property validate

  property_validate : process
    file propsfile  : text;

    variable L     : line;
    variable intyp : std_logic_vector(7 downto 0)  := (others => '0');
    variable insrc : std_logic_vector(7 downto 0)  := (others => '0');
    variable inid  : std_logic_vector(31 downto 0) := (others => '0');

  begin  -- process testdata
    file_open(propsfile, "dataprops.txt");

    while not endfile(propsfile) loop


      wait until rising_edge(CLK) and IDWE = '1';
      readline(propsfile, L);

      hread(L, intyp);
      assert intyp(1 downto 0) = TYP
        report "Error in extracting TYP" severity error;


      hread(L, insrc);
      assert insrc(5 downto 0) = SRC
        report "Error in extracting SRC" severity error;

      hread(L, inid);
      assert inid = ID
        report "Error in extracting ID" severity error;


    end loop;

  end process property_validate;

  -- data validate
  validate_data : process

    file datafile : text;

    variable L    : line;
    variable data : std_logic_vector(15 downto 0) := (others => '0');
    variable len  : integer                       := 0;



  begin  -- process testdata
    file_open(datafile, "data.txt");
    while true loop


      readline(datafile, L);
      read(L, len);
      for i in 0 to len-1 loop
        wait until rising_edge(CLK) and ramwell = '1';
        hread(L, data);
        assert data = ramdout
          report "Error reading output ram value" severity error;

      end loop;  -- i

      if FIFONEXT = '1' then
        readline(datafile, L);
        read(L, len);
      end if;

    end loop;


  end process;


end Behavioral;

