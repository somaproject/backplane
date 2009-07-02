library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;


entity datarouter is
  port (
    CLK       : in std_logic;
    ECYCLE    : in std_logic;
    DIN       : in somabackplane.dataroutearray;
    DINEN     : in std_logic_vector(7 downto 0);
    DINCOMMIT : in std_logic_vector(7 downto 0);

    DOUT         : out std_logic_vector(7 downto 0);
    DOEN         : out std_logic;
    DGRANT       : out std_logic_vector(31 downto 0);
    DGRANTBSTART : out std_logic_vector(31 downto 0)
    );
end datarouter;

architecture Behavioral of datarouter is
  -----------------------------------------------------------------------------
  -- Data router contains four data sequencers for historical reasons
  -----------------------------------------------------------------------------
  --
  --
  --
  -----------------------------------------------------------------------------

  signal dpos         : integer range 0 to 3         := 3;
  signal doutactivate : std_logic_vector(3 downto 0) := (others => '0');

  type douts_t is array (0 to 3) of std_logic_vector(7 downto 0);

  signal douts : douts_t := (others => (others => '0'));

  signal doens : std_logic_vector(3 downto 0) :=  (others => '0');

  component datasequencer
    port (
      CLK          : in  std_logic;
      ECYCLE       : in  std_logic;
      DIN1         : in  std_logic_vector(7 downto 0);
      DIN2         : in  std_logic_vector(7 downto 0);
      DINEN        : in  std_logic_vector(1 downto 0);
      DINCOMMIT    : in  std_logic_vector(1 downto 0);
      -- output dgrant control
      DGRANT       : out std_logic_vector(7 downto 0);
      DGRANTBSTART : out std_logic_vector(7 downto 0);
      -- output data interface
      DOUTACTIVE   : in  std_logic;     -- trigger a dump, must happen EVERY
                                        -- DGRANTLEN ticks
      DOUT         : out std_logic_vector(7 downto 0);
      DOEN         : out std_logic
      );
  end component;
  
begin  -- Behavioral

  gens : for dset in 0 to 3 generate
    datasequencer_inst : datasequencer
      port map (
        CLK       => CLK,
        ECYCLE    => ECYCLE,
        DIN1      => din(dset*2 + 0),
        DIN2      => din(dset*2 + 1),
        DINEN     => dinen(dset*2 +1 downto dset*2),
        DINCOMMIT => dincommit(dset*2 +1 downto dset*2),

        DGRANT       => dgrant(dset*8 +7 downto dset*8),
        DGRANTBSTART => dgrantbstart(dset*8 +7 downto dset*8),

        DOUTACTIVE => doutactivate(dset),
        DOUT       => douts(dset),
        DOEN     => doens(dset));         
  end generate gens;

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        if dpos = 3 then
          dpos <= 0;
        else
          dpos <= dpos + 1;
        end if;
      end if;
    end if;
  end process main;

  DOUTACTIVATE <= "0001" when dpos = 0 else
                  "0010" when dpos = 1 else
                  "0100" when dpos = 2 else
                  "1000";

  DOUT <= douts(dpos);
  DOEN <= doens(dpos);
  
end Behavioral;
