-------------------------------------------------------------------------------
-- Title      : Device Receiver
-- Project    : 
-------------------------------------------------------------------------------
-- File       : devicerx.vhd
-- Author     : Eric Jonas  <jonas@localhost.localdomain>
-- Company    : 
-- Last update: 2006/01/31
-- Platform   : 
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006/01/31  1.0      jonas   Created
-------------------------------------------------------------------------------

entity devicerx is

  port (
    RXBYTECLK : in  std_logic;
    DIEN      : in  std_logic;
    KIN       : in  std_logic;
    ERR       : in  std_logic;
    DIN       : in  std_logic_vector(7 downto 0);
    CLK       : in  std_logic;
    RESET     : in  std_logic;
    DATAENA   : out std_logic;
    EDATAA    : out std_logic_vector(15 downto 0);
    EENA      : out std_logic;
    ECYCLE    : out std_logic;
    DATAENB   : out std_logic;
    EDATAB    : out std_logic_vector(15 downto 0);
    EENB      : out std_logic);

end devicerx;


architecture Behavioral of devicerx is

  -- input latching
  signal dienl : std_logic                    := '0';
  signal kinl  : std_logic                    := '0';
  signal errl  : std_logic                    := '0';
  signal dinl  : std_logic_vector(7 downto 0) := (others => '0');

  signal daen, dben : std_logic := '0';

  signal addra : std_logic_vector(39 downto 0) := (others => '0');
  signal easel : std_logic                     := '0';
  signal rb : std_logic_vector(10 downto 0) := (others => '0');

  signal addrb : std_logic_vector(39 downto 0) := (others => '0');
  signal ebsel : std_logic                     := '0';
  signal ra : std_logic_vector(10 downto 0) := (others => '0');

  signal addrin : std_logic_vector(3 downto 0) := (others => '0');

  signal ecnt : integer range 0 to 39 := 0;

  -- output side

  signal ecyc : std_logic := '0';

  signal oaa : std_logic_vector(9 downto 0) := (others => '0');

  signal ledataa   : std_logic_vector(15 downto 0) := (others => '0');
  signal ledataa   : std_logic                     := '0';
  signal neweventa : std_logic                     := '0';

  signal oab : std_logic_vector(9 downto 0) := (others => '0');

  signal ledatab   : std_logic_vector(15 downto 0) := (others => '0');
  signal ledatab   : std_logic                     := '0';
  signal neweventb : std_logic                     := '0';



begin  -- Behavioral


  EventBufferA: RAMB16_S9_S18
    port map (
      DOA   => open,
      DOB   => ledataa,
      DOPA  => open,
      DOPB  => open,
      ADDRA => ra,
      ADDRB => oaa,
      CLKA  => RXBYTECLK,
      CLKB  => CLK,
      DIA   => dinl,
      DIB   => X"0000",
      DIPA  => "0",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => RESET,
      SSRB  => RESET,
      WEA   => wea,
      WEB   => '0'); 
    
  EventBufferB: RAMB16_S9_S18
    port map (
      DOA   => open,
      DOB   => ledatab,
      DOPA  => open,
      DOPB  => open,
      ADDRA => rb,
      ADDRB => oab,
      CLKA  => RXBYTECLK,
      CLKB  => CLK,
      DIA   => dinl,
      DIB   => X"0000",
      DIPA  => "0",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => RESET,
      SSRB  => RESET,
      WEA   => web,
      WEB   => '0'); 
    
     
  -- input processes
  wea <= easel and dienl and wen; 
  easel <= addra(ecnt);

  ra(3 downto 0) <= addrin ;

  web <= ebsel and dienl and wen; 
  ebsel <= addrb(ecnt);

  rb(3 downto 0) <= addrin ;
  
  inputmain : process (RESET, RXBYTECLK)
  begin
    if RESET = '1' then

      else
        if rising_edge(RXBYTECLK) then

          -- latch inputs
          dienl <= DIEN;

          kinl <= KIN;
          errl <= ERR;
          
          dinl <= DIN;


          if dienl = '1' and cs = ebyte11 then
            ecnt <= ecnt + 1; 
          end if;
          
          if cs = dataena and dienl = '1' then
            daen <= dinl(0);
          end if;

          if dienl = '1' then
            if cs = addra0 then
              addra(7 downto 0) <= dinl; 
            end if;
            if cs = addra1 then
              addra(15 downto 8) <= dinl; 
            end if;
            if cs = addra2 then
              addra(23 downto 16) <= dinl; 
            end if;
            if cs = addra3 then
              addra(31 downto 24) <= dinl; 
            end if;
            if cs = addra4 then
              addra(39 downto 32) <= dinl; 
            end if;
            
          end if;

          if cs = ebyte11 and wea = '1' then
            ra(10 downto 4) <= ra(10 downto 4) + 1; 
          end if;

          
          if cs = dataenb and dienl = '1' then
            dben <= dinl(0);
          end if;

          if dienl = '1' then
            if cs = addrb0 then
              addrb(7 downto 0) <= dinl; 
            end if;
            if cs = addrb1 then
              addrb(15 downto 8) <= dinl; 
            end if;
            if cs = addrb2 then
              addrb(23 downto 16) <= dinl; 
            end if;
            if cs = addrb3 then
              addrb(31 downto 24) <= dinl; 
            end if;
            if cs = addrb4 then
              addrb(39 downto 32) <= dinl; 
            end if;
            
          end if;

          if cs = ebyte11 and web = '1' then
            rb(10 downto 4) <= rb(10 downto 4) + 1; 
          end if;
          
          
          
          
        end if;
    end if;


  end process inputmain;

  outputmain: process(CLK, RESET)
    begin
      if RESET = '1' then

      else
        if rising_edge(CLK) then

          ldataena <= daen;
          DATAENA <= ldataena;

          if wea = '1' and cs = ebyte11 and kinl = '0' and errl =  '0' then
            NEWEVENTA <= '1';
            else
                        NEWEVENTA <= '0'; 
          end if;
          
      
            
        end if;
      end if;

    end process outputmain; 
    
end Behavioral;
