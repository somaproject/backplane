library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library SOMA;
use SOMA.somabackplane.all;
use soma.somabackplane;

entity datatest is

end datatest;


architecture Behavioral of datatest is

  component data
    port (
      CLK         : in  std_logic;
      MEMCLK      : in  std_logic;
      ECYCLE      : in  std_logic;
      MYIP        : in  std_logic_vector(31 downto 0);
      MYMAC       : in  std_logic_vector(47 downto 0);
      MYBCAST     : in  std_logic_vector(31 downto 0);
      FIFOOFERR   : out std_logic;
      -- input
      DIENA       : in  std_logic;
      DINA        : in  std_logic_vector(7 downto 0);
      DIENB       : in  std_logic;
      DINB        : in  std_logic_vector(7 downto 0);
      -- tx output
      DOUT        : out std_logic_vector(15 downto 0);
      DOEN        : out std_logic;
      ARM         : out std_logic;
      GRANT       : in  std_logic;
      -- retx interface
      RETXID      : out std_logic_vector(13 downto 0);
      RETXDONE    : out std_logic;
      RETXPENDING : in  std_logic;
      RETXDOUT    : out std_logic_vector(15 downto 0);
      RETXADDR    : out std_logic_vector(8 downto 0);
      RETXWE      : out std_logic
      );
  end component;

  signal CLK       : std_logic                     := '0';
  signal MEMCLK    : std_logic                     := '0';
  signal mainclk   : std_logic                     := '0';
  signal clkpos    : integer                       := 0;
  signal MYMAC     : std_logic_vector(47 downto 0) := (others => '0');
  signal MYIP      : std_logic_vector(31 downto 0) := (others => '0');
  signal MYBCAST   : std_logic_vector(31 downto 0) := (others => '0');
  signal FIFOOFERR : std_logic                     := '0';

  -- inputs
  signal DIENA, DIENB : std_logic                    := '0';
  signal DINA, DINB   : std_logic_vector(7 downto 0) := (others => '0');

  -- outputs
  signal DOUT  : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN  : std_logic                     := '0';
  signal ARM   : std_logic                     := '0';
  signal GRANT : std_logic                     := '0';

  -- retx IF
  signal RETXID      : std_logic_vector(13 downto 0) := (others => '0');
  signal RETXDONE    : std_logic                     := '0';
  signal RETXPENDING : std_logic                     := '0';
  signal RETXDOUT    : std_logic_vector(15 downto 0) := (others => '0');
  signal RETXADDR    : std_logic_vector(8 downto 0)  := (others => '0');
  signal RETXWE      : std_logic                     := '0';

  signal ECYCLE : std_logic := '0';

  -- input
  signal lenpkt : std_logic_vector(15 downto 0) := (others => '0');

  signal DATAEXPECTED : std_logic_vector(15 downto 0) := (others => '0');
  signal DATAERROR    : std_logic                     := '0';

-- simulated eventbus
  signal epos : integer := 0;

  type outbuffer_t is array (0 to 511) of std_logic_vector(15 downto 0);
  signal outbuffer : outbuffer_t := (others => (others => '0'));



begin  -- Behavioral

  data_uut : data
    port map (
      CLK         => CLK,
      MEMCLK      => MEMCLK,
      ECYCLE      => ECYCLE,
      MYIP        => MYIP,
      MYMAC       => MYMAC,
      MYBCAST     => MYBCAST,
      FIFOOFERR   => FIFOOFERR,
      DIENA       => DIENA,
      DINA        => DINA,
      DIENB       => DIENB,
      DINB        => DINB,
      DOUT        => DOUT,
      DOEN        => DOEN,
      ARM         => ARM,
      GRANT       => GRANT,
      RETXID      => RETXID,
      RETXDONE    => RETXDONE,
      RETXPENDING => RETXPENDING,
      RETXDOUT    => RETXDOUT,
      RETXADDR    => RETXADDR,
      RETXWE      => RETXWE);


  MYMAC <= X"0011d882a689";

  MYIP    <= X"c0a80002";
  MYBCAST <= X"c0a800FF";

  -- basic clocking
  mainclk <= not mainclk after 1.66666 ns;

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      MEMCLK   <= not memclk;
      if clkpos = 5 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;
      if clkpos = 0 then
        CLK    <= '1';
      elsif clkpos = 3 then
        CLK    <= '0';
      end if;
    end if;
  end process;


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
    assert false report "End of Simulation" severity failure;

  end process datainput;

  -- output validate
  dataoutput         : process
    file dataoutfile : text;
    variable L       : line;
    variable len     : integer                       := 0;
    variable data    : std_logic_vector(15 downto 0) := (others => '0');
  begin
    file_open(dataoutfile, "data.txt");
    while not endfile(dataoutfile) loop
      readline(dataoutfile, L);
      read(L, len);
      wait until rising_edge(CLK) and ARM = '1';
      wait until rising_edge(CLK);
      GRANT   <= '1';
      wait until rising_edge(CLK);
      for i in 0 to len-1 loop
        wait until rising_edge(CLK) and DOEN = '1';
        GRANT <= '0';
        hread(L, data);
        assert data = dout report "Error reading data byte" severity Error;

      end loop;  -- i
    end loop; 

  end process dataoutput;
  
end Behavioral;
