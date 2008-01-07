
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity ecoresize is
  port (
    CLK         : in  std_logic;
    OPORTADDR   : out std_logic_vector(7 downto 0);
    OPORTDATA   : out std_logic_vector(15 downto 0);
    OPORTSTROBE : out std_logic;
    FORCEJUMP   : in  std_logic;
    FORCEADDR   : in  std_logic_vector(9 downto 0)
    );
end ecoresize;

architecture Behavioral of ecoresize is

  component ecore
    port (
      CLK         : in  std_logic;
      CPHASEOUT   : out std_logic;
      RESET       : in  std_logic;
      -- instruction interface
      IADDR       : out std_logic_vector(9 downto 0);
      IDATA       : in  std_logic_vector(17 downto 0);
      -- event interface
      EADDR       : out std_logic_vector(2 downto 0);
      EDATA       : in  std_logic_vector(15 downto 0);
      -- io ports
      OPORTADDR   : out std_logic_vector(7 downto 0);
      OPORTDATA   : out std_logic_vector(15 downto 0);
      OPORTSTROBE : out std_logic;

      IPORTADDR   : out std_logic_vector(7 downto 0);
      IPORTDATA   : in  std_logic_vector(15 downto 0);
      IPORTSTROBE : out std_logic;
      -- interrupt interface ports
      FORCEJUMP   : in  std_logic;
      FORCEADDR   : in  std_logic_vector(9 downto 0)
      );

  end component;

  signal cphaseout : std_logic                     := '0';
  signal iaddr     : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata     : std_logic_vector(17 downto 0) := (others => '0');

  signal eaddr : std_logic_vector(3 downto 0)  := (others => '0');
  signal edata : std_logic_vector(15 downto 0) := (others => '0');

  signal loportaddr : std_logic_vector(7 downto 0)  := (others => '0');
  signal loportdata : std_logic_vector(15 downto 0) := (others => '0');

  signal loportstrobe : std_logic := '0';

  signal forcejumpl : std_logic                    := '0';
  signal forceaddrl : std_logic_vector(9 downto 0) := (others => '0');


  component regfile
    generic (
      BITS  :     integer := 16);
    port (
      CLK   : in  std_logic;
      DIA   : in  std_logic_vector(BITS-1 downto 0);
      DOA   : out std_logic_vector(BITS -1 downto 0);
      ADDRA : in  std_logic_vector(3 downto 0);
      WEA   : in  std_logic;
      DOB   : out std_logic_vector(BITS -1 downto 0);
      ADDRB : in  std_logic_vector(3 downto 0)
      );
  end component;


begin  -- Behavioral

  ecore_inst : ecore
    port map (
      CLK        => CLK,
      CPHASEOUT   => cphaseout,
      RESET       => '0',
      IADDR       => iaddr,
      IDATA       => idata,
      EADDR       => eaddr(2 downto 0),
      EDATA       => edata,
      OPORTADDR   => loportaddr,
      OPORTDATA   => loportdata,
      OPORTSTROBE => loportstrobe,
      IPORTADDR   => open,
      IPORTDATA   => X"0000",
      IPORTSTROBE => open,
      FORCEJUMP   => forcejumpl,
      FORCEADDR   => forceaddrl);

  instruction_ram : RAMB16_S18_S18
    port map (
      DOA   => idata(15 downto 0),
      DOPA  => idata(17 downto 16),
      ADDRA => iaddr,
      CLKA  => CLK,
      DIA   => X"0000",
      DIPA  => "00",
      ENA   => '1',
      WEA   => '0',
      SSRA  => '0',
      DOB   => open,
      DOPB  => open,
      ADDRB => "0000000000",
      CLKB  => CLK,
      DIB   => X"0000",
      DIPB  => "00",
      ENB   => '0',
      WEB   => '0',
      SSRB  => '0');
  
  event_regfile: regfile
    generic map (
      BITS => 16)
    port map (
      CLK   => CLK,
      DIA   => X"0000",
      DOA   => edata,
      ADDRA => eaddr,
      WEA   => '0',
      DOB   => open,
      ADDRB => "0000");

  main: process (CLK)
    begin
      if rising_edge(CLK) then
        OPORTADDR <= loportaddr;
        OPORTDATA <= loportdata;
        OPORTSTROBE <= loportstrobe;                      
      end if;      
    end process; 
    
  
end Behavioral;
