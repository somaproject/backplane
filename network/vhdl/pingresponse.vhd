library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.vcomponents.all;


entity pingresponse is

  port (
    CLK   : in std_logic;
    MYMAC : in std_logic_vector(47 downto 0);
    MYIP  : in std_logic_vector(31 downto 0);

    -- IO interface
    START     : in  std_logic;
    DONE      : out std_logic;
    INPKTDATA : in  std_logic_vector(15 downto 0);
    INPKTADDR : out std_logic_vector(9 downto 0);
    PKTSUCCESS : out std_logic; 
    -- output
    ARM   : out std_logic;
    GRANT : in  std_logic;
    DOUT  : out std_logic_vector(15 downto 0);
    DOEN  : out std_logic
    );
end pingresponse;

architecture Behavioral of pingresponse is

  signal paa, pab     : std_logic_vector(9 downto 0)  := (others => '0');
  signal douta, doutb : std_logic_vector(15 downto 0) := (others => '0');

  signal aouta, aoutb : std_logic_vector(9 downto 0) := (others => '0');

  signal weouta, weoutb : std_logic := '0';

  signal dia   : std_logic_vector(15 downto 0) := (others => '0');
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');

  signal wea : std_logic := '0';

  signal datalen : std_logic_vector(15 downto 0) := (others => '0');
  signal txlen : std_logic_vector(15 downto 0) := (others => '0');
  
  signal pingdone, ipdone   : std_logic := '0';
  signal pingstart, ipstart : std_logic := '0';
  signal abort              : std_logic := '0';

  signal insel : std_logic := '0';


  type states is (none, ipstarts, ipwait, pingstarts, pingwait, armout, grantw,
                  pktout, pktsuc, pktdone);

  signal cs, ns : states := none;

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');
  signal outen : std_logic                    := '0';

  component pingipwriter
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

  end component;

  component pingicmpwriter
    port (
      CLK       : in  std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      START     : in  std_logic;
      DONE      : out std_logic;
      DATALEN   : in  std_logic_vector(15 downto 0);
      DOUT      : out std_logic_vector(15 downto 0);
      AOUT      : out std_logic_vector(9 downto 0);
      WEOUT     : out std_logic
      );

  end component;

-------------------------------------------------------------------------------
-- DEBUG
-------------------------------------------------------------------------------
component jtagsimpleout 
    generic (
    JTAG_CHAIN : integer := 0;
    JTAGN : integer := 32);
  port (
    CLK : in std_logic;
    DIN : in std_logic_vector(JTAGN-1 downto 0));
end component; 

signal jtagin : std_logic_vector(39 downto 0) := (others => '0');
signal DEBUG :  std_logic_vector(7 downto 0) := (others => '0'); 
-------------------------------------------------------------------------------

begin  -- Behavioral

  jtagin(7 downto 0) <= DEBUG;
  jtagin(39 downto 8) <= X"ABCDEF78";
  
--     jtag_Debug: jtagsimpleout
--     generic map (
--       JTAG_CHAIN => 2,
--       JTAGN      => 40)
--     port map (
--       CLK => CLK,
--       DIN => jtagin);

  pingipwriter_inst : pingipwriter
    port map (
      CLK       => CLK,
      INPKTDATA => INPKTDATA,
      INPKTADDR => paa,
      START     => ipstart,
      DONE      => ipdone,
      ABORT     => abort,
      DATALEN   => datalen,
      DOUT      => douta,
      AOUT      => aouta,
      WEOUT     => weouta,
      MYMAC     => MYMAC,
      MYIP      => MYIP);

  pingicmpwriter_inst : pingicmpwriter
    port map (
      CLK       => CLK,
      INPKTDATA => inpktdata,
      INPKTADDR => pab,
      START     => pingstart,
      DONE      => pingdone,
      DATALEN   => datalen,
      DOUT      => doutb,
      AOUT      => aoutb,
      WEOUT     => weoutb);

  dia   <= douta  when insel = '0' else doutb;
  addra <= aouta  when insel = '0' else aoutb;
  wea   <= weouta when insel = '0' else weoutb;

  INPKTADDR <= paa when insel = '0' else pab;
  DONE <= '1' when cs = pktdone else '0'; 
  outen <= '1' when cs = pktout else '0';

  ipstart   <= '1' when cs = ipstarts   else '0';
  pingstart <= '1' when cs = pingstarts else '0';

  
  ARM <= '1' when cs = armout or cs = grantw else '0';
  
  PKTSUCCESS <= '1' when cs = pktsuc else '0';
  -- transmit body length in bytes
  txlen <= datalen + "0000100110";
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      DOEN <= outen;

      if cs = none then
        addrb   <= (others => '0');
      else
        if outen = '1' then
          addrb <= addrb + 1;
        end if;
      end if;
    end if;
  end process main;

  fsm : process(cs, INPKTDATA, start, abort, ipdone,
                pingdone, grant, addrb, datalen, txlen)

  begin
    case cs is
      when none =>
        DEBUG(7 downto 0) <= X"00"; 
        insel <= '0';

        if START = '1' then
          ns <= ipstarts;
        else
          ns <= none;
        end if;

      when ipstarts =>
        DEBUG(7 downto 0) <= X"01"; 
        insel <= '0';
        ns    <= ipwait;

      when ipwait =>
        DEBUG(7 downto 0) <= X"02"; 
        insel <= '0';
        if abort = '1' then
          ns  <= pktdone;
        elsif ipdone = '1' then
          ns  <= pingstarts;
        else
          ns  <= ipwait;
        end if;

      when pingstarts =>
        DEBUG(7 downto 0) <= X"03"; 
        insel <= '1';
        ns    <= pingwait;

      when pingwait =>
        DEBUG(7 downto 0) <= X"04"; 
        insel <= '1';
        if pingdone = '1' then
          ns  <= armout;
        else
          ns  <= pingwait;
        end if;

      when armout =>
        DEBUG(7 downto 0) <= X"05"; 
        insel <= '1';
        ns    <= grantw;

      when grantw =>
        DEBUG(7 downto 0) <= X"06"; 
        insel <= '1';
        if GRANT = '1' then
          ns  <= pktout;
        else
          ns  <= grantw;
        end if;

      when pktout =>
        DEBUG(7 downto 0) <= X"07"; 
        insel <= '1';
        if addrb >= ('0' & txlen(15 downto 1)) then
          ns  <= pktsuc;
        else
          ns  <= pktout;
        end if;
        
      when pktsuc =>
        DEBUG(7 downto 0) <= X"08"; 
        insel <= '1';
        ns    <= pktdone;


      when pktdone =>
        DEBUG(7 downto 0) <= X"08"; 
        insel <= '1';
        ns    <= none;

      when others =>
        DEBUG(7 downto 0) <= X"09"; 
        insel <= '1';
        ns    <= none;

    end case;
  end process fsm;

  RAMB16_S18_S18_inst : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",     -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- The follosing INIT_xx declarations specify the intiial contents of the RAM
      -- Address 0 to 255
      INIT_00             => X"000000000000400100000000000045000800000000000000000000000000003e",
      INIT_01             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05             => X"0000000000000000000000000000000000000000000000000000000000000000")

    port map (
      DOA   => open,
      DOB   => DOUT,
      DOPA  => open,
      DOPB  => open,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => dia,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => wea,
      WEB   => '0'
      );

end Behavioral;
