library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memddr2 is
  generic (
      CASLATENCY : in integer);
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
    RDWE   : out std_logic;
    -- debugging
    DQALIGNPOSL : out std_logic_vector(7 downto 0);
    DQALIGNPOSH : out std_logic_vector(7 downto 0);
    DEBUG : out std_logic_vector(3 downto 0)
    );
end memddr2;

architecture Behavioral of memddr2 is

  signal lcas : std_logic := '1';

  signal dsel : integer range 0 to 3 := 0;

  signal lcke  : std_logic                     := '0';
  signal lras  : std_logic                     := '1';
  signal lcs   : std_logic                     := '1';
  signal lwe   : std_logic                     := '1';
  signal laddr : std_logic_vector(12 downto 0) := (others => '0');
  signal lba   : std_logic_vector(1 downto 0)  := (others => '0');
  signal lts   : std_logic                     := '0';

  signal startl : std_logic := '0';
  
  -- per-module signals

  -- Refresh module
  component refreshddr2
    port (
      CLK                  : in  std_logic;
      START                : in  std_logic;
      DONE                 : out std_logic;
      -- ram interface
      CS                   : out std_logic;
      RAS                  : out std_logic;
      CAS                  : out std_logic;
      WE                   : out std_logic
      );
  end component;
  signal refstart, refdone :     std_logic := '0';

  signal refcas : std_logic := '0';
  signal refras : std_logic := '0';
  signal refcs  : std_logic := '0';
  signal refwe  : std_logic := '0';

  --  boot module

  component bootddr2
    port (
      CLK   : in  std_logic;
      START : in  std_logic;
      DONE  : out std_logic;
      -- ram interface
      CKE   : out std_logic;
      CS    : out std_logic;
      RAS   : out std_logic;
      CAS   : out std_logic;
      WE    : out std_logic;
      ADDR  : out std_logic_vector(12 downto 0);
      BA    : out std_logic_vector(1 downto 0);
      -- parameters
      EMR   : in  std_logic_vector(12 downto 0);
      MR    : in  std_logic_vector(12 downto 0)
      );
  end component;

  signal bootstart, bootdone : std_logic := '0';


  signal bootcas  : std_logic                     := '0';
  signal bootras  : std_logic                     := '0';
  signal bootcs   : std_logic                     := '0';
  signal bootwe   : std_logic                     := '0';
  signal bootaddr : std_logic_vector(12 downto 0) := (others => '0');
  signal bootba   : std_logic_vector(1 downto 0)  := (others => '0');
  signal bootcke  : std_logic                     := '0';

  signal emr, mr : std_logic_vector(12 downto 0) := (others => '0');

  -- write module
  -- 
  component writeddr2
  generic (
      CASLATENCY : in integer);
    port (
      CLK    : in  std_logic;
      START  : in  std_logic;
      DONE   : out std_logic;
      -- ram interface
      CS     : out std_logic;
      RAS    : out std_logic;
      CAS    : out std_logic;
      WE     : out std_logic;
      ADDR   : out std_logic_vector(12 downto 0);
      BA     : out std_logic_vector(1 downto 0);
      DOUT   : out std_logic_vector(31 downto 0);
      TS     : out std_logic;
      -- input data interface
      ROWTGT : in  std_logic_vector(14 downto 0);
      WADDR  : out std_logic_vector(7 downto 0);
      WDATA  : in  std_logic_vector(31 downto 0)
      );
  end component;

  signal wstart, wdone : std_logic := '0';

  signal wcas  : std_logic                     := '0';
  signal wras  : std_logic                     := '0';
  signal wcs   : std_logic                     := '0';
  signal wwe   : std_logic                     := '0';
  signal waddr : std_logic_vector(12 downto 0) := (others => '0');
  signal wba   : std_logic_vector(1 downto 0)  := (others => '0');

  signal noterm : std_logic := '0';


  component readddr2
  generic (
      CASLATENCY : in integer);
    port (      CLK         : in  std_logic;
      START       : in  std_logic;
      DONE        : out std_logic;
      -- ram interface
      CS          : out std_logic;
      RAS         : out std_logic;
      CAS         : out std_logic;
      WE          : out std_logic;
      ADDR        : out std_logic_vector(12 downto 0);
      BA          : out std_logic_vector(1 downto 0);
      DIN         : in  std_logic_vector(31 downto 0);
      -- input data interface
      ROWTGT      : in  std_logic_vector(14 downto 0);
      RADDR       : out std_logic_vector(7 downto 0);
      RDATA       : out std_logic_vector(31 downto 0);
      RWE         : out std_logic;
      NOTERMINATE : in  std_logic;
      LATENCYEXTRA : in std_logic_vector(1 downto 0);
      READOFFSET: in std_logic_vector(1 downto 0)
      );
  end component;

  signal rstart, rdone : std_logic := '0';

  signal rcas  : std_logic                     := '0';
  signal rras  : std_logic                     := '0';
  signal rcs   : std_logic                     := '0';
  signal rwe   : std_logic                     := '0';
  signal raddr : std_logic_vector(12 downto 0) := (others => '0');
  signal rba   : std_logic_vector(1 downto 0)  := (others => '0');

  signal notterminate : std_logic := '0';

  component dqalign
    port (
      CLK          : in    std_logic;
      CLK90        : in    std_logic;
      CLK180       : in    std_logic;
      CLK270       : in    std_logic;
      DQS          : inout std_logic;
      DQ           : inout std_logic_vector(7 downto 0);
      TS           : in    std_logic;
      DIN          : in    std_logic_vector(15 downto 0);
      DOUT         : out   std_logic_vector(15 downto 0);
      START        : in    std_logic;
      DONE         : out   std_logic;
      LATENCYEXTRA : out   std_logic;
    POSOUT : out std_logic_vector(7 downto 0)
      
      );
  end component;

  signal alstart : std_logic := '0';
  signal aldone  : std_logic := '0';
  signal aldonel : std_logic := '0';
  signal aldoneh : std_logic := '0';


  signal dout : std_logic_vector(31 downto 0) := (others => '0');
  signal din  : std_logic_vector(31 downto 0) := (others => '0');


  signal ts : std_logic := '0';

  type states is (none, boot, dumbread, aligns, alignw, drw,
                  refresh, read, readdone, inchk, write, writedone);
  signal ocs, ons : states := none;

  signal dinl, dinh   : std_logic_vector(15 downto 0) := (others => '0');
  signal doutl, douth : std_logic_vector(15 downto 0) := (others => '0');

  signal latencyextra : std_logic_vector(1 downto 0) := (others => '0');
  
  component memcontmux
    port (
      CLK      : in  std_logic;
      DSEL     : in  integer range 0 to 3;
      -- RAM!
      CKE      : out std_logic := '0';
      CAS      : out std_logic;
      RAS      : out std_logic;
      CS       : out std_logic;
      WE       : out std_logic;
      ADDR     : out std_logic_vector(12 downto 0);
      BA       : out std_logic_vector(1 downto 0);
      -- Boot module interface
      BOOTCKE  : in  std_logic := '0';
      BOOTCAS  : in  std_logic;
      BOOTRAS  : in  std_logic;
      BOOTCS   : in  std_logic;
      BOOTWE   : in  std_logic;
      BOOTADDR : in  std_logic_vector(12 downto 0);
      BOOTBA   : in  std_logic_vector(1 downto 0);
      -- Refresh module interface
      REFCKE   : in  std_logic := '0';
      REFCAS   : in  std_logic;
      REFRAS   : in  std_logic;
      REFCS    : in  std_logic;
      REFWE    : in  std_logic;
      REFADDR  : in  std_logic_vector(12 downto 0);
      REFBA    : in  std_logic_vector(1 downto 0);
      -- write module interface
      WCKE     : in  std_logic := '0';
      WCAS     : in  std_logic;
      WRAS     : in  std_logic;
      WCS      : in  std_logic;
      WWE      : in  std_logic;
      WADDR    : in  std_logic_vector(12 downto 0);
      WBA      : in  std_logic_vector(1 downto 0);
      -- read module interface
      RCKE     : in  std_logic := '0';
      RCAS     : in  std_logic;
      RRAS     : in  std_logic;
      RCS      : in  std_logic;
      RWE      : in  std_logic;
      RADDR    : in  std_logic_vector(12 downto 0);
      RBA      : in  std_logic_vector(1 downto 0)
      );
  end component;

                                    
