library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity eventbodywriter is
  port (
    CLK    : in  std_logic;
    ECYCLE : in  std_logic;
    EDTX   : in  std_logic_vector(7 downto 0);
    EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
    DOUT   : out std_logic_vector(15 downto 0);
    WEOUT  : out std_logic;
    ADDR   : out std_logic_vector(8 downto 0);
    DONE   : out std_logic);
end eventbodywriter;


architecture Behavioral of eventbodywriter is

  -- counters
  signal ewcnt : std_logic_vector(7 downto 0)         := (others => '0');
  signal epos  : integer range 0 to somabackplane.N-1 := 0;
  signal bcnt  : integer range 0 to 11                := 0;

  signal ldout : std_logic_vector(15 downto 0) := (others => '0');

  signal estart : std_logic := '0';

  signal eincnt : std_logic_vector(8 downto 0) := (others => '0');
  signal eininc : std_logic                    := '0';


  signal elb : std_logic := '0';

  signal etxbit : std_logic := '0';

  signal wrlen : std_logic := '0';

  type states is (none, ehdrw, ebegin, ewaith, ewaitl, wrlens);
  signal cs, ns : states := none;


begin  -- Behavioral

  DOUT <= ldout  when wrlen = '0' else (X"00" & ewcnt);
  ADDR <= eincnt when wrlen = '0' else "000000000";

  elb <= '1' when bcnt = 11 else '0';

  etxbit <= eatx(epos);
  eininc <= '1' when etxbit = '1' and cs = ewaitl else '0';
  weout <= '1' when eininc = '1' or cs = wrlens else '0' ; 

  ldout(7 downto 0) <= edtx;
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- event position counter
      if estart = '1' then
        epos     <= 0;
      else
        if elb = '1' and epos < somabackplane.N -1 then
            epos <= epos + 1;
        end if;
      end if;

      if elb = '1' or estart = '1' then 
        bcnt <= 0;
      else
        bcnt <= bcnt + 1;
      end if;


      -- inputs
      if cs = ewaith then
        ldout(15 downto 8) <= EDTX;
      end if;

      if estart = '1' then
        ewcnt   <= (others => '0');
      else
        if elb = '1' and eininc = '1' then
          ewcnt <= ewcnt + 1;
        end if;
      end if;

      if cs = ebegin then
        eincnt <= "000000001"; 
      else
        if eininc = '1' then
          eincnt <= eincnt + 1; 
        end if;
      end if;

      if cs = wrlens then
        DONE <= '1';
      else
        DONE <= '0'; 
      end if;

    end if;

    
  end process main;

  fsm : process(cs, ECYCLE, epos, BCNT)
  begin
    case cs is
      when none =>
        estart <= '1';
        wrlen  <= '0';
        if ECYCLE = '1' then
          ns   <= ehdrw;
        else
          ns   <= none;
        end if;

      when ehdrw =>
        estart <= '0';
        wrlen  <= '0';
        if epos = 3 and bcnt = 9 then
          ns   <= ebegin;
        else
          ns   <= ehdrw;
        end if;

      when ebegin =>
        estart <= '1';
        wrlen  <= '0';
        ns     <= ewaith;

      when ewaith =>
        estart <= '0';
        wrlen  <= '0';
        ns     <= ewaitl;

      when ewaitl =>
        estart <= '0';
        wrlen  <= '0';
        if epos = somabackplane.N - 1 and bcnt = 11 then
          ns   <= wrlens;
        else
          ns   <= ewaith;
        end if;

      when wrlens =>
        estart <= '0';
        wrlen  <= '1';
        ns     <= none;
      when others =>
        estart <= '0';
        wrlen  <= '0';
        ns     <= none;
    end case;

  end process fsm;



end Behavioral;
