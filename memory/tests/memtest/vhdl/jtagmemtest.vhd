library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity jtagmemtest is
  port (
    CLK    : in    std_logic;
    CLK90  : in    std_logic;
    CLK180 : in    std_logic;
    CLK270 : in    std_logic;
    RESET  : in    std_logic;
    -- RAM!
    CKE    : out   std_logic;
    CAS    : out   std_logic;
    RAS    : out   std_logic;
    CS     : out   std_logic;
    WE     : out   std_logic;
    ADDR   : out   std_logic_vector(12 downto 0);
    BA     : out   std_logic_vector(1 downto 0);
    DQSH   : inout std_logic;
    DQSL   : inout std_logic;
    DQ     : inout std_logic_vector(15 downto 0);
    -- interface
    START  : in    std_logic;
    RW     : in    std_logic;
    DONE   : out   std_logic;
    ROWTGT : in    std_logic_vector(14 downto 0);
    -- write interface
    WRADDR : out   std_logic_vector(7 downto 0);
    WRDATA : in    std_logic_vector(31 downto 0);
    -- read interface
    RDADDR : out   std_logic_vector(7 downto 0);
    RDDATA : out   std_logic_vector(31 downto 0);
    RDWE   : out   std_logic ;
    DEBUG : out std_logic_vector(3 downto 0));
end jtagmemtest;

architecture Behavioral of jtagmemtest is

  signal addrcnt           : std_logic_vector(8 downto 0) := (others => '0');
  signal wraddrl, wraddrll : std_logic_vector(8 downto 0) := (others => '0');
  signal weint                : std_logic                    := '0';


begin  -- Behavioral

  CKE  <= '0';
  CAS  <= '1';
  RAS  <= '1';
  CS   <= '0';
  WE   <= '1';
  ADDR <= (others => '0');
  BA   <= (others => '0');
  DQSH <= 'Z';
  DQSL <= 'Z';
  DQ   <= (others => 'Z');



  -- start RW simply reads into our block ram

  process(CLK)
  begin
    if rising_edge(CLK) then

      if START = '1' then
        addrcnt   <= (others => '0');
      else
        if addrcnt /= "100000000" then
          addrcnt <= addrcnt + 1;
        end if;
      end if;

      if RW = '1' then
        if wraddrl /= "100000000" then
          weint <= '1';
        else
          weint <= '0';
        end if;
      else
        weint   <= '0';
      end if;

      
      wraddrl  <= addrcnt;
      wraddrll <= wraddrl;
      if RW = '0' then
        if addrcnt /= "100000000" then
          RDWE <= '1';
        else
          RDWE <= '0'; 
        end if;
      end if;
      RDADDR <= addrcnt(7 downto 0);

    end if;
  end process;

  WRADDR <= addrcnt(7 downto 0);


  -- the A interface is for input(write), the B is for reading

  RAMB16_S36_S36_inst : RAMB16_S36_S36
    port map (
      DOA   => open,                    -- Port A 32-bit Data Output
      DOB   => RDDATA,                  -- Port B 32-bit Data Output
      ADDRA => wraddrll,                -- Port A 9-bit Address Input
      ADDRB => addrcnt,                 -- Port B 9-bit Address Input
      CLKA  => CLK,                     -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => WRDATA,                  -- Port A 32-bit Data Input
      DIB   => X"00000000",             -- Port B 32-bit Data Input
      DIPA  => "0000",                  -- Port A 4-bit parity Input
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => '1',                     -- Port A RAM Enable Input
      ENB   => '1',                     -- PortB RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => weint,                      -- Port A Write Enable Input
      WEB   => '0'                      -- Port B Write Enable Input
      );



end Behavioral;
