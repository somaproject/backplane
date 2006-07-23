library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity datamemarbit is
  port (
    CLK : in std_logic;
    -- RAM
    RAMWE      : out   std_logic;
    RAMADDR    : out   std_logic_vector(16 downto 0);
    RAMDQ      : inout std_logic_vector(15 downto 0);
    -- memory packet input
    FIFODIN    : in    std_logic_vector(15 downto 0);
    FIFOADDR   : out   std_logic_vector(8 downto 0);
    FIFOVALID  : in    std_logic;
    FIFONEXT   : out   std_logic;
    --retx request
    RETXDOUT   : out   std_logic_vector(15 downto 0);
    RETXADDR   : out   std_logic_vector(8 downto 0);
    RETXWE     : out   std_logic;
    RETXREQ    : in    std_logic;
    RETXDONE   : out   std_logic;
    RETXSRC    : in    std_logic_vector(5 downto 0);
    RETXTYP    : in    std_logic_vector(1 downto 0);
    RETXID     : in    std_logic_vector(31 downto 0);
    -- packet transmission
    TXDOUT     : out   std_logic_vector(15 downto 0);
    TXFIFOFULL : in    std_logic;
    TXFIFOADDR : out   std_logic_vector(8 downto 0);
    TXWE       : out   std_logic;
    TXDONE     : out   std_logic
    );
end datamemarbit;

architecture Behavioral of datamemarbit is

  signal lramwe   : std_logic                     := '0';
  signal lramaddr : std_logic_vector(16 downto 0) := (others => '0');
  signal lts, ts  : std_logic                     := '0';
  signal ramdin   : std_logic_vector(15 downto 0) := (others => '0');
  signal dsel : integer range 0 to 2 := 0;
  
  -- internal IO
  signal src : std_logic_vector(5 downto 0) := (others => '0');
  signal typ : std_logic_vector(1 downto 0) := (others => '0');
  signal id : std_logic_vector(31 downto 0) := (others => '0');
  signal idwe : std_logic := '0';
  signal bp : std_logic_vector(7 downto 0) := (others => '0');
  
  
  -- input interface
  signal inwe            : std_logic := '0';
  signal instart, indone : std_logic := '0';

  signal inaddr : std_logic_vector(16 downto 0) := (others => '0');
  signal indout : std_logic_vector(15 downto 0) := (others => '0');

  -- retx interface

  signal retstart, retdone : std_logic := '0';

  signal retaddr : std_logic_vector(16 downto 0) := (others => '0');


  -- tx interface

  signal outstart, outdone : std_logic := '0';

  signal outaddr : std_logic_vector(16 downto 0) := (others => '0');

  type states is (inreads, inreadw, outwrs,
                  outwrw, retxw, retxs);

  signal cs, ns : states := inreads;
  
  
  component datamempktinput
    port (
      CLK       : in  std_logic;
      DIN       : in  std_logic_vector(15 downto 0);
      ADDROUT   : out std_logic_vector(8 downto 0);
      FIFOVALID : in  std_logic;
      FIFONEXT  : out std_logic;
      START     : in  std_logic;
      DONE      : out std_logic;
      -- ram interface
      RAMWE     : out std_logic;
      RAMADDR   : out std_logic_vector(16 downto 0);
      RAMDOUT   : out std_logic_vector(15 downto 0);
      -- fifo properti
      SRC       : out std_logic_vector(5 downto 0);
      TYP       : out std_logic_vector(1 downto 0);
      ID        : out std_logic_vector(31 downto 0);
      IDWE      : out std_logic;
      BP        : out std_logic_vector(7 downto 0)
      );
  end component;

  component datamempktretx
    port (
      CLK      : in  std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      ADDROUT  : out std_logic_vector(8 downto 0);
      WEOUT    : out std_logic;
      START    : in  std_logic;
      DONE     : out std_logic;
      RETXREQ  : in  std_logic;
      RETXDONE : out std_logic;
      SRCRETX  : in  std_logic_vector(5 downto 0);
      TYPRETX  : in  std_logic_vector(1 downto 0);
      IDRETX   : in  std_logic_vector(31 downto 0);
      -- input parameters
      SRC      : in  std_logic_vector(5 downto 0);
      TYP      : in  std_logic_vector(1 downto 0);
      ID       : in  std_logic_vector(31 downto 0);
      IDWE     : in  std_logic;
      BP       : in  std_logic_vector(7 downto 0);
-- ram interface
      RAMADDR  : out std_logic_vector(16 downto 0);
      RAMDIN   : in  std_logic_vector(15 downto 0)
      );
  end component;


  component datamempkttx
    port (
      CLK      : in  std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      ADDROUT  : out std_logic_vector(8 downto 0);
      FIFOFULL : in  std_logic;
      FIFODONE : out std_logic;
      WEOUT    : out std_logic;
      START    : in  std_logic;
      DONE     : out std_logic;
      -- ram interface;
      RAMADDR  : out std_logic_vector(16 downto 0);
      RAMDIN   : in  std_logic_vector(15 downto 0);
      BP : in std_logic_vector(7 downto 0)
      ); 
  end component; 

