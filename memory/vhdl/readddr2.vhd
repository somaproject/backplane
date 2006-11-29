library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity readddr2 is
  port (
    CLK         : in  std_logic;
    START       : in  std_logic;
    DONE        : out std_logic;
    -- ram interface
    CS          : out std_logic;
    RAS         : out std_logic;
    CAS         : out std_logic;
    WE          : out std_logic;
    ADDR        : out std_logic_vector(12 downto 0);
    BA          : out std_logic_vector(1 downto 0);
    DIN         : in  std_logic_vector(31 downto 0);
    -- input data interface
    ROWTGT      : in  std_logic_vector(14 downto 0);
    RADDR       : out std_logic_vector(7 downto 0);
    RDATA       : out std_logic_vector(31 downto 0);
    RWE         : out std_logic;
    NOTERMINATE : in  std_logic;
    LATENCYEXTRA: in std_logic_vector(1 downto 0);
    READOFFSET : in std_logic_vector(1 downto 0)
    );
end readddr2;

architecture Behavioral of readddr2 is

  signal lcs   : std_logic                     := '0';
  signal lras  : std_logic                     := '1';
  signal lcas  : std_logic                     := '1';
  signal lwe   : std_logic                     := '1';
  signal laddr : std_logic_vector(12 downto 0) := (others => '0');

  signal lba : std_logic_vector(1 downto 0) := (others => '0');

  signal lts   : std_logic                     := '0';
  signal ldout : std_logic_vector(31 downto 0) := (others => '0');

  signal acnt    : std_logic_vector(8 downto 0) := (others => '0');
  signal incacnt : std_logic                    := '0';
  signal asel    : std_logic                    := '0';



  type states is (none, act, actw1, actw2, actw3, actw4, 
                  read, nop1, nop2, nop3, doneprec, donewait,
                  dones);
  signal ocs, ons : states := none;

  type raddrsreg_t is array (13 downto 0) of std_logic_vector(7 downto 0);
  signal raddrsreg : raddrsreg_t := (others => (others => '0'));

  signal rwesreg : std_logic_vector(13 downto 0);


begin  -- Behavioral
laddr <= ("000" & acnt(8 downto 1) & READOFFSET) when asel = '1' else rowtgt(12 downto 0);
 
  
  lba   <= rowtgt(14 downto 13);

  DONE <= '1' when ocs = dones else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      ocs <= ons;

      BA   <= lba;
      ADDR <= laddr; 
      CS   <= lcs;
      RAS  <= lras;
      CAS  <= lcas;
      WE   <= lwe;

      if ocs = none then
        acnt   <= (others => '0');
      else
        if incacnt = '1' then
          acnt <= acnt + 1;
        end if;
      end if;

      -- shift regitsrs
      rwesreg   <= rwesreg(12 downto 0) & incacnt;
      raddrsreg <= raddrsreg(12 downto 0) & acnt(7 downto 0);

      RDATA <= DIN;

    end if;
  end process main;



   RWE <=  rwesreg(10) when  latencyextra(0) = '0' else
            rwesreg(11); 
  
   RADDR <= raddrsreg(10) when latencyextra(0) = '0' else
            raddrsreg(11); 

  fsm : process(ocs, start, acnt, rwesreg)
  begin
    case ocs is
      when none =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if START = '1' then
          ons   <= act;
        else
          ons   <= none;
        end if;

      when act =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '0';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= actw1;

      when actw1 =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= actw2;

      when actw2 =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= actw3;

      when actw3 =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= actw4;

      when actw4 =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= read;

      when read =>
        incacnt <= '1';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '0';
        lwe     <= '1';
        ons     <= nop3;

      when nop3 =>
        incacnt <= '1';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if acnt = "011111111" and NOTERMINATE = '0' then
          ons   <= doneprec;
        else
          ons   <= read;
        end if;

      when doneprec =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '0';
        lcas    <= '1';
        lwe     <= '0';
        ons <= donewait; 
          

      when donewait  =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if  rwesreg(7) = '0' then       -- wait for all reads to finish
          ons <= dones;
        else
          ons <= donewait; 
        end if; 

      when dones =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= none;

      when others =>
        incacnt <= '1';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= none;

    end case;

  end process fsm;

end Behavioral;

