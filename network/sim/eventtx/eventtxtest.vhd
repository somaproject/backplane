library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity eventtxtest is

end eventtxtest;

architecture Behavioral of eventtxtest is

  component eventtx
    port (
      CLK    : in  std_logic;
      MYMAC  : in  std_logic_vector(47 downto 0);
      MYIP   : in  std_logic_vector(31 downto 0);
      MYBCAST  : in  std_logic_vector(31 downto 0);
      ECYCLE : in  std_logic;
      EDTX   : in  std_logic_vector(7 downto 0);
      EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
      DOUT   : out std_logic_vector(15 downto 0);
      DOEN   : out std_logic;
      GRANT  : in  std_logic;
      ARM    : out std_logic
      );

  end component;

  signal CLK    : std_logic := '0';
  signal MYMAC  : std_logic_vector(47 downto 0) := (others => '0');
  signal MYIP   : std_logic_vector(31 downto 0) := (others => '0');
  signal MYBCAST : std_logic_vector(31 downto 0) := (others => '0');
  signal ECYCLE : std_logic := '0';
  signal EDTX   : std_logic_vector(7 downto 0) := (others => '0');
  signal EATX   : std_logic_vector(somabackplane.N-1 downto 0) := (others => '0');
  signal DOUT   : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN   : std_logic := '0';
  signal GRANT  : std_logic := '0';
  signal ARM    : std_logic := '0';

-- simulated eventbus
  signal epos : integer := 0;
  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;



  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');


begin  -- Behavioral

  eventtx_uut: eventtx
    port map (
      CLK    => CLK,
      MYMAC  => MYMAC,
      MYIP   => MYIP,
      MYBCAST => MYBCAST, 
      ECYCLE => ECYCLE,
      EDTX   => EDTX,
      EATX   => EATX,
      DOUT   => DOUT,
      DOEN   => DOEN,
      GRANT  => GRANT,
      ARM    => ARM); 
    

  MYMAC <= X"0011d882a689";

  MYIP <= X"c0a80002";
  MYBCAST <= X"c0a800FF";
  
  -- basic clocking
  CLK <= not CLK after 10 ns;

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


  event_packet_generation : process
    file eventfile        : text;
    variable L            : line;
    variable ineatx : std_logic_vector(79 downto 0) ;
    variable datain : std_logic_vector(15 downto 0); 
      
  begin
    file_open(eventfile, "events.txt");
    while true loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      readline(eventfile, L);
      hread(L, ineatx);
      eatx <= ineatx(somabackplane.N - 1 downto 0) ;

      wait until rising_edge(CLK) and epos = 47;
      -- now we send the events
      readline(eventfile, L);
      
      for i in 0 to somabackplane.N -1 loop
        -- output the event bytes
        for j in 0 to 5 loop
          hread(L, datain); 
          EDTX <= datain(15 downto 8); 
          wait until rising_edge(CLK);
          EDTX <= datain(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;

  -- data verify
  process
    begin

      while true loop
        

      wait until rising_edge(CLK) and ARM = '1';
      wait for 1 us;
      wait until rising_edge(CLK);
      GRANT <= '1'; 
      wait until rising_edge(CLK);
      wait until rising_edge(CLK) and DOEN = '1';
      wait until rising_edge(CLK) and DOEN = '0';
      wait for 2 us;
      end loop;      

    end process; 
end Behavioral;
