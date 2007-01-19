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

  signal ch1lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch1cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch2lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch2cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch3lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch3cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch4lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch4cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch5lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch5cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch6lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch6cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  signal ch7lencounter : std_logic_vector(47 downto 0) := (others => '0');
  signal ch7cntcounter : std_logic_vector(47 downto 0) := (others => '0');

  
  
begin  -- Behavioral

  CH0LEN <= ch0lencounter;
  CH0CNT <= ch0cntcounter;
  
  CH1LEN <= ch1lencounter;
  CH1CNT <= ch1cntcounter;
  
  CH2LEN <= ch2lencounter;
  CH2CNT <= ch2cntcounter;
  
  CH3LEN <= ch3lencounter;
  CH3CNT <= ch3cntcounter;
  
  CH4LEN <= ch4lencounter;
  CH4CNT <= ch4cntcounter;
  
  CH5LEN <= ch5lencounter;
  CH5CNT <= ch5cntcounter;
  
  CH6LEN <= ch6lencounter;
  CH6CNT <= ch6cntcounter;
  
  CH7LEN <= ch7lencounter;
  CH7CNT <= ch7cntcounter;
  
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

        -- channel 1
        if ch1rst = '1' then
          ch1lencounter <= (others => '0');
          ch1cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "001" then
            ch1lencounter <= ch1lencounter + PKTLEN;
            ch1cntcounter <= ch1cntcounter + 1; 
          end if;
        end if;

        -- channel 2
        if ch2rst = '1' then
          ch2lencounter <= (others => '0');
          ch2cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "010" then
            ch2lencounter <= ch2lencounter + PKTLEN;
            ch2cntcounter <= ch2cntcounter + 1; 
          end if;
        end if;

        -- channel 3
        if ch3rst = '1' then
          ch3lencounter <= (others => '0');
          ch3cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "011" then
            ch3lencounter <= ch3lencounter + PKTLEN;
            ch3cntcounter <= ch3cntcounter + 1; 
          end if;
        end if;

        -- channel 4
        if ch4rst = '1' then
          ch4lencounter <= (others => '0');
          ch4cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "100" then
            ch4lencounter <= ch4lencounter + PKTLEN;
            ch4cntcounter <= ch4cntcounter + 1; 
          end if;
        end if;

        -- channel 5
        if ch5rst = '1' then
          ch5lencounter <= (others => '0');
          ch5cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "101" then
            ch5lencounter <= ch5lencounter + PKTLEN;
            ch5cntcounter <= ch5cntcounter + 1; 
          end if;
        end if;

        -- channel 6
        if ch6rst = '1' then
          ch6lencounter <= (others => '0');
          ch6cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "110" then
            ch6lencounter <= ch6lencounter + PKTLEN;
            ch6cntcounter <= ch6cntcounter + 1; 
          end if;
        end if;

        -- channel 7
        if ch7rst = '1' then
          ch7lencounter <= (others => '0');
          ch7cntcounter <= (others => '0');
        else
          if PKTLENEN = '1' and TXCHAN = "111" then
            ch7lencounter <= ch7lencounter + PKTLEN;
            ch7cntcounter <= ch7cntcounter + 1; 
          end if;
        end if;

        
      end if;
    end process main; 

end Behavioral;
