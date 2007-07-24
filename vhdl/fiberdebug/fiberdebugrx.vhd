library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity fiberdebugrx is
  generic (
    DEVICE  :     std_logic_vector(7 downto 0) := X"01"
    );
  port (
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    -- Event bus interface
    ECYCLE  : in  std_logic;
    EARXA   : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRXA   : out std_logic_vector(7 downto 0);
    EARXB   : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRXB   : out std_logic_vector(7 downto 0);
    EDSELRX : out std_logic_vector(3 downto 0);

    -- Fiber interfaces
    FIBERIN : in std_logic
    );

end fiberdebugrx;

architecture Behavioral of fiberdebugrx is

  constant DATAEVENTA : std_logic_vector(7 downto 0) := X"80";
  constant DATAEVENTB : std_logic_vector(7 downto 0) := X"81";

  constant CMDINEVENT : std_logic_vector(7 downto 0) := X"82";

  -- SAMPLE signals
  signal samplea1 : std_logic_vector(15 downto 0) := (others => '0');
  signal samplea2 : std_logic_vector(15 downto 0) := (others => '0');
  signal samplea3 : std_logic_vector(15 downto 0) := (others => '0');
  signal samplea4 : std_logic_vector(15 downto 0) := (others => '0');
  signal sampleac : std_logic_vector(15 downto 0) := (others => '0');

  signal sampleb1 : std_logic_vector(15 downto 0) := (others => '0');
  signal sampleb2 : std_logic_vector(15 downto 0) := (others => '0');
  signal sampleb3 : std_logic_vector(15 downto 0) := (others => '0');
  signal sampleb4 : std_logic_vector(15 downto 0) := (others => '0');
  signal samplebc : std_logic_vector(15 downto 0) := (others => '0');

  signal cmdid, cmdidl   : std_logic_vector(3 downto 0) := (others => '0');
  signal cmdsts, cmdstsl : std_logic_vector(3 downto 0) := (others => '0');

  -- event control and generation
  signal dataeventa : std_logic_vector(95 downto 0) := (others => '0');
  signal dataeventb : std_logic_vector(95 downto 0) := (others => '0');
  signal cmdevent   : std_logic_vector(95 downto 0) := (others => '0');

  signal eina, einb : std_logic_vector(95 downto 0)                 := (others => '0');
  signal eaddrin    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal sendevent : std_logic := '0';

  signal etypsel : integer range 0 to 1 := 0;

  -- decoder IO
  signal decodedout : std_logic := '0';
  signal decodekin  : std_logic := '0';
  signal decodeerr  : std_logic := '0';
  signal decodece   : std_logic := '0';


  component decoder
    port ( CLK      : in  std_logic;
           DIN      : in  std_logic;
           DATAOUT  : out std_logic_vector(7 downto 0);
           KOUT     : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
           RESET    : in  std_logic);
  end component;

  component framedis
    port ( CLK        : in  std_logic;
           RESET      : in  std_logic;
           DIN        : in  std_logic_vector(7 downto 0);
           INWE       : in  std_logic;
           KIN        : in  std_logic;
           ERRIN      : in  std_logic;
           LINKUP     : out std_logic;
           NEWSAMPLES : out std_logic;
           SAMPLEA1   : out std_logic_vector(15 downto 0);
           SAMPLEA2   : out std_logic_vector(15 downto 0);
           SAMPLEA3   : out std_logic_vector(15 downto 0);
           SAMPLEA4   : out std_logic_vector(15 downto 0);
           SAMPLEAC   : out std_logic_vector(15 downto 0);
           SAMPLEB1   : out std_logic_vector(15 downto 0);
           SAMPLEB2   : out std_logic_vector(15 downto 0);
           SAMPLEB3   : out std_logic_vector(15 downto 0);
           SAMPLEB4   : out std_logic_vector(15 downto 0);
           SAMPLEBC   : out std_logic_vector(15 downto 0);
           CMDID      : out std_logic_vector(3 downto 0);
           CMDST      : out std_logic_vector(3 downto 0));
  end component;

  component txeventbuffer
    port (
      CLK      : in  std_logic;
      EVENTIN  : in  std_logic_vector(95 downto 0);
      EADDRIN  : in  std_logic_vector(somabackplane.N -1 downto 0);
      NEWEVENT : in  std_logic;
      -- outputs
      EDRX     : out std_logic_vector(7 downto 0);
      EDRXSEL  : out std_logic_vector(2 downto 0);
      EARX     : out std_logic_vector(somabackplane.N - 1 downto 0));
  end component;

  type states is none, chksamp, newcmd, newsamp;
  signal cs, ns : states := none;


  signal newsamples : std_logic := '0';

begin  -- Behavioral

  eina <= dataeventa when etype = 0 else cmdevent;
  einb <= dataeventb when etype = 0 else cmdevent;

  -- construct the event packets
  dataeventa <= SAMPLEAC &
                SAMPLEA4 &
                SAMPLEA3 &
                SAMPLEA2 &
                SAMPLEA1 &
                DEVICE & DATAEVENTA;

  dataeventb <= SAMPLEBC &
                SAMPLEB4 &
                SAMPLEB3 &
                SAMPLEB2 &
                SAMPLEB1 &
                DEVICE & DATAEVENTB;


  cmdevent <= X"0000" &
                X"0000" &
                X"0000" &
                X"000" & cmdsts &
                X"000" & cmdid &
                DEVICE & CMDINEVENT;

  main : process (CLK, RESET)
  begin  -- process main
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        if cs = newcmd then
          cmdidl  <= cmdid;
          cmdstsl <= cmdsts;
        end if;

      end if;
    end if;
  end process main;

  fsm : process(cs, newsamples, cmdid, cmdidl, cmdsts, cmdstsl)
  begin
    case cs is
      when none =>
        etypesel <= 0;
        sendevent <= '0';
        if newsamples = '1' then
          ns <= chksamp;
        else
          ns <= none; 
        end if;

      when chksamp =>
        etypesel <= 0;
        sendevent <= '0';
        if cmdid /= cmdidl or cmdsts /= cmdstsl 
          ns <= newcmd;
        else
          ns <= newsamp; 
        end if;

      when newcmd =>
        etypesel <= 1;
        sendevent <= '1';
        ns <= newsamp; 

      when newsamp =>
        etypesel <= 0;
        sendevent <= '1';
        ns <= none; 

      when others =>
        etypesel <= 0;
        sendevent <= '0';
        ns <= none; 

    end case;
  end proces fsm;

end Behavioral;