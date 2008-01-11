library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity alutest is

end alutest;

architecture Behavioral of alutest is

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

  signal CLK         : std_logic                     := '0';
  signal CPHASEOUT   : std_logic                     := '0';
  signal RESET       : std_logic                     := '1';
  -- instruction interface
  signal IADDR       : std_logic_vector(9 downto 0)  := (others => '0');
  signal IDATA       : std_logic_vector(17 downto 0) := (others => '0');
  -- event interface
  signal EADDR       : std_logic_vector(2 downto 0)  := (others => '0');
  signal EDATA       : std_logic_vector(15 downto 0) := (others => '0');
  -- io ports
  signal OPORTADDR   : std_logic_vector(7 downto 0)  := (others => '0');
  signal OPORTDATA   : std_logic_vector(15 downto 0) := (others => '0');
  signal OPORTSTROBE : std_logic                     := '0';

  signal IPORTADDR   : std_logic_vector(7 downto 0)  := (others => '0');
  signal IPORTDATA   : std_logic_vector(15 downto 0) := (others => '0');
  signal IPORTSTROBE : std_logic                     := '0';
  -- interrupt interface ports
  signal FORCEJUMP   : std_logic                     := '0';
  signal FORCEADDR   : std_logic_vector(9 downto 0)  := (others => '0');


  component IRAM
    generic (
      filename :     string);
    port (
      CLK      : in  std_logic;
      ADDR     : in  std_logic_vector(9 downto 0);
      DATA     : out std_logic_vector(17 downto 0));
  end component;

  component outverify
    generic (
      filename :     string);
    port (
      CLK      : in  std_logic;
      ADDR     : in  std_logic_vector(7 downto 0);
      DATA     : in  std_logic_vector(15 downto 0);
      STROBE   : in  std_logic;
      EXPADDR  : out std_logic_vector(7 downto 0);
      EXPDATA  : out std_logic_vector(15 downto 0);
      ERR      : out std_logic;
      DONE     : out std_logic);
  end component;

  signal outverifydone : std_logic := '0';
  signal oportexpaddr : std_logic_vector(7 downto 0) := (others => '0');
  signal oportexpdata : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- Behavioral

  ecore_uut : ecore
    port map (
      CLK         => CLK,
      CPHASEOUT   => CPHASEOUT,
      RESET       => RESET,
      IADDR       => IADDR,
      IDATA       => idata,
      EADDR       => EADDR,
      EDATA       => EDATA,
      OPORTADDR   => OPORTADDR,
      OPORTDATA   => OPORTDATA,
      OPORTSTROBE => OPORTSTROBE,
      IPORTADDR   => IPORTADDR,
      IPORTDATA   => IPORTDATA,
      IPORTSTROBE => IPORTSTROBE,
      FORCEJUMP   => FORCEJUMP,
      FORCEADDR   => FORCEADDR);

  IRAM_inst : iram
    generic map (
      filename => "program.iram")
    port map (
      CLK      => CLK,
      ADDR     => IADDR,
      DATA     => IDATA);


  CLK <= not CLK after 5 ns;

  RESET <= '0' after 50 ns;

  -- capture the output writing
  outverify_inst : outverify
    generic map (
      FILENAME => "outport.verify.dat" )
    port map (
      CLK      => CLK,
      ADDR     => OPORTADDR,
      DATA     => OPORTDATA,
      STROBE   => OPORTSTROBE,
      EXPADDR  => OPORTEXPADDR,
      EXPDATA => oportexpdata, 
      DONE => outverifydone);


  -- how to handle the events
  EDATA <= X"EC0" & '0' & eaddr;
  
  process
    begin
      wait until rising_edge(outverifydone);
      report "End of Simulation" severity Failure;
      
    end process;
  
end Behavioral;
