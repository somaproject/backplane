library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

entity eventtx is
  port (
    CLK : in std_logic;
    -- header fields

    MYMAC : in std_logic_vector(47 downto 0);
    MYIP  : in std_logic_vector(31 downto 0);
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
  signal addrhdr  : std_logic_vector(8 downto 0)  := (others => '0');

  signal doutbody  : std_logic_vector(15 downto 0) := (others => '0');
  signal weoutbody : std_logic                     := '0';
  signal addrbody  : std_logic_vector(8 downto 0)  := (others => '0');

  signal ebdone : std_logic := '0';

  signal datalen : std_logic_vector(8 downto 0) := (others => '0');

  signal dia   : std_logic_vector(15 downto 0) := (others => '0');
  signal wea   : std_logic                     := '0';
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');

  signal osel : std_logic := '0';

  signal dataaddr : std_logic_vector(8 downto 0) := (others => '0');

  signal nbsel, bsel : std_logic := '0';

  signal nextbuf : std_logic := '0';

  signal ecnt : std_logic_vector(15 downto 0) := (others => '0');

  type instates is (none, sendchk, hdrs, hdrw, flipbuf);
  signal ics, ncs : instates := none;

  -- output side

  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  signal olen : std_logic_vector(15 downto 0) := (others => '0');

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal outen : std_logic := '0';


  -- components
  component eventheaderwriter
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
      ADDR   : out std_logic_vector(8 downto 0));
  end component;




begin  -- Behavioral

  eventheaderwriter_inst : eventheaderwriter
    port map (
      CLK   => CLK,
      MYMAC => MYMAC,
      MYIP  => MYIP,
      START => hdrstart,
      WLEN  => datalen,
      DOUT  => douthdr,
      WEOUT => weouthdr,
      ADDR  => addrhdr,
      DONE  => hdrdone);

  eventbodywriter_inst : eventboydwriter
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
  addra(8 downto 0) <= addrhdr  when osel = '0' else dataaddr;
  addr(9)           <= nbsel;

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


  outen <= '1' when ocs = pktout else '0';
  addrb(9) <= bsel;
  ARM <= '1' when ocs = armw else '0';

  
  main_output: Process(CLK)
    begin
      if rising_edge(CLK) then
        ocs <= ons;

        if ocs = none then
          olen <= dob; 
        end if;
        
        DOEN <= outen;

        if ocs = none then
          addrb(8 downto 0)  <= (others => '0');
        else
          if outen = '1' then
            addrb <= addrb + 1; 
          end if;
        end if;

      end if;
    end process main_output; 


    input_fsm: process(ics, ebdone, ecnt5, dataddr, hdrdone)
      begin
        case ics is
          when none =>
            nextbuf <= '0';
            hdrstart <= '0';
            if ebdone = '1'  then
              ons <= sendchk;
            else
              ons <= none; 
            end if;

          when sendchk =>
            nextbuf <= '0';
            hdrstart <= '0';
            if ecnt = 5 or dataaddr > "010000000" then
              ons <= hdrs; 
            else
              ons <= none;  
            end if;

          when hdrs =>
            nextbuf <= '0';
            hdrstart <= '1';
            ons <= hdrw;
          when hdrw =>
            nextbuf <= '0';
            hdrstart <= '0';
            if hdrdone = '1' then
              ons <= flipbuf;
            else
              ons <= hdrw; 
            end if;

          when flipbuf =>
            nextbuf <= '1';
            hdrstart <= '0';
            ons <= none;
            
          when others =>
            nextbuf <= '0';
            hdrstart <= '0';
            ons <= none;
        end case;
      end process input_fsm;

      
end Behavioral;
