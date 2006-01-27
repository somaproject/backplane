library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity recover is
  port ( CLKIN    : in  std_logic;
         RESET    : in  std_logic;
         DIN      : in  std_logic;
         DOUT     : out std_logic;
         LEDERROR : out std_logic;
         LEDVALID : out std_logic;
         LEDPOWER : out std_logic
         );

end recover;

architecture Behavioral of recover is

  -- clocks
  signal txclk     : std_logic := '0';
  signal rxclk     : std_logic := '0';
  signal txbyteclk : std_logic := '0';
  signal rxclk90   : std_logic := '0';
  signal rxbyteclk : std_logic := '0';

  -- TX side
  signal txdin : std_logic_vector(7 downto 0) := (others => '0');
  signal txkin : std_logic                    := '0';

  signal addra : std_logic_vector(10 downto 0) := (others => '0');

  -- RX side:
  signal addrb        : std_logic_vector(10 downto 0) := (others => '0');
  signal dopb, rxkout : std_logic                     := '0';
  signal dob, rxdout  : std_logic_vector(7 downto 0)  := (others => '0');

  signal errors, scorrect, sincorrect : std_logic := '0';
  signal scl, scll                    : std_logic := '0';

  signal cnt : std_logic_vector(21 downto 0) := (others => '0');

  component serialrx
    port ( RXCLK     : in  std_logic;
           RXCLK90   : in  std_logic;
           RXBYTECLK : in  std_logic;
           RESET     : in  std_logic;
           DIN       : in  std_logic;
           DOUT      : out std_logic_vector(7 downto 0);
           KOUT      : out std_logic;
           ERR       : out std_logic;
           DOEN      : out std_logic
           );

  end component;

  component serialtx
    port ( TXBYTECLK : in  std_logic;
           TXCLK     : in  std_logic;
           DIN       : in  std_logic_vector(7 downto 0);
           K         : in  std_logic;
           DOUT      : out std_logic
           );

  end component;

  component ioclocks
    port ( CLKIN     : in  std_logic;
           RESET     : in  std_logic;
           TXCLK     : out std_logic;
           TXBYTECLK : out std_logic;
           RXCLK     : out std_logic;
           RXBYTECLK : out std_logic;
           RXCLK90   : out std_logic
           );

  end component;


begin  -- Behavioral
  bytestreamram : RAMB16_S9_S9
    generic map (
      INIT_A  => X"000",
      INIT_B  => X"000",
      SRVAL_A => X"000",
      SRVAL_B => X"000")
    port map (
      DOA     => txdin,
      DOB     => dob,
      DOPA    => txkin,
      DOPB    => dopb,
      ADDRA   => addra,
      ADDRB   => addrb,
      CLKA    => txbyteclk,
      CLKB    => rxbyteclk,
      DIA     => X"00",
      DIB     => X"00",
      DIPA    => '0',
      DIPB    => '0',
      ENA     => '1',
      ENB     => '1',
      SSRA    => RESET,
      SSRB    => RESET,
      WEA     => '0',
      WEB     => '0'  );

  serialrxdev : serialrx
    port map (
      RXCLK     => RXCLK,
      RXCLK90   => RXCLK90,
      RXBYTECLK => RXBYTECLK,
      RESET     => RESET,
      DIN       => DIN,
      DOUT      => rxdout,
      KOUT      => rxkout,
      ERR       => rxerr,
      DOEN      => rxdoen);


  serialtxdev : serialtx
    port map (
      TXBYTECLK => TXBYTECLK,
      TXCLK     => TXCLK,
      DIN       => txdin,
      K         => txkin,
      DOUT      => DOUT);


  clocks : ioclocks
    port map (
      CLKIN     => CLKIN,
      RESEt     => RESET,
      TXCLK     => txclk,
      TXBYTECLK => txbyteclk,
      RXCLK     => rxclk,
      RXBYTECLK => rxbyteclk,
      RXCLK90   => rxclk90);



  -- combinational rx signals
  errors     <= rxdoen and rxerr;
  valids     <= rxdoen and not rxerr;
  symbeq     <= '1' when rxkout = dopb and rxdout = dob;
  scorrect   <= symbeq and valids;
  sincorrect <= (not symbeq) and valids;


  -- tx sequential
  txsequential : process (txbyteclk)
  begin
    if rising_edge(txbyteclk) then
      addra <= addra + 1;
    end if;
  end process txsequential;

  -- rx sequential
  rxsequential : process (CLK, RESET)
  begin  -- process rxsequential
    if RESET = '1' then

    else
      if rising_edge(rxbyteclk) then

        LEDERROR <= errors;
        LEDVALID <= scll;
        LEDPOWER <= cnt(0);

        -- ADDRB counter
        if errors = '1' then
          addrb   <= (others => '0');
        else
          if scorrect = '1' then
            addrb <= addrb + 1;
          end if;
        end if;

        -- output
        if cnt = "0000000000000000000000" then
          scl   <= '0';
          scll  <= scl;
        else
          if sincorrect = '1' then
            scl <= '1';
          end if;
        end if;

        cnt <= cnt + 1;

      end if;
    end if;
  end process rxsequential;






end Behavioral;
