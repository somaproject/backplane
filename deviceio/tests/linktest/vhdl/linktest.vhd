library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity linktest is
  port ( CLKIN_P    : in  std_logic;
         CLKIN_N    : in  std_logic;
         RESET      : in  std_logic;
-- DIN_P : in std_logic;
-- DIN_N : in std_logic;
-- DOUT_P : out std_logic;
-- DOUT_N : out std_logic;
         DOUT       : out std_logic;
         DIN        : in  std_logic;
         LEDGOOD    : out std_logic;
         LEDVALID   : out std_logic;
         LEDPOWER   : out std_logic;
         DEBUGDOUT  : out std_logic;
         DEBUGOCLK  : out std_logic;
         DEBUGFSOUT : out std_logic;
         VALIDOUT   : out std_logic

         );

end linktest;

architecture Behavioral of linktest is

  -- io
  --signal din, dout : std_logic := '0';
  signal clkin : std_logic := '0';

  -- clocks
  signal txclk     : std_logic := '0';
  signal rxclk     : std_logic := '0';
  signal txbyteclk : std_logic := '0';
  signal rxclk90   : std_logic := '0';
  signal rxbyteclk : std_logic := '0';

  -- TX side
  signal txdin : std_logic_vector(7 downto 0) := (others => '0');
  signal txkin : std_logic                    := '0';

  signal addra : std_logic_vector(7 downto 0) := (others => '0');

  -- RX side:
  signal addrb : std_logic_vector(7 downto 0) := (others => '0');

  signal rxkout : std_logic                    := '0';
  signal rxdout : std_logic_vector(7 downto 0) := (others => '0');

  signal errors, scorrect, valids, sincorrect : std_logic := '0';
  signal scl, scll                            : std_logic := '0';

  signal symbeq : std_logic := '0';

  signal lgood, valid : std_logic := '0';

  signal rxdoen, rxerr : std_logic                     := '0';
  signal brst          : std_logic                     := '0';
  signal cnt           : std_logic_vector(21 downto 0) := (others => '0');


  component ioclocks
    port ( CLKIN     : in  std_logic;
           RESET     : in  std_logic;
           TXCLK     : out std_logic;
           TXBYTECLK : out std_logic;
           RXCLK     : out std_logic;
           RXBYTECLK : out std_logic;
           RXCLK90   : out std_logic;
           LOCKED    : out std_logic
           );

  end component;


  component sample
    port ( CLK   : in  std_logic;
           CLK90 : in  std_logic;
           DIN   : in  std_logic;
           DOUT  : out std_logic_vector(3 downto 0)
           );

  end component;

  component datamux
    port ( CLK  : in  std_logic;
           BIN  : in  std_logic_vector(3 downto 0);
           DOEN : out std_logic;
           DOUT : out std_logic
           );

  end component;


  component tinyscope
    port ( CLKIN  : in  std_logic;
           RESET  : in  std_logic;
           CLKOUT : in  std_logic;
           DIN    : in  std_logic_vector(7 downto 0);
           DOUT   : out std_logic;
           OCLK   : out std_logic;
           FSOUT  : out std_logic
           );

  end component;

  signal intbits, intbitsl, intbitsll : std_logic_vector(3 downto 0) := (others => '0');

  signal ioclocks_locked : std_logic := '0';

  signal dvalid, rxdata : std_logic := '0';

  signal testreg : std_logic_vector(31 downto 0) := X"F0F070F0"; -- X"1F1F0F51";

  signal pendingword, targetword1, targetword2, targetword3, targetword4 : std_logic_vector(31 downto 0) := (others => '0');

  signal scopedata : std_logic_vector(7 downto 0) := (others => '0');

begin

  tinyscopeinst : tinyscope
    port map (
      CLKIN  => rxclk,
      RESET  => RESET,
      CLKOUT => RXBYTECLK,
      DIN    => scopedata,
      DOUT   => DEBUGDOUT,
      OCLK   => DEBUGOCLK,
      FSOUT  => DEBUGFSOUT);

  ioclocksinst : ioclocks
    port map (
      CLKIN     => CLKIN,
      RESET     => RESET,
      TXCLK     => txclk,
      RXCLK     => rxclk,
      RXBYTECLK => RXBYTECLK,
      RXCLK90   => rxclk90,
      LOCKED    => ioclocks_locked);

  sampleinst : sample
    port map (
      DIN   => din,
      CLK   => rxclk,
      CLK90 => rxclk90,
      DOUT  => intbits);

  datamuxinst : datamux
    port map (
      CLK  => rxclk,
      BIN  => intbits,
      DOEN => dvalid,
      DOUT => rxdata);


-- DIN_obufds : OBUFDS
-- generic map (
-- IOSTANDARD => "DEFAULT")
-- port map (
-- O => DOUT_P,
-- OB => DOUT_N,
-- I => DOUT
-- );


-- DIN_ibufds : IBUFDS
-- generic map (
-- IOSTANDARD => "DEFAULT")
-- port map (
-- I => DIN_P,
-- IB => DIN_N,
-- O => DIN
-- );

  CLKIN_ibufds : IBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      I          => CLKIN_P,
      IB         => CLKIN_N,
      O          => CLKIN
      );


  -- Transmit
  --
  process (txclk)
  begin
    if rising_edge(txclk) then
      testreg <= testreg(0) & testreg(31 downto 1);
      dout    <= testreg(0);

    end if;
  end process;


--SAMPLES <= "0000";



  LEDPOWER <= '1';

  LEDGOOD <= '1';



  verify            : process(rxclk)
    variable bitcnt : integer range 0 to 31 := 0;
  begin
    if rising_edge(rxclk) then



      if dvalid = '1' then
        pendingword <= rxdata & pendingword(31 downto 1);


        if bitcnt = 31 then
          bitcnt := 0;
        else
          bitcnt := bitcnt +1;
        end if;

        if bitcnt = 31 then
          targetword1 <= pendingword;

        end if;

      end if;
      intbitsl  <= intbits;
      intbitsll <= intbitsl;

      targetword2 <= targetword1;
      targetword3 <= targetword2;
      targetword4 <= targetword3;

      if targetword4 = targetword3 then
        valid <= '1';
      else
        valid <= '0';
      end if;


      LEDVALID <= valid;
      VALIDOUT <= valid;
-- config for normal output

-- configuration for quad bits output


      scopedata(3 downto 0) <= intbitsll;
      scopedata(4)          <= '0';
      scopedata(5)          <= '1';

      scopedata(6) <= dvalid;
      scopedata(7) <= rxdata;

    end if;



  end process;


end Behavioral;
