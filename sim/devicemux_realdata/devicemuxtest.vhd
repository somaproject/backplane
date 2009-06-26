library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_textio.all;

use std.TextIO.all;
use ieee.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;

entity devicemuxtest is

end devicemuxtest;


architecture Behavioral of devicemuxtest is

  component devicemux
    port (
      CLK      : in  std_logic;
      ECYCLE   : in  std_logic;
      DATADOUT : out std_logic_vector(7 downto 0);
      DATADOEN : out std_logic;
      -- port A
      DGRANTA  : in  std_logic;
      EARXA    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXA    : out std_logic_vector(7 downto 0);
      EDSELRXA : in  std_logic_vector(3 downto 0);
      EATXA    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXA    : in  std_logic_vector(7 downto 0);
      -- port B
      DGRANTB  : in  std_logic;
      EARXB    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXB    : out std_logic_vector(7 downto 0);
      EDSELRXB : in  std_logic_vector(3 downto 0);
      EATXB    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXB    : in  std_logic_vector(7 downto 0);
      -- port C
      DGRANTC  : in  std_logic;
      EARXC    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXC    : out std_logic_vector(7 downto 0);
      EDSELRXC : in  std_logic_vector(3 downto 0);
      EATXC    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXC    : in  std_logic_vector(7 downto 0);
      -- port D
      DGRANTD  : in  std_logic;
      EARXD    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXD    : out std_logic_vector(7 downto 0);
      EDSELRXD : in  std_logic_vector(3 downto 0);
      EATXD    : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXD    : in  std_logic_vector(7 downto 0);
      -- IO 
      TXDOUT   : out std_logic_vector(7 downto 0);
      TXKOUT   : out std_logic;
      RXDIN    : in  std_logic_vector(7 downto 0);
      RXKIN    : in  std_logic;
      RXEN     : in  std_logic;
      LOCKED   : in  std_logic);
  end component;

  signal CLK      : std_logic                    := '0';
  signal ECYCLE   : std_logic                    := '0';
  signal DATADOUT : std_logic_vector(7 downto 0) := (others => '0');
  signal DATADOEN : std_logic                    := '0';

  -- port A
  signal DGRANTA : std_logic := '0';

  signal EARXA    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXA    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXA : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXA    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXA    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port B
  signal DGRANTB : std_logic := '0';

  signal EARXB    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXB    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXB : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXB    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXB    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port C
  signal DGRANTC : std_logic := '0';

  signal EARXC    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXC    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXC : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXC    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXC    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port D
  signal DGRANTD : std_logic := '0';

  signal EARXD    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXD    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXD : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXD    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXD    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- IO 
  signal TXDOUT : std_logic_vector(7 downto 0) := (others => '0');
  signal TXKOUT : std_logic                    := '0';
  signal RXDIN  : std_logic_vector(7 downto 0) := (others => '0');
  signal RXKIN  : std_logic                    := '0';
  signal RXEN   : std_logic                    := '0';
  signal LOCKED : std_logic                    := '1';


  signal EDSELRX : std_logic_vector(3 downto 0) := (others => '0');
  signal EDTX    : std_logic_vector(7 downto 0) := (others => '0');

  ---------------------------------------------------------------------------
  -- DEBUG
  ---------------------------------------------------------------------------

  type eventarray is array (0 to 5) of std_logic_vector(15 downto 0);

  type events is array (0 to somabackplane.N-1) of eventarray;

  signal eventinputs : events := (others => (others => X"0000"));

  signal eazeros : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal rxentoggle : std_logic := '0';

  signal pos : integer range 0 to 999 := 0;

  constant K28_0 : std_logic_vector(7 downto 0) := X"1C";
  constant K28_1 : std_logic_vector(7 downto 0) := X"3C";
  constant K28_2 : std_logic_vector(7 downto 0) := X"5C";
  constant K28_3 : std_logic_vector(7 downto 0) := X"7C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"FC";



begin  -- Behavioral

  CLK <= not CLK after 10 ns;


  devicemux_uut : devicemux
    port map (
      clk      => CLK,
      ECYCLE   => ECYCLE,
      DATADOUT => DATADOUT,
      DATADOEN => DATADOEN,
      -- port A
      DGRANTA  => DGRANTA,
      EARXA    => EARXA,
      EDRXA    => EDRXA,
      EDSELRXA => EDSELRXA,
      EATXA    => EATXA(somabackplane.N -1 downto 0),
      EDTXA    => EDTXA,
      -- port B
      DGRANTB  => DGRANTB,
      EARXB    => EARXB,
      EDRXB    => EDRXB,
      EDSELRXB => EDSELRXB,
      EATXB    => EATXB(somabackplane.N -1 downto 0),
      EDTXB    => EDTXB,
      -- port C
      DGRANTC  => DGRANTC,
      EARXC    => EARXC,
      EDRXC    => EDRXC,
      EDSELRXC => EDSELRXC,
      EATXC    => EATXC(somabackplane.N -1 downto 0),
      EDTXC    => EDTXC,
      -- port D
      DGRANTD  => DGRANTD,
      EARXD    => EARXD,
      EDRXD    => EDRXD,
      EDSELRXD => EDSELRXD,
      EATXD    => EATXD(somabackplane.N -1 downto 0),
      EDTXD    => EDTXD,
      -- IO
      TXDOUT   => TXDOUT,
      TXKOUT   => TXKOUT,
      RXDIN    => RXDIN,
      RXKIN    => RXKIN,
      RXEN     => RXEN,
      LOCKED   => LOCKED);


  EDTXA <= EDTX;
  EDTXB <= EDTX;
  EDTXC <= EDTX;
  EDTXD <= EDTX;

  EDSELRXA <= EDSELRX;
  EDSELRXB <= EDSELRX;
  EDSELRXC <= EDSELRX;
  EDSELRXD <= EDSELRX;


  readfile: process
    file dumpfile : text;
    variable L : line;
    variable e, k : integer;
    variable readdin : std_logic_vector(7 downto 0); 
    
  begin
    file_open(dumpfile, "output.txt", read_mode);
    while not endfile(dumpfile) loop
      readline(dumpfile, L); 
      wait until rising_edge(CLK);
      read(L, e);
      read(L, k);
      hread(L, readdin);

      if e = 1 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;

      if k = 1  then
        RXKIN <= '1'; 
      else
        RXKIN <= '0'; 
      end if;
      RXDIN <= readdin; 
      
      RXEN <= not RXEN; 
    end loop;
    wait;
    
  end process readfile; 
end Behavioral;
