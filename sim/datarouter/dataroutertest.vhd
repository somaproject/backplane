library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity dataroutertest is

end dataroutertest;

architecture Behavioral of dataroutertest is

  component datarouter
    port (
      CLK       : in  std_logic;
      ECYCLE    : in  std_logic;
      DIN       : in  somabackplane.dataroutearray;
      DINEN     : in  std_logic_vector(7 downto 0);
      DINCOMMIT : in  std_logic_vector(7 downto 0);
      DOUT      : out std_logic_vector(7 downto 0);
      DOEN      : out std_logic;
      DGRANT    : out std_logic_vector(31 downto 0);
      DGRANTBSTART : out std_logic_vector(31 downto 0)      
      );
  end component;

  signal CLK    : std_logic                    := '0';
  signal ECYCLE : std_logic                    := '0';
  signal DIN    : somabackplane.dataroutearray := (others => (others => '0'));

  signal DINEN : std_logic_vector(7 downto 0) := (others => '0');

  signal DINCOMMIT : std_logic_vector(7 downto 0) := (others => '0');

  signal DOUT : std_logic_vector(7 downto 0) := (others => '0');

  signal DOEN   : std_logic                     := '0';
  signal DGRANT : std_logic_vector(31 downto 0) := (others => '0');
  signal DGRANTBSTART : std_logic_vector(31 downto 0) := (others => '0');

  signal ecnt : integer range 0 to 999 := 990;

  type packetcapture_t is array (0 to 1023) of std_logic_vector(7 downto 0);  -- (others

  signal pktcapture     : packetcapture_t := (others => (others => '0'));
  signal pktcapture_len : integer         := 0;
  signal pktcapture_new : std_logic       := '0';

  signal validate : std_logic_vector(7 downto 0) := (others => '0');

  signal ecyclepos : integer := 0;
  
begin  -- Behavioral

  clk <= not clk after 10 ns;           -- 50 MHz

  datarouter_uut : datarouter
    port map (
      CLK       => CLK,
      ECYCLE    => ECYCLE,
      DIN       => DIN,
      DINEN     => DINEN,
      DINCOMMIT => DINCOMMIT,
      DOUT      => DOUT,
      DOEN      => DOEN,
      DGRANT    => DGRANT,
      DGRANTBSTART => DGRANTBSTART); 

  ecyclegen : process (CLK)
  begin  -- process ecyclegen
    if rising_edge(clk) then
      if ecnt = 999 then
        ecnt <= 0;
      else
        ecnt <= ecnt + 1;
      end if;

      if ecnt = 999 then
        ECYCLE <= '1';
        ecyclepos <= ecyclepos + 1; 
      else
        ECYCLE <= '0';
      end if;

    end if;
  end process ecyclegen;


  -- data sending processes
  --  We have eight processes, each of which sends data of varying lengths
  --
  --
  data_gen_proc : for src in 0 to 7 generate
    signal dgrantl : std_logic := '0';
    signal lastecyclepos : integer := 0;
    begin
      
    tp: process
    begin
      for pktcnt in 0 to 10 loop
        wait until rising_edge(DGRANT(src*4));
        if pktcnt = 0 then
          lastecyclepos <= ecyclepos;
        else
          if (ecyclepos - lastecyclepos) > 50 then  -- must have dgrant once
                                                    -- per ms!!
            report "Error, did not receive dgrant within the past 1 ms (50 ecyclepos counts)" severity error;
          end if;
          lastecyclepos <= ecyclepos; 
        end if;
        wait until rising_edge(CLK);
        wait until rising_edge(CLK);

        -- start of a grant cycle
        for j in 0 to (src mod 4) loop
          -- send this much data
          for bpos in 0 to 249 loop
            if bpos = 0 then
              DIN(src) <= std_logic_vector(TO_UNSIGNED(src, 8));
            elsif bpos = 1 then
              DIN(src) <= std_logic_vector(TO_UNSIGNED(j, 8));
            else
              DIN(src) <= std_logic_vector(TO_UNSIGNED(bpos, 8));
            end if;
            DINEN(src) <= '1';
            wait until rising_edge(CLK);
            DINEN(src) <= '0';
            wait until rising_edge(CLK);
            
          end loop;  -- i
          if j = (src mod 4) then
            -- this is the end, commit
            wait until rising_edge(CLK);
            DINCOMMIT(src) <= '1';
            DINEN(src)     <= '1';
            wait until rising_edge(CLK);
            DINEN(src)     <= '0';
            DINCOMMIT(src) <= '0';
            
          end if;
          wait until rising_edge(CLK) and ECYCLE = '1';
        end loop;  -- j
        
      end loop;  -- pktcnt

      wait;
    end process tp;
    
  end generate data_gen_proc;

  -----------------------------------------------------------------------------
  -- VALIDATION 
  -----------------------------------------------------------------------------
  --  Validation is a bit odd -- we don't want to be tied to a particular
  -- sequencing of dgrant, we just want to make sure that we receive all
  -- of the relevant data. So we have each source inspect the header
  -- of the out-putted packet, and validate its own. 
  --
  -----------------------------------------------------------------------------

  -- code to capture a packet

  process
    variable pktpos : integer := 0;
  begin
    wait until rising_edge(CLK) and DOEN = '1';
    pktpos := 0;
    while DOEN = '1' loop
      pktcapture(pktpos) <= DOUT;
      pktpos             := pktpos + 1;
      wait until rising_edge(CLK);
    end loop;

    pktcapture_len <= pktpos;
    wait until rising_edge(CLK);
    pktcapture_new <= '1';
    wait until rising_edge(CLK);
    pktcapture_new <= '0';
    
  end process;

  -- validation
  data_validate_proc : for src in 0 to 7 generate
    
    process
      variable possible_success : boolean := false;
      variable success_count    : integer := 0;
    begin
      wait until rising_edge(CLK) and pktcapture_new = '1';
      if pktcapture(0) = std_logic_vector(to_unsigned(src, 8)) then
        -- for us;
        --
        possible_success := true;
        
      end if;

      if possible_success then
        success_count := success_count + 1;
      end if;

      if success_count = 10 then
        validate(src) <= '1';
      end if;
    end process;
    
  end generate data_validate_proc;

  -- done validate
  data_validate_all: process(CLK)
    begin
      if rising_edge(CLK) then
        if validate = "11111111" then
          report "End of Simulation" severity failure;
        end if;
      end if;
    end process;

    
end Behavioral;
