-------------------------------------------------------------------------------
-- Title      : devicetx
-- Project    : Soma
-------------------------------------------------------------------------------
-- File       : devicetx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/29
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
    EINB      : in  std_logic_vector(7 downto 0);
    EWEB      : in  std_logic;
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

  signal osel : integer range 0 to 2 := 0;

  type states is (sdata, wdata, seventa, weventa, seventb, weventb);
  signal cs, ns : states := sdata;

  constant K28_0 : std_logic_vector(7 downto 0) := "00011100";
  constant K28_1 : std_logic_vector(7 downto 0) := "00111100";  
  

begin  -- Behavioral

  datatxinst : datatx
    port map (
      CLK       => CLK,
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
      KCHAR => K28_0)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      EIN       => EINA,
      WE        => EWEA,
      TXBYTECLk => TXBYTECLK,
      EDOUT     => eda,
      LASTBYTE  => elba,
      EKOUT     => eka,
      START     => estarta);

  eventtxinstb : eventtx
    generic map (
      KCHAR => K28_1)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      EIN       => EINB,
      WE        => EWEB,
      TXBYTECLk => TXBYTECLK,
      EDOUT     => edb,
      LASTBYTE  => elbb,
      EKOUT     => ekb,
      START     => estartb);
  
    
  data <= dd when osel = 0 else
          eda when osel = 1 else
          edb when osel = 2;
  
  k <= dk when osel = 0 else
          eka when osel = 1 else
          ekb when osel = 2;

  DOUT <= data;
  KOUT <= k;
  
  
  main : process(TXBYTECLK, RESET)
  begin
    if RESET = '1' then
      cs   <= sdata;
    else
      if rising_edge(TXBYTECLK) then
        cs <= ns;
      end if;
    end if;

  end process main;

  fsm : process(cs, dlb, elba, elbb)
  begin
    case cs is
      when sdata =>
        dstart  <= '1';
        estarta <= '0';
        estartb <= '0';
        ns      <= wdata;

      when wdata =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        if dlb = '1' then
          ns    <= seventa;
        else
          ns    <= wdata;
        end if;

      when seventa =>
        dstart  <= '0';
        estarta <= '1';
        estartb <= '0';
        ns      <= weventa;

      when weventa =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        if elba = '1' then
          ns    <= seventb;
        else
          ns    <= weventa;
        end if;


      when seventb =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '1';
        ns      <= weventb;

      when weventb =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        if elbb = '1' then
          ns    <= sdata;
        else
          ns    <= weventb;
        end if;

      when others =>
        dstart  <= '0';
        estarta <= '0';
        estartb <= '0';
        ns      <= sdata;

    end case;
  end process fsm;




end Behavioral;
