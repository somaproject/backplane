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

entity datathroughputtest is

end datathroughputtest;


architecture Behavioral of datathroughputtest is

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
  signal epos              : integer := 0;
  signal pktnum : integer := 0;
  signal delay             : time := 1 ns;

  signal fifoerrcnt : integer := 5;
  

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

  datainput : process
    variable pktcnta, pktcntb :
      std_logic_vector(15 downto 0) := (others => '0');

  begin
    while true loop
      wait until rising_edge(CLK) and ECYCLE = '1';

      for i in 1 to 10 loop
        wait until rising_edge(CLK);
      end loop;  -- i

      -- type byte
      DIENA <= '1';
      DINA  <= X"00";
      DIENB <= '1';
      DINB  <= X"00";
      wait until rising_edge(CLK);

      -- source byte
      DIENA <= '1';
      DINA  <= X"00";
      DIENB <= '1';
      DINB  <= X"00";
      wait until rising_edge(CLK);

      pktcnta := std_logic_vector(TO_UNSIGNED(pktnum*2, 16));
      pktcntb := std_logic_vector(TO_UNSIGNED(pktnum*2+1, 16));

      -- ID, high byte
      DIENA <= '1';
      DINA  <= pktcnta(15 downto 8);
      DIENB <= '1';
      DINB  <= pktcnta(15 downto 8);
      wait until rising_edge(CLK);

      -- ID, low byte
      DIENA <= '1';
      DINA  <= pktcnta(7 downto 0);
      DIENB <= '1';
      DINB  <= pktcnta(7 downto 0);
      wait until rising_edge(CLK);

      for i in 0 to 595 loop
        DIENA <= '1';
        DINA  <= X"00";
        DIENB <= '1';
        DINB  <= X"00";
        wait until rising_edge(CLK);
      end loop;  -- i

      -- terminate packet

      DIENA  <= '0';
      DINA   <= X"00";
      DIENB  <= '0';
      DINB   <= X"00";
      wait until rising_edge(CLK);
      pktnum <= pktnum + 1;
    end loop;
  end process datainput;

  process
  begin
    delay <= 20 us;
    for i in 1 to fifoerrcnt loop
      wait until rising_edge(CLK) and FIFOOFERR = '1';
      
    end loop;  -- i
    delay <= 1 ns;
    wait for 1000 us;
    report "End of Simulation" severity failure;
    
  end process;

  -- output validate
  dataoutput : process
    variable fecnt : integer := 0;
    variable pktnumout : integer := 0;
    
  begin
    fecnt := fifoerrcnt;                -- local copy
    while true loop

      wait until rising_edge(CLK) and ARM = '1';
      wait until rising_edge(CLK);
      GRANT   <= '1';
      wait until rising_edge(CLK);
      for i in 0 to 299 loop
        wait until rising_edge(CLK) and DOEN = '1';
        GRANT <= '0';
        if i = 23 then
          
            while pktnumout /= TO_INTEGER(unsigned(DOUT)) and fecnt >= 0 loop
              report "pktnumout = " & integer'image(pktnumout) & " wheras dout is " & integer'image(TO_INTEGER(unsigned(DOUT))) & " with fecnt =" & integer'image(fecnt ); 
              
              pktnumout := pktnumout + 1;
              fecnt := fecnt - 1;
            end loop; 
              
            assert pktnumout = TO_INTEGER(unsigned(DOUT)) report "Error in rx packetnum, expecting " & integer'image(pktnumout) & " but got " & integer'image(TO_INTEGER(unsigned(DOUT))) severity error;

        end if;
      end loop;  -- i
      pktnumout := pktnumout + 1;
      -- wait for 10 us, to allow fifo to overflow
      wait for delay;
    end loop;

  end process dataoutput;
end Behavioral;
