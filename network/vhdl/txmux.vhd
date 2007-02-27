library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack.all;
use WORK.networkstack;

entity txmux is
  port (
    CLK      : in  std_logic;
    DEN      : in  std_logic_vector(6 downto 0);
    DIN0     : in  std_logic_vector(15 downto 0);
    DIN1     : in  std_logic_vector(15 downto 0);
    DIN2     : in  std_logic_vector(15 downto 0);
    DIN3     : in  std_logic_vector(15 downto 0);
    DIN4     : in  std_logic_vector(15 downto 0);
    DIN5     : in  std_logic_vector(15 downto 0);
    DIN6     : in  std_logic_vector(15 downto 0);
    GRANT    : out std_logic_vector(6 downto 0);
    ARM      : in  std_logic_vector(6 downto 0);
    DOUT     : out std_logic_vector(15 downto 0);
    TXDONE   : out std_logic;
    NEWFRAME : out std_logic;
    -- staus output
    PKTLEN   : out std_logic_vector(15 downto 0);
    PKTLENEN : out std_logic;
    TXCHAN   : out std_logic_vector(2 downto 0)
    );

end txmux;


architecture Behavioral of txmux is


  signal dinmux          : std_logic_vector(15 downto 0) := (others => '0');
  signal denmux, denmuxl : std_logic                     := '0';

  signal lchan, chan : integer range 0 to 6         := 0;
  signal arml        : std_logic_vector(6 downto 0) := (others => '0');
  signal orarml      : std_logic                    := '0';

  signal grantmux : std_logic := '0';

  type states is (start, grants, grantw, chanlat, delayw);
  signal cs, ns : states := start;

  signal waitcnt : integer range 0 to 15 := 0;

begin  -- Behavioral

  dinmux <= DIN0  when chan = 0 else
            DIN1  when chan = 1 else
            DIN2  when chan = 2 else
            DIN3  when chan = 3 else
            DIN4  when chan = 4 else
            DIN5  when chan = 5 else
            DIN6;

  TXCHAN <= "000" when chan = 0 else
            "001" when chan = 1 else
            "010" when chan = 2 else
            "011" when chan = 3 else
            "100" when chan = 4 else
            "101" when chan = 5 else
            "110" when chan = 6 else
            "111";


  denmux <= DEN(chan);

  -- priority encoder
  lchan <= 0 when arml(0) = '1' else
           1 when arml(1) = '1' else
           2 when arml(2) = '1' else
           3 when arml(3) = '1' else
           4 when arml(4) = '1' else
           5 when arml(5) = '1' else
           6 when arml(6) = '1' else
           0;

  orarml <= arml(0) or arml(1) or arml(2) or arml(3) or arml(4) or arml(5)
            or arml(6);

  setregs : for i in 0 to 6 generate
    process (CLK)
    begin
      if rising_edge(CLK) then
        if cs = grantw and chan = i then
          arml(i)   <= '0';
        else
          if ARM(i) = '1' then
            arml(i) <= '1';
          end if;
        end if;

        if grantmux = '1' and chan = i then
          grant(i) <= '1';
        else
          grant(i) <= '0';
        end if;

        if waitcnt = 14 then
          TXDONE <= '1';
        else
          TXDONE <= '0';
        end if;

      end if;

    end process;
  end generate setregs;



  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      DOUT     <= dinmux;
      NEWFRAME <= denmux;

      denmuxl    <= denmux;
      PKTLEN     <= dinmux;
      if denmux = '1' and denmuxl = '0' then
        PKTLENEN <= '1';
      else
        PKTLENEN <= '0';
      end if;


      if cs = chanlat then
        chan <= lchan;
      end if;

      if cs = grantw then
        waitcnt   <= 0;
      else
        if cs = delayw then
          waitcnt <= waitcnt + 1;
        end if;
      end if;

    end if;
  end process main;

  fsm : process(cs, chan, orarml, denmux, waitcnt)
  begin
    case cs is
      when start =>
        grantmux <= '0';
        if orarml = '1' then
          ns     <= chanlat;
        else
          ns     <= start;
        end if;

      when chanlat =>
        grantmux <= '0';
        ns       <= grants;

      when grants =>
        grantmux <= '1';
        if denmux = '1' then
          ns     <= grantw;
        else
          ns     <= grants;
        end if;

      when grantw =>
        grantmux <= '0';
        if denmux = '0' then
          ns     <= delayw;
        else
          ns     <= grantw;
        end if;

      when delayw =>
        grantmux <= '0';
        if waitcnt = 14 then
          ns     <= start;
        else
          ns     <= delayw;
        end if;

      when others =>
        grantmux <= '0';
        ns       <= start;

    end case;
  end process fsm;


end Behavioral;
