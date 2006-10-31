library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

library work;
use WORK.HY5PS121621F_PACK.all;

entity retxbuffertest is

end retxbuffertest;

architecture Behavioral of retxbuffertest is

  component retxbuffer
    port (
      CLK   : in std_logic;
      CLKHI : in std_logic;

      -- buffer set A input (write) interface
      WIDA   : in std_logic_vector(13 downto 0);
      WDINA  : in std_logic_vector(15 downto 0);
      WADDRA : in std_logic_vector(8 downto 0);
      WRA    : in std_logic;
      WDONEA : in std_logic;
      WCLKA  : in std_logic;

      -- output buffer A set B (reads) interface
      RIDA    : in  std_logic_vector (13 downto 0);
      RREQA   : in  std_logic;
      RDOUTA  : out std_logic_vector(15 downto 0);
      RADDRA  : out std_logic_vector(8 downto 0);
      RDONEA  : out std_logic;
      RWROUTA : out std_logic;
      RCLKA   : in  std_logic;


      --buffer set B input (write) interfafe
      WIDB   : in std_logic_vector(13 downto 0);
      WDINB  : in std_logic_vector(15 downto 0);
      WADDRB : in std_logic_vector(8 downto 0);
      WRB    : in std_logic;
      WDONEB : in std_logic;
      WCLKB  : in std_logic;

      -- output buffer B set Rad (reads) interface
      RIDB    : in  std_logic_vector (13 downto 0);
      RREQB   : in  std_logic;
      RDOUTB  : out std_logic_vector(15 downto 0);
      RADDRB  : out std_logic_vector(8 downto 0);
      RDONEB  : out std_logic;
      RWROUTB : out std_logic;
      RCLKB   : in  std_logic;

      -- memory output interface
      MEMSTART  : out std_logic;
      MEMRW     : out std_logic;
      MEMDONE   : in  std_logic;
      MEMWRADDR : in  std_logic_vector(7 downto 0);
      MEMWRDATA : out std_logic_vector(31 downto 0);
      MEMROWTGT : out std_logic_vector(14 downto 0);
      MEMRDDATA : in  std_logic_vector(31 downto 0);
      MEMRDADDR : in  std_logic_vector(7 downto 0);
      MEMRDWE   : in  std_logic
      );
  end component;


  signal CLKNOM : std_logic := '0';
  signal CLKHI  : std_logic := '0';

  -- buffer set A input (write) interface
  signal WIDA   : std_logic_vector(13 downto 0) := (others => '0');
  signal WDINA  : std_logic_vector(15 downto 0) := (others => '0');
  signal WADDRA : std_logic_vector(8 downto 0)  := (others => '0');
  signal WRA    : std_logic                     := '0';
  signal WDONEA : std_logic                     := '0';

  -- output buffer A set B (reads) interface
  signal RIDA    : std_logic_vector (13 downto 0) := (others => '0');
  signal RREQA   : std_logic                      := '0';
  signal RDOUTA  : std_logic_vector(15 downto 0)  := (others => '0');
  signal RADDRA  : std_logic_vector(8 downto 0)   := (others => '0');
  signal RDONEA  : std_logic                      := '0';
  signal RWROUTA : std_logic                      := '0';


