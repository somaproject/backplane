library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;


entity eventrxtest is
end eventrxtest;

architecture behavior of eventrxtest is


  component eventrx

    port (
      TXBYTECLK : in  std_logic;
      RXBYTECLK : in  std_logic;
      DIN       : in  std_logic_vector(7 downto 0);
      KIN       : in  std_logic;
      ERR       : in  std_logic;
      DIEN      : in  std_logic;
      EDATASEL  : in  std_logic_vector(3 downto 0);
      EADDRA    : out std_logic_vector(39 downto 0);
      EDATAA    : out std_logic_vector(7 downto 0);
      EADDRB    : out std_logic_vector(39 downto 0);
      EDATAB    : out std_logic_vector(7 downto 0);
      ECYCLE    : in  std_logic
      );

  end component;

  signal TXBYTECLK      : std_logic                     := '0';
  signal RXBYTECLK      : std_logic                     := '0';
  signal DIN            : std_logic_vector(7 downto 0)  := (others => '0');
  signal KIN            : std_logic                     := '0';
  signal ERR            : std_logic                     := '0';
  signal DIEN          : std_logic                     := '0';
  signal EDATASEL       : std_logic_vector(3 downto 0) := (others => '0');
  signal EADDRA, EADDRB : std_logic_vector(39 downto 0) := (others => '0');
  signal EDATAA, EDATAB : std_logic_vector(7 downto 0)  := (others => '0');
  signal ECYCLE         : std_logic                     := '0';

  constant TXBYTECLKPERIOD : time             := 40 ns;
  constant K28_0           : std_logic_vector := "00011100";
  constant K28_1           : std_logic_vector := "00111100";

  signal eventstr : std_logic_vector(95 downto 0);
  signal addrstr  : std_logic_vector(39 downto 0);

  signal addrin  : std_logic_vector(39 downto 0);
  signal datain  : std_logic_vector(95 downto 0);
  signal kcharin : std_logic_vector(7 downto 0);

  signal addraout : std_logic_vector(39 downto 0);
  signal dataaout : std_logic_vector(95 downto 0);
  signal addrbout : std_logic_vector(39 downto 0);
  signal databout : std_logic_vector(95 downto 0);


  signal assert_event, assert_event_done : std_logic := '0';
  signal write_event, write_event_done  : std_logic := '0';

