library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;


entity bootspiio is
  port (
    CLK     : in  std_logic;
    CURBYTE : out std_logic_vector(10 downto 0);
    DOUT    : out std_logic_vector(15 downto 0);
    DIN     : in  std_logic_vector(15 downto 0);
    ADDR    : in  std_logic_vector(9 downto 0);
    WE      : in  std_logic;
    CMDDONE : out std_logic := '0';
    CMDREQ  : in  std_logic;
    -- SPI INTERFACE
    CLKHI   : in  std_logic;
    SPIMOSI : in  std_logic := '0'; 
    SPIMISO : out std_logic := '0';
    SPICS   : in  std_logic;
    SPICLK  : in  std_logic);

end bootspiio;

architecture Behavioral of bootspiio is

  signal wea, weal, weall : std_logic := '0';

  signal spimosil : std_logic := '0';
  signal lspimiso : std_logic := '0';
  signal spicsl   : std_logic := '0';
  signal spicsll  : std_logic := '0';

  signal spiclkl  : std_logic := '0';
  signal spiclkll : std_logic := '0';

  signal cmdreql : std_logic := '0';
  signal lspireq : std_logic := '0';
  signal spireq : std_logic := '0';

  signal addra : std_logic_vector(13 downto 0) := (others => '0');

  signal spicsdone : std_logic := '0';

  signal dinb, dob : std_logic_vector(15 downto 0)
        := (others => '0');
  
begin  -- Behavioral

  RAMBUF : RAMB16_S1_S18 port map (
    DOA(0) => lspimiso,
    DOB    => dob,
    ADDRA  => addra,
    ADDRB  => ADDR,
    CLKA   => CLKHI,
    CLKB   => CLK,
    DIA(0) => spimosil,
    DIB    => dinb,
    DIPB   => "00",
    ENA    => '1',
    ENB    => '1',
    SSRA   => '0',
    SSRB   => '0',
    WEA    => wea,
    WEB    => WE);

  dinb(7) <= DIN(8);
  dinb(6) <= DIN(9);
  dinb(5) <= DIN(10);
  dinb(4) <= DIN(11);
  dinb(3) <= DIN(12);
  dinb(2) <= DIN(13);
  dinb(1) <= DIN(14);
  dinb(0) <= DIN(15);
  
  dinb(15) <= DIN(0);
  dinb(14) <= DIN(1);
  dinb(13) <= DIN(2);
  dinb(12) <= DIN(3);
  dinb(11) <= DIN(4);
  dinb(10) <= DIN(5);
  dinb(9) <= DIN(6);
  dinb(8) <= DIN(7);

  DOUT(7) <= dob(8);
  DOUT(6) <= dob(9);
  DOUT(5) <= dob(10);
  DOUT(4) <= dob(11);
  DOUT(3) <= dob(12);
  DOUT(2) <= dob(13);
  DOUT(1) <= dob(14);
  DOUT(0) <= dob(15);

  DOUT(15) <= dob(0);
  DOUT(14) <= dob(1);
  DOUT(13) <= dob(2);
  DOUT(12) <= dob(3);
  DOUT(11) <= dob(4);
  DOUT(10) <= dob(5);
  DOUT(9) <= dob(6);
  DOUT(8) <= dob(7);

  
-- high-speed SPI CLOCK DOMAIN
  wea       <= spiclkl and not spiclkll;
  spicsdone <= spicsl and not spicsll;

  clkhidomain : process(CLKHI)
  begin
    if rising_edge(CLKHI) then
      spimosil <= SPIMOSI;
      spicsl   <= SPICS;
      spicsll  <= spicsl;

      spiclkl <= SPICLK;
      spiclkll <= spiclkl; 

      weal <= wea;
      weall <= weal;
      if weall = '1'  or lspireq = '1' or spireq = '1' then
        if lspireq = '1'  then
          spimiso <= lspireq;
        else
          SPIMISO <= lspimiso; 
        end if;
      end if;
      
      if wea = '1' then
        addra   <=  addra + 1;
      else
        if spicsl = '1' then
          addra <= (others => '0');
        end if;
      end if;

      if cmdreql = '1' then
        lspireq   <= '1';
      else
        if spicsl = '0' then
          lspireq <= '0';
        end if;
      end if;

      spireq <= lspireq; 

      cmdreql <= CMDREQ;


      if CMDREQ = '1' then
        CMDDONE   <= '0';
      else
        if spicsdone = '1' then
          CMDDONE <= '1';
        end if;
      end if;

    end if;
  end process clkhidomain;


  -- slower clock domain
  main : process(CLK)
  begin
    if rising_edge(CLK) then

    end if;
  end process main;

end Behavioral;
