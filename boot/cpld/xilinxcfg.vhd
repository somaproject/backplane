library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity xilinxcfg is
  generic (
    SIMPLE : in boolean := false);
  port (
    CLK    : in  std_logic;
    RESET : in std_logic; 
    DSTART : out std_logic;
    DIN    : in  std_logic_vector(7 downto 0);
    DDONE  : in  std_logic;
    DVALID : in  std_logic;
    ADDR   : out std_logic_vector(15 downto 0);
    FCLK   : out std_logic;
    FPROG  : out std_logic;
    FDIN   : out std_logic;
    FSEL   : out std_logic
    );

end xilinxcfg;


architecture Behavioral of xilinxcfg is

-- simple xilinx configuration interface.
--
--


  signal lfclk, lfdin : std_logic := '0';
  signal lfprog       : std_logic := '1';


  type states is (none, prog, progdone, dvstart, dvwait, dvlow, dvhigh, donechk, done);

  signal cs, ns : states                        := none;
  signal cnt    : std_logic_vector(10 downto 0) := (others => '0');

  signal cntrst, cnten : std_logic := '0';
  
  signal ocnten : std_logic            := '0';
  signal ocnt   : integer range 0 to 7 := 0;

  signal ldin : std_logic_vector(7 downto 0) := (others => '0');
begin  -- Behavioral

  lfdin <= ldin(ocnt);
  ADDR  <= "00000" & cnt;

  FDIN  <= lfdin;
  FCLK  <= lfclk;
  FPROG <= lfprog;

  fsel <= '1' when cs = done else '0'; 

  main : process(CLK)
  begin
    if RESET = '1' then
      cs <= none; 
else
    if rising_edge(CLK) then

      cs <= ns;

      if dvalid = '1' then
        ldin <= din;              
      end if;

      if cntrst = '1' then
        cnt   <= (others => '0');
      else
        if cnten = '1' then
          cnt <= cnt + 1;
        end if;
      end if;

      if ocnten = '1' then
        if ocnt = 7 then
          ocnt <= 0;
        else
          ocnt <= ocnt + 1;
        end if;
      end if;

    end if;
    end if;
  end process main;


  fsm : process(cs, cnt, ddone, dvalid, ocnt)
  begin
    case cs is
      when none =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '1';
        cnten  <= '0';
        dstart <= '0';
        ocnten <= '0';
        if DDONE = '1' then
          ns   <= prog;
        else
          ns   <= none;
        end if;

      when prog =>
        lfclk  <= '0';
        lfprog <= '0';
        cntrst <= '0';
        cnten  <= '1';
        dstart <= '0';
        ocnten <= '0';
        if cnt = "11111111111" then
          ns   <= progdone;
        else
          ns   <= prog;
        end if;

      when progdone =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '1';
        cnten  <= '0';
        dstart <= '0';
        ocnten <= '0';
        ns     <= dvstart;

      when dvstart =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '0';
        dstart <= '1';
        ocnten <= '0';
        ns     <= dvwait;
      when dvwait  =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '0';
        dstart <= '0';
        ocnten <= '0';
        if ddone = '1' then
          ns   <= donechk;
        else
          if SIMPLE  and (dvalid = '1') then
            ns <= dvlow;
          else
            ns <= dvwait;
          end if;
        end if;

      when dvlow   =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '0';
        dstart <= '0';
        ocnten <= '0';
        ns     <= dvhigh;
      when dvhigh  =>
        lfclk  <= '1';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '0';
        dstart <= '0';
        ocnten <= '1';
        if ocnt = 7 then
          ns   <= dvwait;
        else
          ns   <= dvlow;
        end if;
      when donechk =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '1';
        dstart <= '0';
        ocnten <= '0';
        if cnt = "11110000000" then
          ns   <= done;
        else
          ns   <= dvstart;
        end if;
      when done    =>
        lfclk  <= '0';
        lfprog <= '1';
        cntrst <= '0';
        cnten  <= '1';
        dstart <= '0';
        ocnten <= '0';
        ns     <= done;
    end case;

  end process fsm;
end Behavioral;


