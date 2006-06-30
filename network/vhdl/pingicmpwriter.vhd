library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity pingicmpwriter is
  port (
    CLK       : in  std_logic;
    INPKTDATA : in  std_logic_vector(15 downto 0);
    INPKTADDR : out std_logic_vector(9 downto 0);
    START     : in  std_logic;
    DONE      : out std_logic;
    DATALEN   : in std_logic_vector(15 downto 0);
    DOUT      : out std_logic_vector(15 downto 0);
    AOUT      : out std_logic_vector(9 downto 0);
    WEOUT     : out std_logic
    );

end pingicmpwriter;

architecture Behavioral of pingicmpwriter is

  signal dmux : integer range 0 to 1 := 0;

  signal chksel : std_logic := '0';
  signal chkld  : std_logic := '0';
  signal chken  : std_logic := '0';

  signal csum, cdin : std_logic_vector(15 downto 0) := (others => '0');

  signal pia : std_logic_vector(9 downto 0) := (others => '0');

  signal acnt, acntl : std_logic_vector(9 downto 0) := (others => '0');
  signal addrinc : std_logic := '0';

  
  signal pktlen : std_logic_vector(9 downto 0) := (others => '0');

  type states is (none, loadcsum, startpkt, datawait, chkwr, pktdone);
  

  signal cs, ns : states := none;

  component ipchecksum
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      LD     : in  std_logic;
      EN     : in  std_logic;
      CHKOUT : out std_logic_vector(15 downto 0));
  end component;

begin  -- Behavioral

  ipchecksum_inst : ipchecksum
    port map (
      CLK    => CLK,
      DIN    => cdin,
      LD     => chksel,
      EN     => chken,
      CHKOUT => csum);


  DOUT <= inpktdata when dmux = 1 else
          csum;
  
  AOUT <= "0000010011" when dmux = 0 else acntl;

  INPKTADDR <= acnt;

  cdin <= INPKTDATA when chksel = '0' else X"0000";
  chksel <= '1' when cs = loadcsum else '0';
  
  DONE  <= '1' when cs = pktdone else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

    if cs = loadcsum then
      acnt <= "0000010100";
    else
      if addrinc = '1' then
        acnt <= acnt + 1; 
      end if;
    end if;

    if cs = loadcsum then
      pktlen <= (others => '0'); 
    else
      if addrinc = '1' then
        pktlen <= pktlen + 2; 
      end if;
    end if;

    acntl <= acnt;
      
    end if;
  end process main;

  fsm : process(cs, START, INPKTDATA, DATALEN, pktlen)
  begin
    case cs is
      when none =>
        chken <= '0';
        addrinc <= '0';
        WEOUT <= '0';
        dmux <= 1; 
        if START = '1' then
          ns <= loadcsum;
        else
          ns <= none; 
        end if;

      when loadcsum =>
        chken <= '1';
        addrinc <= '0';
        WEOUT <= '0';
        dmux <= 1; 
        ns <= startpkt;
        
      when startpkt =>
        chken <= '0';
        addrinc <= '1';
        WEOUT <= '0';
        dmux <= 1; 
        ns <= datawait;
        
      when datawait =>
        chken <= '1';
        addrinc <= '1';
        WEOUT <= '1';
        dmux <= 1; 
        if DATALEN(9 downto 0) = pktlen then
          ns <= chkwr;
          else
            ns <= datawait; 
        end if;

      when chkwr =>
        chken <= '0';
        addrinc <= '0';
        WEOUT <= '1';
        dmux <= 0; 
        ns <= pktdone;
        
      when pktdone =>
        chken <= '0';
        addrinc <= '0';
        WEOUT <= '0';
        dmux <= 0; 
        ns <= none; 
        
      when others =>
        chken <= '0';
        addrinc <= '0';
        WEOUT <= '0';
        dmux <= 0; 
        ns <= none; 

    end case;
  end process fsm;
end Behavioral;
