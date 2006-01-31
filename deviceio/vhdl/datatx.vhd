-------------------------------------------------------------------------------
-- Title      : datatx
-- Project    : Soma
-------------------------------------------------------------------------------
-- File       : datatx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/30
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Transmission of events and support packets. 
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

entity datatx is
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

end datatx;

architecture Behavioral of datatx is

  signal dinl         : std_logic_vector(7 downto 0) := (others => '0');
  signal dwel, ddonel : std_logic                    := '0';

  signal addra, addral, addrall :
    std_logic_vector(10 downto 0) := (others => '0');

  signal dl, dll : std_logic := '0';
  signal rstl    : std_logic := '0';

  signal addrb : std_logic_vector(10 downto 0) := (others => '0');
  signal osel  : integer range 0 to 3          := 0;

  signal dob : std_logic_vector(7 downto 0) := (others => '0');

  constant K28_2 : std_logic_vector(7 downto 0) := "01011100";
  constant K28_3 : std_logic_vector(7 downto 0) := "01111100";
  constant K28_4 : std_logic_vector(7 downto 0) := "10011100";

  type states is (none, waitsend, header, sdata, footer, footer2, done);

  signal cs, ns : states := none;


begin  -- Behavioral

  databuffer: ramb16_s9_s9
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
    
    port map (
      CLKA => CLK,
      ENA => '1',
      SSRA => RESET,
      WEA => dwel,
      ADDRA => addra, 
      DIA => dinl,
      DIPA => "0",
      DOPA => open,
      DOA => open,
      CLKB => TXBYTECLK,
      ENB => '1',
      SSRB => RESET,
      WEB => dwel,
      ADDRB => addrb, 
      DIB => X"00",
      DIPB => "0",
      DOPB => open,
      DOB => dob); 
      

  
-- input domain
  inputmain : process(CLK)
  begin
    if rising_edge(CLK) then
      dinl   <= DIN;
      dwel   <= DWE;
      ddonel <= DDONE;

      if ddonel = '1' then
        addra   <= (others => '0');
      else
        if dwel = '1' then
          addra <= addra + 1;
        end if;
      end if;

      if ddonel = '1' then
        addral <= addra;        
      end if;

      if rstl = '1' then
        dl   <= '0';
      else
        if ddonel = '1' then
          dl <= '1';
        end if;
      end if;
    end if;

  end process inputmain;



  DOUT <= K28_2 when osel = 0 else
          dob   when osel = 1 else
          K28_3 when osel = 2 else
          K28_4;

  outputmain : process(TXBYTECLK, RESET)
  begin
    if RESET = '1' then
      cs <= none; 
    else

      if rising_edge(TXBYTECLK) then
        cs <= ns; 
        addrall <= addral;
        dll     <= dl;

        if cs = done then
          rstl <= '1';
        else
          rstl <= '0';

        end if;

        if cs = done then
          addrb   <= (others => '0');
        else
          if cs = sdata then
            addrb <= addrb + 1;

          end if;
        end if;

      end if;
    end if;
  end process outputmain;


  fsm : process (CS, dll, start, addrb, addra, addral, addrall)
  begin
    case cs is
      when none =>
        osel     <= 3;
        lastbyte <= '1';
        kout     <= '0';

        if dll = '1' and START = '0' then
          ns     <= waitsend;
        else
          ns     <= none;
        end if;

      when waitsend =>
        osel     <= 1;
        lastbyte <= '0';
        kout     <= '0';
        if start = '1' then
          ns     <= header;
        else
          ns     <= waitsend;
        end if;

      when header =>
        osel     <= 0;
        lastbyte <= '0';
        kout     <= '1';
        ns       <= sdata;

      when sdata =>
        osel     <= 1;
        lastbyte <= '0';
        kout     <= '0';

        if addrb + 1 = addrall then
          ns   <= footer2;
        else
          if addrb(5 downto 0) = "111111" then
            ns <= footer;
          else
            ns <= sdata;
          end if;
        end if;

      when footer =>
        osel     <= 2;
        lastbyte <= '1';
        kout     <= '1';
        ns       <= waitsend;

      when footer2 =>
        osel     <= 2;
        lastbyte <= '0';
        kout     <= '1';
        ns       <= done;

      when done =>
        osel     <= 3;
        lastbyte <= '1';
        kout     <= '1';
        ns       <= none;

      when others =>
        osel     <= 0;
        lastbyte <= '0';
        kout     <= '0';
        ns       <= done;

    end case;

  end process;
end Behavioral;
