library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;

entity eventtx is
  port (
    CLK : in std_logic;
    -- header fields

    MYMAC : in std_logic_vector(47 downto 0);
    MYIP  : in std_logic_vector(31 downto 0);
    MYBCAST : in std_logic_vector(31 downto 0); 
    -- event interface

    ECYCLE : in std_logic;
    EDTX   : in std_logic_vector(7 downto 0);
    EATX   : in std_logic_vector(somabackplane.N-1 downto 0);

    -- tx IF
    DOUT  : out std_logic_vector(15 downto 0);
    DOEN  : out std_logic;
    GRANT : in  std_logic;
    ARM   : out std_logic
    );

end eventtx;

architecture Behavioral of eventtx is


-- input side
  signal hdrstart, hdrdone : std_logic := '0';

  signal douthdr  : std_logic_vector(15 downto 0) := (others => '0');
  signal weouthdr : std_logic                     := '0';
  signal addrhdr  : std_logic_vector(9 downto 0)  := (others => '0');

  signal doutbody  : std_logic_vector(15 downto 0) := (others => '0');
  signal weoutbody : std_logic                     := '0';
  signal addrbody  : std_logic_vector(9 downto 0)  := (others => '0');

  signal ebdone : std_logic := '0';

  signal datalen : std_logic_vector(9 downto 0) := (others => '0');

  signal dia   : std_logic_vector(15 downto 0) := (others => '0');
  signal wea   : std_logic                     := '0';
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');

  signal osel : std_logic := '0';

  signal dataaddr : std_logic_vector(9 downto 0) := (others => '0');

  signal nbsel, bsel : std_logic := '0';

  signal nextbuf : std_logic := '0';

  signal ecnt : std_logic_vector(15 downto 0) := (others => '0');


  signal wea1, wea2 : std_logic := '0';
  
  type instates is (none, sendchk, hdrs, hdrw, flipbuf);
  signal ics, ins : instates := none;

  -- output side

  signal dob : std_logic_vector(15 downto 0) := (others => '0');
  signal dob1, dob2 : std_logic_vector(15 downto 0) := (others => '0');
  
  signal olen : std_logic_vector(15 downto 0) := (others => '0');

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal outen : std_logic := '0';

  type outstates is (none, armw, pktout, done);
  signal ocs, ons : outstates := none;

  -- components
  component eventheaderwriter
    port (
      CLK   : in  std_logic;
      MYMAC : in  std_logic_vector(47 downto 0);
      MYIP  : in  std_logic_vector(31 downto 0);
      MYBCAST : in std_logic_vector(31 downto 0); 
      START : in  std_logic;
      WLEN  : in  std_logic_vector(9 downto 0);
      DOUT  : out std_logic_vector(15 downto 0);
      WEOUT : out std_logic;
      ADDR  : out std_logic_vector(9 downto 0);
      DONE  : out std_logic);
  end component;

  component eventbodywriter
    port (
      CLK    : in  std_logic;
      ECYCLE : in  std_logic;
      EDTX   : in  std_logic_vector(7 downto 0);
      EATX   : in  std_logic_vector(somabackplane.N-1 downto 0);
      DONE   : out std_logic;
      DOUT   : out std_logic_vector(15 downto 0);
      WEOUT  : out std_logic;
      ADDR   : out std_logic_vector(9 downto 0));
  end component;




