library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


library soma;
use soma.somabackplane.all;
use soma.somabackplane;

entity backplanetest is

end backplanetest;


architecture Behavioral of backplanetest is
  component backplane
    port (
      CLKIN         : in    std_logic;
      DSPCFG        : out   std_logic_vector(15 downto 0);
      -- SPI interface
      SPIMOSI       : in    std_logic;
      SPIMISO       : out   std_logic;
      SPICS         : in    std_logic;
      SPICLK        : in    std_logic;
      -- LEDS
      LEDPOWER      : out   std_logic;
      LEDEVENT      : out   std_logic;
      -- NIC boot interface
      NICFCLK       : out   std_logic;
      NICFDIN       : out   std_logic;
      NICFPROG      : out   std_logic;
      -- NIC interface
      NICSCLK       : out   std_logic;
      NICSIN        : in    std_logic;
      NICSOUT       : out   std_logic;
      NICSCS        : out   std_logic;
      NICDOUT       : out   std_logic_vector(15 downto 0);
      NICNEWFRAME   : out   std_logic;
      NICDIN        : in    std_logic_vector(15 downto 0);
      NICNEXTFRAME  : out   std_logic;
      NICDINEN      : in    std_logic;
      NICIOCLK      : out   std_logic;
      -- MEMORY interface
      RAMCLKOUT_P   : out   std_logic;
      RAMCLKOUT_N   : out   std_logic;
      RAMCKE        : out   std_logic := '0';
      RAMCAS        : out   std_logic;
      RAMRAS        : out   std_logic;
      RAMCS         : out   std_logic;
      RAMWE         : out   std_logic;
      RAMADDR       : out   std_logic_vector(12 downto 0);
      RAMBA         : out   std_logic_vector(1 downto 0);
      RAMDQSH       : inout std_logic;
      RAMDQSL       : inout std_logic;
      RAMDQ         : inout std_logic_vector(15 downto 0);
      FIBERDEBUGOUT : out   std_logic;
      FIBERDEBUGIN  : in    std_logic;
      -- DSP Boards
      DSPTXIO_P     : out   std_logic_vector(15 downto 0);
      DSPTXIO_N     : out   std_logic_vector(15 downto 0);
      DSPRXIO_P     : in    std_logic_vector(15 downto 0);
      DSPRXIO_N     : in    std_logic_vector(15 downto 0);
      -- ADIO
      ADIOTXIO_P    : out   std_logic;
      ADIOTXIO_N    : out   std_logic;
      ADIORXIO_P    : in    std_logic;
      ADIORXIO_N    : in    std_logic;
      -- SYS / DISPLAY
      SYSTXIO_P     : out   std_logic;
      SYSTXIO_N     : out   std_logic;
      SYSRXIO_P     : in    std_logic;
      SYSRXIO_N     : in    std_logic;
      -- NEP
      NEPTXIO_P     : out   std_logic;
      NEPTXIO_N     : out   std_logic;
      NEPRXIO_P     : in    std_logic;
      NEPRXIO_N     : in    std_logic
      );
  end component;


  signal CLKIN, CLK : std_logic                     := '0';
  signal DSPCFG     : std_logic_vector(15 downto 0) := (others => '0');

  signal SPIMOSI  : std_logic := '0';
  signal SPIMISO  : std_logic := '0';
  signal SPICS    : std_logic := '1';
  signal SPICLK   : std_logic := '0';
  signal LEDPOWER : std_logic := '0';
  signal LEDEVENT : std_logic := '0';

  signal NICFCLK  : std_logic := '0';
  signal NICFDIN  : std_logic := '0';
  signal NICFPROG : std_logic := '0';

  signal NICSCLK      : std_logic                     := '0';
  signal NICSIN       : std_logic                     := '0';
  signal NICSOUT      : std_logic                     := '0';
  signal NICSCS       : std_logic                     := '0';
  signal NICDOUT      : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEWFRAME  : std_logic                     := '0';
  signal NICDIN       : std_logic_vector(15 downto 0) := (others => '0');
  signal NICNEXTFRAME : std_logic                     := '0';
  signal NICDINEN     : std_logic                     := '0';
  signal NICIOCLK     : std_logic                     := '0';
  signal RAMCLKOUT_P  : std_logic                     := '0';
  signal RAMCLKOUT_N  : std_logic                     := '0';
  signal RAMCKE       : std_logic                     := '0';
  signal RAMCAS       : std_logic                     := '0';
  signal RAMRAS       : std_logic                     := '0';
  signal RAMCS        : std_logic                     := '0';
  signal RAMWE        : std_logic                     := '0';
  signal RAMADDR      : std_logic_vector(12 downto 0) := (others => '0');
  signal RAMBA        : std_logic_vector(1 downto 0)  := (others => '0');
  signal RAMDQSH      : std_logic                     := '0';
  signal RAMDQSL      : std_logic                     := '0';
  signal RAMDQ        : std_logic_vector(15 downto 0) := (others => '0');

  signal FIBERDEBUGIN, FIBERDEBUGOUT : std_logic := '0';

  -- DSP Boards
  signal DSPTXIO_P  : std_logic_vector(15 downto 0) := (others => '1');
  signal DSPTXIO_N  : std_logic_vector(15 downto 0) := (others => '0');
  signal DSPRXIO_P  : std_logic_vector(15 downto 0) := (others => '1');
  signal DSPRXIO_N  : std_logic_vector(15 downto 0) := (others => '0');
  -- ADIO
  signal ADIOTXIO_P : std_logic                     := '0';
  signal ADIOTXIO_N : std_logic                     := '1';
  signal ADIORXIO_P : std_logic                     := '0';
  signal ADIORXIO_N : std_logic                     := '1';
  -- SYS / DISPLAY
  signal SYSTXIO_P  : std_logic                     := '0';
  signal SYSTXIO_N  : std_logic                     := '1';
  signal SYSRXIO_P  : std_logic                     := '0';
  signal SYSRXIO_N  : std_logic                     := '1';
  -- NEP
  signal NEPTXIO_P  : std_logic                     := '0';
  signal NEPTXIO_N  : std_logic                     := '1';
  signal NEPRXIO_P  : std_logic                     := '0';
  signal NEPRXIO_N  : std_logic                     := '1';


  signal nicfpgastart, nicvalidboot : std_logic := '0';

  constant filename    : string := "network.bit";
  constant filename2   : string := "xysilly.bin";
  signal   spifilename : string(1 to 32);

  function cts (c   : character) return std_logic_vector is
    variable result : std_logic_vector(7 downto 0);
  begin
    result := std_logic_vector(TO_UNSIGNED(character'pos(c), 8));
    return result;
  end;

  function stc (s   : std_logic_vector(7 downto 0)) return character is
    variable result : character;
  begin
    result := character'val(TO_INTEGER(unsigned(s)));
    return result;
  end;

  signal latestnicfpgabits : std_logic_vector(63 downto 0) := (others => '0');


begin  -- Behavioral

  ---------------------------------------------------------------------------
  -- Fake SPI interface
  --
  --  Very primitive, just read in the values and then let us later process
  ---------------------------------------------------------------------------
  process
    variable wordin        : std_logic_vector(15 downto 0);
    variable wordout       : std_logic_vector(15 downto 0);
    variable addrin, lenin : std_logic_vector(31 downto 0) := (others => '0');
    variable len           : integer                       := 0;

  begin
    wait until rising_edge(SPIMISO);
    wait for 1 us;                      -- just a delay
    SPICS <= '0';
    wait until rising_edge(CLK);
    wait until rising_edge(CLK);

    -- send command request
    wordout := X"0001";
    for i in 15 downto 0 loop
      SPIMOSI <= wordout(i);
      wait until rising_edge(CLK);
      SPICLK  <= '1';
      wait until rising_edge(CLK);
      SPICLK  <= '0';
    end loop;  -- i
    -- read in the command

    for i in 15 downto 0 loop
      wait until rising_edge(CLK);
      wordin(i) := SPIMISO;
      SPICLK <= '1';
      wait until rising_edge(CLK);
      SPICLK <= '0';
    end loop;  -- i
    -- wait
    if wordin = X"0001" then
      report "SPI : Recovered file open command" severity note;

      for cpos in 1 to 16 loop
        -- get the word
        for i in 15 downto 0 loop
          wait until rising_edge(CLK);
          wordin(i) := SPIMISO;
          SPICLK                <= '1';
          wait until rising_edge(CLK);
          SPICLK                <= '0';
        end loop;  -- i
        -- save in filename
        spifilename(cpos*2 - 1) <= stc(wordin(15 downto 8));
        spifilename(cpos*2 )    <= stc(wordin(7 downto 0));
      end loop;  -- cpos

      wait for 50 us;                   -- arbitrary fopen delay

      wordout := X"0001";               -- success
      for i in 15 downto 0 loop
        wait until rising_edge(CLK);
        SPIMOSI <= wordout(i);
        SPICLK  <= '1';
        wait until rising_edge(CLK);
        SPICLK  <= '0';
      end loop;  -- i

      wordout := X"0000";               -- len high
      for i in 15 downto 0 loop
        wait until rising_edge(CLK);
        SPIMOSI <= wordout(i);
        SPICLK  <= '1';
        wait until rising_edge(CLK);
        SPICLK  <= '0';
      end loop;  -- i

      wordout := X"0070";               -- len low
      for i in 15 downto 0 loop
        wait until rising_edge(CLK);
        SPIMOSI <= wordout(i);
        SPICLK  <= '1';
        wait until rising_edge(CLK);
        SPICLK  <= '0';

      end loop;  -- i
      wait until rising_edge(CLK);
      SPICS    <= '1';
    elsif wordin = X"0002" then
      report "SPI : Recovered file read command" severity note;
      -- read in the addr
      for i in 31 downto 0 loop
        wait until rising_edge(CLK);
        addrin(i) := SPIMISO;
        SPICLK <= '1';
        wait until rising_edge(CLK);
        SPICLK <= '0';
      end loop;  -- i
      -- read in the len
      for i in 31 downto 0 loop
        wait until rising_edge(CLK);
        lenin(i)  := SPIMISO;
        SPICLK <= '1';
        wait until rising_edge(CLK);
        SPICLK <= '0';
      end loop;  -- i

      wait for 100 us;
      wordout := addrin(15 downto 0);
      len     := to_integer(unsigned(lenin));
      report "The requested length is " & integer'image(len) severity note;

      for word in 0 to (len -1) loop
        for i in 7 downto 0 loop
          SPIMOSI <= wordout(i);
          wait until rising_edge(CLK);
          SPICLK  <= '1';
          wait until rising_edge(CLK);
          SPICLK  <= '0';
        end loop;  -- i
        wordout := wordout + 1;
      end loop;  -- word
      report "SPI fread data tx done" severity note;
      wait until rising_edge(CLK);
      SPICS       <= '1';

    end if;

  end process;



  backplane_uut : backplane
    port map (
      CLKIN         => CLKIN,
      DSPCFG        => DSPCFG,
      LEDPOWER      => LEDPOWER,
      LEDEVENT      => LEDEVENT,
      NICFCLK       => NICFCLK,
      NICFDIN       => NICFDIN,
      NICFPROG      => NICFPROG,
      -- NIC SERIAL INTERFACE
      SPICLK        => SPICLK,
      SPIMISO       => SPIMISO,
      SPIMOSI       => SPIMOSI,
      SPICS         => SPICS,
      -- NIC DATA INTERFACE
      NICSCLK       => NICSCLK,
      NICSIN        => NICSIN,
      NICSOUT       => NICSOUT,
      NICSCS        => NICSCS,
      NICDOUT       => NICDOUT,
      NICNEWFRAME   => NICNEWFRAME,
      NICDIN        => NICDIN,
      NICNEXTFRAME  => NICNEXTFRAME,
      NICDINEN      => NICDINEN,
      NICIOCLK      => NICIOCLK,
      -- RAM INTERFACE
      RAMCLKOUT_P   => RAMCLKOUT_P,
      RAMCLKOUT_N   => RAMCLKOUT_N,
      RAMCKE        => RAMCKE,
      RAMCAS        => RAMCAS,
      RAMRAS        => RAMRAS,
      RAMCS         => RAMCS,
      RAMWE         => RAMWE,
      RAMADDR       => RAMADDR,
      RAMBA         => RAMBA,
      RAMDQSH       => RAMDQSH,
      RAMDQSL       => RAMDQSL,
      RAMDQ         => RAMDQ,
      FIBERDEBUGIN  => FIBERDEBUGIN,
      FIBERDEBUGOUT => FIBERDEBUGOUT,
      -- 
      DSPTXIO_P     => DSPTXIO_P,
      DSPTXIO_N     => DSPTXIO_N,
      DSPRXIO_P     => DSPRXIO_P,
      DSPRXIO_N     => DSPRXIO_N, 
      -- ADIO
      ADIOTXIO_P    => ADIOTXIO_P,
      ADIOTXIO_N    => ADIOTXIO_N,
      ADIORXIO_P    => ADIORXIO_P,
      ADIORXIO_N    => ADIORXIO_N,
      -- SYS / DISPLAY
      SYSTXIO_P     => SYSTXIO_P,
      SYSTXIO_N     => SYSTXIO_N,
      SYSRXIO_P     => SYSRXIO_P,
      SYSRXIO_N     => SYSRXIO_N,
      -- NEP
      NEPTXIO_P     => NEPTXIO_P,
      NEPTXIO_N     => NEPTXIO_N,
      NEPRXIO_P     => NEPRXIO_P,
      NEPRXIO_N     => NEPRXIO_N
      );


  CLKIN <= not CLKIN after 10 ns;
  CLK   <= CLKIN;

-- main : process
-- begin
-- nicfpgastart <= '1';
-- wait for 100 ns;
-- nicfpgastart <= '0';
-- wait until rising_edge(CLK) and nicvalidboot = '1';
-- assert false report "End of Simulation" severity failure;


-- wait;

-- end process;

  -- send test event
  
  datainput       : process
    file req_file : text open read_mode is "client_requests.txt";
    variable L    : line;
    variable len  : integer := 0;
    variable word : std_logic_vector(15 downto 0);
    variable datagram_ecnt : integer := 0;
  begin
    wait for 50 us;
    
    while not endfile(req_file) loop

      wait until rising_edge(CLK);
      readline(req_file, L);
      read(L, len);
      wait for 10 us;

      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      wait until rising_edge(CLK);
      for i in 0 to len-1 loop
        hread(L, word);
        NICDINEN           <= '1';
        NICDIN             <= word;
        wait until rising_edge(CLK);
        if i = 23 then
          datagram_ecnt := to_integer(unsigned(NICDIN));
        end if;
      end loop;  -- i 
      NICDINEN             <= '0';
      wait until rising_edge(CLK); 
      wait for 50 us;

    end loop;
    wait;
  end process datainput;


end Behavioral;
