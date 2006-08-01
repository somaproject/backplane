library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity datamempktretx is
  
  port (
    CLK       : in  std_logic;
    DOUT       : out  std_logic_vector(15 downto 0);
    ADDROUT    : out std_logic_vector(8 downto 0);
    WEOUT : out std_logic; 

    START     : in  std_logic;
    DONE      : out std_logic;

    RETXREQ : in std_logic;
    RETXDONE : out std_logic;

    SRCRETX : in std_logic_vector(5 downto 0);
    TYPRETX: in std_logic_vector(1 downto 0);
    IDRETX : in std_logic_vector(31 downto 0);
    
    -- input parameters
    SRC : in std_logic_vector(5 downto 0);
    TYP : in std_logic_vector(1 downto 0);
    ID : in std_logic_vector(31 downto 0); 
    IDWE : in std_logic;
    BP : in std_logic_vector(7 downto 0);
    
-- ram interface
    
    RAMADDR   : out std_logic_vector(16 downto 0);
    RAMDIN : in std_logic_vector(15 downto 0)

    ); 

end datamempktretx; 

architecture Behavioral of datamempktretx is

  signal addr : std_logic_vector(8 downto 0) := (others => '0');

  signal addrsreg1, addrsreg2, addrsreg3, addrsreg4, addrsreg5
    : std_logic_vector(8 downto 0) := (others => '0');

  signal wesreg : std_logic_vector(4 downto 0) := (others => '0');

  signal addrinc  : std_logic := '0';

  signal len : std_logic_vector(8 downto 0) := (others => '0');

  signal lutaddra : std_logic_vector(10 downto 0) := (others => '0');
  signal lutaddrb : std_logic_vector(10 downto 0) := (others => '0');
  signal bpout : std_logic_vector(7 downto 0) := (others => '0');
  
  type states is (none, pendchk, addrst, addrw,
                  extraw, retxdones, retxdones2,  dones);
  
  signal cs, ns : states := none;

  signal retxrst, retxpending : std_logic := '0';
  
begin  -- Behavioral


  ADDROUT <= addrsreg5; 
  WEOUT <= wesreg(4); 
  RAMADDR <= bpout & addr; 
  DONE <= '1' when cs = dones  else '0';
  DOUT <= RAMDIN; 
  lutaddrb <= (SRC & TYP & ID(2 downto 0));

  retxrst <= '1' when cs = retxdones or cs = retxdones2 else '0'; 
  RETXDONE <= retxrst; 
  
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

      if addr = "000000100" then
        len <= ramdin(9 downto 1); 
      end if;

      -- registers
      addrsreg5 <= addrsreg4;
      addrsreg4 <= addrsreg3;
      addrsreg3 <= addrsreg2;
      addrsreg2 <= addrsreg1;
      addrsreg1 <= addr;

      wesreg <= wesreg(3 downto 0) & addrinc;

      --
      if RETXREQ = '1' then
        lutaddra <= srcretx & typretx & idretx(2 downto 0);
        
      end if;

      if retxrst = '1' then
        retxpending <= '0';
      else
        if RETXREQ = '1'  then
          retxpending <= '1'; 
        end if;
      end if;
    end if;
  end process main; 



  fsm: process(cs, START, RETXPENDING, addr, len)
    begin
      case cs is
        when none  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          if START = '1' then
            ns <= pendchk;
          else
            ns <= none; 
          end if;
          
        when pendchk  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          if RETXPENDING = '1' then
            ns <= addrst;
          else
            ns <= dones; 
          end if;
          
        when dones  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          ns <= none;
          
        when addrst  =>
          ADDRINC <= '1';
          --WEOUT <= '1';
          if addr = "000001000" then
            ns <= addrw;
          else
            ns <= addrst; 
          end if;

        when addrw  =>
          ADDRINC <= '1';
          --WEOUT <= '1';
          if addr = len then
            ns <= extraw;
          else
            ns <= addrw; 
          end if;

        when extraw  =>
          ADDRINC <= '1';
          --WEOUT <= '1';
          if addr = len + "000001000"  then
            ns <= retxdones;
          else
            ns <= extraw; 
          end if;
          
        when retxdones  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          ns <= retxdones2;
          
        when retxdones2  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          ns <= dones; 
          
        when others  =>
          ADDRINC <= '0';
          --WEOUT <= '0';
          ns <= none; 
      end case;
    end process fsm;

    LUT_inst : RAMB16_S9_S9
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
    port map (
      DOA   => bpout,
      DOB   => open, 
      ADDRA => lutaddra,
      ADDRB => lutaddrb, 
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => X"00", 
      DIB   => BP, 
      DIPA  => "0",
      DIPB  => "0",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => '0',
      WEB   => IDWE
      );


end Behavioral;