begin  -- Behavioral

  eventheaderwriter_inst : eventheaderwriter
    port map (
      CLK   => CLK,
      MYMAC => MYMAC,
      MYIP  => MYIP,
      MYBCAST => MYBCAST, 
      START => hdrstart,
      WLEN  => datalen,
      DOUT  => douthdr,
      WEOUT => weouthdr,
      ADDR  => addrhdr,
      DONE  => hdrdone);

  eventbodywriter_inst : eventbodywriter
    port map (
      CLK    => CLK,
      ECYCLE => ECYCLE,
      EDTX   => EDTX,
      EATX   => EATX,
      DONE   => ebdone,
      DOUT   => doutbody,
      WEOUT  => weoutbody,
      ADDR   => addrbody);

  -- combinationals, input side

  dia               <= douthdr  when osel = '0' else doutbody;
  wea               <= weouthdr when osel = '0' else weoutbody;
  wea1 <= wea and bsel;
  wea2 <= wea and nbsel;
  
  addra <= addrhdr  when osel = '0' else (dataaddr + "0000010110");


  dataaddr <= addrbody + datalen;
  nbsel    <= not bsel;

  main_input : process(CLK)
  begin
    if rising_edge(CLK) then
      ics <= ins;

      if nextbuf = '1' then
        bsel <= nbsel;
      end if;

      if nextbuf = '1' then
        datalen   <= (others => '0');
      else
        if ics = sendchk then
          datalen <= dataaddr;
        end if;
      end if;

      if nextbuf = '1' then
        ecnt   <= (others => '0');
      else
        if ebdone = '1' then
          ecnt <= ecnt + 1;
        end if;
      end if;


    end if;
  end process main_input;


  outen    <= '1' when ocs = pktout else '0';
  ARM      <= '1' when ocs = armw   else '0';
  dob <= dob1 when nbsel = '1' else dob2;
  
  DOUT <= dob; 
  main_output : process(CLK)
  begin
    if rising_edge(CLK) then
      ocs <= ons;

      if ocs = armw then
        olen <= dob;
      end if;

      DOEN <= outen;

      if ocs = none then
        addrb <= (others => '0');
      else
        if outen = '1' then
          addrb <= addrb + 1;
        end if;
      end if;

    end if;
  end process main_output;


  input_fsm : process(ics, ebdone, ecnt, dataaddr, hdrdone)
  begin
    case ics is
      when none =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel <= '1'; 
        if ebdone = '1' then
          ins    <= sendchk;
        else
          ins    <= none;
        end if;

      when sendchk =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel <= '1'; 
        if ecnt = 5 or dataaddr > "0001100100" then
          ins    <= hdrs;
        else
          ins    <= none;
        end if;

      when hdrs =>
        nextbuf  <= '0';
        hdrstart <= '1';
        osel <= '0'; 
        ins      <= hdrw;
      when hdrw =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel <= '0'; 
        if hdrdone = '1' then
          ins    <= flipbuf;
        else
          ins    <= hdrw;
        end if;

      when flipbuf =>
        nextbuf  <= '1';
        hdrstart <= '0';
        osel <= '1'; 
        ins      <= none;

      when others =>
        nextbuf  <= '0';
        hdrstart <= '0';
        osel <= '1'; 
        ins      <= none;
    end case;
  end process input_fsm;


  output_fsm : process(ocs, nextbuf, GRANT, olen, addrb)
  begin
    case ocs is
      when none =>
        if nextbuf = '1' then
          ons <= armw;
        else
          ons <= none;
        end if;

      when armw =>
        if grant = '1' then
          ons <= pktout;
        else
          ons <= armw;
        end if;

      when pktout =>
        if olen(10 downto 1) -1  = addrb then
          ons <= done;
        else
          ons <= pktout;
        end if;

      when done   =>
        ons <= none;
      when others =>
        ons <= none;
    end case;
  end process output_fsm;

rambuffer1 : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",     -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- The follosing INIT_xx declarations specify the intiial contents of the RAM
      -- Address 0 to 255
      INIT_00             => X"000000000000401100000000000045000800000000000000FFFFFFFFFFFF0000",
      INIT_01             => X"00000000000000000000000000000000000000000000000013889c4000000000"
)

    port map (
      DOA                 => open,
      DOB                 => dob1,
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => dia,
      DIB                 => X"0000",
      DIPA                => "00",
      DIPB                => "00",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => wea1,
      WEB                 => '0'
      );

  rambuffer2 : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "GENERATE_X_ONLY",     -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- The follosing INIT_xx declarations specify the intiial contents of the RAM
      -- Address 0 to 255
      INIT_00             => X"000000000000401100000000000045000800000000000000FFFFFFFFFFFF0000",
      INIT_01             => X"00000000000000000000000000000000000000000000000013889c4000000000"
)

    port map (
      DOA                 => open,
      DOB                 => dob2,
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => dia,
      DIB                 => X"0000",
      DIPA                => "00",
      DIPB                => "00",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => wea2,
      WEB                 => '0'
      );

end Behavioral;
