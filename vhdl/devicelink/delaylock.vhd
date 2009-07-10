library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity delaylock is
  port (
    CLK       : in  std_logic;
    START     : in  std_logic;
    DONE      : out std_logic;
    LOCKED    : out std_logic;
    DEBUG     : out std_logic;
    DEBUGADDR : in  std_logic_vector(5 downto 0);
    WINPOS    : out std_logic_vector(5 downto 0);
    WINLEN    : out std_logic_vector(5 downto 0);
    -- delay interface
    DLYRST    : out std_logic;
    DLYINC    : out std_logic;
    DLYCE     : out std_logic;
    DIN       : in  std_logic_vector(9 downto 0)
    );
end delaylock;

architecture Behavioral of delaylock is

  -- data latching
  signal dinl, dinll : std_logic_vector(9 downto 0) := (others => '0');
  signal lastdinll : std_logic_vector(9 downto 0) := (others => '0');

  signal modcnt : std_logic_vector(5 downto 0) := (others => '0');
  signal poscnt : std_logic_vector(5 downto 0) := (others => '0');
  signal posrst : std_logic                    := '0';
  signal posinc : std_logic                    := '0';


  signal rdcnt    : integer range 0 to 1023 := 0;
  signal rdcntrst : std_logic               := '0';

  -- delay table signals
  signal dtrst, dtwe, dtdin : std_logic := '0';

  -- window lock signals
  signal winaddr          : std_logic_vector(5 downto 0) := (others => '0');
  signal windin           : std_logic                    := '0';
  signal windone          : std_logic                    := '0';
  signal winfail          : std_logic                    := '0';
  signal winstart         : std_logic                    := '0';
  signal lwinpos, lwinlen : std_logic_vector(5 downto 0) := (others => '0');

  
  type states is (none, rstcnt,
                  waits, readv, bitgood, biterror, nextdly,
                  wlockst, wlockw, rstdly, faillock,
                  compmod, startlck, lockpos, dones);

  signal cs, ns : states := none;

  constant MODMAX : integer := 53;

  constant RDCNTMAX : integer := 100;

  component delaytable
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      WE       : in  std_logic;
      DIN      : in  std_logic;
      ADDRIN   : in  std_logic_vector(5 downto 0);
      DOUTA    : out std_logic;
      ADDROUTA : in  std_logic_vector(5 downto 0);
      DOUTB    : out std_logic;
      ADDROUTB : in  std_logic_vector(5 downto 0)
      );
  end component;


  component windowdetect
    generic (
      MAXCNT : integer := 24;
      ADDRN  : integer := 4);
    port (
      CLK    : in  std_logic;
      START  : in  std_logic;
      ADDR   : out std_logic_vector(ADDRN-1 downto 0);
      DIN    : in  std_logic;
      -- Outputs
      OUTPOS : out std_logic_vector(ADDRN-1 downto 0);
      OUTLEN : out std_logic_vector(ADDRN -1 downto 0);
      DONE   : out std_logic;
      FAIL   : out std_logic
      );
  end component;

