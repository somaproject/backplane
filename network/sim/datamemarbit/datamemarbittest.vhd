library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity datamemarbittest is

end datamemarbittest;

architecture Behavioral of datamemarbittest is

  component datamemarbit
    port (
      CLK        : in    std_logic;
      -- RAM
      RAMWE      : out   std_logic;
      RAMADDR    : out   std_logic_vector(16 downto 0);
      RAMDQ      : inout std_logic_vector(15 downto 0);
      -- memory packet input
      FIFODIN    : in    std_logic_vector(15 downto 0);
      FIFOADDR   : out   std_logic_vector(8 downto 0);
      FIFOVALID  : in    std_logic;
      FIFONEXT   : out   std_logic;
      --retx request
      RETXDOUT   : out   std_logic_vector(15 downto 0);
      RETXADDR   : out   std_logic_vector(8 downto 0);
      RETXWE     : out   std_logic;
      RETXREQ    : in    std_logic;
      RETXDONE   : out   std_logic;
      RETXSRC    : in    std_logic_vector(5 downto 0);
      RETXTYP    : in    std_logic_vector(1 downto 0);
      RETXID     : in    std_logic_vector(31 downto 0);
      -- packet transmission
      TXDOUT     : out   std_logic_vector(15 downto 0);
      TXFIFOFULL : in    std_logic;
      TXFIFOADDR : out   std_logic_vector(8 downto 0);
      TXWE       : out   std_logic;
      TXDONE     : out   std_logic
      );
  end component;

  signal CLK        : std_logic                     := '0';
  -- RAM
  signal RAMWE      : std_logic                     := '0';
  signal RAMADDR    : std_logic_vector(16 downto 0) := (others => '0');
  signal RAMDQ      : std_logic_vector(15 downto 0) := (others => '0');
  -- memory packet input
  signal FIFODIN    : std_logic_vector(15 downto 0) := (others => '0');
  signal FIFOADDR   : std_logic_vector(8 downto 0)  := (others => '0');
  signal FIFOVALID  : std_logic                     := '0';
  signal FIFONEXT   : std_logic                     := '0';
  --retx request
  signal RETXDOUT   : std_logic_vector(15 downto 0) := (others => '0');
  signal RETXADDR   : std_logic_vector(8 downto 0)  := (others => '0');
  signal RETXWE     : std_logic                     := '0';
  signal RETXREQ    : std_logic                     := '0';
  signal RETXDONE   : std_logic                     := '0';
  signal RETXSRC    : std_logic_vector(5 downto 0)  := (others => '0');
  signal RETXTYP    : std_logic_vector(1 downto 0)  := (others => '0');
  signal RETXID     : std_logic_vector(31 downto 0) := (others => '0');
  -- packet transmission
  signal TXDOUT     : std_logic_vector(15 downto 0) := (others => '0');
  signal TXFIFOFULL : std_logic                     := '0';
  signal TXFIFOADDR : std_logic_vector(8 downto 0)  := (others => '0');
  signal TXWE       : std_logic                     := '0';
  signal TXDONE     : std_logic                     := '0';


  -- output vals
  signal expected_output_data, actual_output_data : std_logic_vector(15 downto 0) := (others => '0');

  signal expected_retx_data, actual_retx_data : std_logic_vector(15 downto 0) := (others => '0');

  signal ramwel, ramwell     : std_logic := '0';
  signal ramaddrl, ramaddrll : std_logic_vector(16 downto 0)
                                         := (others => '0');

  signal currentpkt : integer := 0;

