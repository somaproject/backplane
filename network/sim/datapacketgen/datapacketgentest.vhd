library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity datapacketgentest is

end datapacketgentest;


architecture Behavioral of datapacketgentest is

  component dataacquire
    port (
      CLK    : in  std_logic;
      ECYCLE : in  std_logic;
      DIN    : in  std_logic_vector(7 downto 0);
      DIEN   : in  std_logic;
      DOUT   : out std_logic_vector(15 downto 0);
      ADDR   : in  std_logic_vector(8 downto 0);
      LEN    : out std_logic_vector(9 downto 0));
  end component;

  component datapacketgen
    port (
      CLK       : in  std_logic;
      ECYCLE    : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      MYBCAST   : in  std_logic_vector(31 downto 0);
      ADDRA     : out std_logic_vector(8 downto 0);
      LENA      : in  std_logic_vector(9 downto 0);
      DIA       : in  std_logic_vector(15 downto 0);
      ADDRB     : out std_logic_vector(8 downto 0);
      LENB      : in  std_logic_vector(9 downto 0);
      DIB       : in  std_logic_vector(15 downto 0);
      -- output interface at 100 MHz
      MEMCLK    : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      ADDROUT   : in  std_logic_vector(8 downto 0);
      FIFOVALID : out std_logic;
      FIFONEXT  : in  std_logic
      );
  end component;


  signal MEMCLK : std_logic := '0';

  signal CLK     : std_logic                     := '0';
  signal MYMAC   : std_logic_vector(47 downto 0) := (others => '0');
  signal MYIP    : std_logic_vector(31 downto 0) := (others => '0');
  signal MYBCAST : std_logic_vector(31 downto 0) := (others => '0');
  signal ECYCLE  : std_logic                     := '0';

  -- inputs
  signal DIENA, DIENB : std_logic                    := '0';
  signal DINA, DINB   : std_logic_vector(7 downto 0) := (others => '0');

  -- interconnect
  signal ACQDIA, ACQDIB     : std_logic_vector(15 downto 0) := (others => '0');
  signal ACQADDRA, ACQADDRB : std_logic_vector(8 downto 0)  := (others => '0');

  signal LENA, LENB : std_logic_vector(9 downto 0) := (others => '0');

  -- outputs
  signal DOUT      : std_logic_vector(15 downto 0) := (others => '0');
  signal ADDROUT   : std_logic_vector(8 downto 0)  := (others => '0');
  signal FIFONEXT  : std_logic                     := '0';
  signal FIFOVALID : std_logic                     := '0';


  -- input
  signal lenpkt : std_logic_vector(15 downto 0) := (others => '0');

  signal DATAEXPECTED : std_logic_vector(15 downto 0) := (others => '0');
  signal DATAERROR    : std_logic                     := '0';

-- simulated eventbus
  signal epos : integer := 0;

begin  -- Behavioral

  datapacketgen_uut : datapacketgen
    port map (
      CLK       => CLK,
      ECYCLE    => ECYCLE,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      MYBCAST   => mYBCAST,
      ADDRA     => ACQADDRA,
      LENA      => LENA,
      DIA       => ACQDIA,
      ADDRB     => ACQADDRB,
      LENB      => LENB,
      DIB       => ACQDIB,
      MEMCLK    => MEMCLK,
      DOUT      => DOUT,
      ADDROUT   => ADDROUT,
      FIFOVALID => FIFOVALID,
      FIFONEXT  => FIFONEXT);

  acqa_uut : dataacquire
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      DIN    => DINA,
      DIEN   => DIENA,
      DOUT   => ACQDIA,
      ADDR   => ACQADDRA,
      LEN    => LENA );

  acqb_uut : dataacquire
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      DIN    => DINB,
      DIEN   => DIENB,
      DOUT   => ACQDIB,
      ADDR   => ACQADDRB,
      LEN    => LENB );

  MYMAC <= X"0011d882a689";

  MYIP    <= X"c0a80002";
  MYBCAST <= X"c0a800FF";

  -- basic clocking
  MEMCLK  <= not MEMCLK after 5 ns;
  clkproc : process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then
      CLK <= not CLK;
    end if;
  end process clkproc;

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

  -- input stage

  datainput                   : process
    file datafilea, datafileb : text;
    variable L                : line;
    variable doen             : std_logic                    := '0';
    variable data             : std_logic_vector(7 downto 0) := (others => '0');

  begin
    file_open(datafilea, "dataa.txt");
    file_open(datafileb, "datab.txt");

    wait until rising_edge(CLK) and ECYCLE = '1';
    while not endfile(datafilea) loop

      readline(datafilea, L);
      read(L, doen);
      hread(L, data);
      DINA  <= data;
      DIENA <= doen;

      readline(datafileb, L);
      read(L, doen);
      hread(L, data);
      DINB  <= data;
      DIENB <= doen;
      wait until rising_edge(CLK);

    end loop;
    assert False report "End of Simulation" severity failure;

    
  end process datainput;


  -- capture the output packets

  outputget          : process
    file netdatafile : text;
    variable L       : line;
    variable data    : std_logic_vector(15 downto 0) := (others => '0');
    variable len     : integer                       := 0;

  begin
    file_open(netdatafile, "data.txt");

    while not endfile(netdatafile) loop
      wait until rising_edge(MEMCLK) and ECYCLE = '1';

      -- read length
      for j in 0 to 1 loop


        if FIFOVALID = '1' then
          readline(netdatafile, L);
          read(L, len);
          ADDROUT <= (others => '0');
          wait until rising_edge(MEMCLK);

          for i in 0 to len -1 loop
            wait until rising_edge(MEMCLK);
            hread(L, data);
            DATAEXPECTED <= data;
            wait for 1 ns;

            if data /= DOUT then
              DATAERROR <= '1';
            else
              DATAERROR <= '0';
            end if;
            wait for 1 ns;
            assert data = DOUT report "Error reading data" severity error;
            ADDROUT     <= ADDROUT + 1;

          end loop;  -- i

          wait until rising_edge(MEMCLK);
          FIFONEXT <= '1';
          wait until rising_edge(MEMCLK);
          FIFONEXT <= '0';
          wait for 2 us;
          wait until rising_edge(MEMCLK);
          wait until rising_edge(MEMCLK);
          wait until rising_edge(MEMCLK);

        end if;
      end loop;  -- j
    end loop;

    assert False report "End of Simulation" severity Failure;
    
  end process outputget;

end Behavioral;
