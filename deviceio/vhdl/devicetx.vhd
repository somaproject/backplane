-------------------------------------------------------------------------------
-- Title      : devicetx
-- Project    : Soma
-------------------------------------------------------------------------------
-- File       : devicetx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/02/01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Transmission of events and data
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/27  1.0      jonas   Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity devicetx is

  port (
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    DIN       : in  std_logic_vector(7 downto 0);
    DDONE     : in  std_logic;
    DWE       : in  std_logic;
    ECYCLE    : in  std_logic;
    EINA      : in  std_logic_vector(7 downto 0);
    EWEA      : in  std_logic;
    SVALIDA   : out std_logic;
    EINB      : in  std_logic_vector(7 downto 0);
    EWEB      : in  std_logic;
    SVALIDB   : out std_logic;
    TXBYTECLK : in  std_logic;
    DOUT      : out std_logic_vector(7 downto 0);
    KOUT      : out std_logic
    );

end devicetx;

architecture Behavioral of devicetx is

  component datatx
    port ( CLK       : in  std_logic;
           RESET     : in  std_logic;
           DIN       : in  std_logic_vector(7 downto 0);
           DWE       : in  std_logic;
           DDONE     : in  std_logic;
           ECYCLE    : in  std_logic;
           TXBYTECLK : in  std_logic;
           DOUT      : out std_logic_vector(7 downto 0);
           LASTBYTE  : out std_logic;
           KOUT      : out std_logic;
           START     : in  std_logic
           );

  end component;

  component eventtx
    generic (
      KCHAR          :     std_logic_vector(7 downto 0));
    port ( CLK       : in  std_logic;
           RESET     : in  std_logic;
           EIN       : in  std_logic_vector(7 downto 0);
           WE        : in  std_logic;
           ECYCLE    : in  std_logic;
           SVALID    : out std_logic;
           TXBYTECLK : in  std_logic;
           EDOUT     : out std_logic_vector(7 downto 0);
           LASTBYTE  : out std_logic;
           EKOUT     : out std_logic;
           START     : in  std_logic
           );
  end component;

  signal dstart, estarta, estartb : std_logic := '0';
  signal dlb, elba, elbb          : std_logic := '0';
  signal dk, eka, ekb             : std_logic := '0';

  signal dd, eda, edb : std_logic_vector(7 downto 0) := (others => '0');

  signal data : std_logic_vector(7 downto 0) := (others => '0');
  signal k    : std_logic                    := '0';

  signal osel    : integer range 0 to 3 := 0;
  signal ecyclel : std_logic            := '0';

  signal ecnt : integer range 0 to 60000 := 0;

  type states is (none, sheader, sdata, wdata, seventa, weventa, seventb, weventb);
  signal cs, ns : states := sdata;

  constant K28_0 : std_logic_vector(7 downto 0) := "00011100";
  constant K28_1 : std_logic_vector(7 downto 0) := "00111100";
  constant K28_5 : std_logic_vector(7 downto 0) := "10111100";


begin  -- Behavioral

  datatxinst : datatx
    port map ( CLK       => CLK,
               RESET     => RESET,
               DIN       => DIN,
               DWE       => DWE,
               DDONE     => DDONE,
               ECYCLE    => ECYCLE,
               TXBYTECLK => TXBYTECLK,
               DOUT      => dd,
               LASTBYTE  => dlb,
               KOUT      => dk,
               START     => dstart);

  eventtxinsta : eventtx
    generic map (
      KCHAR     => K28_0)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      EIN       => EINA,
      WE        => EWEA,
      ECYCLE    => ECYCLE,
      SVALID    => SVALIDA,
      TXBYTECLk => TXBYTECLK,
      EDOUT     => eda,
      LASTBYTE  => elba,
      EKOUT     => eka,
      START     => estarta);

  eventtxinstb : eventtx
    generic map (
      KCHAR     => K28_1)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      EIN       => EINB,
      WE        => EWEB,
      ECYCLE    => ECYCLE,
      SVALID    => SVALIDB,
      TXBYTECLk => TXBYTECLK,
      EDOUT     => edb,
      LASTBYTE  => elbb,
      EKOUT     => ekb,
      START     => estartb);


  data <= K28_5 when osel = 0 else
         dd    when osel = 1 else
          eda   when osel = 2 else
          edb  when osel = 3;

  k <= '1' when cs = sheader and osel = 0 else
       dk  when osel = 1                  else
       eka when osel = 2                  else
       ekb when osel = 3 else '0';

  DOUT <= data;
  KOUT <= k;


  main : process(TXBYTECLK, RESET)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(TXBYTECLK) then
        cs <= ns;

        if cs = none then
          ecnt <= 0;
        else
          ecnt <= ecnt + 1;
        end if;


      end if;
    end if;

  end process main;

  clkmain : process(CLK)
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        ecyclel   <= '1';
      else
        if cs = sheader then
          ecyclel <= '0';
        end if;
      end if;
    end if;
  end process clkmain;


  fsm : process(cs, dlb, elba, elbb, ecyclel)
  begin
    case cs is
      when none =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel    <= 0;
        if ecyclel = '1' then
          ns    <= sheader;
        else
          ns    <= none;
        end if;

      when sheader =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel    <= 0;
        ns      <= seventa;

      when seventa =>
        dstart  <= '0';
        estarta <= '1';
        estartb <= '0';
        osel    <= 2;
        ns      <= seventa;
        ns      <= weventa;

      when weventa =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel <= 2; 
        if elba = '1' then
          ns    <= seventb;
        else
          ns    <= weventa;
        end if;


      when seventb =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '1';
        osel <= 3; 
        ns      <= weventb;

      when weventb =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel <= 3 ;
        if elbb = '1' then
          if ecnt > 480 then
            ns <= none;
          elsif ecnt > 400 then
            ns <= seventa;
          else
            ns <= sdata;
          end if;
        else
          ns   <= weventb;
        end if;


      when sdata =>
        dstart  <= '1';
        estarta <= '0';
        estartb <= '0';
        osel <= 1; 
        ns      <= wdata;

      when wdata =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel <= 1; 
        if dlb = '1' then
          ns    <= seventa;
        else
          ns    <= wdata;
        end if;


      when others =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        osel <= 0; 
        ns      <= sdata;

    end case;
  end process fsm;




end Behavioral;
