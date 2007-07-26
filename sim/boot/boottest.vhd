library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity boottest is

end boottest;

architecture Behavioral of boottest is


  component boot

    generic (
      M       :     integer                      := 20;
      DEVICE  :     std_logic_vector(7 downto 0) := X"01"
      );
    port (
      CLK     : in  std_logic;
      RESET   : in  std_logic;
      EDTX    : in  std_logic_vector(7 downto 0);
      EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0);
      SDOUT   : out std_logic;
      SDIN    : in  std_logic;
      SCLK    : out std_logic;
      SCS     : out std_logic;
      SEROUT  : out std_logic_vector(M-1 downto 0));

  end component;

  constant M : integer := 20;

  signal CLK   : std_logic                    := '0';
  signal RESET : std_logic                    := '0';
  signal EDTX  : std_logic_vector(7 downto 0) := (others => '0');

  signal EATX    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal ECYCLE  : std_logic                                     := '0';
  signal EARX    : std_logic_vector(somabackplane.N - 1 downto 0)
                                                                 := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0)
                                                                 := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0)
                                                                 := (others => '0');

  signal SDIN  : std_logic := '0';
  signal SDOUT : std_logic := '0';
  signal SCLK  : std_logic := '0';
  signal SCS   : std_logic := '0';

  signal SEROUT : std_logic_vector(M-1 downto 0) := (others => '0');


  signal epos : integer range 0 to 999 := 950;
  component mmc
    generic (
      mode : integer := 0);

    port (
      RESET : in  std_logic;
      SCLK  : in  std_logic;
      SDIN  : in  std_logic;
      SDOUT : out std_logic;
      SCS   : in  std_logic

      );
  end component;


  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal bootaddr : std_logic_vector(15 downto 0) := (others => '0');
  signal bootlen  : std_logic_vector(15 downto 0) := (others => '0');

  component simplefpga
    port (
      START     : in  std_logic;
      BOOTADDR  : in  std_logic_vector(15 downto 0);
      BOOTLEN   : in  std_logic_vector(15 downto 0);
      FCLK      : in  std_logic;
      FDIN      : in  std_logic;
      FPROG     : in  std_logic;
      VALIDBOOT : out std_logic
      );
  end component;

  signal fpgavalidboot, fpgastart : std_logic_vector(M-1 downto 0) := (others => '0');


  component bootdeserialize
    
    port (
      CLK   : in  std_logic;
      DIN   : in  std_logic;
      FPROG : out std_logic;
      FDIN  : out std_logic;
      FCLK  : out std_logic);
  end component;

  type settings is (none, noop, noopdone,
                    firstwrite, firstwritedone,
                    multiwrite, multiwriteerror, multiwritedone);
  signal state : settings := none;

  signal fprog, fclk, fdin : std_logic_vector(M-1 downto 0) := (others => '0');

begin


  boot_uut : boot
    generic map (
      M       => 20,
      DEVICE  => X"01")
    port map (
      CLK     => CLK,
      RESET   => RESET,
      EDTX    => EDTX,
      EATX    => EATX,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX,
      SDOUT   => SDOUT,
      SDIN    => SDIN,
      SCLK    => SCLK,
      SCS     => SCS,
      SEROUT  => SEROUT);


  mmc_inst : mmc
    generic map (
      mode => 1)
    port map (
      RESET => RESET,
      SCLK  => SCLK,
      SDIN  => SDOUT,
      SDOUT => SDIN,
      SCS   => SCS);

  -- basic clocking
  CLK   <= not CLK after 10 ns;
  RESET <= '0'     after 100 ns;

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
  begin

    while true loop

      wait until rising_edge(CLK) and epos = 47;
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


  deserializers   : for i in 0 to M-1 generate
    deserializers : bootdeserialize
      port map (
        CLK   => CLK,
        DIN   => SEROUT(i),
        FPROG => fprog(i),
        FDIN  => fdin(i),
        FCLK  => fclk(i));

  end generate deserializers;

  fpgas      : for i in 0 to M-1 generate
    fpgatest : simplefpga
      port map (
        START     => fpgastart(i),
        BOOTADDR  => bootaddr,
        bootlen   => bootlen,
        FCLK      => fclk(i),
        FDIN      => fdin(i),
        FPROG     => fprog(i),
        VALIDBOOT => fpgavalidboot(i));

  end generate fpgas;



  main : process
    --generate the commands, read the outputs
    --
  begin
    -- first, we send no-op and make sure we have no reaction
    wait until rising_edge(CLK) and ECYCLE = '1';
    state <= noop;

    eventinputs(0)(0) <= (others => '1');
    EATX(0)           <= '1';
    wait until rising_edge(CLK) and ECYCLE = '1';
    EATX              <= eazeros;


    -- now, verify they don't do anything

    wait until rising_edge(CLK) and ECYCLE = '1';
    assert EARX'stable(20 us) report "EARX registered an event" severity
      error;
    state <= noopdone;

    -- now try and send a correct event
    wait until rising_edge(CLK) and ECYCLE = '1';
    state             <= firstwrite;
    eventinputs(4)(0) <= X"2004";
    eventinputs(4)(1) <= X"0000";
    eventinputs(4)(2) <= X"0010";
    bootlen           <= X"0002";
    wait for 1 ns;
    
    eventinputs(4)(3) <= bootlen;
    wait for 1 ns;

    bootaddr          <= X"0020";
    wait for 1 ns;

    eventinputs(4)(4) <= bootaddr;
    wait for 1 ns;
    
    wait until rising_edge(CLK);
    fpgastart(4) <= '1';
    wait until rising_edge(CLK);
    fpgastart(4) <= '0';
    
    wait until rising_edge(CLK) and ECYCLE = '1';
    eventinputs(4)(5) <= X"0000";
    EATX(0)           <= '0';
    EATX(4)           <= '1';



    -- now try and acquire the event
    while EARX(4) /= '1' loop
      wait until rising_edge(CLK) and ECYCLE = '1';
      EATX <= eazeros;
    end loop;

    EDSELRX <= "0000";
    wait until rising_edge(CLK);
    assert EDRX = X"20"
      report "1 : invalid transmitted event : command ID" severity error;

    EDSELRX <= "0001";
    wait until rising_edge(CLK);
    assert EDRX = X"01"
      report "1 : invalid transmitted event : device" severity error;

    EDSELRX <= "0011";
    wait until rising_edge(CLK);
    assert EDRX = X"02"
      report "1 : invalid transmitted event : response" severity error;
    state   <= firstwritedone;



    wait until rising_edge(CLK) and fpgavalidboot(4) = '1';
    
    assert false report "End of Simulation" severity failure;

  end process main;

end Behavioral;
