library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity datamempktinput is
  
  port (
    CLK       : in  std_logic;
    DIN       : in  std_logic_vector(15 downto 0);
    ADDROUT    : out std_logic_vector(8 downto 0);
    FIFOVALID : in  std_logic;
    FIFONEXT  : out std_logic;
    START     : in  std_logic;
    DONE      : out std_logic;
    -- ram interface
    
    RAMWE     : out std_logic;
    RAMADDR   : out std_logic_vector(16 downto 0);
    RAMDOUT : out std_logic_vector(15 downto 0);
    -- fifo properti
    SRC : out std_logic_vector(5 downto 0);
    TYP : out std_logic_vector(1 downto 0);
    ID : out std_logic_vector(31 downto 0);
    IDWE : out std_logic;
    BP : out std_logic_vector(7 downto 0)
    ); 

end datamempktinput;

architecture Behavioral of datamempktinput is

  signal bufaddr : std_logic_vector(8 downto 0) := (others => '0');
  signal baseaddr : std_logic_vector(7 downto 0) := (others => '0');

  signal lramaddr : std_logic_vector(16 downto 0) := (others => '0');

  signal lramdout : std_logic_vector(15 downto 0) := (others => '0');

  signal bufaddrinc  : std_logic := '0';

  signal len : std_logic_vector(8 downto 0) := (others => '0');
  
  type states is (none, chkvalid, startwr, wrwait, addrwe, donewr);
  signal cs, ns : states := none;
  
  
begin  -- Behavioral


  ADDROUT <= lramaddr(8 downto 0);
  lramaddr <= baseaddr & bufaddr;

  DONE <= '1' when cs = donewr else '0';

  FIFONEXT <= '1' when cs = addrwe else '0'; 
  main: process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      -- top-down
      RAMADDR <= lramaddr;
      
      if cs = none then
        bufaddr <= (others => '0');
      else
        if bufaddrinc = '1' then
          bufaddr <= bufaddr + 1; 
        end if;
      end if;

      if cs = addrwe then
        baseaddr <= baseaddr + 1; 
      end if;

      BP <= baseaddr;

      lramdout <= DIN;
      RAMDOUT <= lramdout;

      if bufaddr =  "000011001" then
        src <= DIN(5 downto 0);
        typ <= DIN(9 downto 8);
        
      end if;

      if bufaddr =  "000010111" then
        ID(31 downto 16) <= DIN; 
      end if;

      if bufaddr =  "000011000" then
        ID(15 downto 0) <= DIN; 
      end if;

      if bufaddr =  "000000001" then
        len <= DIN(9 downto 1); 
      end if;

    end if;
  end process main; 



  fsm: process(cs, START, FIFOVALID, bufaddr, len)
    begin
      case cs is
        when none  =>
          bufaddrinc <= '0';
          ramwe <= '0';
          idwe <= '0';
          if START = '1' then
            ns <= chkvalid;
          else
            ns <= none; 
          end if;

        when chkvalid  =>
          bufaddrinc <= '0';
          ramwe <= '0';
          idwe <= '0';
          if FIFOVALID = '1' then
            ns <= startwr; 
          else
            ns <= donewr; 
          end if;

        when startwr  =>
          bufaddrinc <= '1';
          ramwe <= '0';
          idwe <= '0';
          ns <= wrwait; 
          
        when wrwait  =>
          bufaddrinc <= '1';
          ramwe <= '1';
          idwe <= '0';
          if bufaddr = len then
            ns <= addrwe;
          else
            ns <= wrwait; 
          end if;
          
        when addrwe  =>
          bufaddrinc <= '1';
          ramwe <= '0';
          idwe <= '1';
          ns <= donewr;
          
        when donewr  =>
          bufaddrinc <= '0';
          ramwe <= '0';
          idwe <= '0';
          ns <= none; 
                   
        when others  =>
          bufaddrinc <= '0';
          ramwe <= '0';
          idwe <= '0';
          ns <= none; 
      end case;
    end process fsm;

    
end Behavioral;
