library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;

entity devicemuxdataroutertest is

end devicemuxdataroutertest;


architecture Behavioral of devicemuxdataroutertest is

  component devicemux
    port (
      CLK           : in  std_logic;
      ECYCLE        : in  std_logic;
      DATADOUT      : out std_logic_vector(7 downto 0);
      DATADOEN      : out std_logic;
      DATACOMMIT    : out std_logic;
      -- port A
      DGRANTA       : in  std_logic;
      DGRANTBSTARTA : in  std_logic;
      EARXA         : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXA         : out std_logic_vector(7 downto 0);
      EDSELRXA      : in  std_logic_vector(3 downto 0);
      EATXA         : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXA         : in  std_logic_vector(7 downto 0);
      -- port B
      DGRANTB       : in  std_logic;
      DGRANTBSTARTB : in  std_logic;
      EARXB         : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXB         : out std_logic_vector(7 downto 0);
      EDSELRXB      : in  std_logic_vector(3 downto 0);
      EATXB         : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXB         : in  std_logic_vector(7 downto 0);
      -- port C
      DGRANTC       : in  std_logic;
      DGRANTBSTARTC : in  std_logic;
      EARXC         : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXC         : out std_logic_vector(7 downto 0);
      EDSELRXC      : in  std_logic_vector(3 downto 0);
      EATXC         : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXC         : in  std_logic_vector(7 downto 0);
      -- port D
      DGRANTD       : in  std_logic;
      DGRANTBSTARTD : in  std_logic;
      EARXD         : out std_logic_vector(somabackplane.N -1 downto 0);
      EDRXD         : out std_logic_vector(7 downto 0);
      EDSELRXD      : in  std_logic_vector(3 downto 0);
      EATXD         : in  std_logic_vector(somabackplane.N-1 downto 0);
      EDTXD         : in  std_logic_vector(7 downto 0);
      -- IO 
      TXDOUT        : out std_logic_vector(7 downto 0);
      TXKOUT        : out std_logic;
      RXDIN         : in  std_logic_vector(7 downto 0);
      RXKIN         : in  std_logic;
      RXEN          : in  std_logic;
      LOCKED        : in  std_logic);
  end component;

  component datarouter
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
  end component;

  signal CLK        : std_logic                    := '0';
  signal ECYCLE     : std_logic                    := '0';
  signal DATADOUT   : std_logic_vector(7 downto 0) := (others => '0');
  signal DATADOEN   : std_logic                    := '0';
  signal DATACOMMIT : std_logic                    := '0';

  signal router_din                     : somabackplane.dataroutearray;
  signal router_dinen, router_dincommit : std_logic_vector(7 downto 0) := (others => '0');

  signal router_dout : std_logic_vector(7 downto 0) := (others => '0');
  signal router_doen : std_logic                    := '0';

  signal dgrant, dgrantbstart : std_logic_vector(31 downto 0) := (others => '0');

  -- port A
  signal EARXA    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXA    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXA : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXA    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXA    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port B
  signal EARXB    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXB    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXB : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXB    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXB    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port C
  signal EARXC    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal EDRXC    : std_logic_vector(7 downto 0)                  := (others => '0');
  signal EDSELRXC : std_logic_vector(3 downto 0)                  := (others => '0');
  signal EATXC    : std_logic_vector(79 downto 0)                 := (others => '0');
  signal EDTXC    : std_logic_vector(7 downto 0)                  := (others => '0');

  -- port D

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
  constant K28_4 : std_logic_vector(7 downto 0) := X"9C";
  constant K28_6 : std_logic_vector(7 downto 0) := X"DC";
  constant K28_7 : std_logic_vector(7 downto 0) := X"FC";

  signal data_verify_done : std_logic := '0';

  -----------------------------------------------------------------------------
  -- Decode signals
  -----------------------------------------------------------------------------
  component fakedspboard
    port (
      CLK    : in  std_logic;
      RXDIN  : in  std_logic_vector(7 downto 0);
      RXKIN  : in  std_logic;
      TXDOUT : out std_logic_vector(7 downto 0);
      TXKOUT : out std_logic
      );                                -- '0'
  end component;

  type   packetcapture_t is array (0 to 1023) of integer;
  signal packetcapture  : packetcapture_t := (others => 0);
  signal packetcapturel : packetcapture_t := (others => 0);

  signal newpacket : std_logic := '0';

  signal rx_done : std_logic_vector(3 downto 0) := (others => '0');

  
