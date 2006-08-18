library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use WORK.HY5PS121621F_PACK.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memddr2test is

end memddr2test;

architecture Behavioral of memddr2test is

  component memddr2
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET  : in    std_logic;
      -- RAM!
      CKE    : out   std_logic;
      CAS    : out   std_logic;
      RAS    : out   std_logic;
      CS     : out   std_logic;
      WE     : out   std_logic;
      ADDR   : out   std_logic_vector(12 downto 0);
      BA     : out   std_logic_vector(1 downto 0);
      DQSH   : inout std_logic;
      DQSL   : inout std_logic;
      DQ     : inout std_logic_vector(15 downto 0);
      -- interface
      START  : in    std_logic;
      RW     : in    std_logic;
      DONE   : out   std_logic;
      -- write interface
      ROWTGT : in    std_logic_vector(14 downto 0);
      WRADDR : out   std_logic_vector(7 downto 0);
      WRDATA : in    std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out   std_logic_vector(7 downto 0);
      RDDATA : out   std_logic_vector(31 downto 0);
      RDWE   : out   std_logic
      );
  end component;

  signal CLK, CLKN     : std_logic := '0';
  signal CLK90, CLK90N : std_logic := '0';
  signal CLK180        : std_logic := '0';
  signal CLK270        : std_logic := '0';
  signal RESET         : std_logic := '1';


  -- RAM!
  signal CKE    : std_logic                     := '0';
  signal CAS    : std_logic                     := '1';
  signal RAS    : std_logic                     := '1';
  signal CS     : std_logic                     := '1';
  signal WE     : std_logic                     := '1';
  signal ADDR   : std_logic_vector(12 downto 0) := (others => '0');
  signal BA     : std_logic_vector(1 downto 0)  := (others => '0');
  signal DQSH   : std_logic                     := '0';
  signal DQSL   : std_logic                     := '0';
  signal DQ     : std_logic_vector(15 downto 0) := (others => '0');
  -- interface
  signal START  : std_logic                     := '0';
  signal RW     : std_logic                     := '0';
  signal DONE   : std_logic                     := '0';
  -- write interface
  signal ROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal WRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal WRDATA : std_logic_vector(31 downto 0) := (others => '0');
  -- read interface
  signal RDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal RDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal RDWE   : std_logic                     := '0';

  component HY5PS121621F
    generic (
      TimingCheckFlag :       boolean                       := true;
      PUSCheckFlag    :       boolean                       := false;
      Part_Number     :       PART_NUM_TYPE                 := B400);
    port
      ( DQ            : inout std_logic_vector(15 downto 0) := (others => 'Z');
        LDQS          : inout std_logic                     := 'Z';
        LDQSB         : inout std_logic                     := 'Z';
        UDQS          : inout std_logic                     := 'Z';
        UDQSB         : inout std_logic                     := 'Z';
        LDM           : in    std_logic;
        WEB           : in    std_logic;
        CASB          : in    std_logic;
        RASB          : in    std_logic;
        CSB           : in    std_logic;
        BA            : in    std_logic_vector(1 downto 0);
        ADDR          : in    std_logic_vector(12 downto 0);
        CKE           : in    std_logic;
        CLK           : in    std_logic;
        CLKB          : in    std_logic;
        UDM           : in    std_logic;
        odelay        : in    time                          := 0 ps);
  end component;

  signal mainclk : std_logic := '0';
  signal clkpos  : integer   := 0;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.6666 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal odelay : time := 0 ps;