--buffer set B input (write) interfafe
  signal WIDB   : std_logic_vector(13 downto 0) := (others => '0');
  signal WDINB  : std_logic_vector(15 downto 0) := (others => '0');
  signal WADDRB : std_logic_vector(8 downto 0)  := (others => '0');
  signal WRB    : std_logic                     := '0';
  signal WDONEB : std_logic                     := '0';

  -- output buffer B set Rad (reads) interface
  signal RIDB   : std_logic_vector (13 downto 0) := (others => '0');
  signal RREQB  : std_logic                      := '0';
  signal RDOUTB : std_logic_vector(15 downto 0)  := (others => '0');
  signal RADDRB : std_logic_vector(8 downto 0)   := (others => '0');

  signal RDONEB  : std_logic := '0';
  signal RWROUTB : std_logic := '0';

  -- memory output interface
  signal MEMSTART  : std_logic                     := '0';
  signal MEMRW     : std_logic                     := '0';
  signal MEMDONE   : std_logic                     := '0';
  signal MEMWRADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal MEMWRDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal MEMROWTGT : std_logic_vector(14 downto 0) := (others => '0');
  signal MEMRDDATA : std_logic_vector(31 downto 0) := (others => '0');
  signal MEMRDADDR : std_logic_vector(7 downto 0)  := (others => '0');
  signal MEMRDWE   : std_logic                     := '0';


  component memddr2
    port (
      CLK    : in    std_logic;
      CLK90  : in    std_logic;
      CLK180 : in    std_logic;
      CLK270 : in    std_logic;
      RESET  : in    std_logic;
      -- RAM!
      CKE    : out   std_logic := '0';
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
      ROWTGT : in  std_logic_vector(14 downto 0);
      WRADDR : out std_logic_vector(7 downto 0);
      WRDATA : in  std_logic_vector(31 downto 0);
      -- read interface
      RDADDR : out std_logic_vector(7 downto 0);
      RDDATA : out std_logic_vector(31 downto 0);
      RDWE   : out std_logic
      );
  end component;

  signal CLK, CLKN     : std_logic := '0';
  signal CLK90, CLK90N : std_logic := '0';
  signal CLK180        : std_logic := '0';
  signal CLK270        : std_logic := '0';
  signal RESET         : std_logic := '1';


  -- RAM!
  signal CKE  : std_logic                     := '0';
  signal CAS  : std_logic                     := '1';
  signal RAS  : std_logic                     := '1';
  signal CS   : std_logic                     := '1';
  signal WE   : std_logic                     := '1';
  signal ADDR : std_logic_vector(12 downto 0) := (others => '0');
  signal BA   : std_logic_vector(1 downto 0)  := (others => '0');
  signal DQSH : std_logic                     := '0';
  signal DQSL : std_logic                     := '0';
  signal DQ   : std_logic_vector(15 downto 0) := (others => '0');



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

  signal mainclk    : std_logic := '0';
  signal clkpos     : integer   := 0;
  signal clkslowpos : integer   := 0;

  signal clockoffset : time := 3.2 ns;

  signal clk_period : time := 6.6666 ns;

  signal wrdcnt : integer := 0;

  signal burstcnt : std_logic_vector(7 downto 0) := (others => '0');

  signal odelay : time := 0 ps;

  type outbuffer is array (0 to 511) of std_logic_vector(15 downto 0);
  signal outbuffera : outbuffer;
  signal outbufferb : outbuffer;

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
      START  => MEMSTART,
      RW     => MEMRW,
      DONE   => MEMDONE,
      ROWTGT => MEMROWTGT,
      WRADDR => MEMWRADDR,
      WRDATA => MEMWRDATA,
      RDADDR => MEMRDADDR,
      RDDATA => MEMRDDATA,
      RDWE   => MEMRDWE);

  mainclk <= not mainclk after (clk_period / 8);
  RESET   <= '0'         after 20 ns;

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

      if clkslowpos = 11 then
        clkslowpos <= 0;
      else
        clkslowpos <= clkslowpos + 1;
      end if;

      if clkslowpos = 0 then
        CLKnom <= '1';
      elsif clkslowpos = 6 then
        CLKnom <= '0';

      end if;

    end if;
  end process;

  clkhi  <= CLK;
  CLKN   <= not CLK;
  CLK90N <= not CLK90;

  retxbuffer_uut : retxbuffer
    port map (
      CLK       => CLKnom,
      CLKHI     => CLKHI,
      WIDA      => WIDA,
      WDINA     => WDINA,
      WADDRA    => WADDRA,
      WRA       => WRA,
      WDONEA    => WDONEA,
      WCLKA     => CLKnom,
      RIDA      => RIDA,
      RREQA     => RREQA,
      RDOUTA    => RDOUTA,
      RADDRA    => RADDRA,
      RDONEA    => RDONEA,
      RWROUTA   => RWROUTA,
      RCLKA     => CLKnom,
      WIDB      => WIDB,
      WDINB     => WDINB,
      WADDRB    => WADDRB,
      WRB       => WRB,
      WDONEB    => WDONEB,
      WCLKB     => CLKnom,
      RIDB      => RIDB,
      RREQB     => RREQB,
      RDOUTB    => RDOUTB,
      RADDRB    => RADDRB,
      RDONEB    => RDONEB,
      RWROUTB   => RWROUTB,
      RCLKB     => CLKnom,
      MEMSTART  => MEMSTART,
      MEMRW     => MEMRW,
      MEMDONE   => MEMDONE,
      MEMWRADDR => MEMWRADDR,
      MEMWRDATA => MEMWRDATA,
      MEMROWTGT => MEMROWTGT,
      MEMRDDATA => MEMRDDATA,
      MEMRDADDR => MEMRDADDR,
      MEMRDWE   => MEMRDWE);

  -- exhausting test infrastructure
  -- input A process
  inputA : process
  begin
    wait for 320 us;
    for i in 0 to 63 loop
      for j in 0 to 511 loop
        wait until rising_edge(CLKnom);
        wdina  <= std_logic_vector(TO_UNSIGNED(i, 6))
                  & std_logic_vector(TO_UNSIGNED(j, 10));
        waddra <= std_logic_vector(TO_UNSIGNED(j, 9));
        wra    <= '1';
      end loop;  -- j
      wait until rising_edge(CLKnom);
      wra      <= '0';
      wida     <= std_logic_vector(to_UNSIGNED((i+1) * 7, 14));
      wdonea   <= '1';
      wait until rising_edge(CLKnom);
      wdonea   <= '0';
      wait for 10 us;

    end loop;  -- i 
  end process inputA;

  -- output buffer capture
  process(CLKnom)
  begin
    if rising_edge(CLKnom) then
      if RWROUTA = '1' then
        outbuffera(to_INTEGER(unsigned(raddra))) <= rdouta;
      end if;
    end if;
  end process;
  -- output process A:

  outputA : process
  begin
    wait for 340 us;
    for i in 0 to 63 loop
      wait until rising_edge(CLKnom);
      rida  <= std_logic_vector(to_UNSIGNED((i+1) * 7, 14));
      rreqa <= '1';
      wait until rising_edge(CLKnom);
      rreqa <= '0';
      wait until rising_edge(CLKnom) and rdonea = '1';

      for j in 0 to 511 loop
        assert outbuffera(j) = std_logic_vector(TO_UNSIGNED(i, 6))
          & std_logic_vector(TO_UNSIGNED(j, 10))
          report "Error in reading outputA buffer" severity error;

      end loop;
      wait for 10 us;

    end loop;  -- i 
    report "Finished reading A buffer sets" severity note;


  end process outputA;

  -- input B process
  inputB : process
  begin
    wait for 320 us;
    for i in 0 to 63 loop
      for j in 0 to 511 loop
        wait until rising_edge(CLKnom);
        wdinb  <= std_logic_vector(TO_UNSIGNED(i, 6))
                  & std_logic_vector(TO_UNSIGNED(j, 10));
        waddrb <= std_logic_vector(TO_UNSIGNED(j, 9));
        wrb    <= '1';
      end loop;  -- j
      wait until rising_edge(CLKnom);
      wrb      <= '0';
      widb     <= std_logic_vector(to_UNSIGNED((i+1) * 13, 14));
      wdoneb   <= '1';
      wait until rising_edge(CLKnom);
      wdoneb   <= '0';
      wait for 10 us;

    end loop;  -- i 
  end process inputB;

  -- output buffer capture
  process(CLKnom)
  begin
    if rising_edge(CLKnom) then
      if RWROUTB = '1' then
        outbufferb(to_INTEGER(unsigned(raddrb))) <= rdoutb;
      end if;
    end if;
  end process;
  -- output process A:

  outputB : process
  begin
    wait for 340 us;
    for i in 0 to 63 loop
      wait until rising_edge(CLKnom);
      ridb  <= std_logic_vector(to_UNSIGNED((i+1) * 13, 14));
      rreqb <= '1';
      wait until rising_edge(CLKnom);
      rreqb <= '0';
      wait until rising_edge(CLKnom) and rdoneb = '1';

      for j in 0 to 511 loop
        assert outbufferb(j) = std_logic_vector(TO_UNSIGNED(i, 6))
          & std_logic_vector(TO_UNSIGNED(j, 10))
          report "Error in reading outputB buffer" severity error;

      end loop;
      wait for 10 us;

    end loop;  -- i 
    report "Finished reading B buffer sets" severity note;

    report "End of Simulation" severity failure;

  end process outputB;


end Behavioral;
