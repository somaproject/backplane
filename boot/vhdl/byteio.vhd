library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity byteio is
  port ( CLK     : in  std_logic;
         PIN     : in  std_logic_vector(7 downto 0);
         POUT    : out std_logic_vector(7 downto 0);
         SDIN    : in  std_logic;
         SDOUT   : out std_logic;
         SCLK    : out std_logic;
         BSTART  : in  std_logic;
         BDONE   : out std_logic
         );
end byteio;

architecture Behavioral of byteio is

  signal bcnt : integer range 0 to 7 := 0;


  type states is (none, l1, h1, h2, l2, done);
  signal cs, ns : states := none;

  signal ireg, oreg : std_logic_vector(7 downto 0) := (others => '0');

  signal inen, outen, outld : std_logic := '0';


begin

  POUT  <= ireg;
  SDOUT <= oreg(7);

  BDONE <= '1' when cs = done else '0';

  process (CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = l2 then
        if bcnt = 7 then
          bcnt <= 0;
        else
          bcnt <= bcnt +1;
        end if;

      end if;

      if inen = '1' then
        ireg <= ireg(6 downto 0) & SDIN;
      end if;

      if outld = '1' then
        oreg               <= PIN;
      else
        if outen = '1' then
          oreg(7 downto 1) <= oreg(6 downto 0); 
        end if;
      end if;

    end if;
  end process;

  fsm : process(cs, bcnt, BSTART) is
  begin
    case cs is
      when none =>
        inen  <= '0';
        outld <= '1';
        outen <= '0';
        sclk  <= '0';
        if BSTART = '1' then
          ns  <= l1;
        else
          ns  <= none;
        end if;
      when l1   =>
        inen  <= '1';
        outld <= '0';
        outen <= '0';
        sclk  <= '0';
        ns    <= h1;
      when h1   =>
        inen  <= '0';
        outld <= '0';
        outen <= '0';
        sclk  <= '1';
        ns    <= h2;
      when h2   =>
        inen  <= '0';
        outld <= '0';
        outen <= '1';
        sclk  <= '0';
        ns    <= l2;
      when l2   =>
        inen  <= '0';
        outld <= '0';
        outen <= '0';
        sclk  <= '0';
        if bcnt = 7 then
          ns  <= done;
        else
          ns  <= l1; 
        end if; 
      when done =>
        inen <= '0'; 
        outld <= '0';
        outen <= '1'; 
        sclk <= '0'; 
        ns <= none;
    end case; 
    
  end process fsm; 
end Behavioral;

