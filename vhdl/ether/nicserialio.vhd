library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity nicserialio is
  port (
    CLK   : in  std_logic;
    START : in  std_logic;
    RW    : in  std_logic;
    ADDR  : in  std_logic_vector(5 downto 0);
    DIN   : in  std_logic_vector(31 downto 0);
    DOUT  : out std_logic_vector(31 downto 0);
    DONE  : out std_logic;
    SCLK  : out std_logic;
    SOUT  : out std_logic;
    SCS   : out std_logic;
    SIN   : in  std_logic);
end nicserialio;


architecture Behavioral of nicserialio is
  signal lsout : std_logic_vector(39 downto 0) := (others => '0');

  signal lscs, lsclk : std_logic                     := '0';
  signal sinl        : std_logic                     := '0';
  signal ldout       : std_logic_vector(31 downto 0) := (others => '0');

  type states is (none, loadreg, shiftl1, shifth1, shiftin,
                  shiftl2, nextbit, dones);
  signal cs, ns : states := none;

  signal ticcnt : integer range 0 to 15         := 0;
  signal ticcnten : std_logic := '0';
  signal bitcnt : integer range 0 to 47         := 0;
  signal startl : std_logic                     := '0';
  signal rwl    : std_logic                     := '0';
  signal addrl  : std_logic_vector(5 downto 0)  := (others => '0');
  signal dinl   : std_logic_vector(31 downto 0) := (others => '0');



begin  -- Behavioral


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      startl <= START;
      rwl    <= RW;
      addrl  <= ADDR;
      dinl   <= DIN;
      sinl   <= SIN;

      SCS  <= lscs;
      SOUT <= lsout(39);
      SCLK <= lsclk;


      if cs = nextbit then
        if bitcnt = 39 then
          bitcnt <= 0;
        else
          bitcnt <= bitcnt + 1;
        end if;
      end if;



      if ticcnten = '1' then
        if ticcnt = 15 then
          ticcnt <= 0;

        else
          ticcnt <= ticcnt + 1;
        end if;

      end if;

      if cs = loadreg then
        lsout   <= rwl & '0' & addrl & dinl;
      else
        if cs = nextbit then
          lsout <= lsout(38 downto 0) & '0';
        end if;
      end if;

      if cs = shiftin then
        ldout <= ldout(30 downto 0) & sinl;
      end if;

      DOUT <= ldout;

      if cs = dones then
        DONE <= '1';
      else
        DONE <= '0';
      end if;
    end if;

  end process main;


  fsm : process(cs, startl, ticcnt, bitcnt)
  begin
    case cs is
      when none =>
        ticcnten <= '0';
        lscs      <= '1';
        lsclk    <= '0';
        if startl = '1' then
          ns     <= loadreg;
        else
          ns     <= none;
        end if;

      when loadreg =>
        ticcnten <= '0';
        lscs      <= '0';
        lsclk    <= '0';
        ns       <= shiftl1;

      when shiftl1 =>
        ticcnten <= '1';
        lscs      <= '0';
        lsclk    <= '0';
        if ticcnt = 15 then
          ns     <= shiftin;
        else
          ns     <= shiftl1;
        end if;

      when shiftin =>
        ticcnten <= '0';
        lscs      <= '0';
        lsclk    <= '1';
        ns       <= shifth1;

      when shifth1 =>
        ticcnten <= '1';
        lscs      <= '0';
        lsclk    <= '1';
        if ticcnt = 15 then
          ns     <= shiftl2;
        else
          ns     <= shifth1;
        end if;

      when shiftl2 =>
        ticcnten <= '1';
        lscs      <= '0';
        lsclk    <= '0';
        if ticcnt = 15 then
          ns     <= nextbit;
        else
          ns     <= shiftl2;
        end if;

      when nextbit =>
        ticcnten <= '0';
        lscs      <= '0';
        lsclk    <= '0';
        if bitcnt = 39 then
          ns     <= dones;
        else
          ns     <= shiftl1;
        end if;

      when dones =>
        ticcnten <= '0';
        lscs      <= '1';
        lsclk    <= '0';
        ns       <= none;

      when others =>
        ticcnten <= '0';
        lscs      <= '1';
        lsclk    <= '0';
        ns       <= none;

    end case;

  end process fsm;
end Behavioral;


