library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;


entity eventrxresponsewr is

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

end eventrxresponsewr;


architecture Behavioral of eventrxresponsewr is

  signal insel   : integer range 0 to 2          := 0;
  signal hdrdout : std_logic_vector(15 downto 0) := (others => '0');
  signal hdraddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal hdrwe   : std_logic                     := '0';

  signal dia   : std_logic_vector(15 downto 0) := (others => '0');
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');
  signal wea   : std_logic                     := '0';

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal outen : std_logic := '0';

  type states is (none, hdrst, hdrwait, noncewr,
                  sucwr, dones, pktout, armw);

  signal cs, ns : states := none;

  signal hdrstart, hdrdone : std_logic := '0';


  component udpheaderwriter
    port (
      CLK      : in  std_logic;
      SRCMAC   : in  std_logic_vector(47 downto 0);
      SRCIP    : in  std_logic_vector(31 downto 0);
      DESTMAC  : in  std_logic_vector(47 downto 0);
      DESTIP   : in  std_logic_vector(31 downto 0);
      DESTPORT : in  std_logic_vector(15 downto 0);
      START    : in  std_logic;
      WLEN     : in  std_logic_vector(9 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      WEOUT    : out std_logic;
      ADDR     : out std_logic_vector(9 downto 0);
      DONE     : out std_logic);
  end component;

begin  -- Behavioral

  wea <= hdrwe when insel = 0 else
         '1'   when insel = 1 else
         '1';

  dia <= hdrdout when insel = 0 else
         NONCE   when insel = 1 else
         "000000000000000" & SUCCESS;

  addra <= hdraddr      when insel = 0 else
           "0000010110" when insel = 1 else
           "0000010111";

  DONE <= '1' when cs = dones else '0';

  outen    <= '1' when cs = pktout else '0';
  ARM      <= '1' when cs = armw   else '0';
  hdrstart <= '1' when cs = hdrst  else '0';
  udpheaderwriter_inst : udpheaderwriter
    port map (
      CLK      => CLK,
      SRCMAC   => SRCMAC,
      SRCIP    => SRCIP,
      DESTMAC  => DESTMAC,
      DESTIP   => DESTIP,
      DESTPORT => DESTPORT,
      START    => hdrstart,
      WLEN     => "0000000010",
      DOUT     => hdrdout,
      WEOUT    => hdrwe,
      ADDR     => hdraddr,
      DONE     => hdrdone);

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if cs = none then
        addrb   <= (others => '0');
      else
        if outen = '1' then
          addrb <= addrb + 1;
        end if;
      end if;

      DOEN <= outen;

    end if;

  end process main;

  fsm : process(cs, START, hdrdone, GRANT, addrb)
  begin
    case cs is
      when none =>
        insel <= 0;
        if START = '1' then
          ns  <= hdrst;
        else
          ns  <= none;
        end if;

      when hdrst =>
        insel <= 0;
        ns    <= hdrwait;

      when hdrwait =>
        insel <= 0;
        if hdrdone = '1' then
          ns  <= noncewr;
        else
          ns  <= hdrwait;
        end if;

      when noncewr =>
        insel <= 1;
        ns    <= sucwr;

      when sucwr =>
        insel <= 2;
        ns    <= armw;

      when armw =>
        insel <= 0;
        if GRANT = '1' then
          ns  <= pktout;
        else
          ns  <= armw;
        end if;

      when pktout =>
        insel <= 0;
        if addrb = "0000100000" then
          ns  <= dones;
        else
          ns  <= pktout;
        end if;

      when dones =>
        insel <= 0;
        ns    <= none;

      when others =>
        insel <= 0;
        ns    <= none;
    end case;

  end process fsm;

  rambuffer : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",
      INIT_00             => X"000000000000401100000000000045000800000000000000FFFFFFFFFFFF0000",
      INIT_01             => X"000000000000000000000000000000000000000000000000000013ec00000000"
      )


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
