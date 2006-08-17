library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dqalign is

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
    LATENCYEXTRA : out   std_logic

    );

end dqalign;

architecture Behavioral of dqalign is

  -- data strobe signals
  signal dqsinc : std_logic := '0';
  signal inrst  : std_logic := '0';
  signal dqsce  : std_logic := '0';

  signal dqsdelay     : std_logic := '0';
  signal dqsq1, dqsq2 : std_logic := '0';
  signal dqsamp       : std_logic := '0';

  signal dqsq1l, dqsq2l : std_logic := '0';

  -- data signals
  signal dqdelay              : std_logic_vector(7 downto 0) := (others => '0');
  signal ddq1, ddq2           : std_logic_vector(7 downto 0) := (others => '0');
  signal ddq1l, ddq2l, ddq2ll : std_logic_vector(7 downto 0) := (others => '0');
  signal dinddr               : std_logic_vector(7 downto 0) := (others => '0');
  signal dqinc                : std_logic                    := '0';
  signal dqce                 : std_logic                    := '0';

  signal ince : std_logic                    := '1';
  signal dqi  : std_logic_vector(7 downto 0) := (others => '0');


  -- counters
  signal dqscnt : std_logic_vector(5 downto 0) := (others => '0');
  signal dqcnt  : std_logic_vector(5 downto 0) := (others => '0');

  -- state machine
  type states is (none, resetall, startw1, startw2, startw3,
                  propw1, propw2, propw3, propw4, nexttick,
                  datainc, propdone, dones);

  signal cs, ns : states := none;

  signal osel : std_logic := '0';

  signal dqsin : std_logic := '0';

  constant PPOS : integer := 22;


begin  -- Behavioral

  LATENCYEXTRA <= osel;

  IDELAY_dqs : IDELAY
    generic map (
      IOBDELAY_TYPE  => "VARIABLE",
      IOBDELAY_VALUE => 0)
    port map (
      O              => dqsdelay,
      C              => CLK,
      CE             => dqsce,
      I              => dqsin,
      INC            => dqsinc,
      RST            => inrst
      );

  IOBUF_inst : IOBUF
    port map (
      O  => dqsin,
      IO => DQS,
      I  => CLK90,
      T  => TS
      );

  iogen       : for i in 0 to 7 generate
    IDELAY_dq : IDELAY
      generic map (
        IOBDELAY_TYPE  => "VARIABLE",
        IOBDELAY_VALUE => 0)
      port map (
        O              => dqdelay(i),
        C              => CLK,
        CE             => dqce,
        I              => dqi(i),
        INC            => dqinc,
        RST            => inrst
        );

    IDDR_dq : IDDR
      generic map (
        DDR_CLK_EDGE => "OPPOSITE_EDGE",
        INIT_Q1      => '0',
        INIT_Q2      => '0',
        SRTYPE       => "SYNC")
      port map (
        Q1           => ddq1(i),
        Q2           => ddq2(i),
        C            => CLK,
        CE           => '1',
        D            => dqdelay(i),
        R            => inrst,
        S            => '0'
        );

    ODDR_dq : ODDR
      generic map(
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT         => '0',
        SRTYPE       => "SYNC")
      port map (
        Q            => dinddr(i),
        C            => CLK,
        CE           => '1',
        D1           => DIN(i+8),
        D2           => DIN(i),
        R            => inrst,
        S            => '0'
        );
  end generate iogen;


  DONE <= '1' when cs = dones else '0';


  dqs_dq : IDDR
    generic map (
      DDR_CLK_EDGE => "OPPOSITE_EDGE",
      INIT_Q1      => '0',
      INIT_Q2      => '0',
      SRTYPE       => "SYNC")
    port map (
      Q1           => dqsq1,
      Q2           => dqsq2,
      C            => CLK,
      CE           => '1',
      D            => dqsdelay,
      R            => inrst,
      S            => '0'
      );

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- dqs components
      if dqsamp = '1' then
        dqsq1l <= dqsq1;
        dqsq2l <= dqsq2;
      end if;

      if inrst = '1' then
        dqscnt   <= (others => '0');
      else
        if dqsinc = '1' then
          dqscnt <= dqscnt + 1;
        end if;
      end if;


      -- dq components
      if inrst = '1' then
        dqcnt   <= (others => '0');
      else
        if dqinc = '1' then
          dqcnt <= dqcnt + 1;
        end if;
      end if;

      if ince = '1' then
        ddq1l <= ddq1;
        ddq2l <= ddq2;
      end if;

      ddq2ll              <= ddq2l;
      if osel = '1' then
        DOUT(15 downto 8) <= ddq1l;
        DOUT(7 downto 0)  <= ddq2l;

      else
        DOUT(15 downto 8) <= ddq2ll;
        DOUT(7 downto 0)  <= ddq1l;
      end if;

      if cs = propw4 then
        if dqscnt >= PPOS then
          osel <= '0';
        else
          osel <= '1';
        end if;
      end if;

    end if;
  end process main;


  fsm : process(cs, START, dqsq1, dqsq2, dqsq1l, dqcnt, dqscnt)
  begin
    case cs is
      when none =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        if START = '1' then
          ns   <= resetall;
        else
          ns   <= none;
        end if;

      when resetall =>
        inrst  <= '1';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= startw1;

      when startw1 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= startw2;

      when startw2 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= startw3;

      when startw3 =>
        inrst  <= '0';
        dqsamp <= '1';
        dqsinc <= '1';
        dqsce  <= '1';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= propw1;

      when propw1 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= propw2;

      when propw2 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= propw3;

      when propw3 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= propw4;

      when propw4 =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        if dqsq1 /= dqsq1l then
          ns   <= datainc;
        else
          ns   <= nexttick;
        end if;

      when nexttick =>
        inrst  <= '0';
        dqsamp <= '1';
        dqsinc <= '1';
        dqsce  <= '1';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= propw1;

      when datainc  =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '1';
        dqce   <= '1';
        if dqscnt < PPOS then
          if dqcnt = dqscnt + "010110" then
            ns <= propdone;
          else
            ns <= datainc;
          end if;
        else
          if dqcnt = dqscnt - "010110" then
            ns <= propdone;
          else
            ns <= datainc;
          end if;
        end if;
      when propdone =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= dones;

      when dones =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        if start = '1' then
          ns   <= resetall;
        else
          ns   <= dones;
        end if;

      when others =>
        inrst  <= '0';
        dqsamp <= '0';
        dqsinc <= '0';
        dqsce  <= '0';
        dqinc  <= '0';
        dqce   <= '0';
        ns     <= none;
    end case;
  end process fsm;


  out_gen      : for i in 0 to 7 generate
    IOBUF_inst : IOBUF
      port map (
        O  => dqi(i),                   -- Buffer output
        IO => dq(i),                    -- Buffer inout port (connect directly to top-level port)
        I  => dinddr(i),                -- Buffer input
        T  => TS                        -- 3-state enable input 
        );

  end generate out_gen;
end Behavioral;