begin  -- Behavioral

  CLK <= not clk after 5 ns;

  datamemarbit_uut : datamemarbit
    port map (
      CLK        => CLK,
      RAMWE      => RAMWE,
      RAMADDR    => RAMADDR,
      RAMDQ      => RAMDQ,
      FIFODIN    => FIFODIN,
      FIFOADDR   => FIFOADDR,
      FIFOVALID  => FIFOVALID,
      FIFONEXT   => FIFONEXT,
      RETXDOUT   => RETXDOUT,
      RETXADDR   => RETXADDR,
      RETXWE     => RETXWE,
      RETXREQ    => RETXREQ,
      RETXDONE   => RETXDONE,
      RETXSRC    => RETXSRC,
      RETXTYP    => RETXTYP,
      RETXID     => RETXID,
      TXDOUT     => TXDOUT,
      TXFIFOADDR => TXFIFOADDR,
      TXFIFOFULL => TXFIFOFULL,
      TXWE       => TXWE,
      TXDONE     => TXDONE);

  -- input process

  datainput        : process
    file datafile  : text;
    variable L     : line;
    variable delay : integer := 0;
    variable len   : integer := 0;

    variable data : std_logic_vector(15 downto 0) := (others => '0');
    -- memory construct
    type ramdata is array ( 0 to 1023)
      of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    file_open(datafile, "data.txt");
    while not endfile(datafile) loop
      FIFOVALID <= '0';

      readline(datafile, L);
      read(L, delay);
      read(L, len);

      -- wait for the delay
      for i in 0 to delay loop
        wait until rising_edge(CLK);
      end loop;  -- i

      for i in 0 to len -1 loop
        hread(L, memory(i));
      end loop;  -- i

      FIFOVALID <= '1';

      while FIFONEXT = '0' loop
        wait until rising_edge(CLK);
        FIFODIN <= memory(TO_INTEGER(unsigned(FIFOADDR)));

      end loop;
      currentpkt <= currentpkt + 1;

    end loop;

    assert false report "End of Simulation" severity failure;
  end process datainput;

  data_output_validate : process
    file datafile      : text;
    variable L         : line;
    variable delay     : integer := 0;
    variable len       : integer := 0;

    variable data : std_logic_vector(15 downto 0) := (others => '0');
    -- memory construct
    type ramdata is array ( 0 to 1023)
      of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    file_open(datafile, "data.txt");
    while not endfile(datafile) loop
      TXFIFOFULL <= '0';
      while TXDONE /= '1' loop
        wait until rising_edge(CLK);
        if TXWE = '1' then
          memory(TO_INTEGER(unsigned(TXFIFOADDR))) := TXDOUT;
        end if;
      end loop;


      readline(datafile, L);
      read(L, delay);
      read(L, len);

      for i in 0 to len -1 loop
        hread(L, data);
        expected_output_data <= data;
        actual_output_data   <= memory(i);
        assert memory(i) = data report "Error in TX data" severity error;
        wait for 0.5 ns;
      end loop;  -- i

      TXFIFOFULL <= '0';

    end loop;

  end process data_output_validate;



  memoryinst : process(CLK, ramwel)
    -- memory construct
    type ramdata is array ( 0 to 131071)
    of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    if ramwel = '0' then
      RAMDQ   <= (others => 'Z');
    end if;
    if rising_edge(CLK) then
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
  --


  retx_req_and_validate : process
    file retxfile       : text;
    variable L          : line;
    variable waitfornum : integer := 0;
    variable len        : integer := 0;
    variable idin       : std_logic_vector(31 downto 0);
    variable srcin      : std_logic_vector(7 downto 0);
    variable typin      : std_logic_vector(7 downto 0);


    variable data : std_logic_vector(15 downto 0) := (others => '0');
    -- memory construct
    type ramdata is array ( 0 to 1023)
      of std_logic_vector(15 downto 0);

    variable memory : ramdata := (others => X"0000");

  begin
    file_open(retxfile, "retxreq.txt");
    while not endfile(retxfile) loop
      readline(retxfile, L);
      read(L, waitfornum);
      hread(L, idin);
      hread(L, typin);
      hread(L, srcin);
      read(L, len);

      wait until currentpkt = waitfornum;
      wait until rising_edge(CLK);
      RETXSRC <= srcin(5 downto 0);
      RETXTYP <= typin(1 downto 0);
      RETXID  <= idin;
      RETXREQ <= '1';
      wait until rising_edge(CLK);
      RETXREQ <= '0';

      while RETXDONE /= '1' loop
        wait until rising_edge(CLK);
        if RETXWE = '1' then
          memory(TO_INTEGER(unsigned(RETXADDR))) := RETXDOUT;
        end if;
      end loop;

      for i in 0 to len -1 loop
        hread(L, data);
        expected_retx_data <= data;
        actual_retx_data   <= memory(i);
        assert memory(i) = data report "Error in reTX data" severity error;
        wait for 0.5 ns;
      end loop;  -- i
      
    end loop;
    wait; 
  end process retx_req_and_validate;

end Behavioral;
