library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;

entity datasequencer is
  port (
    CLK       : in std_logic;
    ECYCLE    : in std_logic;
    DIN1      : in std_logic_vector(7 downto 0);
    DIN2      : in std_logic_vector(7 downto 0);
    DINEN     : in std_logic_vector(1 downto 0);
    DINCOMMIT : in std_logic_vector(1 downto 0);
    -- output dgrant control
    DGRANT       : out std_logic_vector(7 downto 0);
    DGRANTBSTART : out std_logic_vector(7 downto 0);
    -- output data interface
    DOUTACTIVE  : in std_logic;        -- trigger a dump, must happen EVERY
                                        -- DGRANTLEN ticks
    DOUT        : out std_logic_vector(7 downto 0) := (others => '0'); 
    DOEN        : out std_logic
    );
end datasequencer;

architecture Behavioral of datasequencer is
  -----------------------------------------------------------------------------
  -- Data sequencer 
  -----------------------------------------------------------------------------
  --
  --
  --
  -----------------------------------------------------------------------------
  
  constant DGRANTLEN : integer := 4;
  -- we assume we're going to be getting ~4x 256 byte chunks,
  -- so it's 4 bytes long

  signal cnt       : std_logic_vector(2 downto 0)     := (others => '1');
  signal dgrantpos : integer range 0 to DGRANTLEN - 1 := 0;

  signal bufdin       : std_logic_vector(7 downto 0) := (others => '0');
  signal bufdincommit : std_logic_vector(0 downto 0) := (others => '0');
  signal bufwe        : std_logic                    := '0';

  signal nextdgrant : std_logic := '0';

  signal addra : std_logic_vector(10 downto 0) := "00000000000";
  signal addrb : std_logic_vector(10 downto 0) := "00000000000";

  signal cyclecommit     : std_logic := '0';
  signal lastcyclecommit : std_logic := '0';

  signal dob   : std_logic_vector(7 downto 0) := (others => '0');
  signal doben : std_logic_vector(0 downto 0) := (others => '0');

  signal ldoen : std_logic := '0';
  
begin  -- Behavioral

  RAMB16_S9_S9_inst : RAMB16_S9_S9
    generic map (
      SIM_COLLISION_CHECK => "NONE")
    port map (
      DOA   => open,
      DOB   => dob,
      DOPB  => doben,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => bufdin,
      DIB   => X"00",
      DIPA  => bufdincommit,
      DIPB  => "0",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => bufwe,
      WEB   => '0'
      );

  
  process(CLK)
  begin
    if rising_edge(CLK) then
      if ECYCLE = '1' then
        if dgrantpos = DGRANTLEN - 1 then
          dgrantpos <= 0;
        else
          dgrantpos <= dgrantpos + 1;
        end if;

        if dgrantpos = DGRANTLEN -1 then
          cnt <= cnt + 1;
        end if;
        
      end if;

      if ECYCLE = '1' and dgrantpos = DGRANTLEN - 1 then
        nextdgrant <= '1';
      else
        nextdgrant <= '0';
      end if;

      if nextdgrant = '1' then
        addra(9 downto 0) <= (others => '0');
      else
        if bufwe = '1' then
          addra(9 downto 0) <= addra(9 downto 0) + 1;
        end if;
      end if;


      if nextdgrant = '1' then
        cyclecommit     <= '0';
      else
        if bufdincommit(0) = '1' and bufwe = '1' then
          addra(10)         <= not addra(10);
          
          cyclecommit <= '1';
        end if;
        if doben(0) = '1' then
        end if;
      end if;

      -- output
      if nextdgrant = '1' then
        addrb(9 downto 0) <= (others => '0');
        ldoen <= '0';
        lastcyclecommit <= cyclecommit;
        
      else
        if lastcyclecommit = '1' and DOUTACTIVE = '1' then
          if doben(0) = '0' then
            ldoen             <= '1';
            addrb(9 downto 0) <= addrb(9 downto 0) + 1;
          else
            ldoen <= '0';
            lastcyclecommit <= '0';
            addrb(10) <= not addrb(10); 
          end if;
        else
          ldoen <= '0'; 
        end if;
      end if;

      if ldoen = '1' and doben(0) = '0' then
        DOEN <= ldoen;
        DOUT <= dob;
      else
        DOEN <= '0';
      end if;

      
    end if;
  end process;

  bufdin <= DIN1 when cnt(2) = '0' else
            DIN2;

  bufwe <= DINEN(0) when cnt(2) = '0' else
           DINEN(1);
  
  bufdincommit(0) <= DINCOMMIT(0) when cnt(2) = '0' else
                     DINCOMMIT(1);

  grantgen : for i in 0 to 7 generate
    DGRANT(i)       <= '1' when cnt = conv_std_logic_vector(i, 3)                   else '0';
    DGRANTBSTART(i) <= '1' when cnt = conv_std_logic_vector(i, 3) and dgrantpos = 0 else '0';
  end generate grantgen;
  
end Behavioral;
