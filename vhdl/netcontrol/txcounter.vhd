library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity txcounter is

  port (
    CLK      : in  std_logic;
    PKTLENEN : in  std_logic;
    PKTLEN   : in  std_logic_vector(15 downto 0);
    TXCHAN   : in  std_logic_vector(2 downto 0);
    -- Channel 0
    CH0LEN   : out std_logic_vector(47 downto 0);
    CH0CNT   : out std_logic_vector(47 downto 0);
    CH0RST   : in  std_logic;
    -- Channel 1
    CH1LEN   : out std_logic_vector(47 downto 0);
    CH1CNT   : out std_logic_vector(47 downto 0);
    CH1RST   : in  std_logic;
    -- Channel 2
    CH2LEN   : out std_logic_vector(47 downto 0);
    CH2CNT   : out std_logic_vector(47 downto 0);
    CH2RST   : in  std_logic;
    -- Channel 3
    CH3LEN   : out std_logic_vector(47 downto 0);
    CH3CNT   : out std_logic_vector(47 downto 0);
    CH3RST   : in  std_logic;
    -- Channel 4
    CH4LEN   : out std_logic_vector(47 downto 0);
    CH4CNT   : out std_logic_vector(47 downto 0);
    CH4RST   : in  std_logic;
    -- Channel 5
    CH5LEN   : out std_logic_vector(47 downto 0);
    CH5CNT   : out std_logic_vector(47 downto 0);
    CH5RST   : in  std_logic;
    -- Channel 6
    CH6LEN   : out std_logic_vector(47 downto 0);
    CH6CNT   : out std_logic_vector(47 downto 0);
    CH6RST   : in  std_logic;
    -- Channel 7
    CH7LEN   : out std_logic_vector(47 downto 0);
    CH7CNT   : out std_logic_vector(47 downto 0);
    CH7RST   : in  std_logic
    );

end txcounter;

architecture Behavioral of txcounter is


  signal ch0lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch0cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  
  
begin  -- Behavioral

  main: process(CLK)
    begin
      if rising_edge(CLK) then

        -- channel 0 
        if ch0rst = '1' then
          ch0lencounter <= (others => '0');
          ch0cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "000" then
            ch0lencounter <= ch0lencounter + PKTLEN;
            ch0cntcounter <= ch0cntcounter + 1; 
          end if;
        end if;

        
      end if;
    end process main; 

end Behavioral;
