library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity framedis is
  port ( CLK        : in  std_logic;
         RESET      : in  std_logic;
         DIN        : in  std_logic_vector(7 downto 0);
         INWE       : in  std_logic;
         KIN        : in  std_logic;
         ERRIN      : in  std_logic;
         LINKUP     : out std_logic;
         NEWSAMPLES : out std_logic;
         SAMPLEA1   : out std_logic_vector(15 downto 0);
         SAMPLEA2   : out std_logic_vector(15 downto 0);
         SAMPLEA3   : out std_logic_vector(15 downto 0);
         SAMPLEA4   : out std_logic_vector(15 downto 0);
         SAMPLEAC   : out std_logic_vector(15 downto 0);
         SAMPLEB1   : out std_logic_vector(15 downto 0);
         SAMPLEB2   : out std_logic_vector(15 downto 0);
         SAMPLEB3   : out std_logic_vector(15 downto 0);
         SAMPLEB4   : out std_logic_vector(15 downto 0);
         SAMPLEBC   : out std_logic_vector(15 downto 0);
         CMDID      : out std_logic_vector(3 downto 0);
         CMDST      : out std_logic_vector(3 downto 0));
end framedis;

architecture Behavioral of framedis is

  -- decode signals
  signal inwel : std_logic                    := '0';
  signal data  : std_logic_vector(7 downto 0) := (others => '0');

  -- pre-latch data signals
  signal lsamplea1, lsamplea2, lsamplea3, lsamplea4, lsampleac,
    lsampleb1, lsampleb2, lsampleb3, lsampleb4, lsamplebc
 : std_logic_vector(15 downto 0) := (others => '0');

  signal incnt : integer range 0 to 25 := 0;

  --command status
  signal lcmdst, lcmdid : std_logic_vector(3 downto 0) := (others => '0');

  signal donef : std_logic := '0';

  -- tiny fsm!
  type states is (up, down);
  signal cs, ns : states := down;

begin


  donef <= '1' when inwel = '1' and incnt = 24 else '0';


  clock : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs   <= down;
    else
      if rising_edge(CLK) then
        cs <= ns;

        inwel <= inwe;

        if (kin = '1' and DIN = X"BC") or
          errin = '1' then
          incnt     <= 0;
        else
          if inwe = '1' then
            if incnt = 25 then
              incnt <= 0;
            else
              incnt <= incnt + 1;
            end if;
          end if;
        end if;

        NEWSAMPLES <= donef;

        -- latching for A samples

        -- SAMPLE A1
        if incnt = 1 and inwe = '1' then
          lsamplea1(15 downto 8) <= DIN;
        end if;
        if incnt = 2 and inwe = '1' then
          lsamplea1(7 downto 0)  <= DIN;
        end if;


        -- SAMPLE A2
        if incnt = 3 and inwe = '1' then
          lsamplea2(15 downto 8) <= DIN;
        end if;
        if incnt = 4 and inwe = '1' then
          lsamplea2(7 downto 0)  <= DIN;
        end if;

        -- SAMPLE A3
        if incnt = 5 and inwe = '1' then
          lsamplea3(15 downto 8) <= DIN;
        end if;
        if incnt = 6 and inwe = '1' then
          lsamplea3(7 downto 0)  <= DIN;
        end if;


        -- SAMPLE A4
        if incnt = 7 and inwe = '1' then
          lsamplea4(15 downto 8) <= DIN;
        end if;
        if incnt = 8 and inwe = '1' then
          lsamplea4(7 downto 0)  <= DIN;
        end if;


        -- SAMPLE AC
        if incnt = 9 and inwe = '1' then
          lsampleac(15 downto 8) <= DIN;
        end if;
        if incnt = 10 and inwe = '1' then
          lsampleac(7 downto 0)  <= DIN;
        end if;


        -- latching for V samples

        -- SAMPLE B1
        if incnt = 11 and inwe = '1' then
          lsampleb1(15 downto 8) <= DIN;
        end if;
        if incnt = 12 and inwe = '1' then
          lsampleb1(7 downto 0)  <= DIN;
        end if;


        -- SAMPLE B2
        if incnt = 13 and inwe = '1' then
          lsampleb2(15 downto 8) <= DIN;
        end if;
        if incnt = 14 and inwe = '1' then
          lsampleb2(7 downto 0)  <= DIN;
        end if;


        -- SAMPLE B3
        if incnt = 15 and inwe = '1' then
          lsampleb3(15 downto 8) <= DIN;
        end if;
        if incnt = 16 and inwe = '1' then
          lsampleb3(7 downto 0)  <= DIN;
        end if;

        -- SAMPLE B4
        if incnt = 17 and inwe = '1' then
          lsampleb4(15 downto 8) <= DIN;
        end if;
        if incnt = 18 and inwe = '1' then
          lsampleb4(7 downto 0)  <= DIN;
        end if;

        -- SAMPLE BC
        if incnt = 19 and inwe = '1' then
          lsamplebc(15 downto 8) <= DIN;
        end if;
        if incnt = 20 and inwe = '1' then
          lsamplebc(7 downto 0)  <= DIN;
        end if;


        -- COMMAND-STATUS related registers
        if incnt = 21 and inwe = '1' then
          lcmdid <= DIN(4 downto 1);
        end if;

        if incnt = 0 and inwe = '1' then
          lcmdst <= DIN(3 downto 0);
        end if;


        --- final latching
        if donef = '1' then
          SAMPLEA1 <= lsamplea1;
          SAMPLEA2 <= lsamplea2;
          SAMPLEA3 <= lsamplea3;
          SAMPLEA4 <= lsamplea4;
          SAMPLEAC <= lsampleac;

          SAMPLEB1 <= lsampleb1;
          SAMPLEB2 <= lsampleb2;
          SAMPLEB3 <= lsampleb3;
          SAMPLEB4 <= lsampleb4;
          SAMPLEBC <= lsamplebc;

          CMDID <= lcmdid(3 downto 0);

          CMDST <= lcmdst;
        end if;
      end if;
    end if;
  end process clock;

  fsm : process(cs, ERRIN, donef) is
  begin
    case cs is
      when up     =>
        LINKUP <= '1';
        if ERRIN = '1' then
          ns   <= down;
        else
          ns   <= up;
        end if;
      when down   =>
        LINKUP <= '0';
        if donef = '1' then
          ns   <= up;
        else
          ns   <= down;
        end if;
      when others =>
        LINKUP <= '0';
        ns     <= down;
    end case;
  end process fsm;


end Behavioral;
