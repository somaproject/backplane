
-- VHDL Test Bench Created from source file databus_control.vhd -- 17:02:28 05/18/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT databus_control
	PORT(
		clk : IN std_logic;
		sysdata : IN std_logic_vector(15 downto 0);
		dack : IN std_logic;
		reset : IN std_logic;
		raddrr : IN std_logic_vector(19 downto 0);    
		data : INOUT std_logic_vector(15 downto 0);      
		den : OUT std_logic_vector(15 downto 0);
		we : OUT std_logic;
		addr : OUT std_logic_vector(19 downto 0);
		clk2x : OUT std_logic;
		rdatar : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL sysdata :  std_logic_vector(15 downto 0);
	SIGNAL dack :  std_logic := 'H';
	SIGNAL den :  std_logic_vector(15 downto 0);
	SIGNAL reset :  std_logic;
	SIGNAL we :  std_logic;
	SIGNAL addr :  std_logic_vector(19 downto 0);
	SIGNAL data :  std_logic_vector(15 downto 0);
	SIGNAL clk2x :  std_logic;
	SIGNAL rdatar :  std_logic_vector(15 downto 0);
	SIGNAL raddrr :  std_logic_vector(19 downto 0);
	signal dq : std_logic_vector(17 downto 0); 

-- testing components
	component simDSPboard_simple is
	    Port ( CLK : in std_logic;
	           SYSDATA : out std_logic_vector(15 downto 0);
	           DEN : in std_logic;
	           DACK : out std_logic);
	end component;
	component mt55l256l18p IS
	    GENERIC (
	        -- Constant parameters
	        addr_bits : INTEGER := 18;
	        data_bits : INTEGER := 18;

	        -- Timing parameters for -10 (100 Mhz)
	        tKHKH    : TIME    := 10.0 ns;
	        tKHKL    : TIME    :=  2.5 ns;
	        tKLKH    : TIME    :=  2.5 ns;
	        tKHQV    : TIME    :=  5.0 ns;
	        tAVKH    : TIME    :=  2.0 ns;
	        tEVKH    : TIME    :=  2.0 ns;
	        tCVKH    : TIME    :=  2.0 ns;
	        tDVKH    : TIME    :=  2.0 ns;
	        tKHAX    : TIME    :=  0.5 ns;
	        tKHEX    : TIME    :=  0.5 ns;
	        tKHCX    : TIME    :=  0.5 ns;
	        tKHDX    : TIME    :=  0.5 ns
	    );

	    -- Port Declarations
	    PORT (
	        Dq        : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0);   -- Data I/O
	        Addr      : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0);   -- Address
	        Lbo_n     : IN    STD_LOGIC;                                   -- Burst Mode
	        Clk       : IN    STD_LOGIC;                                   -- Clk
	        Cke_n     : IN    STD_LOGIC;                                   -- Cke#
	        Ld_n      : IN    STD_LOGIC;                                   -- Adv/Ld#
	        Bwa_n     : IN    STD_LOGIC;                                   -- Bwa#
	        Bwb_n     : IN    STD_LOGIC;                                   -- BWb#
	        Rw_n      : IN    STD_LOGIC;                                   -- RW#
	        Oe_n      : IN    STD_LOGIC;                                   -- OE#
	        Ce_n      : IN    STD_LOGIC;                                   -- CE#
	        Ce2_n     : IN    STD_LOGIC;                                   -- CE2#
	        Ce2       : IN    STD_LOGIC;                                   -- CE2
	        Zz        : IN    STD_LOGIC                                    -- Snooze Mode
	    );
	END component;



attribute box_type : string;



attribute box_type of mt55l256l18p : component is "black_box";
attribute box_type of simDSPboard_simple : component is "black_box";



	constant Tperiod : time := 50 ns; 

BEGIN

	uut: databus_control PORT MAP(
		clk => clk,
		sysdata => sysdata,
		dack => dack,
		den => den,
		reset => reset,
		we => we,
		addr => addr,
		data => data,
		clk2x => clk2x,
		rdatar => rdatar,
		raddrr => raddrr
	);

	DSPboard_0: simDSPboard_simple port map (
		CLK => CLK,
		SYSDATA => sysdata,
		DEN => den(0),
		DACK => dack ); 

	DSPboard_1: simDSPboard_simple port map (
		CLK => CLK,
		SYSDATA => sysdata,
		DEN => den(1),
		DACK => dack ); 
     DQ <= ("00" & DATA); 

	ZBT_RAM:  mt55l256l18p generic map (
		        -- Timing parameters for -7.5 (133 Mhz)
		        tKHKH => 7.5 ns,
		        tKHKL => 2.0 ns,
		        tKLKH => 2.0 ns,
		        tKHQV => 4.2 ns,
		        tAVKH => 1.7 ns,
		        tEVKH => 1.7 ns,
		        tCVKH => 1.7 ns,
		        tDVKH => 1.7 ns,
		        tKHAX => 0.5 ns,
		        tKHEX => 0.5 ns,
		        tKHCX => 0.5 ns,
		        tKHDX => 0.5 ns)
				port map (
		        Dq =>  dq,   -- Data I/O
		        Addr  => ADDR(17 downto 0),   -- Address
		        Lbo_n  => '1',  -- Burst Mode
		        Clk    => clk2x, -- Clk
		        Cke_n  => '0',  -- Cke#
		        Ld_n   => '0', -- Adv/Ld#
		        Bwa_n  => '0', -- Bwa#
		        Bwb_n  => '0', -- BWb#
		        Rw_n   => we, -- RW#
		        Oe_n   => '0', -- OE#
		        Ce_n   => '0', -- CE#
		        Ce2_n  => '0', -- CE2#
		        Ce2    => '1', -- CE2
		        Zz     => '0' -- Snooze Mode
				  ); 		

-- clocks
	clk <= not clk after Tperiod/2; 

   reset <= '0' after 40 ns; 

   dack <= 'H';


   rdatar <= (others => '0');
   raddrr <= (others => '0');



   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;

END;
