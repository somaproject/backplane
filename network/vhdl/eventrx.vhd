library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library soma;
use SOMA.somabackplane.all;
use soma.somabackplane;

entity eventrx is
  port (
    CLK       : in  std_logic;
    INPKTADDR : out std_logic_vector(9 downto 0);
    INPKTDATA : in  std_logic_vector(15 downto 0);
    START     : in  std_logic;
    DONE      : out std_logic;
    EVTRXSUC : out std_logic;
    EVTFIFOFULL : out std_logic; 
    -- input parameters
    MYMAC     : in  std_logic_vector(47 downto 0);
    MYIP      : in  std_logic_vector(31 downto 0);
    -- Event interface
    ECYCLE    : in  std_logic;
    EARX      : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX      : out std_logic_vector(7 downto 0);
    EDSELRX   : in  std_logic_vector(3 downto 0);
    -- output to TX interface
    DOUT      : out std_logic_vector(15 downto 0);
    DOEN      : out std_logic;
    ARM       : out std_logic;
    GRANT     : in  std_logic);
end eventrx;

architecture Behavioral of eventrx is
  -- input selection
  signal asel   : integer range 0 to 1                    := 0;
  signal inaddr : std_logic_vector(9 downto 0) := (others => '0');

  signal efree   : std_logic_vector(5 downto 0) := (others => '0');
  signal ecnt    : std_logic_vector(3 downto 0) := (others => '0');
  signal success : std_logic                    := '0';

  -- response registers
  signal nonce    : std_logic_vector(15 downto 0) := (others => '0');
  signal destmac  : std_logic_vector(47 downto 0) := (others => '0');
  signal destport : std_logic_vector(15 downto 0) := (others => '0');
  signal destip   : std_logic_vector(31 downto 0) := (others => '0');


  -- io
  signal estart, edone, edones : std_logic := '0';
  signal txstart, txdone, txdones : std_logic := '0';

  signal outaddr, ebaddr : std_logic_vector(9 downto 0) := (others => '0');


  type states is (none, destmach, destmacm, destmacl, destiph, destipl,
                  dportw, noncew, ecntw, chkfree,
                  successt, successw, failst, failw, dones);

  signal cs, ns : states := none;
  
  component eventrxbusoutput
    port (
      CLK     : in  std_logic;
      ADDROUT : out std_logic_vector(9 downto 0);
      EFREE   : out std_logic_vector(5 downto 0);
      DIN     : in  std_logic_vector(15 downto 0);
      ECNT    : in  std_logic_vector(3 downto 0); 
      START   : in  std_logic;
      DONE    : out std_logic;
      -- event bus interface
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0)
      );

  end component;

component eventrxresponsewr 

  port (
    CLK      : in  std_logic;
    START    : in  std_logic;
    DONE     : out std_logic;
    -- input parameters
    SRCMAC   : in  std_logic_vector(47 downto 0);
    SRCIP    : in  std_logic_vector(31 downto 0);
    DESTIP   : in  std_logic_vector(31 downto 0);
    DESTMAC  : in  std_logic_vector(47 downto 0);
    DESTPORT : in  std_logic_vector(15 downto 0);
    NONCE    : in  std_logic_vector(15 downto 0);
    SUCCESS  : in  std_logic;
    -- output to TX interface
    DOUT     : out std_logic_vector(15 downto 0);
    DOEN     : out std_logic;
    ARM      : out std_logic;
    GRANT    : in  std_logic);

end component;

