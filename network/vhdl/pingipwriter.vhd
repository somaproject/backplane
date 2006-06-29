library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity pingipwriter is
  port (
    CLK       : in  std_logic;
    INPKTDATA : in  std_logic_vector(15 downto 0);
    INPKTADDR : out std_logic_vector(9 downto 0);
    START     : in  std_logic;
    DONE      : out std_logic;
    ABORT     : out std_logic;
    DATALEN   : out std_logic_vector(15 downto 0);
    DOUT      : out std_logic_vector(15 downto 0);
    AOUT      : out std_logic_vector(9 downto 0);
    WEOUT     : out std_logic;
    MYMAC     : in  std_logic_vector(47 downto 0);
    MYIP      : in  std_logic_vector(31 downto 0)
    );

end pingipwriter;

architecture Behavioral of pingipwriter is

  signal dmux : integer range 0 to 6 := 0;

  signal chksel : std_logic := '0';
  signal chkld  : std_logic := '0';
  signal chken  : std_logic := '0';

  signal csum, cdin : std_logic_vector(15 downto 0) := (others => '0');
  signal len : std_logic_vector(15 downto 0) := (others => '0');
  
  signal pia : std_logic_vector(9 downto 0) := (others => '0');

  
  type states is (none, gettype, chkping, pktabort, pktdone,
                  wrlen, destmac1, destmac2, destmac3, srcmac1,
                  srcmac2, srcmac3, wriplen, srcip1, srcip2,
                  destip1, destip2, wrchk);

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
      LD     => chkld,
      EN     => chken,
      CHKOUT => csum);


  DOUT <= mymac(47 downto 32) when dmux = 0 else
          mymac(31 downto 16) when dmux = 1 else
          mymac(15 downto 0)  when dmux = 2 else
          myip(31 downto 16)  when dmux = 3 else
          myip(15 downto 0)   when dmux = 4 else
          inpktdata           when dmux = 5 else
          csum;

  INPKTADDR <= pia;

  cdin <= INPKTDATA when chksel = '0' else X"1234";

  
  DONE  <= '1' when cs = pktdone else '0';
  ABORT <= '1' when cs = pktabort   else '0';

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

      if cs = wriplen then
        len <= INPKTDATA;
      end if;

      DATALEN <= len - X"0000010110";

    end if;
  end process main;

  fsm: process(cs, START, INPKTDATA)
    begin
      case cs is
        when  none =>
          WEOUT <= '0';
          AOUT <= "0000000000";
          pia <= "0000000000";
          dmux <= 0;
          chksel <= '1';
          chken <= '1';
          if START = '1' then
            ns <= gettype;
          else
            ns <= none; 
          end if;
          
        when  gettype =>
          WEOUT <= '0';
          AOUT <= "0000000000";
          pia <= "0000010100";
          dmux <= 0;
          chksel <= '0';
          chken <= '0';
          ns <= chkping;
          
        when chkping =>
          WEOUT <= '0';
          AOUT <= "0000000000";
          pia <= "0000000000";
          dmux <= 0;
          chksel <= '0';
          chken <= '0';
          if inpktdata = X"0800" then
            ns <= wrlen;
          else
            ns <= pktabort;
          end if;

        when pktabort =>
          WEOUT <= '0';
          AOUT <= "0000000000";
          pia <= "0000000000";
          dmux <= 0;
          chksel <= '0';
          chken <= '0';
          ns <= none; 

        when wrlen =>
          WEOUT <= '1';
          AOUT <= "0000000000";
          pia <= "0000000100";
          dmux <= 5;
          chksel <= '0';
          chken <= '0';
          ns <= destmac1; 
          
        when destmac1 =>
          WEOUT <= '1';
          AOUT <= "0000000001";
          pia <= "0000000101";
          dmux <= 5;
          chksel <= '0';
          chken <= '0';
          ns <= destmac2; 
          
        when destmac2 =>
          WEOUT <= '1';
          AOUT <= "0000000010";
          pia <= "0000000110";
          dmux <= 5;
          chksel <= '0';
          chken <= '0';
          ns <= destmac3; 
          
        when destmac3 =>
          WEOUT <= '1';
          AOUT <= "0000000011";
          pia <= "0000000010";
          dmux <= 5;
          chksel <= '0';
          chken <= '0';
          ns <= srcmac1;
          
        when srcmac1 =>
          WEOUT <= '1';
          AOUT <= "0000000100";
          pia <= "0000000010";
          dmux <= 0;
          chksel <= '0';
          chken <= '0';
          ns <= srcmac2; 
          
        when srcmac2 =>
          WEOUT <= '1';
          AOUT <= "0000000101";
          pia <= "0000000010";
          dmux <= 1;
          chksel <= '0';
          chken <= '0';
          ns <= srcmac3; 
          
        when srcmac3 =>
          WEOUT <= '1';
          AOUT <= "0000000110";
          pia <= "0000001001";
          dmux <= 2;
          chksel <= '0';
          chken <= '0';
          ns <= wriplen; 
          
        when wriplen =>
          WEOUT <= '1';
          AOUT <= "0000001001";
          pia <= "0000001110";
          dmux <= 5;
          chksel <= '0';
          chken <= '1';
          ns <= srcip1; 
          
        when srcip1 =>
          WEOUT <= '1';
          AOUT <= "0000001111";
          pia <= "0000001111";
          dmux <= 3;
          chksel <= '0';
          chken <= '1';
          ns <= srcip2; 
          
        when srcip2 =>
          WEOUT <= '1';
          AOUT <= "0000001111";
          pia <= "0000001110";
          dmux <= 4;
          chksel <= '0';
          chken <= '1';
          ns <= destip1; 
          
        when destip1 =>
          WEOUT <= '1';
          AOUT <= "0000010000";
          pia <= "0000001111";
          dmux <= 5;
          chksel <= '0';
          chken <= '1';
          ns <= destip1; 
          
        when destip2 =>
          WEOUT <= '1';
          AOUT <= "0000010001";
          pia <= "0000001110";
          dmux <= 5;
          chksel <= '0';
          chken <= '1';
          ns <= wrchk; 

        when wrchk =>
          WEOUT <= '1';
          AOUT <= "0000001101";
          pia <= "0000001110";
          dmux <= 6;
          chksel <= '0';
          chken <= '1';
          ns <= pktdone; 
          
        when pktdone=>
          WEOUT <= '0';
          AOUT <= "0000001101";
          pia <= "0000001110";
          dmux <= 6;
          chksel <= '0';
          chken <= '0';
          ns <= none;
          
        when others=>
          WEOUT <= '0';
          AOUT <= "0000001101";
          pia <= "0000001110";
          dmux <= 6;
          chksel <= '0';
          chken <= '0';
          ns <= none;  

      end case;
    end process fsm; 
end Behavioral;