begin

  eventrx_uut : eventrx port map (
    TXBYTECLK => TXBYTECLK,
    RXBYTECLK => RXBYTECLK,
    DIN       => DIN,
    KIN       => KIN,
    ERR       => ERR,
    DIEN      => DIEN,
    EDATASEL  => EDATASEL,
    EADDRA    => EADDRA,
    EDATAA    => EDATAA,
    EADDRB    => EADDRB,
    EDATAB    => EDATAB,
    ECYCLE    => ECYCLE);

  TXBYTECLK <= not TXBYTECLK after TXBYTECLKPERIOD/2;
  RXBYTECLK <= not RXBYTECLK after (TXBYTECLKPERIOD * 31/32)/2;

  assert_event_proc : process 
  begin
    while true loop
      wait until rising_edge(assert_event);
      assert_event_done <= '1'; 
      wait until rising_edge(ECYCLE);
      wait until rising_edge(TXBYTECLK);
      wait for 5 ns;
      

      assert addraout = EADDRA report "Error in address for event A"
      severity error;
      assert addrbout = EADDRB report "Error in address for event B"
      severity error;

      wait until rising_edge(TXBYTECLK);
      for j in 0 to 11 loop
        EDATASEL <= std_logic_vector(TO_UNSIGNED(j, 4));
        wait until rising_edge(TXBYTECLK);
        if addraout /= X"0000000000" then
          assert dataaout((j+1)*8-1 downto j*8) = EDATAA
            report "Error reading event A byte" severity error;
        end if;

        if addrbout /= X"0000000000" then
          assert databout((j+1)*8-1 downto j*8) = EDATAB
            report "Error reading event B byte" severity error;
        end if;

      end loop;  -- j

      assert_event_done <= '0'; 
    end loop;

  end process assert_event_proc;


  event_cycle    : process(TXBYTECLK)
    variable cnt : integer range 0 to 499 := 480;
  begin
    if rising_edge(TXBYTECLK) then
      if cnt = 499 then
        cnt                               := 0;
      else
        cnt                               := cnt +1;
      end if;

      if cnt = 499 then
        ECYCLE <= '1';
      else
        ECYCLE <= '0';
      end if;
    end if;
  end process event_cycle;


  write_event_proc : process 
  begin
    while 1 = 1 loop
      wait until rising_edge(write_event);
      write_event_done <= '1'; 
      wait until rising_edge(RXBYTECLK);
      DIN    <= kcharin;
      DIEN   <= '1';
      KIN    <= '1';
      for i in 0 to 4 loop
        wait until rising_edge(RXBYTECLK);
        DIN  <= addrin((i+1)*8-1 downto i*8);
        DIEN <= '1';
        KIN  <= '0';
      end loop;  -- i

      for i in 0 to 11 loop
        wait until rising_edge(RXBYTECLK);
        DIN  <= datain((i+1)*8-1 downto i*8);
        DIEN <= '1';
        KIN  <= '0';

      end loop;  -- i
      write_event_done <= '0'; 
    end loop;
  end process write_event_proc;


  maintest : process
  begin
    -- a very simple test
    wait until falling_edge(ECYCLE);
    
  
  -- we shouldn't get anything:
    addraout <= X"0000000000";
    dataaout <= X"000000000000000000000000";
    addrbout <= X"0000000000";
    databout <= X"000000000000000000000000";
    assert_event <= '1';
    wait for 4 ns;
    assert_event <= '0'; 
    wait until falling_edge(assert_event_done);
    report "done with null read";
    

    ---------------------------------------------------------------------------
    -- Event A write
    -------------------------------------------------------------------------
    
    kcharin <= k28_0;
    addrin <= X"ABCDEF1234"; 
    datain <=  X"0123456789ABCDEF01234567";
    
    write_event <= '1';
        wait for 4 ns;
    write_event <= '0'; 
    wait until falling_edge(write_event_done);

    addraout <= X"ABCDEF1234"; 
    dataaout <= X"0123456789ABCDEF01234567";
    addrbout <= X"0000000000";
    databout <= X"000000000000000000000000";
    report "Verifying Event A Write...";
    assert_event <= '1';
    wait for 4 ns;
    assert_event <= '0'; 
    wait until falling_edge(assert_event_done);


    ---------------------------------------------------------------------------
    -- Event B write
    -------------------------------------------------------------------------
    
    kcharin <= k28_1;
    addrin <= X"CDEF1234AB"; 
    datain <=  X"0123456789ABCDEF01234567";
    
    write_event <= '1';
        wait for 4 ns;
    write_event <= '0'; 
    wait until falling_edge(write_event_done);

    addrbout <= X"CDEF1234AB"; 
    databout <= X"0123456789ABCDEF01234567";
    addraout <= X"0000000000";
    dataaout <= X"000000000000000000000000";

    report "Verifying Event B Write...";    
    assert_event <= '1';
    wait for 4 ns;
    assert_event <= '0'; 
    wait until falling_edge(assert_event_done);

    


    ---------------------------------------------------------------------------
    -- Event A &  B write
    -------------------------------------------------------------------------
    
    kcharin <= k28_0;
    addrin <= X"1122334455"; 
    datain <=  X"999988889ac4145888899887";
    
    write_event <= '1';
    wait for 4 ns;
    write_event <= '0'; 
    wait until falling_edge(write_event_done);

    kcharin <= k28_1;
    addrin <= X"CDEF553411"; 
    datain <=  X"000000000000000EF0123457";
    
    write_event <= '1';
        wait for 4 ns;
    write_event <= '0'; 
    wait until falling_edge(write_event_done);

    
    addraout <= X"1122334455"; 
    dataaout <= X"999988889ac4145888899887";
    addrbout <= X"CDEF553411";
    databout <= X"000000000000000EF0123457";
    report "verifying A & B write";
    
    assert_event <= '1';
    wait for 4 ns;
    assert_event <= '0'; 
    wait until falling_edge(assert_event_done);


    assert false report "End of Simulation" severity FAILURE;    

  end process;


end;
