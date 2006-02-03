library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity linktest is
  port ( CLKIN    : in  std_logic;
         RESET    : in  std_logic;
--           DIN_P      : in  std_logic;
--           DIN_N      : in  std_logic;         
--           DOUT_P     : out std_logic;
--           DOUT_N     : out std_logic;         
         LEDGOOD : out std_logic;
         LEDVALID : out std_logic;
         LEDPOWER : out std_logic
         );

end linktest;

architecture Behavioral of linktest is

  -- io
  signal din, dout : std_logic := '0';
  
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



--     DIN_obufds : OBUFDS
--     generic map (
--        IOSTANDARD => "DEFAULT")
--     port map (
--        O =>  DOUT_P,  
--        OB => DOUT_N,  
--        I => DOUT   
--     );

  
--     DIN_ibufds : IBUFDS
--     generic map (
--        IOSTANDARD => "DEFAULT")
--     port map (
--        I => DIN_P,
--        IB =>DIN_N,
--        O => DIN   
--     );

  DIN <= DOUT; 
  -- Transmit
  --
  txdin     <= X"BC" when addra = X"00" else addra;
  txkin     <= '1'   when addra = X"00" else '0';
  txsequential : process (txbyteclk)
  begin
    if rising_edge(txbyteclk) then
      addra <= addra + 1;
    end if;
  end process txsequential;

  -- rx sequential
  brst <= '1' when rxkout = '1' and rxdout = X"BC" and rxdoen = '1' and rxerr = '0' else '0';


  rxsequential : process (rxbyteclk, RESET)
  begin  -- process rxsequential
    if RESET = '1' then

    else
      if rising_edge(rxbyteclk) then


        if valid = '0' then
          lgood <= '0';
        else
          if cnt = "0000000000000000000000" then
            lgood <= '1'; 
          end if;
        end if;

        if cnt = "1111111111111111111111" then
          cnt <= (others => '0');
        else
          cnt <= cnt + 1; 
        end if;

        LEDGOOD <= lgood; 
        LEDPOWER <= cnt(21);
        LEDVALID <= valid;
        
        -- ADDRB counter
        if brst = '1' then
          addrb   <= X"01";
        else
          if rxdoen = '1' and rxerr = '0' then
            addrb <= addrb + 1;
          end if;
        end if;
        
        if RXDOEN = '1' or RXERR = '1' then
          if (brst = '1' or addrb = rxdout ) and rxerr = '0' then
            valid <= '1';
          else
            valid <= '0';
          end if;
        end if;
      end if;
    end if;
  end process rxsequential;






end Behavioral;
