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
    ECYCLE  : out std_logic;
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
      DIN      : in  networkstack.dataarray;
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

  signal eventstart : std_logic                    := '0';
  signal eventaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal eventdone  : std_logic                    := '0';

  signal arpstart : std_logic                    := '0';
  signal arpaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal arpdone  : std_logic                    := '0';

  signal pingstart : std_logic                    := '0';
  signal pingaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal pingdone  : std_logic                    := '0';

  signal retxstart : std_logic                    := '0';
  signal retxaddr  : std_logic_vector(9 downto 0) := (others => '0');
  signal retxdone  : std_logic                    := '0';

  -- output

  signal den   : std_logic_vector(4 downto 0) := (others => '0');
  signal din   : networkstack.dataarray := (others => (others => '0'));
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
       PINGSTART  => pingstart,
       PINGADDR   => pingaddr,
       PINGDONE   => pingdone,
       RETXSTART  => retxstart,
       RETXADDR   => retxaddr,
       RETXDONE   => retxdone,
       ARPSTART   => arpstart,
       ARPADDR    => arpaddr,
       ARPDONE    => arpdone,
       EVENTSTART => eventstart,
       EVENTADDR  => eventaddr,
       EVENTDONE  => eventdone);


   txmux_inst : txmux
     port map (
       CLK      => CLK,
       DEN      => den,
       DIN      => din,
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
       START     => arpstart,
       DONE      => arpdone,
       INPKTDATA => pktdata,
       INPKTADDR => arpaddr,
       ARM       => arm(4),
       GRANT     => grant(4),
       DOUT      => din(4),
       DOEN      => den(4));

   pingresponse_inst : pingresponse
     port map (
       CLK       => CLK,
       MYMAC     => MYMAC,
       MYIP      => MYIP,
       START     => pingstart,
       DONE      => pingdone,
       INPKTDATA => pktdata,
       INPKTADDR => pingaddr,
       ARM       => arm(3),
       GRANT     => grant(3),
       DOUT      => din(3),
       DOEN      => den(3));



end Behavioral;
