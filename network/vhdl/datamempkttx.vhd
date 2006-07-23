library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity datamempkttx is
  
  port (
    CLK       : in  std_logic;
    DOUT       : out  std_logic_vector(15 downto 0);
    ADDROUT    : out std_logic_vector(8 downto 0);
    FIFOFULL : in  std_logic;
    FIFODONE  : out std_logic;
    WEOUT : out std_logic; 
    START     : in  std_logic;
    DONE      : out std_logic;
    -- ram interface
    
    RAMADDR   : out std_logic_vector(16 downto 0);
    RAMDIN : in std_logic_vector(15 downto 0);
    BP : in std_logic_vector(7 downto 0)
    ); 

end datamempkttx; 

architecture Behavioral of datamempkttx is

  signal addr : std_logic_vector(8 downto 0) := (others => '0');
  signal baseaddr : std_logic_vector(7 downto 0) := (others => '0');

  signal addrsreg1, addrsreg2, addrsreg3, addrsreg4, addrsreg5
    : std_logic_vector(8 downto 0) := (others => '0');

  signal wesreg : std_logic_vector(4 downto 0) := (others => '0');

  signal addrinc  : std_logic := '0';

  signal len : std_logic_vector(8 downto 0) := (others => '0');
  
  type states is (none, bpcheck, addrst, addrw,
                  extraw, fifodones, dones);
  
  signal cs, ns : states := none;
  
begin  -- Behavioral


  ADDROUT <= addrsreg5; 
  WEOUT <= wesreg(4); 
  DOUT <= RAMDIN;
  FIFODONE <= '1' when cs = fifodones else '0'; 
  DONE <= '1' when cs = dones else '0';

  RAMADDR <= baseaddr & addr;
  
  main: process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- top-down
      
      if cs = none then
        addr <= (others => '0');
      else
        if addrinc = '1' then
          addr <= addr + 1; 
        end if;
      end if;

      if cs = fifodones then
        baseaddr <= baseaddr + 1; 
      end if;

      if addr = "000000100" then
        len <= RAMDIN(9 downto 1); 
      end if;

      -- registers
      addrsreg5 <= addrsreg4;
      addrsreg4 <= addrsreg3;
      addrsreg3 <= addrsreg2;
      addrsreg2 <= addrsreg1;
      addrsreg1 <= addr;

      wesreg <= wesreg(3 downto 0) & addrinc;
      
    end if;
  end process main; 



  fsm: process(cs, START, BP, baseaddr,  FIFOFULL, addr, len)
    begin
      case cs is
        when none  =>
          ADDRINC <= '0';
          -- WEOUT <= '0';
          if START = '0' then
            ns <= bpcheck;
          else
            ns <= none; 
          end if;
          
        when bpcheck  =>
          ADDRINC <= '0';
          -- WEOUT <= '0';
          if BP /= baseaddr and FIFOFULL = '0' then
            ns <= addrst;
          else
            ns <= dones; 
          end if;
          
        when dones  =>
          ADDRINC <= '0';
          -- WEOUT <= '0';
          ns <= none; 
          
        when addrst  =>
          ADDRINC <= '1';
          -- WEOUT <= '1';
          if addr = "000001000" then
            ns <= addrw;
          else
            ns <= addrst; 
          end if;

        when addrw  =>
          ADDRINC <= '1';
          -- WEOUT <= '1';
          if addr = len then
            ns <= extraw;
          else
            ns <= addrw; 
          end if;

        when extraw  =>
          ADDRINC <= '1';
          -- WEOUT <= '1';
          if addr = len + "000001000"  then
            ns <= fifodones;
          else
            ns <= extraw; 
          end if; 

        when fifodones  =>
          ADDRINC <= '0';
          ns <= dones; 
         
        when others  =>
          ADDRINC <= '0';
          -- WEOUT <= '0';
          ns <= none; 
      end case;
    end process fsm;

end Behavioral;
