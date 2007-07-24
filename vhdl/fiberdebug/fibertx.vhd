library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity fibertx is
  port ( CLK      : in  std_logic;
         CMDIN    : in  std_logic_vector(47 downto 0);
         SENDCMD  : in  std_logic;
         FIBEROUT : out std_logic);

end fibertx;

architecture Behavioral of fibertx is

  signal cmdinl  : std_logic_vector(47 downto 0) := (others => '0');
  signal cmdinll : std_logic_vector(47 downto 0) := (others => '0');
  signal cmdinlll : std_logic_vector(47 downto 0) := (others => '0');

  signal sendcmdl : std_logic := '0';

  signal outbyte, clk8 : std_logic                    := '0';
  signal outbytepos    : std_logic_vector(3 downto 0) := (others => '0');
  signal clk8pos       : std_logic_vector(3 downto 0) := (others => '0');

  signal bytein : std_logic_vector(7 downto 0) := (others => '0');

  signal modesel : integer range 0 to 3 := 0;

  signal din, dinl : std_logic_vector(7 downto 0) := (others => '0');

  signal bytesel    : integer range 0 to 7 := 0;
  signal byteselrst : std_logic            := '0';

  -- output-related signals

  signal kin, sout     : std_logic                    := '0';
  signal dout, doutreg : std_logic_vector(9 downto 0) := (others => '0');

  type states is (none, cmdlat, sendk, sendb, done);
  signal cs, ns : states := none;


  component encode8b10b
    port (
      din  : in  std_logic_vector(7 downto 0);
      kin  : in  std_logic;
      clk  : in  std_logic;
      dout : out std_logic_vector(9 downto 0);
      ce   : in  std_logic);
  end component;

begin

  bytein <= cmdinlll(7 downto 0)   when bytesel = 0 else
            cmdinlll(15 downto 8)  when bytesel = 1 else
            cmdinlll(23 downto 16) when bytesel = 2 else
            cmdinlll(31 downto 24) when bytesel = 3 else
            cmdinlll(39 downto 32) when bytesel = 4 else
            cmdinlll(47 downto 40) when bytesel = 5; 

  din <= bytein when modesel = 0 else
         X"BC"  when modesel = 1 else
         X"00";

  sout <= doutreg(0);

  encoder : encode8b10b port map (
    DIN  => dinl,
    KIN  => kin,
    CE   => outbyte,
    DOUT => dout,
    CLK  => CLK);

  clock : process( CLK) is
  begin
    if rising_edge(CLK) then
      cs <= ns;

      sendcmdl <= sendcmd;
      cmdinl   <= CMDIN;
      cmdinll <= cmdinl; 
      
      if cs = cmdlat then
        cmdinlll <= cmdinll;
      end if;

      -- timing
      if clk8pos = "1001" then
        clk8pos <= (others => '0');
      else
        clk8pos <= clk8pos + 1;
      end if;

      if clk8pos = "0000" then
        clk8 <= '1';
      else
        clk8 <= '0';
      end if;

      if clk8 = '1' then
        if outbytepos = "1001" then
          outbytepos <= (others => '0');
        else
          outbytepos <= outbytepos + 1;
        end if;
      end if;

      if clk8 = '1' and outbytepos = "0000" then
        outbyte <= '1';
      else
        outbyte <= '0';
      end if;

      if cs = sendk then
        bytesel     <= 0;
      else
        if outbyte = '1' and cs = sendb then
          if bytesel = 7 then
            bytesel <= 0;
          else
            bytesel <= bytesel + 1;
          end if;
        end if;
      end if;


      -- outbyte-related

      if outbyte = '1' then
        dinl  <= din;
        if modesel = 1 then
          kin <= '1';
        else
          kin <= '0';
        end if;
      end if;

      if outbyte = '1' then
        doutreg   <= dout;
      else
        if clk8 = '1' then
          doutreg <= '0' & doutreg(9 downto 1);
        end if;
      end if;

      if clk8 = '1' then
        FIBEROUT <= sout;
      end if;

    end if;

  end process clock;


  fsm : process(cs, sendcmdl, outbyte, bytesel)
  begin
    case cs is
      when none =>
        modesel <= 2;
        if sendcmdl = '1' then
          ns    <= cmdlat;
        else
          ns    <= none;
        end if;

      when cmdlat =>
        modesel <= 2;
        ns      <= sendk;

      when sendk =>
        modesel <= 1;
        if outbyte = '1' then
          ns    <= sendb;
        else
          ns    <= sendk;
        end if;

      when sendb =>
        modesel <= 0;
        if outbyte = '1' and bytesel = 5 then
          ns    <= done;
        else
          ns    <= sendb;
        end if;

      when done =>
        modesel <= 0;
        ns      <= none;

      when others =>
        modesel <= 0;
        ns      <= none;

    end case;

  end process fsm;

end Behavioral;