begin  -- Behavioral

  delaytable_inst : delaytable
    port map (
      CLK      => CLK,
      RESET    => dtrst,
      WE       => dtwe,
      DIN      => dtdin,
      ADDRIN   => poscnt(5 downto 0),
      DOUTA    => DEBUG,
      ADDROUTA => DEBUGADDR ,
      DOUTB    => windin,
      ADDROUTB => winaddr);

  windowdetect_inst : windowdetect
    generic map (
      MAXCNT => 53,
      ADDRN  => 6)
    port map (
      CLK    => CLK,
      START  => winstart,
      ADDR   => winaddr,
      DIN    => windin,
      OUTPOS => lwinpos,
      OUTLEN => lwinlen,
      DONE   => windone,
      FAIL   => winfail);

  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

      -- modulus counter, to figure out where exactly we should
      -- position the counter
      if cs = rstdly then
        modcnt <= (others => '0');
      else
        if cs = compmod then
          if modcnt = std_logic_vector(TO_unsigned(MODMAX-1, 6)) then
            modcnt <= (others => '0');
          else
            modcnt <= modcnt + 1;
          end if;
        end if;
      end if;

      -- generic position counter
      if posrst = '1' then
        poscnt <= (others => '0');
      else
        if posinc = '1' then
          poscnt <= poscnt + 1;
        end if;
      end if;

      -- latching of input data
      dinl  <= DIN;
      dinll <= dinl;

      if cs = nextdly then
        lastdinll <= dinll;               
      end if;

      if cs = wlockst then
        winstart <= '1';
      else
        winstart <= '0';
      end if;

      if cs = dones then
        done   <= '1';
        locked <= '1';
      elsif cs = faillock then
        done   <= '1';
        locked <= '0';
      else
        done   <= '0';
        locked <= '0';
      end if;

      if rdcntrst = '1' then
        rdcnt <= 0;
      else
        if rdcnt = 1023 then
          rdcnt <= 0;
        else
          rdcnt <= rdcnt + 1;
        end if;
      end if;

      WINPOS <= lwinpos;
      WINLEN <= lwinlen;
      
    end if;
  end process main;


  fsm : process(cs, rdcnt, dinl, dinll, windone,
                lastdinll, winfail, poscnt, lwinpos, lwinlen)
  begin
    case cs is
      when none =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if START = '1' then
          ns <= rstcnt;
        else
          ns <= none;
        end if;

      when rstcnt =>
        DLYRST   <= '1';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '1';
        posinc   <= '0';
        dtrst    <= '1';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '1';
        ns       <= waits;
        
      when waits =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if rdcnt = RDCNTMAX then
          ns <= readv;
        else
          ns <= waits;
        end if;

      when readv =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if rdcnt = 2*RDCNTMAX then
          ns <= bitgood;
        else
          if dinl /= dinll or (dinll /= lastdinll and poscnt /= 0) then
            ns <= biterror;
          else
            ns <= readv;
          end if;
        end if;
        
      when bitgood =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '1';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= nextdly;

      when biterror =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '1';
        dtdin    <= '1';
        rdcntrst <= '0';
        ns       <= nextdly;

      when nextdly =>
        DLYRST   <= '0';
        DLYINC   <= '1';
        DLYCE    <= '1';
        posrst   <= '0';
        posinc   <= '1';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '1';
        if poscnt = modmax then
          ns <= wlockst;
        else
          ns <= waits;
        end if;

      when wlockst =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= wlockw;
        
      when wlockw =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if windone = '1' then
          if winfail = '0' then
            ns <= rstdly;
          else
            ns <= faillock;
          end if;
        else
          ns <= wlockw;
        end if;
        
      when faillock =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= none;

      when rstdly =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '1';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= compmod;

      when compmod =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '1';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if poscnt(5 downto 0) = lwinpos + ('0' & lwinlen(5 downto 1)) then
          ns <= startlck;
        else
          ns <= compmod;
        end if;

      when startlck =>
        DLYRST   <= '1';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '1';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';

        ns <= lockpos;
        
      when lockpos =>
        DLYRST   <= '0';
        DLYINC   <= '1';
        DLYCE    <= '1';
        posrst   <= '0';
        posinc   <= '1';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        if poscnt(5 downto 0) < (modcnt -1) then
          ns <= lockpos;
        else
          ns <= dones;
        end if;
        
      when dones =>
        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= none;
        
      when others =>

        DLYRST   <= '0';
        DLYINC   <= '0';
        DLYCE    <= '0';
        posrst   <= '0';
        posinc   <= '0';
        dtrst    <= '0';
        dtwe     <= '0';
        dtdin    <= '0';
        rdcntrst <= '0';
        ns       <= none;
        
        
    end case;

  end process fsm;
end Behavioral;

