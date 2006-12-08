library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.numeric_std.all;



library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;


entity rxeventfifo is
  port (
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    ECYCLE : in  std_logic;
    EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
    EDTX   : in  std_logic_vector(7 downto 0); 
    -- outputs
    EOUTD  : out std_logic_vector(15 downto 0);
    EOUTA  : in std_logic_vector(2 downto 0);
    EVALID : out std_logic;
    ENEXT  : in  std_logic
    );
end rxeventfifo;


architecture Behavioral of rxeventfifo is

  signal epos : std_logic_vector(6 downto 0) := (others => '0');
  signal bcnt : std_logic_vector(3 downto 0) := (others => '0');

  
  signal eincnt : std_logic_vector(6 downto 0) := (others => '0');

  signal elb, binc, einc : std_logic := '0';

  signal addra : std_logic_vector(10 downto 0) := (others => '0');

  signal estart : std_logic := '0';

  signal etxbit : std_logic := '0';
  signal eininc : std_logic := '0';
  
  -- output side signals
  signal eoutcnt : std_logic_vector(6 downto 0) := (others => '0');

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');
  signal eoutdint : std_logic_vector(15 downto 0) := (others => '0');
  
  -- input state machine

  type states is (none, ehdrw, event, ewait);

  signal cs, ns : states := none;

  signal epos_max : std_logic_vector(6 downto 0) := (others => '0');
  
begin  -- Behavioral

  -- combinational
  elb <= '1' when bcnt = "1011" else '0';

  eininc <= '1' when ( etxbit = '1' and cs = ewait and elb = '1') else '0';

  addra <= eincnt & bcnt;
  addrb <= eoutcnt & EOUTA;
  
  epos_max <=  std_logic_vector(TO_UNSIGNED(somabackplane.N -1, 7)); 
  etxbit <= EATX(conv_integer(epos)); -- when epos <= epos_max else '0'; 

  EVALID <= '1' when eincnt /= eoutcnt else '0'; 

  EOUTD <= eoutdint(7 downto 0) & eoutdint(15 downto 8);
  -- 
  mainin : process(CLK)
  begin
    if RESET = '1' then
      cs <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        -- counters

        -- EPOS COUNTER
        if estart = '1' then
          epos     <= (others => '0');
        else
          if elb = '1' then
            if epos = epos_max then
              epos <= (others => '0');
            else
              epos <= epos + 1;
            end if;

          end if;
        end if;

        -- BCNT COUNTER

        if elb = '1' or estart = '1' then
          bcnt <= (others => '0');
        else
          bcnt <= bcnt + 1;
        end if;

        -- EINCNT counter
        if eininc = '1' then
          eincnt <= eincnt + 1;
        end if;

        -- EOUTCNT counter
        if ENEXT = '1' then
          eoutcnt <= eoutcnt + 1;

        end if;

      end if;
    end if;

  end process mainin;


  fsm : process (cs, ECYCLE, epos, bcnt)
  begin
    case cs is
      when none =>
        estart <= '1';
        if ECYCLE = '1' then
          ns   <= ehdrw;
        else
          ns   <= none;
        end if;

      when ehdrw =>
        estart <= '0';
        if epos = "0000011" and bcnt = "1001" then
          ns   <= event;
        else
          ns   <= ehdrw;
        end if;

      when event  =>
        estart <= '1';
        ns     <= ewait;
      when ewait   =>
        estart <= '0';
        if (epos = std_logic_vector(TO_UNSIGNED(somabackplane.N -1, 7)))
          and bcnt = "1011" then
          ns   <= none;
        else
          ns   <= ewait;
        end if;
      when others =>
        estart <= '0';
        ns     <= none;
    end case;

  end process fsm;


  -- ram

  RAMB16_S9_S18_inst : RAMB16_S9_S18
    generic map (
      INIT_A              => X"000000000",   
      INIT_B              => X"000000000", 
      WRITE_MODE_A        => "WRITE_FIRST",  
      WRITE_MODE_B        => "WRITE_FIRST",  
      SIM_COLLISION_CHECK => "NONE"     
      )
    port map (
      DOA                 => open,
      DOB                 => eoutdint, 
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => EDTX,
      DIB                 => X"0000",
      DIPA                => "0",
      DIPB                => "00",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => RESET,
      SSRB                => RESET,
      WEA                 => '1',
      WEB                 => '0' 
      );

end Behavioral;
