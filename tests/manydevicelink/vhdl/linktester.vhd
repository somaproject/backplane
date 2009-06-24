-----------------------------------------------------------------------------
-- Title      : linktester
-- Project    : 
-----------------------------------------------------------------------------
-- File       : linktester.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2009-06-23
-- Platform   : 
-----------------------------------------------------------------------------
-- Description: a loopback data tester
-----------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/03/04  1.0      jonas   Created
-----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity linktester is

  port (
    CLK        : in  std_logic;
    RXBITCLK   : in  std_logic;
    RXWORDCLK  : in  std_logic;
    TXHBITCLK  : in  std_logic;
    TXWORDCLK  : in  std_logic;
    RESET      : in  std_logic;
    AUTOLINK : in std_logic; 
    ATTEMPTLINK : in std_logic; 
    TXIO_P     : out std_logic;
    TXIO_N     : out std_logic;
    RXIO_P     : in  std_logic;
    RXIO_N     : in  std_logic;
    VALID      : out std_logic;
    LOCKED     : out std_logic;
    DEBUGSTATE : out std_logic_vector(7 downto 0);
    DEBUGADDR : in std_logic_vector(7 downto 0); 
    DEBUGVALUE : out std_logic_vector(15 downto 0)
    );

end linktester;


architecture Behavioral of linktester is
  signal din, dout : std_logic_vector(7 downto 0) := (others => '0');
  signal kin, kout : std_logic                    := '0';

  signal dinl         : std_logic_vector(7 downto 0) := (others => '0');
  signal dinll        : std_logic_vector(7 downto 0) := (others => '0');
  signal rxdata_valid : std_logic                    := '0';

  signal outcnt : std_logic_vector(7 downto 0) := (others => '0');
  signal bin1   : std_logic_vector(7 downto 0) := (others => '0');
  signal bin2   : std_logic_vector(7 downto 0) := (others => '0');
  signal kin1   : std_logic                    := '0';
  signal kin2   : std_logic                    := '0';

  signal llocked : std_logic := '0';

  signal rxdouten : std_logic := '0';

  component coredevicelink
    generic (N            : integer := 0;
             DCNTMAX      : integer := 220000000;
             DROPDURATION : integer := 200000000;
             SYNCDURATION : integer := 200000000;
             LOCKABORT    : integer :=  1000000
             );
    port (
      CLK         : in std_logic;
      RXBITCLK    : in std_logic;
      RXWORDCLK   : in std_logic;
      TXHBITCLK   : in std_logic;
      TXWORDCLK   : in std_logic;
      RESET       : in std_logic;
      AUTOLINK    : in std_logic := '1';
      ATTEMPTLINK : in std_logic := '0';

      TXDIN     : in  std_logic_vector(7 downto 0);
      TXKIN     : in  std_logic;
      TXIO_P    : out std_logic;
      TXIO_N    : out std_logic;
      RXIO_P    : in  std_logic;
      RXIO_N    : in  std_logic;
      RXDOUT    : out std_logic_vector(7 downto 0);
      RXDOUTEN  : out std_logic;
      RXKOUT    : out std_logic;
      DROPLOCK  : in  std_logic;
      LOCKED    : out std_logic;
      DEBUGADDR : in  std_logic_vector(7 downto 0);
      DEBUG     : out std_logic_vector(15 downto 0);
      DEBUGSTATEOUT : out std_logic_vector(7 downto 0)

      );

  end component;

  signal txen : std_logic := '0';
  
begin  -- Behavioral

  devicelink_inst : coredevicelink
    generic map (
      N       => 4)
    port map (
      CLK         => CLK,
      RXBITCLK    => RXBITCLK,
      RXWORDCLK   => RXWORDCLK,
      TXHBITCLK   => TXHBITCLK,
      TXWORDCLK   => TXWORDCLK,
      RESET       => RESET,
      AUTOLINK    => AUTOLINK,
      ATTEMPTLINK => ATTEMPTLINK,
      TXDIN       => dout,
      TXKIN       => kout,
      TXIO_P      => TXIO_P,
      TXIO_N      => TXIO_N,
      RXIO_P      => RXIO_P,
      RXIO_N      => RXIO_N,
      RXDOUT      => din,
      RXKOUT      => kin,
      RXDOUTEN    => rxdouten,
      DROPLOCK    => '0',
      LOCKED      => llocked,
      DEBUGADDR   => debugaddr,
      DEBUG       => DEBUGVALUE,
      DEBUGSTATEOUT => debugstate); 

  output : process(CLK)
  begin
    if rising_edge(CLK) then
      txen <= not txen;
      if txen = '1' then                -- only send every other tick
        dout   <= outcnt;
        kout   <= '0';
        outcnt <= outcnt + 1;
        
      end if;

    end if;
  end process output;

  input : process(CLK)
  begin
    if rising_edge(CLK) then

      if rxdouten = '1' then
        dinl  <= din;
        dinll <= dinl;
      end if;

      if dinl = dinll + 1 then
        rxdata_valid <= '1';
      else
        rxdata_valid <= '0';
      end if;

      if llocked = '1' and rxdata_valid = '1' then
        VALID <= '1';
      else
        VALID <= '0';
      end if;

      LOCKED <= llocked;

    end if;

  end process input;

end Behavioral;