begin  -- Behavioral

  lramwe <= inwe when dsel = 0 else
            '1' when dsel = 1 else
            '1';

  lramaddr <= inaddr when dsel = 0 else
              retaddr when dsel = 1 else
              outaddr ;

  lts <= '0' when dsel = 0 else
         '1' when dsel = 1 else
         '1';

  main: process(CLK)
    begin
      if rising_edge(CLK) then
        cs <= ns;
        
        RAMWE <= lramwe;
        RAMADDR <= lramaddr;
        ts <= lts;

        if ts = '1'  then
          RAMDQ <= (others => 'Z');
        else
          RAMDQ <= indout; 
        end if;

        RAMDIN <= RAMDQ; 
      end if;
    end process main;

    datamempktinput_inst: datamempktinput
      port map (
        CLK => CLK,
        DIN => FIFODIN,
        ADDROUT => FIFOADDR,
        FIFOVALID => FIFOVALID,
        FIFONEXT => FIFONEXT,
        START => instart,
        DONE => indone,
        RAMWE => inwe,
        RAMADDR => inaddr,
        RAMDOUT => indout, 
        SRC => src,
        TYP => typ,
        ID => id,
        IDWE => idwe,
        BP => bp);

  datamempktretx_inst: datamempktretx
    port map (
      CLK      => CLK,
      DOUT     => RETXDOUT,
      ADDROUT  => RETXADDR,
      WEOUT    => RETXWE,
      START    => retstart,
      DONE     => retdone,
      RETXREQ  => RETXREQ,
      RETXDONE => RETXDONE,
      SRCRETX  => RETXSRC,
      TYPRETX  => RETXTYP,
      IDRETX   => RETXID,
      SRC      => src,
      TYP      => typ,
      ID       => id,
      IDWE     => idwe,
      BP       => bp,
      RAMADDR  => retaddr,
      RAMDIN   => ramdin); 

  datamempkttx_inst: datamempkttx
    port map (
      CLK      => CLK,
      DOUT     => TXDOUT,
      ADDROUT  => TXFIFOADDR,
      FIFOFULL => TXFIFOFULL,
      WEOUT     => TXWE,
      FIFODONE => TXDONE,
      START    => outstart,
      DONE     => outdone,
      RAMADDR  => outaddr,
      RAMDIN   => ramdin,
      BP       => bp); 

    fsm: process(cs, indone, outdone, retdone)
      begin
        case cs is
          when inreads =>
            dsel <= 0;
            instart <= '1';
            outstart <= '0';
            retstart <= '0';
            ns <= inreadw; 
            
          when inreadw =>
            dsel <= 0;
            instart <= '0';
            outstart <= '0';
            retstart <= '0';
            if indone = '1'  then
              ns <= outwrs;
            else
              ns <= inreadw; 
            end if;
             
          when outwrs =>
            dsel <= 2;
            instart <= '0';
            outstart <= '1';
            retstart <= '0';
            ns <= outwrw; 
            
          when outwrw =>
            dsel <= 2;
            instart <= '0';
            outstart <= '0';
            retstart <= '0';
            if outdone = '1'  then
              ns <= retxs;
            else
              ns <= outwrw; 
            end if;
            
          when retxs =>
            dsel <= 1;
            instart <= '0';
            outstart <= '0';
            retstart <= '1';
            ns <= retxw ; 
            
          when retxw =>
            dsel <= 1;
            instart <= '0';
            outstart <= '0';
            retstart <= '0';
            if retdone = '1'  then
              ns <= inreads; 
            else
              ns <= retxw; 
            end if;
            
           
          when others => null;
        end case;
      end process fsm; 

      
end Behavioral;