begin  -- Behavioral

  DQSH <= 'L';
  DQSL <= 'L';
  memddr2_uut : memddr2
    port map (
      CLK    => CLK,
      CLK90  => CLK90,
      CLK180 => CLK180,
      CLK270 => CLK270,
      RESET  => RESET,
      CKE    => CKE,
      CAS    => CAS,
      RAS    => RAS,
      CS     => CS,
      WE     => WE,
      ADDR   => ADDR,
      BA     => BA,
      DQSH   => DQSH,
      DQSL   => DQSL,
      DQ     => DQ,
      START  => START,
      RW     => RW,
      DONE   => DONE,
      ROWTGT => ROWTGT,
      WRADDR => WRADDR,
      WRDATA => WRDATA,
      RDADDR => RDADDR,
      RDDATA => RDDATA,
      RDWE   => RDWE);

  mainclk <= not mainclk after (clk_period / 8);

  memory_inst : HY5PS121621F
    generic map (
      TimingCheckFlag => true,
      PUSCheckFlag    => true,
      PArt_number     => B400)
    port map (
      DQ              => DQ,
      LDQS            => DQSL,
      UDQS            => DQSH,
      WEB             => WE,
      LDM             => '0',
      UDM             => '0',
      CASB            => CAS,
      RASB            => RAS,
      CSB             => CS,
      BA              => BA,
      ADDR            => ADDR,
      CKE             => CKE,
      CLK             => CLK90,
      CLKB            => CLK90N,
      odelay          => odelay);

  process(mainclk)
  begin
    if rising_edge(mainclk) then
      if clkpos = 3 then
        clkpos <= 0;
      else
        clkpos <= clkpos + 1;
      end if;

      if clkpos = 0 then
        CLK <= '1';
      elsif clkpos = 2 then
        CLK <= '0';
      end if;

      if clkpos = 1 then
        CLK90 <= '1';
      elsif clkpos = 3 then
        CLK90 <= '0';
      end if;

      if clkpos = 2 then
        CLK180 <= '1';
      elsif clkpos = 0 then
        CLK180 <= '0';
      end if;

      if clkpos = 3 then
        CLK270 <= '1';
      elsif clkpos = 1 then
        CLK270 <= '0';
      end if;
    end if;
  end process;


  CLKN   <= not CLK;
  CLK90N <= not CLK90;



  -- fake write memory
  wrmem              : process(CLK)
    variable wraddrl : std_logic_vector(7 downto 0) := (others => '0');

  begin
    if rising_edge(CLK) then
      WRDATA <= ( (burstcnt & wraddrl) & (not (burstcnt & wraddrl) ));
      wraddrl := WRADDR;

    end if;
  end process wrmem;

  main : process
  begin


    for tpos in 0 to 20 loop
      RESET <= '1';
      wait for 50 ns;

      RESET <= '0';
      wait for 300 us;

      odelay <= 107 ps * tpos;


      wait until rising_edge(CLK);

      for i in 0 to 10 loop
        START <= '1';
        RW    <= '1';
        wait until rising_edge(CLK) and DONE = '1';

        START <= '0';
        RW    <= '1';
        wait for 5 us;

        wait until rising_edge(CLK);

        START <= '1';
        RW    <= '0';
        wait until rising_edge(CLK) and DONE = '1';

        START <= '0';
        RW    <= '0';
        wait for 5 us;
        --report "Finished with Row" severity Note;

        burstcnt <= burstcnt + 1;
        ROWTGT   <= ROWTGT + 1;
      end loop;  -- i

    end loop;  -- tpos

    report "End of Simulation" severity failure;

    wait;

  end process main;


  -- reader
  read_verify : process

  begin
    -- wait for read to start


    wait until falling_edge(RESET);

    ---------------------------------------------------------------------------
    -- READ AND VERIFY 10 BURSTS
    ---------------------------------------------------------------------------

    -- we wait for  the first write to get into the read-verification
    -- code so that we avoid the dqdelay lock read burst

    wait until rising_edge(CLK) and START = '1' and RW = '1';

    for i in 0 to 10 loop
      wrdcnt <= 0;
      wait until rising_edge(CLK) and START = '1' and RW = '0';

      while DONE /= '1' loop
        if RDWE = '1' then
          if rddata = ((burstcnt & rdaddr) & (not (burstcnt & rdaddr))) then
            wrdcnt <= wrdcnt + 1;
          else
            report "error reading back data" severity error;
          end if;
        end if;
        wait until rising_edge(CLK);

      end loop;
      if wrdcnt /= 256 then
        report "Read less than 256 words" severity error;
      end if;
    end loop;  -- i


  end process read_verify;
end Behavioral;
