library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
use WORK.somabackplane.all;
use Work.somabackplane;

entity networktest is

end networktest;

architecture Behavioral of networktest is

  component network
    port (
      CLK          : in  std_logic;
      MEMCLK       : in  std_logic;
      RESET        : in  std_logic;
      -- config
      MYIP         : in  std_logic_vector(31 downto 0);
      MYMAC        : in  std_logic_vector(47 downto 0);
      MYBCAST      : in  std_logic_vector(31 downto 0);
      -- input
      NICNEXTFRAME : out std_logic;
      NICDINEN     : in  std_logic;
      NICDIN       : in  std_logic_vector(15 downto 0);
      -- output
      DOUT         : out std_logic_vector(15 downto 0);
      NEWFRAME     : out std_logic;
      IOCLOCK      : out std_logic;

      -- event bus
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX    : in  std_logic_vector(7 downto 0);

      -- data bus
      DIENA   : in    std_logic;
      DINA    : in    std_logic_vector(7 downto 0);
      DIENB   : in    std_logic;
      DINB    : in    std_logic_vector(7 downto 0);
      -- memory interface
      RAMDQ   : inout std_logic_vector(15 downto 0);
      RAMWE   : out   std_logic;
      RAMADDR : out   std_logic_vector(16 downto 0);
      RAMCLK  : out   std_logic

      );
  end component;



  signal CLK          : std_logic                     := '0';
  signal memclk : std_logic := '0';
  
  signal RESET        : std_logic                     := '1';
  -- config
  signal MYIP         : std_logic_vector(31 downto 0) := (others => '0');
  signal MYMAC        : std_logic_vector(47 downto 0) := (others => '0');
  signal MYBCAST      : std_logic_vector(31 downto 0) := (others => '0');
  -- input
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');
  -- output
  signal DOUT         : std_logic_vector(15 downto 0) := (others => '0');
  signal NEWFRAME     : std_logic                     := '0';
  signal IOCLOCK      : std_logic                     := '0';

  -- event bus
  signal ECYCLE : std_logic := '0';

  signal EARX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EATX : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  signal EDTX : std_logic_vector(7 downto 0) := (others => '0');

  -- ram
  signal RAMCLK : std_logic := '0';
  signal RAMADDR : std_logic_vector(16 downto 0) := (others => '0');
  signal RAMWE : std_logic := '1';
  signal RAMDQ : std_logic_vector(15 downto 0) := (others => 'Z');

  -- data bus
  signal dina, dinb : std_logic_vector(7 downto 0) := (others => '0');
  signal diena, dienb : std_logic := '0';

-- simulated eventbus
  signal epos : integer := 0;

-- memory signals
  signal ramwel, ramwell     : std_logic := '0';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                         := (others => '0');
  

begin  -- Behavioral

  network_uut : network
    port map (
      CLK          => CLK,
      MEMCLK => MEMCLK,
      RESET        => RESET,
      MYIP         => MYIP,
      MYMAC        => MYMAC,
      MYBCAST      => MYBCAST,
      NICNEXTFRAME => NICNEXTFRAME,
      NICDINEN     => NICDINEN,
      NICDIN       => NICDIN,

      DOUT         => DOUT,
      NEWFRAME     => NEWFRAME,
      IOCLOCK      => IOCLOCK,

      ECYCLE       => ECYCLE,
      EARX         => EARX,
      EATX         => EATX,
      EDRX         => EDRX,
      EDSELRX      => EDSELRX,
      EDTX         => EDTX,

      DIENA => DIENA,
      DINA => DINA,
      DIENB => DIENB,
      DINB => DINB,

      RAMDQ => RAMDQ,
      RAMWE => RAMWE,
      RAMADDR => RAMADDR,
      RAMCLK => RAMCLK);

  CLK   <= not CLK after 10 ns;
  MEMCLK <= not CLK after 5 ns;
  
  RESET <= '0'     after 20 ns;
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
  -- configuration fields for device identity
  -- 
  myip    <= X"C0a80002";               -- 192.168.0.2
  mybcast <= X"C0a000FF";
  mymac   <= X"DEADBEEF1234";

  main : process
  begin
    wait for 2 us;
--    networkstack.writepkt("arpquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
    wait for 2 us;

--    networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);
--    networkstack.writepkt("pingquery.txt", CLK, NICDINEN, NICNEXTFRAME, NICDIN);

    wait;

  end process main;

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

  memoryinst : process(MEMCLK, ramwel)
    -- memory construct
    type ramdata is array ( 0 to 131071)
    of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    if ramwel = '0' then
      RAMDQ   <= (others => 'Z');
    end if;
    if rising_edge(MEMCLK) then
      ramwel  <= RAMWE;
      ramwell <= ramwel;

      ramaddrl  <= RAMADDR;
      ramaddrll <= ramaddrl;

      if ramwell = '0' then
        memory(TO_INTEGER(unsigned(ramaddrll))) := RAMDQ;
      else
        RAMDQ <= memory(TO_INTEGER(unsigned(ramaddrll)));
      end if;

    end if;
  end process memoryinst;

  -- retx request and verify

end Behavioral;
