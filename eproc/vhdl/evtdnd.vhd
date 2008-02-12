library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity evtdnd is
  port (
    CLK     : in  std_logic;
    CMD     : in  std_logic_vector(7 downto 0);
    SRC     : in  std_logic_vector(7 downto 0);
    ADDR    : out std_logic_vector(9 downto 0) := (others => '0'); 
    MATCH   : out std_logic;
    START   : in  std_logic;
    DONE    : out std_logic;
    -- interface
    TGTDIN  : in  std_logic_vector(15 downto 0);
    TGTWE   : in  std_logic;
    TGTADDR : in  std_logic_vector(5 downto 0)
    );
end evtdnd;


architecture Behavioral of evtdnd is

  signal cmdwe, srcwe, addrwe : std_logic                     := '0';
  signal cmdcmp, srccmp       : std_logic_vector(15 downto 0) := (others => '0');
  signal compaddr             : std_logic_vector(3 downto 0)  := (others => '0');

  signal srcmatch, cmdmatch : std_logic := '0';

  signal destaddr : std_logic_vector(9 downto 0) := (others => '0');
  
  component regfile
    generic (
      BITS  :     integer := 16);
    port (
      CLK   : in  std_logic;
      DIA   : in  std_logic_vector(BITS-1 downto 0);
      DOA   : out std_logic_vector(BITS -1 downto 0);
      ADDRA : in  std_logic_vector(3 downto 0);
      WEA   : in  std_logic;
      DOB   : out std_logic_vector(BITS -1 downto 0);
      ADDRB : in  std_logic_vector(3 downto 0)
      );
  end component;

  type states is (none, rstvals, compare, dones);
  signal cs, ns : states := none;


begin  -- Behavioral

  DONE <= '1' when cs = dones else '0';
  
  cmdregs : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLK,
      DIA   => TGTDIN,
      DOA   => open,
      ADDRA => tgtaddr(5 downto 2),
      WEA   => cmdwe,
      ADDRB => compaddr,
      DOB   => cmdcmp);

  srcregs : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLK,
      DIA   => TGTDIN,
      DOA   => open,
      ADDRA => tgtaddr(5 downto 2),
      WEA   => srcwe,
      ADDRB => compaddr,
      DOB   => srccmp);

  addrregs : regfile
    generic map (
      BITS  => 10)
    port map (
      CLK   => CLK,
      DIA   => TGTDIN(9 downto 0),
      DOA   => open,
      ADDRA => tgtaddr(5 downto 2),
      WEA   => addrwe,
      ADDRB => compaddr,
      DOB   => destaddr);

  cmdwe  <= '1' when tgtwe = '1' and tgtaddr(1 downto 0) = "01" else '0';
  srcwe  <= '1' when tgtwe = '1' and tgtaddr(1 downto 0) = "10" else '0';
  addrwe <= '1' when tgtwe = '1' and tgtaddr(1 downto 0) = "00" else '0';

  cmdmatch <= '1' when (cmdcmp(7 downto 0) <= cmd) and
              (cmdcmp(15 downto 8) >= cmd) else '0';

  srcmatch <= '1' when (srccmp(7 downto 0) <= src) and
              (srccmp(15 downto 8) >= src) else '0';


  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = none then
        compaddr   <= (others => '0');
      else
        if cs = compare then
          compaddr <= compaddr + 1;
        end if;
      end if;

      if cs = compare and cmdmatch = '1' and srcmatch = '1' then
        ADDR <= destaddr;
      end if;
      
      if cs = compare and cmdmatch = '1' and srcmatch = '1' then
        MATCH <= '1';
      else
        if cs = rstvals then
          MATCH <= '0'; 
        end if;
      end if;
      
    end if;
  end process main;

  fsm : process(cs, START, compaddr)
  begin
    case cs is
      when none =>
        if START = '1' then
          ns <= rstvals;
        else
          ns <= none;
        end if;

      when rstvals =>
        ns <= compare;

      when compare =>
        if compaddr = "1111" then
          ns <= dones;
        else
          ns <= compare;
        end if;
      when dones   =>
        ns   <= none;
      when others  =>
        ns   <= none;
    end case;
  end process;
end Behavioral;
