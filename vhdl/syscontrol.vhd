library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity syscontrol is

  port (
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    EDTX    : in  std_logic_vector(7 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0)
    );
end syscontrol;

architecture Behavioral of syscontrol is

  signal romaddr : std_logic_vector(8 downto 0) := (others => '0');
  signal bootevt : std_logic_vector(16*6-1 downto 0) := (others => '0');

  signal edrxall : std_logic_vector(16*6-1 downto 0) := (others => '0');

  signal osel : std_logic := '0';

  signal boot_id : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  
  
  -- event inputs
  signal enext : std_logic                     := '0';
  signal eouta : std_logic_vector(2 downto 0)  := (others = > '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');

  signal evalid :     std_logic := '0';

  

  component rxeventfifo
    port (
      CLK       : in  std_logic;
      RESET     : in  std_logic;
      ECYCLE    : in  std_logic;
      EATX      : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX      : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD     : out std_logic_vector(15 downto 0);
      EOUTA     : in  std_logic_vector(2 downto 0);
      EVALID    : out std_logic;
      ENEXT     : in  std_logic
      );
  end component;

begin  -- Behavioral

  boot_id(2) <= '1'; 

  EDRX <= edrxall(7 downto 0) when 
  rxeventfifo_inst : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      eoutd  => eoutd,
      eouta  => eouta,
      EVALID => evalid,
      ENEXT  => enext);
  

  
end Behavioral;
