library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.vcomponents.all;


entity arpresponse is
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
    DOEN  : out std_logic);
end arpresponse;

architecture Behavioral of arpresponse is

  signal dia  : std_logic_vector(15 downto 0) := (others => '0');
  signal dmux : integer range 0 to 5          := 0;

  signal addra   : std_logic_vector(7 downto 0) := (others => '0');
  signal ramaddr : std_logic_vector(9 downto 0) := (others => '0');


  signal wea : std_logic := '0';

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');
  signal outen : std_logic                    := '0';

  type states is (none, gettgtip, chktgtip1, chktgtip2,
                  destmac1, destmac2, destmac3, destmac4, srcmac1,
                  srcmac2, srcmac3, sendmac1, sendmac2, sendmac3, sendip1,
                  sendip2, tgtmac1, tgtmac2, tgtmac3, tgtmac4, tgtip1,
                  tgtip2, armout, grantw, pktout, pktsuc,  pktdone);

  signal cs, ns : states := none;


begin  -- Behavioral

  dia <= mymac(47 downto 32) when dmux = 0 else
         mymac(31 downto 16) when dmux = 1 else
         mymac(15 downto 0)  when dmux = 2 else
         myip(31 downto 16)  when dmux = 3 else
         myip(15 downto 0)   when dmux = 4 else
         inpktdata;

  outen <= '1' when cs = pktout else '0';

  ramaddr <= "00" & addra;

  DONE <= '1' when cs = pktdone else '0';
  ARM  <= '1' when cs = armout  else '0';

  PKTSUCCESS <= '1' when cs = pktsuc else '0';
  
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

  fsm : process(cs, INPKTDATA, START, GRANT, addrb)
  begin
    case cs is
      when none =>
        WEA       <= '0';
        dmux      <= 0;
        addra     <= X"00";
        INPKTADDR <= "0000000000";
        if START = '1' then
          ns      <= gettgtip;
        else
          ns      <= none;
        end if;

      when gettgtip =>
        WEA       <= '0';
        dmux      <= 0;
        addra     <= X"00";
        INPKTADDR <= "0000010100";
        ns        <= chktgtip1;

      when chktgtip1 =>
        WEA       <= '0';
        dmux      <= 0;
        addra     <= X"00";
        INPKTADDR <= "0000010101";
        if INPKTDATA = MYIP(31 downto 16) then
          ns      <= chktgtip2;
        else
          ns      <= pktdone;
        end if;

      when chktgtip2 =>
        WEA       <= '0';
        dmux      <= 0;
        addra     <= X"00";
        INPKTADDR <= "0000010101";
        if INPKTDATA = MYIP(15 downto 0) then
          ns      <= destmac1;
        else
          ns      <= pktdone;
        end if;

      when destmac1 =>
        WEA       <= '0';
        dmux      <= 5;
        addra     <= X"01";
        INPKTADDR <= "0000000100";
        ns        <= destmac2;

      when destmac2 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"01";
        INPKTADDR <= "0000000101";
        ns        <= destmac3;

      when destmac3 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"02";
        INPKTADDR <= "0000000110";
        ns        <= destmac4;

      when destmac4 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"03";
        INPKTADDR <= "0000000101";
        ns        <= srcmac1;

      when srcmac1 =>
        WEA       <= '1';
        dmux      <= 0;
        addra     <= X"04";
        INPKTADDR <= "0000000101";
        ns        <= srcmac2;

      when srcmac2 =>
        WEA       <= '1';
        dmux      <= 1;
        addra     <= X"05";
        INPKTADDR <= "0000000101";
        ns        <= srcmac3;

      when srcmac3 =>
        WEA       <= '1';
        dmux      <= 2;
        addra     <= X"06";
        INPKTADDR <= "0000000101";
        ns        <= sendmac1;

      when sendmac1 =>
        WEA       <= '1';
        dmux      <= 0;
        addra     <= X"0C";
        INPKTADDR <= "0000000101";
        ns        <= sendmac2;

      when sendmac2 =>
        WEA       <= '1';
        dmux      <= 1;
        addra     <= X"0D";
        INPKTADDR <= "0000000101";
        ns        <= sendmac3;

      when sendmac3 =>
        WEA       <= '1';
        dmux      <= 2;
        addra     <= X"0E";
        INPKTADDR <= "0000000101";
        ns        <= sendip1;

      when sendip1 =>
        WEA       <= '1';
        dmux      <= 3;
        addra     <= X"0F";
        INPKTADDR <= "0000000101";
        ns        <= sendip2;

      when sendip2 =>
        WEA       <= '1';
        dmux      <= 4;
        addra     <= X"10";
        INPKTADDR <= "0000000101";
        ns        <= tgtmac1;

      when tgtmac1 =>
        WEA       <= '0';
        dmux      <= 5;
        addra     <= X"11";
        INPKTADDR <= "0000001100";
        ns        <= tgtmac2;

      when tgtmac2 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"11";
        INPKTADDR <= "0000001101";
        ns        <= tgtmac3;

      when tgtmac3 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"12";
        INPKTADDR <= "0000001110";
        ns        <= tgtmac4;

      when tgtmac4 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"13";
        INPKTADDR <= "0000001111";
        ns        <= tgtip1;

      when tgtip1 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"14";
        INPKTADDR <= "0000010000";
        ns        <= tgtip2;

      when tgtip2 =>
        WEA       <= '1';
        dmux      <= 5;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        ns        <= armout;

      when armout =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        ns        <= grantw;

      when grantw =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        if GRANT = '1' then
          ns      <= pktout;
        else
          ns      <= grantw;
        end if;

       when pktout =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        if addrb = "0000011111" then
          ns      <= pktsuc;
        else
          ns      <= pktout;
        end if;

       when pktsuc =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        ns <= pktdone; 

      when pktdone =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        ns        <= none;

      when others =>
        WEA       <= '0';
        dmux      <= 1;
        addra     <= X"15";
        INPKTADDR <= "0000010000";
        ns        <= none;
    end case;
  end process fsm;

  RAMB16_S18_S18_inst : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "ALL",     -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- The follosing INIT_xx declarations specify the intiial contents of the RAM
      -- Address 0 to 255
      INIT_00             => X"000000000000000000020604080000010806000000000000000000000000003e",
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
      ADDRA => ramaddr,
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
