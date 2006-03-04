-------------------------------------------------------------------------------
-- Title      : linktester
-- Project    : 
-------------------------------------------------------------------------------
-- File       : linktester.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/03/04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: a loopback data tester
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/03/04  1.0      jonas	Created
-------------------------------------------------------------------------------


entity linktester is
  
  port (
    CLK   : in std_logic;
    RESET : in std_logic;
    DIN   : in std_logic_vector(7 downto 0);
    KIN   : in std_logic;
    DOUT : out std_logic;
    KOUT : out std_logic;
    LOCKED : in std_logic;
    VALID : out std_logic    
    );

end linktester;


architecture Behavioral of linktester is
  signal outcnt : std_logic_vector(8 downto 0) := (others => '0');
  signal inbyte1 : std_logic_vector(7 downto 0) := (others => '0');
  signal inbyte2 : std_logic_vector(7 downto 0) := (others => '0');
  signal ink1  : std_logic := '0';
  signal ink2  : std_logic := '0';
  
begin  -- Behavioral

  output: process(CLK)
    begin
      if rising_edge(CLK) then 
        if outcnt = "100000000" then
          DOUT <= X"BC";
          KOUT <= '1';
          outcnt <= (others => '0'); 
        else
          DOUT <= outcnt(7 downto 0);
          KOUT <= '0';
          outcnt <= outcnt + 1; 
        end if;
      end if;
    end process output; 
  

  input: process(CLK)
    begin
      if rising_edge(CLK) then
        if LOCKED = '0' then
          VALID <= '0';
        else
          bin1 <= DIN;
          bin2 <= inbyte1;

          kin1 <= KIN;
          kin2 <= kin1;

          if kin2 = '1' and bin2 = X"BC" and
            kin1 = '0' and bin1 = X"00" then
            VALID <= '1';
          elsif kin2 = '0' and bin2 = X"FF" and
            kin1 = '1' and bin1 = X"BC" then
            VALID <= '1';
          elsif kin2 = '0' and kin1 = '0' and bin2 -1 = bin1 then
            VALID <= '1';
          else
            VALID <= '0';             
          end if;
          
        end if;
        
      end if;

    end process input; 
      
end Behavioral;
