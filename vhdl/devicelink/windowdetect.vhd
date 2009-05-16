library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity windowdetect is
  
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
    FAIL : out std_logic
    );

end windowdetect;

architecture Behavioral of windowdetect is

  signal startpos, addrcnt, spanlen :
    std_logic_vector(ADDRN-1 downto 0) := (others => '0');

  signal spanlenl : std_logic_vector(ADDRN-1 downto 0) := (others => '0');

  type states is (none, rstcnt, nextpos, readw, reads, nextaddr,
                  cntcomp, newmax, nextstart, dones);

  signal cs, ns : states := none;

  signal notfail : std_logic := '0';
  
begin  -- Behavioral

  ADDR <= addrcnt;
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- startpos counter
      if cs = rstcnt then
        startpos <= (others => '0');
      else
        if cs = nextstart then
          startpos <= startpos + 1;
        end if;
      end if;

      -- outpos
      if cs = rstcnt then
        outpos <= (others => '0');
      else
        if cs = newmax then
          outpos <= startpos;
        end if;
      end if;

      -- addrcnt
      if cs = nextpos then
        addrcnt <= startpos;
      else
        if cs = nextaddr then
          if addrcnt = std_logic_vector(TO_UNSIGNED(MAXCNT-1, ADDRN)) then
            addrcnt <= (others => '0');
          else
            addrcnt <= addrcnt + 1;
          end if;
        end if;
      end if;

      if cs = nextpos then
        spanlen <= (others => '0'); 
      else
        if cs = nextaddr then
          spanlen <= spanlen + 1;
        end if;
      end if;

      if cs = rstcnt then
        spanlenl <= (others => '0');
      else
        if cs = newmax then
          spanlenl <= spanlen;
        end if;
      end if;

      if cs = dones then
        DONE <= '1';
        OUTLEN <= spanlenl;
        FAIL <= notfail; 
      else
        DONE <= '0';
      end if;

      if cs = rstcnt then
        notfail <= '0';
      else
        if cs = nextaddr then
          notfail <= '1'; 
        end if;
      end if;
      
    end if;
  end process main;


  fsm : process(cs, start, din, spanlenl, spanlen, startpos)
  begin
    case cs is
      when none =>
        if START = '1' then
          ns <= rstcnt;
        else
          ns <= none;
        end if;

      when rstcnt =>
        ns <= nextpos;

      when nextpos =>
        ns <= readw;

      when readw =>
        ns <= reads;

      when reads =>
        if DIN = '1' or
          spanlen = std_logic_vector(TO_UNSIGNED(MAXCNT, ADDRN)) then
          ns <= cntcomp;
        else
          ns <= nextaddr;
        end if;

      when nextaddr =>
        ns <= readw;

      when cntcomp =>
        if spanlen > spanlenl then
          ns <= newmax;
        else
          ns <= nextstart;
        end if;

      when newmax =>
        ns <= nextstart;
        
      when nextstart =>
        if startpos = MAXCNT-1 then
          ns <= dones;
        else
          ns <= nextpos;
          
        end if;

      when dones =>
        ns <= none;
        
      when others =>
        ns <= none;
        
    end case;
  end process fsm;

end Behavioral;
