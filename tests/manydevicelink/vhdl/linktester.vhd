-------------------------------------------------------------------------------
-- Title      : linktester
-- Project    : 
-------------------------------------------------------------------------------
-- File       : linktester.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/03/05
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: a loopback data tester
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/03/04  1.0      jonas   Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity linktester is

  port (
    CLK          : in  std_logic;
    RXBITCLK     : in  std_logic;
    TXHBITCLK    : in  std_logic;
    TXHBITCLK180 : in  std_logic;
    RESET        : in  std_logic;
    TXIO_P       : out std_logic;
    TXIO_N       : out std_logic;
    RXIO_P       : in  std_logic;
    RXIO_N       : in  std_logic;
    VALID        : out std_logic
    );

end linktester;


architecture Behavioral of linktester is
  signal din, dout : std_logic_vector(7 downto 0) := (others => '0');
  signal kin, kout : std_logic                    := '0';


  signal outcnt : std_logic_vector(8 downto 0) := (others => '0');
  signal bin1   : std_logic_vector(7 downto 0) := (others => '0');
  signal bin2   : std_logic_vector(7 downto 0) := (others => '0');
  signal kin1   : std_logic                    := '0';
  signal kin2   : std_logic                    := '0';

  signal locked : std_logic := '0';


  component coredevicelink
    generic ( N    :     integer := 0);
    port (
      CLK          : in  std_logic;
      RXBITCLK     : in  std_logic;
      TXHBITCLK    : in  std_logic;
      TXHBITCLK180 : in  std_logic;
      RESET        : in  std_logic;
      TXDIN        : in  std_logic_vector(7 downto 0);
      TXKIN        : in  std_logic;
      TXIO_P       : out std_logic;
      TXIO_N       : out std_logic;
      RXIO_P       : in  std_logic;
      RXIO_N       : in  std_logic;
      RXDOUT       : out std_logic_vector(7 downto 0);
      RXKOUT       : out std_logic;
      DROPLOCK     : in  std_logic;
      LOCKED       : out std_logic
      );

  end component;

begin  -- Behavioral

  devicelink_inst : coredevicelink
    generic map (
      N            => 10)
    port map (
      CLK          => CLK,
      RXBITCLK     => RXBITCLK,
      TXHBITCLK    => TXHBITCLK,
      TXHBITCLK180 => TXHBITCLK180,
      RESET        => RESET,
      TXDIN        => dout,
      TXKIN        => kout,
      TXIO_P       => TXIO_P,
      TXIO_N       => TXIO_N,
      RXIO_P       => RXIO_P,
      RXIO_N       => RXIO_N,
      RXDOUT       => din,
      RXKOUT         => kin,
      DROPLOCK     => '0',
      LOCKED       => locked);

  output : process(CLK)
  begin
    if rising_edge(CLK) then
      if outcnt = "100000000" then
        dout   <= X"BC";
        kout   <= '1';
        outcnt <= (others => '0');
      else
        dout   <= outcnt(7 downto 0);
        kout   <= '0';
        outcnt <= outcnt + 1;
      end if;
    end if;
  end process output;


  input : process(CLK)
  begin
    if rising_edge(CLK) then
      if locked = '0' then
        VALID <= '0';
      else
        bin1  <= din;
        bin2  <= bin1;

        kin1 <= kin;
        kin2 <= kin1;

        if kin2 = '1' and bin2 = X"BC" and
          kin1 = '0' and bin1 = X"00" then
          VALID <= '1';
        elsif kin2 = '0' and bin2 = X"FF" and
          kin1 = '1' and bin1 = X"BC" then
          VALID <= '1';
        elsif kin2 = '0' and kin1 = '0' and bin2 -1 = bin1 then
          VALID <= '1';
        else
          VALID <= '0';
        end if;

      end if;

    end if;

  end process input;

end Behavioral;
