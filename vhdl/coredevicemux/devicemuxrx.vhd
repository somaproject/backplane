library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;
use soma.all;

entity devicemuxrx is
  port (
    CLK      : in  std_logic;
    ECYCLE   : in  std_logic;
    LOCKED   : in  std_logic;
    -- Data port outputs
    DATADOUT : out std_logic_vector(7 downto 0);
    DATADOEN : out std_logic; 
    -- port A
    EARXA    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXA    : out std_logic_vector(7 downto 0);
    EDSELRXA : in  std_logic_vector(3 downto 0);
    -- port B
    EARXB    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXB    : out std_logic_vector(7 downto 0);
    EDSELRXB : in  std_logic_vector(3 downto 0);
    -- port C
    EARXC    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXC    : out std_logic_vector(7 downto 0);
    EDSELRXC : in  std_logic_vector(3 downto 0);
    -- port D
    EARXD    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRXD    : out std_logic_vector(7 downto 0);
    EDSELRXD : in  std_logic_vector(3 downto 0);
    -- outputs
    RXDIN    : in  std_logic_vector(7 downto 0);
    RXKIN    : in  std_logic);
end devicemuxrx;

architecture Behavioral of devicemuxrx is

  type states is (lockw, ewait, dwait,
                  estart1, ewait1,
                  estart2, ewait2,
                  estart3, ewait3,
                  estart4, ewait4);
  signal cs, ns : states := lockw;

  signal estart : std_logic_vector(3 downto 0) := (others => '0');
  signal edone  : std_logic_vector(3 downto 0) := (others => '0');


  signal clear : std_logic := '0';

  constant K28_0 : std_logic_vector(7 downto 0) := X"1C";
  constant K28_1 : std_logic_vector(7 downto 0) := X"3C";
  constant K28_2 : std_logic_vector(7 downto 0) := X"5C";
  constant K28_3 : std_logic_vector(7 downto 0) := X"7C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"FC";


  component devicemuxeventrx2
    port (
      CLK     : in  std_logic;
      DIN     : in  std_logic_vector(7 downto 0);
      START   : in  std_logic;
      DONE    : out std_logic;
      ECYCLE  : in  std_logic;
      EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRX    : out std_logic_vector(7 downto 0);
      EDSELRX : in  std_logic_vector(3 downto 0));
  end component;

  constant MAXDATASIZE : integer :=  768;
  signal datacnt : integer range 0 to 1023 := 0;
  
begin

  eventrxA_inst : devicemuxeventrx2
    port map (
      CLK     => CLK,
      DIN     => RXDIN,
      START   => estart(0),
      done    => edone(0),
      ECYCLE  => ECYCLE,
      EARX    => EARXA,
      EDRX    => EDRXA,
      EDSELRX => EDSELRXA);

  eventrxB_inst : devicemuxeventrx2
    port map (
      CLK     => CLK,
      DIN     => RXDIN,
      START   => estart(1),
      done    => edone(1),
      ECYCLE  => ECYCLE,
      EARX    => EARXB,
      EDRX    => EDRXB,
      EDSELRX => EDSELRXB);

  eventrxC_inst : devicemuxeventrx2
    port map (
      CLK     => CLK,
      DIN     => RXDIN,
      START   => estart(2),
      done    => edone(2),
      ECYCLE  => ECYCLE,
      EARX    => EARXC,
      EDRX    => EDRXC,
      EDSELRX => EDSELRXC);

  eventrxD_inst : devicemuxeventrx2
    port map (
      CLK     => CLK,
      DIN     => RXDIN,
      START   => estart(3),
      done    => edone(3),
      ECYCLE  => ECYCLE,
      EARX    => EARXD,
      EDRX    => EDRXD,
      EDSELRX => EDSELRXD);

  main : process (CLK)
  begin
    if rising_edge(CLK) then
      if locked = '1' then
        cs <= ns;
      else
        cs <= lockw;
      end if;


      if cs = dwait and rxkin = '0' then
        DATADOEN <= '1';
      else
        DATADOEN <= '0';
      end if;
      DATADOUT <= RXDIN;

      if RXDIN = K28_6 and rxkin = '1' then
        datacnt <= 0;
      else
        if cs = dwait then
          datacnt <= datacnt + 1; 
        end if;
      end if; 
    end if;
  end process main;

  estart(0) <= '1' when cs = estart1 else '0';
  estart(1) <= '1' when cs = estart2 else '0';
  estart(2) <= '1' when cs = estart3 else '0';
  estart(3) <= '1' when cs = estart4 else '0';
  
  fsm : process(cs, locked, edone, RXKIN, RXDIN, datacnt)
  begin
    case cs is
      when lockw =>
        clear <= '0';
        if LOCKED = '1' then
          ns  <= ewait;
        else
          ns  <= lockw;
        end if;

      when ewait =>
        clear  <= '0';
        if LOCKED = '0' then
          ns   <= lockw;
        else
          if RXKIN = '1' and RXDIN = K28_0 then
            ns <= estart1;
          elsif RXKIN = '1' and RXDIN = K28_1 then
            ns <= estart2;
          elsif RXKIN = '1' and RXDIN = K28_2 then
            ns <= estart3;
          elsif RXKIN = '1' and RXDIN = K28_3 then
            ns <= estart4;
          elsif RXKIN = '1' and RXDIN = K28_6 then
            ns <= dwait;
          else
            ns <= ewait;
          end if;
        end if;

        -- Event Stream 1
      when estart1 =>
        clear <= '0';
        ns    <= ewait1;
      when ewait1  =>
        clear <= '0';
        if edone(0) = '1' then
          ns  <= ewait;
        else
          ns  <= ewait1;
        end if;

        -- Event Stream 2
      when estart2 =>
        clear <= '0';
        ns    <= ewait2;
      when ewait2  =>
        clear <= '0';
        if edone(1) = '1' then
          ns  <= ewait;
        else
          ns  <= ewait2;
        end if;

        -- Event Stream 3
      when estart3 =>
        clear <= '0';
        ns    <= ewait3;
      when ewait3  =>
        clear <= '0';
        if edone(2) = '1' then
          ns  <= ewait;
        else
          ns  <= ewait3;
        end if;

        -- Event Stream 4
      when estart4 =>
        clear <= '0';
        ns    <= ewait4;
      when ewait4  =>
        clear <= '0';
        if edone(3) = '1' then
          ns  <= ewait;
        else
          ns  <= ewait4;
        end if;

        -- data
      when dwait =>
        clear <= '0';
        if (RXKIN = '1' and RXDIN = K28_7) or (datacnt = MAXDATASIZE)  then
          ns  <= ewait;
        else
          ns <= dwait; 
        end if;

      when others =>
        clear <= '0';
        ns    <= lockw;
    end case;
  end process fsm;

end Behavioral;
