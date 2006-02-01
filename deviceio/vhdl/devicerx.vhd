-------------------------------------------------------------------------------
-- Title      : Device Receiver
-- Project    : 
-------------------------------------------------------------------------------
-- File       : devicerx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/02/01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/31  1.0      jonas   Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;


entity devicerx is

  port (
    RXBYTECLK : in  std_logic;
    RESET     : in  std_logic;
    DIEN      : in  std_logic;
    KIN       : in  std_logic;
    ERR       : in  std_logic;
    DIN       : in  std_logic_vector(7 downto 0);
    CLK       : in  std_logic;
    ECYCLE    : out std_logic;
    EDOENA    : out std_logic;
    EDOUTA    : out std_logic_vector(15 downto 0);
    DENA      : out std_logic;
    EDOENB    : out std_logic;
    EDOUTB    : out std_logic_vector(15 downto 0);
    DENB      : out std_logic);
end devicerx;


architecture Behavioral of devicerx is

  -- input latching
  signal dienl : std_logic                    := '0';
  signal kinl  : std_logic                    := '0';
  signal errl  : std_logic                    := '0';
  signal dinl  : std_logic_vector(7 downto 0) := (others => '0');

  signal dataena, dataenb   : std_logic := '0';
  signal dataenal, dataenbl : std_logic := '0';

  signal addra : std_logic_vector(39 downto 0) := (others => '0');

  signal addrb : std_logic_vector(39 downto 0) := (others => '0');


  signal addrin : std_logic_vector(3 downto 0) := (others => '0');

  signal bpos : integer range 0 to 511 := 0;

  signal inrst : std_logic := '0';

  type states is (none,
                  latchdena, addra0, addra1, addra2, addra3, addra4,
                  latchdenb, addrb0, addrb1, addrb2, addrb3, addrb4,
                  writee);

  signal cs, ns : states := none;

  constant K28_5 : std_logic_vector(7 downto 0) := "10111100";

  component rxbuffer

    port (
      RXBYTECLK : in  std_logic;
      RESET     : in  std_logic;
      DEN       : in  std_logic;
      EA        : in  std_logic_vector(39 downto 0);
      DIN       : in  std_logic_vector(7 downto 0);
      CLK       : in  std_logic;
      DOEN      : out std_logic;
      DOUT      : out std_logic_vector(15 downto 0));

  end component;

  
  -- output side

  signal ecyc : std_logic := '0';

  signal neweventa : std_logic := '0';

  signal oab : std_logic_vector(9 downto 0) := (others => '0');

  signal neweventb : std_logic := '0';



begin  -- Behavioral


  rxbufferA : rxbuffer
    port map (
      RXBYTECLK => RXBYTECLK,
      RESET     => RESET,
      DEN       => dienl,
      EA        => addra,
      DIN       => dinl,
      CLK       => CLK,
      DOEN      => EDOENA,
      DOUT      => EDOUTA);

  rxbufferB : rxbuffer
    port map (
      RXBYTECLK => RXBYTECLK,
      RESET     => RESET,
      DEN       => dienl,
      EA        => addrb,
      DIN       => dinl,
      CLK       => CLK,
      DOEN      => EDOENB,
      DOUT      => EDOUTB);


  -- input processes

  inrst <= '1' when cs = writee else '0';


  inputmain : process (RESET, RXBYTECLK)
  begin
    if RESET = '1' then
      cs <= none;
    else
      if rising_edge(RXBYTECLK) then

        if dienl = '1' then
          if cs /= none and ( errl = '1' or kinl = '1' ) then
            ns <= none;
          else
            ns <= cs;
          end if;
        end if;
        -- latch inputs
        dienl  <= DIEN;

        kinl <= KIN;
        errl <= ERR;

        dinl <= DIN;


        if dienl = '1' and cs = none then
          bpos   <= 0;
        else
          if dienl = '1' then
            bpos <= bpos + 1;
          end if;
        end if;


        -- state-based input latching, A side

        if cs = latchdena and dienl = '1' then
          dataena <= dinl(0);
        end if;

        if dienl = '1' then
          if cs = addra0 then
            addra(7 downto 0)   <= dinl;
          end if;
          if cs = addra1 then
            addra(15 downto 8)  <= dinl;
          end if;
          if cs = addra2 then
            addra(23 downto 16) <= dinl;
          end if;
          if cs = addra3 then
            addra(31 downto 24) <= dinl;
          end if;
          if cs = addra4 then
            addra(39 downto 32) <= dinl;
          end if;

        end if;



        if cs = latchdenb and dienl = '1' then
          dataenb <= dinl(0);
        end if;

        if dienl = '1' then
          if cs = addrb0 then
            addrb(7 downto 0)   <= dinl;
          end if;
          if cs = addrb1 then
            addrb(15 downto 8)  <= dinl;
          end if;
          if cs = addrb2 then
            addrb(23 downto 16) <= dinl;
          end if;
          if cs = addrb3 then
            addrb(31 downto 24) <= dinl;
          end if;
          if cs = addrb4 then
            addrb(39 downto 32) <= dinl;
          end if;

        end if;

      end if;
    end if;


  end process inputmain;

  outputmain : process(CLK, RESET)
  begin
    if RESET = '1' then

    else
      if rising_edge(CLK) then

        dataenal <= dataena;
        DENA     <= dataenal;

        dataenbl <= dataenb;
        DENB     <= dataenbl;


      end if;
    end if;

  end process outputmain;


  fsm : process (cs, kinl, dinl, bpos)
  begin
    case cs is
      when none      =>
        if dinl = K28_5 and kinl = '1' then
          ns <= latchdena;
        else
          ns <= none;
        end if;
      when latchdena =>
        ns   <= addra0;
      when addra0    =>
        ns   <= addra1;
      when addra1    =>
        ns   <= addra2;
      when addra2    =>
        ns   <= addra3;
      when addra3    =>
        ns   <= addra4;
      when addra4    =>
        ns   <= latchdenb;

      when latchdenb =>
        ns   <= addrb0;
      when addrb0    =>
        ns   <= addrb1;
      when addrb1    =>
        ns   <= addrb2;
      when addrb2    =>
        ns   <= addrb3;
      when addrb3    =>
        ns   <= addrb4;
      when addrb4    =>
        ns   <= writee;
      when writee    =>
        if bpos > 497 then
          ns <= none;

        else
          ns <= writee;
        end if;

      when others => null;
    end case;

  end process fsm;

end Behavioral;
