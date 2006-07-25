library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


use WORK.networkstack.all;
use WORK.networkstack;


library UNISIM;
use UNISIM.vcomponents.all;

entity network is
  port (
    CLK          : in  std_logic;
    RESET        : in  std_logic;
    -- config
    MYIP         : in  std_logic_vector(31 downto 0);
    MYMAC        : in  std_logic_vector(47 downto 0);
    MYBCAST      : in  std_logic_vector(31 downto 0);
    -- input
    NICNEXTFRAME : out std_logic;
    NICDINEN     : in  std_logic;
    NICDIN       : in  std_logic_vector(15 downto 0);
    -- output
    DOUT         : out std_logic_vector(15 downto 0);
    NEWFRAME     : out std_logic;
    IOCLOCK      : out std_logic;

    -- event bus
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
    EDTX    : in  std_logic_vector(7 downto 0)

    -- data bus
    --                                  -- none at the moment;
    );
end network;

architecture Behavioral of network is


  component inputcontrol
    port (
      CLK        : in  std_logic;
      RESET      : in  std_logic;
      NEXTFRAME  : out std_logic;
      DINEN      : in  std_logic;
      DIN        : in  std_logic_vector(15 downto 0);
      PKTDATA    : out std_logic_vector(15 downto 0);
      -- ICMP echo request IO
      PINGSTART  : out std_logic;
      PINGADDR   : in  std_logic_vector(9 downto 0);
      PINGDONE   : in  std_logic;
      -- retransmit request 
      RETXSTART  : out std_logic;
      RETXADDR   : in  std_logic_vector(9 downto 0);
      RETXDONE   : in  std_logic;
      -- ARP Request
      ARPSTART   : out std_logic;
      ARPADDR    : in  std_logic_vector(9 downto 0);
      ARPDONE    : in  std_logic;
                                        -- input event
      EVENTSTART : out std_logic;
      EVENTADDR  : in  std_logic_vector(9 downto 0);
      EVENTDONE  : in  std_logic
      );
  end component;

  component txmux
    port (
      CLK      : in  std_logic;
      DEN      : in  std_logic_vector(4 downto 0);
      DIN0     : in  std_logic_vector(15 downto 0);
      DIN1     : in  std_logic_vector(15 downto 0);
      DIN2     : in  std_logic_vector(15 downto 0);
      DIN3     : in  std_logic_vector(15 downto 0);
      DIN4     : in  std_logic_vector(15 downto 0);
      GRANT    : out std_logic_vector(4 downto 0);
      ARM      : in  std_logic_vector(4 downto 0);
      DOUT     : out std_logic_vector(15 downto 0);
      NEWFRAME : out std_logic
      );
  end component;


  component arpresponse
    port (
      CLK       : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;

  component pingresponse
    port (
      CLK       : in  std_logic;
      MYMAC     : in  std_logic_vector(47 downto 0);
      MYIP      : in  std_logic_vector(31 downto 0);
      -- IO interface
      START     : in  std_logic;
      DONE      : out std_logic;
      INPKTDATA : in  std_logic_vector(15 downto 0);
      INPKTADDR : out std_logic_vector(9 downto 0);
      -- output
      ARM       : out std_logic;
      GRANT     : in  std_logic;
      DOUT      : out std_logic_vector(15 downto 0);
      DOEN      : out std_logic);
  end component;


  -- input if

  signal pktdata : std_logic_vector(15 downto 0) := (others => '0');

  signal eventinstart : std_logic                    := '0';
  signal eventinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal eventindone  : std_logic                    := '0';

  signal arpinstart : std_logic                    := '0';
  signal arpinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal arpindone  : std_logic                    := '0';

  signal pinginstart : std_logic                    := '0';
  signal pinginaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal pingindone  : std_logic                    := '0';

  signal retxinstart : std_logic                    := '0';
  signal retxinaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal retxindone  : std_logic                    := '0';

  -- output

  signal den  : std_logic_vector(4 downto 0)  := (others => '0');
  signal din0 : std_logic_vector(15 downto 0) := (others => '0');
  signal din1 : std_logic_vector(15 downto 0) := (others => '0');
  signal din2 : std_logic_vector(15 downto 0) := (others => '0');
  signal din3 : std_logic_vector(15 downto 0) := (others => '0');
  signal din4 : std_logic_vector(15 downto 0) := (others => '0');

  signal grant : std_logic_vector(4 downto 0) := (others => '0');
  signal arm   : std_logic_vector(4 downto 0) := (others => '0');


begin  -- Behavioral

  inputcontrol_inst : inputcontrol
    port map (
      CLK        => CLK,
      RESET      => RESET,
      NEXTFRAME  => NICNEXTFRAME,
      DINEN      => NICDINEN,
      DIN        => NICDIN,
      PKTDATA    => pktdata,
      PINGSTART  => pinginstart,
      PINGADDR   => pinginaddr,
      PINGDONE   => pingindone,
      RETXSTART  => retxinstart,
      RETXADDR   => retxinaddr,
      RETXDONE   => retxindone,
      ARPSTART   => arpinstart,
      ARPADDR    => arpinaddr,
      ARPDONE    => arpindone,
      EVENTSTART => eventinstart,
      EVENTADDR  => eventinaddr,
      EVENTDONE  => eventindone);


  txmux_inst : txmux
    port map (
      CLK      => CLK,
      DEN      => den,
      DIN0     => din0,
      DIN1     => din1,
      DIN2     => din2,
      DIN3     => din3,
      DIN4     => din4,
      GRANT    => grant,
      ARM      => arm,
      DOUT     => dout,
      NEWFRAME => newframe);

  IOCLOCK <= CLK;

  arpresponse_inst : arpresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => arpinstart,
      DONE      => arpindone,
      INPKTDATA => pktdata,
      INPKTADDR => arpinaddr,
      ARM       => arm(4),
      GRANT     => grant(4),
      DOUT      => din4,
      DOEN      => den(4));

  pingresponse_inst : pingresponse
    port map (
      CLK       => CLK,
      MYMAC     => MYMAC,
      MYIP      => MYIP,
      START     => pinginstart,
      DONE      => pingindone,
      INPKTDATA => pktdata,
      INPKTADDR => pinginaddr,
      ARM       => arm(3),
      GRANT     => grant(3),
      DOUT      => din3,
      DOEN      => den(3));

  din0 <= (others => '0');
  din1 <= (others => '0');
  din2 <= (others => '0');

end Behavioral;
