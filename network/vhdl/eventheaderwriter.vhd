library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity eventheaderwriter is
  port (
    CLK   : in  std_logic;
    MYMAC : in  std_logic_vector(47 downto 0);
    MYIP  : in  std_logic_vector(31 downto 0);
    START : in  std_logic;
    WLEN  : in  std_logic_vector(8 downto 0);
    DOUT  : out std_logic_vector(15 downto 0);
    WEOUT : out std_logic;
    ADDR  : out std_logic_vector(8 downto 0);
    DONE  : out std_logic);
end eventheaderwriter;


architecture Behavioral of eventheaderwriter is

  signal dmux                    : integer range 0 to 8          := 0;
  signal udplen, iplen, framelen : std_logic_vector(15 downto 0) := (others => '0');

  signal cdin : std_logic_vector(15 downto 0) := (others => '0');

  signal ld    : std_logic                     := '0';
  signal chken : std_logic                     := '0';
  signal csum  : std_logic_vector(15 downto 0) := (others => '0');

  signal ain : std_logic_vector(15 downto 0) := (others => '0');

  signal doutint : std_logic_vector(15 downto 0) := (others => '0');

  
  type states is (none, macwh, macwm, macwl, ipwh, ipwl, udplenw, iplenw, framelw, chksumw);

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

  ain(9 downto 1) <= WLEN;
  udplen          <= ain + X"0004";
  iplen           <= ain + X"0018";
  framelen        <= ain + X"0028";

  doutint <= MYMAC(47 downto 32) when dmux = 0 else
             MYMAC(31 downto 16) when dmux = 1 else
             MYMAC(15 downto 0)  when dmux = 2 else
             MYIP(31 downto 16)  when dmux = 3 else
             MYIP(15 downto 0)   when dmux = 4 else
             udplen              when dmux = 5 else
             iplen               when dmux = 6 else
             framelen            when dmux = 7 else
             csum;
  DOUT    <= doutint;
  cdin    <= doutint             when ld = '0' else X"1234";

  ld <= '1' when cs = none else '0';

  DONE <= '1' when cs = chksumw else '0'; 
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
        addr  <= "000000000";
        chken <= '1';
        weout <= '0';
        if START = '1' then
          ns  <= macwh;
        else
          ns  <= none;
        end if;

      when macwh =>
        dmux  <= 0;
        addr  <= "000000100";
        chken <= '0';
        weout <= '1';
        ns    <= macwm;

      when macwm =>
        dmux  <= 1;
        addr  <= "000000101";
        chken <= '0';
        weout <= '1';
        ns    <= macwl;

      when macwl =>
        dmux  <= 2;
        addr  <= "000000110";
        chken <= '0';
        weout <= '1';
        ns    <= ipwh;

      when ipwh =>
        dmux  <= 3;
        addr  <= "000001110";
        chken <= '1';
        weout <= '1';
        ns    <= ipwl;

      when ipwl =>
        dmux  <= 4;
        addr  <= "000001111";
        chken <= '1';
        weout <= '1';
        ns    <= udplenw;

      when udplenw =>
        dmux  <= 5;
        addr  <= "000010100";
        chken <= '0';
        weout <= '1';
        ns    <= iplenw;

      when iplenw =>
        dmux  <= 6;
        addr  <= "000001001";
        chken <= '1';
        weout <= '1';
        ns    <= framelw;

      when framelw =>
        dmux  <= 7;
        addr  <= "000000000";
        chken <= '0';
        weout <= '1';
        ns    <= chksumw;

      when chksumw =>
        dmux  <= 8;
        addr  <= "000001101";
        chken <= '0';
        weout <= '1';
        ns    <= none;

      when others =>
        dmux  <= 8;
        addr  <= "000001101";
        chken <= '0';
        weout <= '0';
        ns    <= none;


    end case;
  end process fsm;
end Behavioral;
