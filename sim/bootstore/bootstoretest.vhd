library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity bootstoretest is

end bootstoretest;

architecture Behavioral of bootstoretest is

  component bootstore
    generic (
      DEVICE  :     std_logic_vector(7 downto 0)                   := X"01"
      );
    port (
      CLK     : in  std_logic;
      CLKHI   : in  std_logic;
      RESET   : in  std_logic;
      -- event interface
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0) := (others => '0');
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      -- SPI INTERFACE
      SPIMOSI : in  std_logic;
      SPIMISO : out std_logic;
      SPICS   : in  std_logic;
      SPICLK  : in  std_logic
      );
  end component;


  signal CLK    : std_logic := '0';
  signal CLKHI  : std_logic := '0';
  signal RESET  : std_logic := '0';
  -- event interface
  signal EDTX   : std_logic_vector(7 downto 0)
                            := (others => '0');
  signal EATX   : std_logic_vector(somabackplane.N -1 downto 0)
                            := (others => '0');
  signal ECYCLE : std_logic := '0';

  signal EARX    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  -- SPI INTERFACE
  signal SPIMOSI : std_logic                    := '0';
  signal SPIMISO : std_logic                    := '0';
  signal SPICS   : std_logic                    := '1';
  signal SPICLK  : std_logic                    := '0';

  signal   mainclk     : integer range 0 to 5 := 0;
  constant filename    : string               := "abcdefg.bin";
  signal   spifilename : string(1 to 32);

  ---------------------------------------------------------------------------
  -- DEBUG
  ---------------------------------------------------------------------------

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal pos : integer range 0 to 999 := 0;

  constant BOOTDEVICE : std_logic_vector(7 downto 0) := X"27";

  signal curhandle : std_logic_vector(7 downto 0) := (others => '0');

  constant GETHAND  : std_logic_vector(7 downto 0) := X"90";
  constant SETFNAME : std_logic_vector(7 downto 0) := X"91";
  constant FOPEN    : std_logic_vector(7 downto 0) := X"92";
  constant FREAD    : std_logic_vector(7 downto 0) := X"93";

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