begin  -- Behavioral

  din(15 downto 0)  <= dinh(7 downto 0) & dinl(7 downto 0);
  din(31 downto 16) <= dinh(15 downto 8) & dinl(15 downto 8);


  doutl <= dout(23 downto 16) & dout(7 downto 0);
  douth <= dout(31 downto 24) & dout(15 downto 8);

  refreshddr2_inst : refreshddr2
    port map (
      CLK   => CLK,
      START => refstart,
      DONE  => refdone,
      CS    => refcs,
      RAS   => refras,
      CAS   => refcas,
      WE    => refwe);



  bootddr2_inst : bootddr2
    port map (
      CLK   => CLK,
      START => bootstart,
      DONE  => bootdone,
      CKE   => bootcke,
      RAS   => bootras,
      CAS   => bootcas,
      CS    => bootcs,
      WE    => bootwe,
      ADDR  => bootaddr,
      BA    => bootba,
      EMR   => emr,
      MR    => mr);


  writeddr2_inst : writeddr2
    generic map (
      CASLATENCY => CASLATENCY)
    port map (
      CLK    => CLK,
      START  => wstart,
      DONE   => wdone,
      CS     => wcs,
      RAS    => wras,
      CAS    => wcas,
      WE     => wwe,
      ADDR   => waddr,
      BA     => wba,
      DOUT   => dout,
      ts     => ts,
      ROWTGT => ROWTGT,
      WADDR  => WRADDR,
      WDATA  => WRDATA);

  readaddr2_inst : readddr2
    generic map (
      CASLATENCY => CASLATENCY)
    port map (
      CLK         => CLK,
      START       => rstart,
      DONE        => rdone,
      CS          => rcs,
      RAS         => rras,
      CAS         => rcas,
      WE          => rwe,
      ADDR        => raddr,
      BA          => rba,
      DIN         => din,
      ROWTGT      => rowtgt,
      RADDR       => RDADDR,
      RDATA       => RDDATA,
      RWE         => RDWE,
      NOTERMINATE => noterm,
      LATENCYEXTRA => latencyextra,
      READOFFSET => "00");

  dqalign_inst_low : dqalign
    port map (
      CLK          => CLK,
      CLK90        => CLK90,
      CLK180       => CLK180,
      CLK270       => CLK270,
      DQS          => DQSL,
      DQ           => DQ(7 downto 0),
      TS           => ts,
      DIN          => doutl,
      DOUT         => dinl,
      START        => alstart,
      DONE         => aldonel,
      LATENCYEXTRA => latencyextra(0), 
      POSOUT => DQALIGNPOSL);

  dqalign_inst_high : dqalign
    port map (
      CLK          => CLK,
      CLK90        => CLK90,
      CLK180       => CLK180,
      CLK270       => CLK270,
      DQS          => DQSH,
      DQ           => DQ(15 downto 8),
      TS           => ts,
      DIN          => douth,
      DOUT         => dinh,
      START        => alstart,
      DONE         => aldoneh,
      LATENCYEXTRA => latencyextra(1),
      POSOUT => DQALIGNPOSH
      );

  DEBUG(1 downto 0) <= latencyextra;
  
  aldone <= aldonel and aldoneh;

  memcontmux_inst : memcontmux
    port map (
      CLK      => CLK,
      DSEL     => dsel,
      CKE      => CKE,
      CAS      => CAS,
      RAS      => RAS,
      CS       => CS,
      WE       => WE,
      ADDR     => ADDR,
      BA       => BA,
      BOOTCKE  => bootcke,
      BOOTCAS  => bootcas,
      BOOTRAS  => bootras,
      BOOTCS   => bootcs,
      BOOTWE   => bootwe,
      BOOTADDR => bootaddr,
      BOOTBA   => bootba,
      REFCKE   => '1',
      REFCAS   => refcas,
      REFRAS   => refras,
      REFCS    => REFcs,
      REFADDR  => "0000000000000",
      REFWE    => refwe,
      REFBA    => "00",
      WCKE     => '1',
      WCAS     => wcas,
      WRAS     => wras,
      WCS      => wcs,
      WWE      => wwe,
      WADDR    => waddr,
      WBA      => wba,
      RCKE     => '1',
      RCAS     => rcas,
      RRAS     => rras,
      RCS      => rcs,
      RWE      => rwe,
      RADDR    => raddr,
      RBA      => rba);



  mr <= "0010000110010" when CASLATENCY = 3 else
        "0010001000010" when CASLATENCY = 4 else
        "0010001010010" when CASLATENCY = 5;

  emr <= "0010000000000";

  DONE <= '1' when ocs = readdone or ocs = writedone else '0';

  main : process(CLK)
  begin
    if reset = '1' then
      ocs <= none;
    else
      if rising_edge(CLK) then

        ocs <= ons;

        if ocs = readdone or ocs = writedone then
          startl <= '0';
        else
          if START = '1' then
            startl <= '1'; 
          end if;
        end if;

      end if;
    end if;
  end process main;

  fsm : process(ocs, bootdone, aldone, rdone, wdone, refdone, start,
                startl, rw)
  begin
    case ocs is
      when none =>
        dsel      <= 1;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        ons       <= boot;

      when boot =>
        dsel      <= 1;
        bootstart <= '1';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        if bootdone = '1' then
          ons     <= dumbread;
        else
          ons     <= boot;
        end if;

      when dumbread =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '1';
        wstart    <= '0';
        noterm    <= '1';
        alstart   <= '0';
        ons       <= aligns;

      when aligns =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '1';
        alstart   <= '1';
        ons       <= alignw;

      when alignw =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '1';
        alstart   <= '0';
        if aldone = '1' then
          ons     <= drw;
        else
          ons     <= alignw;
        end if;

      when drw =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        if rdone = '1' then
          ons     <= refresh;
        else
          ons     <= drw;
        end if;

      when refresh =>
        dsel      <= 1;
        bootstart <= '0';
        refstart  <= '1';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        if refdone = '1' then
          ons     <= inchk;
        else
          ons     <= refresh;
        end if;

      when inchk =>
        dsel      <= 1;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        if startl = '1' then
          if rw = '0' then
            ons   <= read;
          else
            ons   <= write;
          end if;
        else
          ons     <= inchk;
        end if;

      when read =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '1';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        if rdone = '1' then
          ons     <= readdone;
        else
          ons     <= read;
        end if;

      when readdone =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        ons       <= refresh;

      when write =>
        dsel      <= 2;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '1';
        noterm    <= '0';
        alstart   <= '0';
        if wdone = '1' then
          ons     <= writedone;
        else
          ons     <= write;
        end if;

      when writedone =>
        dsel      <= 3;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        ons       <= refresh;

      when others =>
        dsel      <= 0;
        bootstart <= '0';
        refstart  <= '0';
        rstart    <= '0';
        wstart    <= '0';
        noterm    <= '0';
        alstart   <= '0';
        ons       <= none;
    end case;

  end process fsm;

end Behavioral;