begin  -- Behavioral

  CLK <= not CLK after 10 ns;


  devicemux_uut : devicemux
    port map (
      clk           => CLK,
      ECYCLE        => ECYCLE,
      DATADOUT      => DATADOUT,
      DATADOEN      => DATADOEN,
      DATACOMMIT    => DATACOMMIT,
      -- port A
      DGRANTA       => dgrant(0),
      DGRANTBSTARTA => DGRANTBSTART(0),
      EARXA         => EARXA,
      EDRXA         => EDRXA,
      EDSELRXA      => EDSELRXA,
      EATXA         => EATXA(somabackplane.N -1 downto 0),
      EDTXA         => EDTXA,
      -- port B
      DGRANTB       => DGRANT(1),
      DGRANTBSTARTB => DGRANTBSTART(1),
      EARXB         => EARXB,
      EDRXB         => EDRXB,
      EDSELRXB      => EDSELRXB,
      EATXB         => EATXB(somabackplane.N -1 downto 0),
      EDTXB         => EDTXB,
      -- port C
      DGRANTC       => DGRANT(2),
      DGRANTBSTARTC => DGRANTBSTART(2),
      EARXC         => EARXC,
      EDRXC         => EDRXC,
      EDSELRXC      => EDSELRXC,
      EATXC         => EATXC(somabackplane.N -1 downto 0),
      EDTXC         => EDTXC,
      -- port D
      DGRANTD       => DGRANT(3),
      DGRANTBSTARTD => DGRANTBSTART(3),
      EARXD         => EARXD,
      EDRXD         => EDRXD,
      EDSELRXD      => EDSELRXD,
      EATXD         => EATXD(somabackplane.N -1 downto 0),
      EDTXD         => EDTXD,
      -- IO
      TXDOUT        => TXDOUT,
      TXKOUT        => TXKOUT,
      RXDIN         => RXDIN,
      RXKIN         => RXKIN,
      RXEN          => RXEN,
      LOCKED        => LOCKED);


  router_din(0)       <= DATADOUT;
  router_dinen(0)     <= DATADOEN;
  router_dincommit(0) <= DATACOMMIT;

  datarouteR_uut : datarouter
    port map (
      CLK          => CLK,
      ECYCLE       => ECYCLE,
      din          => router_din,
      DINEN        => router_dinen,
      DINCOMMIT    => router_dincommit,
      DOUT         => router_dout,
      DOEN         => router_doen,
      DGRANT       => DGRANT,
      DGRANTBSTART => DGRANTBSTART);


  fakedspboard_0 : fakedspboard
    port map (
      CLK    => CLK,
      RXDIN  => TXDOUT,
      RXKIN  => TXKOUT,
      TXDOUT => RXDIN,
      TXKOUT => RXKIN);



  EDTXA <= EDTX;
  EDTXB <= EDTX;
  EDTXC <= EDTX;
  EDTXD <= EDTX;

  EDSELRXA <= EDSELRX;
  EDSELRXB <= EDSELRX;
  EDSELRXC <= EDSELRX;
  EDSELRXD <= EDSELRX;


  ecycle_generation : process(CLK)
  begin
    if rising_edge(CLK) then
      if pos = 999 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 999 then
        ECYCLE <= '1' after 4 ns;
      else
        ECYCLE <= '0' after 4 ns;
      end if;

      rxentoggle <= not rxentoggle;
      RXEN       <= rxentoggle;
    end if;
  end process ecycle_generation;


  event_packet_generation : process
  begin

    while true loop
      wait until rising_edge(CLK) and pos = 47;
      -- now we send the events
      for i in 0 to somabackplane.N -1 loop
                                        -- output the event bytes
        for j in 0 to 5 loop
          EDTX <= eventinputs(i)(j)(15 downto 8);
          wait until rising_edge(CLK);
          EDTX <= eventinputs(i)(j)(7 downto 0);
          wait until rising_edge(CLK);
        end loop;  -- j
      end loop;  -- i
    end loop;

  end process;


  -- recover data
  data_packet_capture : process
  begin
    for i in 0 to 1023 loop
      packetcapture(i) <= 0;
    end loop;  -- i

    wait until rising_edge(CLK) and router_doen = '1';
    for i in 0 to 1023 loop
      packetcapture(i) <= to_integer(unsigned(router_dout));
      wait until rising_edge(CLK);
      if router_doen = '0' then
        exit;
      end if;
    end loop;  -- i
    -- captured
    wait until rising_edge(CLK);
    packetcapturel <= packetcapture;
    newpacket      <= '1';
    wait until rising_edge(CLK);
    newpacket      <= '0';
    
  end process;

  -- validate date
  ---------------------------------------------------------------------------
  -- Each of these corresponds to one datasport in the fakedsp
  ---------------------------------------------------------------------------
  datavalidate : for i in 0 to 3 generate
    process
      -- we need the BEswap variables because we must seend each byte
      -- LSB first, but we need to send the high-byte first
      variable tmpword              : integer;
      variable tmpwordl, tmpwordh   : integer;
      variable pktlen, pktlenBEswap : std_logic_vector(15 downto 0) := X"0000";
      variable pktlen_integer       : integer                       := 0;
      variable pktword              : integer                       := 0;
    begin
      
      for bufnum in 0 to 19 loop
        while true loop
          
          wait until rising_edge(newpacket);
          if packetcapturel(0) = 0 and packetcapturel(1) = i then
            -- this is for us!
            pktlen_integer := bufnum*20 + 172;
            pktlen         := std_logic_vector(TO_UNSIGNED(pktlen_integer, 16));
            -- then the body
            for bufpos in 0 to (pktlen_integer/2)-1 loop
              if bufpos > 1 then
                tmpword := bufnum * 256 + bufpos + 4 + i;
                pktword := packetcapturel(bufpos * 2) * 256 +
                           packetcapturel(bufpos * 2 + 1);
                assert tmpword = pktword report "recovered word incorrect, expected "
                  & integer'image(tmpword) & " but received " & integer'image(pktword)

                  severity error;
                
              end if;
              
            end loop;
            exit;
          else

          end if;
        end loop;
      end loop;  -- bufnum
      rx_done(i) <= '1';
      wait;
    end process;
    
  end generate datavalidate;


  process
    begin
      wait until rising_edge(CLK) and rx_done = "1111";
      report "End of simulation" severity failure;
    end process;
    
end Behavioral;