begin  -- Behavioral

  mainclk <= (mainclk + 1) mod 6 after 3.333333333333 ns;
  CLKHI   <= '1' when mainclk = 0 or mainclk = 2 or mainclk = 4 else '0';
  CLK     <= '1' when mainclk = 0 or mainclk = 1 or mainclk = 2 else '0';


  bootstore_uut : bootstore
    generic map (
      DEVICE  => BOOTDEVICE)
    port map (
      CLK     => CLK,
      CLKHI   => CLKHI,
      RESET   => RESET,
      EDTX    => EDTX,
      EATX    => EATX,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      SPIMOSI => SPIMOSI,
      SPIMISO => SPIMISO,
      SPICS   => SPICS,
      SPICLK  => SPICLK);


  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;
    end if;
  end process ecycle_generation;


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

      wordout := X"1234";               -- len high
      for i in 15 downto 0 loop
        wait until rising_edge(CLK);
        SPIMOSI <= wordout(i);
        SPICLK  <= '1';
        wait until rising_edge(CLK);
        SPICLK  <= '0';
      end loop;  -- i

      wordout := X"5678";               -- len low
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

      for word in 0 to len loop
        for i in 15 downto 0 loop
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


  event_packet_generation : process
  begin

    while true loop

      wait until rising_edge(CLK) and pos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
                                        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;

  sendeventtest          : process
    variable readpktnum  : integer                       := 0;
    variable readpktword : std_logic_vector(15 downto 0) := (others => '0');
    variable readword    : std_logic_vector(15 downto 0) := (others => '0');
    variable readwordnum : integer                       := 0;

  begin

    -- send an event and show that we get a noop response
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= X"8200";
    eventinputs(0)(1) <= X"0000";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';

    -------------------------------------------------------------------------
    -- Get the handle
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= GETHAND & X"00";
    eventinputs(0)(1) <= X"0000";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';
    -- now verify we got the handle!
    assert EARX(0) = '1' report "Error setting the EARX" severity error;
    assert EDRX = X"90" report "Error setting command" severity error;
    EDSELRX           <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = BOOTDEVICE report "Error setting command" severity error;
    -- get the success result
    EDSELRX           <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"00" report "Error getting success result" severity error;

    -- get the handle
    EDSELRX   <= "0101";
    wait until rising_edge(CLK);
    curhandle <= EDRX;
    report "'get the handle' test done" severity note;
    

    -------------------------------------------------------------------------
    -- Try to get the handle again; should fail with a handle-already-acq
    -- error
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= GETHAND & X"00";
    eventinputs(0)(1) <= X"0000";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"0000";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';
    -- now verify we got the handle!
    assert EARX(0) = '1' report "Error setting the EARX" severity error;
    EDSELRX           <= "0000";
    wait until rising_edge(CLK); 
    assert EDRX = X"90" report "Error setting command" severity error;
    EDSELRX           <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = BOOTDEVICE report "Error setting command" severity error;
    -- get the success result
    EDSELRX           <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"04" report "Error getting secondary handle req result" severity error;

    wait until rising_edge(CLK);
    report "'get the handle when it's already acquired' test done" severity note;

    -------------------------------------------------------------------------
    -- Set the filename to be the filename signal
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= SETFNAME & X"00";
    eventinputs(0)(1) <= curhandle & X"00";
    eventinputs(0)(2) <= cts(filename(1)) & cts(filename(2));
    eventinputs(0)(3) <= cts(filename(3)) & cts(filename(4));
    eventinputs(0)(4) <= cts(filename(5)) & cts(filename(6));
    eventinputs(0)(5) <= cts(filename(7)) & cts(filename(8));
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= SETFNAME & X"00";
    eventinputs(0)(1) <= curhandle & X"08";
    eventinputs(0)(2) <= cts(filename(9)) & cts(filename(10));
    eventinputs(0)(3) <= cts(filename(11)) & X"00";
    wait until rising_edge(CLK) and ECYCLE = '1';


    EATX <= (others => '0');

    wait until rising_edge(CLK) and ECYCLE = '1';

    -------------------------------------------------------------------------
    -- send FOPEN
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= FOPEN & X"00";
    eventinputs(0)(1) <= curhandle & X"00";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';
    wait until rising_edge(CLK) and EARX(0) = '1';
    EDSELRX           <= "0000";
    wait until rising_edge(CLK);
    -- verify the event
    assert EDRX = FOPEN report "error receiving command" severity error;
    EDSELRX           <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = BOOTDEVICE report "Error receiving device device" severity error;

    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = "01" report "receiving success response" severity error;

    EDSELRX <= "0100";
    wait until rising_edge(CLK);
    assert EDRX = X"12" report "Error receiving fopen len" severity error;

    EDSELRX <= "0101";
    wait until rising_edge(CLK);
    assert EDRX = X"34" report "Error receiving fopen len" severity error;

    EDSELRX <= "0110";
    wait until rising_edge(CLK);
    assert EDRX = X"56" report "Error receiving fopen len" severity error;

    EDSELRX <= "0111";
    wait until rising_edge(CLK);
    assert EDRX = X"78" report "Error receiving fopen len" severity error;

    -------------------------------------------------------------------------
    -- send FREAD 1 
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= FREAD & X"00";
    eventinputs(0)(1) <= curhandle & X"00";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"0100";
    eventinputs(0)(4) <= X"0000";
    eventinputs(0)(5) <= X"0100";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';

    -- now hope we get a response
    for i in 0 to 31 loop
      wait until rising_edge(CLK) and EARX(0) = '1';

      -- check header
      EDSELRX <= "0000";
      wait until rising_edge(CLK);

      assert EDRX = X"94" report
        "fread error : event read command byte incorrect" severity error;
      EDSELRX <= "0001";
      wait until rising_edge(CLK);

      assert EDRX = BOOTDEVICE report
        "fread error : event source incorrect" severity error;

      -- check byte pos
      EDSELRX <= "0010";
      wait until rising_edge(CLK);
      readpktword(15 downto 8) := EDRX;

      EDSELRX <= "0011";
      wait until rising_edge(CLK);
      readpktword(7 downto 0) := EDRX;
      readpktnum              := to_integer(unsigned(readpktword));
      assert readpktnum = i report
        "fread : error reading packet num" severity error;

      -- now read the actual data bytes within the packet
      for wordnum in 0 to 3 loop
        -- first byte of data word!
        EDSELRX <= std_logic_vector(TO_UNSIGNED(wordnum*2 + 4, 4));
        wait until rising_edge(CLK);
        readword(15 downto 8) := EDRX;

        -- second byte of data word! 
        EDSELRX <= std_logic_vector(TO_UNSIGNED(wordnum*2 + 5, 4));
        wait until rising_edge(CLK);
        readword(7 downto 0) := EDRX;
        readwordnum          := to_integer(unsigned(readword));
        assert (256 + i * 4 + wordnum) = readwordnum report
          "Error reading data word" severity error;
