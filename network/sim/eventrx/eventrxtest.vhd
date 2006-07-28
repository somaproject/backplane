library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity eventrxtest is

end eventrxtest;


architecture Behavioral of eventrxtest is

  component eventrx
    port (
      CLK       : in  std_logic;
      INPKTADDR : out std_logic_vector(9 downto 0);
      INPKTDATA : in  std_logic_vector(15 downto 0);
      START     : in  std_logic;
      DONE      : out std_logic;
      -- input parameters
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- Event interface
      ECYCLE    : in  std_logic;
      EARX      : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX      : out std_logic_vector(7 downto 0);
      EDSELRX   : in  std_logic_vector(3 downto 0);
      -- output to TX interface
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic;
      ARM       : out std_logic;
      GRANT     : in  std_logic);
  end component;

  signal CLK       : std_logic                     := '0';
  signal INPKTADDR : std_logic_vector(9 downto 0)  := (others => '0');
  signal INPKTDATA : std_logic_vector(15 downto 0) := (others => '0');
  signal START     : std_logic                     := '0';
  signal DONE      : std_logic                     := '0';

  -- input parameters
  signal MYMAC : std_logic_vector(47 downto 0) := (others => '0');
  signal MYIP  : std_logic_vector(31 downto 0) := (others => '0');

  -- Event interface
  signal ECYCLE  : std_logic                    := '0';
  signal EARX    : std_logic_vector(somabackplane.N -1 downto 0)
                                                := (others => '0');
  signal EDRX    : std_logic_vector(7 downto 0) := (others => '0');
  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');

  -- output to TX interface
  signal DOUT  : std_logic_vector(15 downto 0) := (others => '0');
  signal DOEN  : std_logic                     := '0';
  signal ARM   : std_logic                     := '0';
  signal GRANT : std_logic                     := '0';

begin  -- Behavioral

  eventrx_uut: eventrx
    port map (
      CLK       => CLK,
      INPKTADDR => INPKTADDR,
      INPKTDATA => INPKTDATA,
      START     => START,
      DONE      => DONE,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      ECYCLE    => ECYCLE,
      EARX      => EARX,
      EDRX      => EDRX,
      EDSELRX   => EDSELRX,
      DOUT      => DOUT,
      DOEN      => DOEN,
      ARM       => ARM,
      GRANT     => GRANT); 

  CLK <= not CLK after 10 ns;
  

end Behavioral;