begin  -- Behavioral

  eventrxbusoutput_inst: eventrxbusoutput
    port map (
      CLK     => CLK,
      ADDROUT => ebaddr,
      EFREE   => efree,
      DIN     => INPKTDATA,
      ECNT    => ecnt,
      START   => estart,
      DONE    => edone,
      ECYCLE  => ECYCLE,
      EARX    => EARX,
      EDRX    => EDRX,
      EDSELRX => EDSELRX); 

  eventrxresponsewr_inst: eventrxresponsewr
    port map (
      CLK      => CLK,
      START    => txstart,
      DONE     => txdone,
      SRCMAC   => MYMAC,
      SRCIP    => MYIP,
      DESTIP   => destip,
      DESTMAC  => destmac,
      DESTPORT => destport,
      NONCE    => nonce,
      SUCCESS  => success,
      DOUT     => DOUT,
      ARM      => ARM,
      GRANT    => GRANT,
      DOEN     => DOEN); 
    
  INPKTADDR <= inaddr when asel = 0 else outaddr;
  DONE <= '1' when cs = dones else '0'; 
  outaddr <= ebaddr + "0000011000";

  EVTRXSUC <= '1' when cs = dones else '0';
  EVTFIFOFULL <= '1' when cs = failst else '0'; 
  

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = ecntw then
        ecnt <= INPKTDATA(3 downto 0);
      end if;

      if cs = destmach then
        destmac(47 downto 32) <= INPKTDATA;
      end if;

      if cs = destmacm then
        destmac(31 downto 16) <= INPKTDATA;
      end if;

      if cs = destmacl then
        destmac(15 downto 0) <= INPKTDATA;
      end if;

      if cs = destiph then
        destip(31 downto 16) <= INPKTDATA;
      end if;

      if cs = destipl then
        destip(15 downto 0) <= INPKTDATA;
      end if;

      if cs = dportw then
        destport <= INPKTDATA;
      end if;

      if cs = noncew then
        nonce <= INPKTDATA;
      end if;

      if cs = none then
        edones   <= '0';
      else
        if edone = '1' then
          edones <= '1';
        end if;
      end if;

      if cs = none then
        txdones   <= '0';
      else
        if txdone = '1' then
          txdones <= '1';
        end if;
      end if;

    end if;

  end process main;


  fsm: process(cs, START, txdones, edones, ecnt, efree)
    begin
      case cs is
        when  none =>
          asel <= 0;
          inaddr <= "0000000100";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          if START = '1' then
            ns <= destmach;
          else
            ns <= none; 
          end if;
          
        when  destmach =>
          asel <= 0;
          inaddr <= "0000000101";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= destmacm; 

        when  destmacm =>
          asel <= 0;
          inaddr <= "0000000110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= destmacl; 

        when  destmacl =>
          asel <= 0;
          inaddr <= "0000001110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= destiph; 

        when  destiph =>
          asel <= 0;
          inaddr <= "0000001111";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= destipl; 

        when  destipl =>
          asel <= 0;
          inaddr <= "0000010010";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= dportw; 

        when  dportw =>
          asel <= 0;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= noncew; 

        when  noncew =>
          asel <= 0;
          inaddr <= "0000010111";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= ecntw; 

        when  ecntw =>
          asel <= 0;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= chkfree; 

        when  chkfree  =>
          asel <= 0;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          if ecnt <= efree then
            ns <= successt;
          else
            ns <= failst; 
          end if;
         
        when  successt  =>
          asel <= 1;
          inaddr <= "0000010110";
          txstart <= '1';
          estart <= '1';
          success <= '1';
          ns <= successw; 

        when  successw  =>
          asel <= 1;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '1';
          if txdones = '1' and edones = '1' then
            ns <= dones;
          else
            ns <= successw; 
          end if;

        when  dones  =>
          asel <= 1;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= none;

        when  failst  =>
          asel <= 1;
          inaddr <= "0000010110";
          txstart <= '1';
          estart <= '0';
          success <= '0';
          ns <= failw; 

        when  failw  =>
          asel <= 1;
          inaddr <= "0000010110";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          if txdones = '1' then
            ns <= dones;
          else
            ns <= failw; 
          end if;
          
        when others  =>
          asel <= 0;
          inaddr <= "0000000000";
          txstart <= '0';
          estart <= '0';
          success <= '0';
          ns <= none; 
      end case;
    end process fsm;
    
end Behavioral;
