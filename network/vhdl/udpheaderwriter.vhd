library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity udpheaderwriter is
  port (
    CLK      : in  std_logic;
    SRCMAC    : in  std_logic_vector(47 downto 0);
    SRCIP     : in  std_logic_vector(31 downto 0);
    DESTMAC : in std_logic_vector(47 downto 0); 
    DESTIP  : in  std_logic_vector(31 downto 0);
    DESTPORT : in  std_logic_vector(15 downto 0);
    START    : in  std_logic;
    WLEN     : in  std_logic_vector(9 downto 0);
    DOUT     : out std_logic_vector(15 downto 0);
    WEOUT    : out std_logic;
    ADDR     : out std_logic_vector(9 downto 0);
    DONE     : out std_logic);
end udpheaderwriter;


architecture Behavioral of udpheaderwriter is

  signal dmux                    : integer range 0 to 14        := 0;
  signal udplen, iplen, framelen : std_logic_vector(15 downto 0) := (others => '0');

  signal cdin : std_logic_vector(15 downto 0) := (others => '0');

  signal ld    : std_logic                     := '0';
  signal chken : std_logic                     := '0';
  signal csum  : std_logic_vector(15 downto 0) := (others => '0');

  signal ain : std_logic_vector(15 downto 0) := (others => '0');

  signal doutint : std_logic_vector(15 downto 0) := (others => '0');


  type states is (none, desmacwh, desmacwm, desmacwl,
                  srcmacwh, srcmacwm, srcmacwl,
                  srcipwh, srcipwl, destipwh, destipwl,
                  udpportw,             udplenw, iplenw, framelw, chksumw);

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
      LD     => ld,
      EN     => chken,
      CHKOUT => csum);

  ain(10 downto 1) <= WLEN;
  udplen           <= ain + X"0008";
  iplen            <= ain + X"001c";
  framelen         <= ain + X"002c";

  doutint <= DESTMAC(47 downto 32) when dmux = 0 else
             DESTMAC(31 downto 16) when dmux = 1 else
             DESTMAC(15 downto 0) when dmux = 2 else 
             SRCMAC(47 downto 32)   when dmux = 3  else
             SRCMAC(31 downto 16)   when dmux = 4  else
             SRCMAC(15 downto 0)    when dmux = 5  else
             SRCIP(31 downto 16)    when dmux = 6  else
             SRCIP(15 downto 0)     when dmux = 7  else
             DESTIP(31 downto 16) when dmux = 8  else
             DESTIP(15 downto 0)  when dmux = 9  else
             DESTPORT              when dmux = 10  else
             udplen                when dmux = 11  else
             iplen                 when dmux = 12  else
             framelen              when dmux = 13 else
             csum;
  DOUT    <= doutint;
  cdin    <= doutint               when ld = '0'  else X"8511";

  ld <= '1' when cs = none else '0';

  DONE   <= '1' when cs = chksumw else '0';
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

    end if;
  end process main;

  fsm : process(cs, START)
  begin
    case cs is
      when none =>
        dmux  <= 0;
        addr  <= "0000000000";
        chken <= '1';
        weout <= '0';
        if START = '1' then
          ns  <= desmacwh;
        else
          ns  <= none;
        end if;

      when desmacwh =>
        dmux  <= 0;
        addr  <= "0000000001";
        chken <= '0';
        weout <= '1';
        ns    <= desmacwm;

      when desmacwm =>
        dmux  <= 1;
        addr  <= "0000000010";
        chken <= '0';
        weout <= '1';
        ns    <= desmacwl;

      when desmacwl =>
        dmux  <= 2;
        addr  <= "0000000011";
        chken <= '0';
        weout <= '1';
        ns    <= srcmacwh;

      when srcmacwh =>
        dmux  <= 3;
        addr  <= "0000000100";
        chken <= '0';
        weout <= '1';
        ns    <= srcmacwm;

      when srcmacwm =>
        dmux  <= 4;
        addr  <= "0000000101";
        chken <= '0';
        weout <= '1';
        ns    <= srcmacwl;

      when srcmacwl =>
        dmux  <= 5;
        addr  <= "0000000110";
        chken <= '0';
        weout <= '1';
        ns    <= srcipwh;

      when srcipwh =>
        dmux  <= 6;
        addr  <= "0000001110";
        chken <= '1';
        weout <= '1';
        ns    <= srcipwl;

      when srcipwl =>
        dmux  <= 7;
        addr  <= "0000001111";
        chken <= '1';
        weout <= '1';
        ns    <= destipwh;

      when destipwh =>
        dmux  <= 8;
        addr  <= "0000010000";
        chken <= '1';
        weout <= '1';
        ns    <= destipwl;

      when destipwl =>
        dmux  <= 9;
        addr  <= "0000010001";
        chken <= '1';
        weout <= '1';
        ns    <= udpportw;

      when udpportw =>
        dmux  <= 10;
        addr  <= "0000010011";
        chken <= '0';
        weout <= '1';
        ns    <= udplenw;

      when udplenw =>
        dmux  <= 11;
        addr  <= "0000010100";
        chken <= '0';
        weout <= '1';
        ns    <= iplenw;

      when iplenw =>
        dmux  <= 12;
        addr  <= "0000001001";
        chken <= '1';
        weout <= '1';
        ns    <= framelw;

      when framelw =>
        dmux  <= 13;
        addr  <= "0000000000";
        chken <= '0';
        weout <= '1';
        ns    <= chksumw;

      when chksumw =>
        dmux  <= 14;
        addr  <= "0000001101";
        chken <= '0';
        weout <= '1';
        ns    <= none;

      when others =>
        dmux  <= 11;
        addr  <= "0000001101";
        chken <= '0';
        weout <= '0';
        ns    <= none;


    end case;
  end process fsm;
end Behavioral;