-- report "Recovered word num is " & integer'image(readwordnum) &
-- " " & integer'image(256 + i *4 + wordnum)
-- severity Note;

      end loop;  -- wordnum
      wait until rising_edge(CLK) and ECYCLE = '1';       
    end loop;

    report "fread 1 successful " severity note;



    
    -------------------------------------------------------------------------
    -- send FREAD 2
    -------------------------------------------------------------------------

    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX(0)           <= '1';
    eventinputs(0)(0) <= FREAD & X"00";
    eventinputs(0)(1) <= curhandle & X"00";
    eventinputs(0)(2) <= X"0000";
    eventinputs(0)(3) <= X"0200";
    eventinputs(0)(4) <= X"0000";
    eventinputs(0)(5) <= X"0100";
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= (others => '0');
    wait until rising_edge(CLK) and ECYCLE = '1';

    -- now hope we get a response
    for i in 0 to 31 loop
      wait until rising_edge(CLK) and EARX(0) = '1';

      -- check header
      EDSELRX <= "0000";
      wait until rising_edge(CLK);

      assert EDRX = X"94" report
        "fread error : event read command byte incorrect" severity error;
      EDSELRX <= "0001";
      wait until rising_edge(CLK);

      assert EDRX = BOOTDEVICE report
        "fread error : event source incorrect" severity error;

      -- check byte pos
      EDSELRX <= "0010";
      wait until rising_edge(CLK);
      readpktword(15 downto 8) := EDRX;

      EDSELRX <= "0011";
      wait until rising_edge(CLK);
      readpktword(7 downto 0) := EDRX;
      readpktnum              := to_integer(unsigned(readpktword));
      assert readpktnum = i report
        "fread : error reading packet num" severity error;

      -- now read the actual data bytes within the packet
      for wordnum in 0 to 3 loop
        -- first byte of data word!
        EDSELRX <= std_logic_vector(TO_UNSIGNED(wordnum*2 + 4, 4));
        wait until rising_edge(CLK);
        readword(15 downto 8) := EDRX;

        -- second byte of data word! 
        EDSELRX <= std_logic_vector(TO_UNSIGNED(wordnum*2 + 5, 4));
        wait until rising_edge(CLK);
        readword(7 downto 0) := EDRX;
        readwordnum          := to_integer(unsigned(readword));
        assert (256*2 + i * 4 + wordnum) = readwordnum report
          "Error reading data word" severity error;
-- report "Recovered word num is " & integer'image(readwordnum) &
-- " " & integer'image(256 + i *4 + wordnum)
-- severity Note;

      end loop;  -- wordnum
    wait until rising_edge(CLK) and ECYCLE = '1';

    end loop;

    report "fread 2 successful " severity note;


    

    report "End of Simulation" severity failure;
    wait;
  end process;

end Behavioral;
