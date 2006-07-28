library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.vcomponents.all;


entity eventrxbusoutput is
  port (
    CLK     : in  std_logic;
    ADDROUT : out std_logic_vector(9 downto 0);
    EFREE   : out std_logic_vector(5 downto 0);
    DIN     : in  std_logic_vector(15 downto 0);
    ECNT    : in  std_logic_vector(3 downto 0);
    START   : in  std_logic;
    DONE    : out std_logic;
    -- event bus interface
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N -1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0)
    );

end eventrxbusoutput;

architecture Behavioral of eventrxbusoutput is

  -- input side
  signal ecntint : std_logic_vector(5 downto 0) := (others => '0');
  signal iaddr   : std_logic_vector(3 downto 0) := (others => '0');
  signal ibp     : std_logic_vector(5 downto 0) := (others => '0');

  signal addra : std_logic_vector(9 downto 0) := (others => '0');

  signal ibpinc, iaddrinc : std_logic := '0';

  type instates is (none, indone, echeck, inwait, nextevt);
  signal ics, ins : instates := none;


  -- output signals
  signal oaddr : std_logic_vector(3 downto 0) := (others => '0');
  signal obp   : std_logic_vector(5 downto 0) := (others => '0');
  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal leaout : std_logic_vector(79 downto 0) := (others => '0');
  signal ledout : std_logic_vector(95 downto 0) := (others => '0');
  signal edout  : std_logic_vector(95 downto 0) := (others => '0');

  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  type outstates is (none, inwait, oaddrinc, obpwinc, donew);
  signal ocs, ons : outstates := none;

  signal epos : integer range 0 to 999 := 0;



begin  -- Behavioral

  -- input constructions
  ADDROUT <= ecntint & iaddr;
  EFREE   <=  obp - ibp - 1;

  DONE <= '1' when ics = indone else '0';

  main_in : process(CLK)
  begin
    if rising_edge(CLK) then
      ics <= ins;

      addra <= ibp & iaddr;

      if ics = none then
        ecntint   <= (others => '0');
      else
        if ibpinc = '1' then
          ecntint <= ecntint + 1;
        end if;
      end if;

      if ics = echeck then
        iaddr   <= (others => '0');
      else
        if iaddrinc = '1' then
          iaddr <= iaddr + 1;
        end if;
      end if;

      if ibpinc = '1' then
        ibp <= ibp + 1;
      end if;


    end if;
  end process main_in;

  fsm_in : process(ics, START, ecntint, ECNT, iaddr)
  begin
    case ics is
      when none =>
        iaddrinc <= '0';
        ibpinc   <= '0';
        if START = '1' then
          ins    <= echeck;
        else
          ins    <= none;
        end if;

      when echeck =>
        iaddrinc <= '0';
        ibpinc   <= '0';
        if ecntint = ECNT then
          ins    <= indone;
        else
          ins    <= inwait;
        end if;

      when inwait =>
        iaddrinc <= '1';
        ibpinc   <= '0';
        if iaddr = X"B" then
          ins    <= nextevt;
        else
          ins    <= inwait;
        end if;

      when nextevt =>
        iaddrinc <= '0';
        ibpinc   <= '1';
        ins      <= echeck;

      when indone =>
        iaddrinc <= '0';
        ibpinc   <= '0';
        ins      <= none;

      when others =>
        iaddrinc <= '0';
        ibpinc   <= '0';
        ins      <= none;

    end case;
  end process fsm_in;

-- output side

  addrb <= obp & oaddr;

  EDRX <= edout(7 downto 0) when EDSELRX = X"0" else
          edout(15 downto 8) when EDSELRX = X"1" else
          edout(23 downto 16) when EDSELRX = X"2" else
          edout(31 downto 24) when EDSELRX = X"3" else
          edout(39 downto 32) when EDSELRX = X"4" else
          edout(47 downto 40) when EDSELRX = X"5" else
          edout(55 downto 48) when EDSELRX = X"6" else
          edout(63 downto 56) when EDSELRX = X"7" else
          edout(71 downto 64) when EDSELRX = X"8" else
          edout(79 downto 72) when EDSELRX = X"9" else
          edout(87 downto 80)  when EDSELRX = X"A" else
          edout(95 downto 88); 

  main_out : process(CLK)
  begin
    if rising_edge(CLK) then

      ocs <= ons;

      if ECYCLE = '1' then
        epos   <= 0;
      else
        if epos = 999 then
          epos <= 0;
        else
          epos <= epos + 1;
        end if;

      end if;

      -- addresses
      if ocs = obpwinc then
        obp <= obp + 1;
      end if;

      if ocs = inwait then
        oaddr   <= (others => '0');
      else
        if ocs = oaddrinc then
          oaddr <= oaddr + 1;
        end if;

      end if;


      -- address capture
      if ocs = inwait then
        leaout(15 downto 0)   <= (others => '0');
      else
        if oaddr = "0001" then
          leaout(15 downto 0) <= dob;
        end if;
      end if;

      if ocs = inwait then
        leaout(31 downto 16)   <= (others => '0');
      else
        if oaddr = "0010" then
          leaout(31 downto 16) <= dob;
        end if;
      end if;

      if ocs = inwait then
        leaout(47 downto 32)   <= (others => '0');
      else
        if oaddr = "0011" then
          leaout(47 downto 32) <= dob;
        end if;
      end if;

      if ocs = inwait then
        leaout(63 downto 48)   <= (others => '0');
      else
        if oaddr = "0100" then
          leaout(63 downto 48) <= dob;
        end if;
      end if;

      if ocs = inwait then
        leaout(79 downto 64)   <= (others => '0');
      else
        if oaddr = "0101" then
          leaout(79 downto 64) <= dob;
        end if;
      end if;

      -- data capture

      if ocs = inwait then
        ledout(15 downto 0)    <= (others => '0');
      else
        if oaddr = "0110" then
          ledout(15 downto 0) <= dob;
        end if;
      end if;

      if ocs = inwait then
        ledout(31 downto 16)   <= (others => '0');
      else
        if oaddr = "0111" then
          ledout(31 downto 16) <= dob;
        end if;
      end if;

      if ocs = inwait then
        ledout(47 downto 32)   <= (others => '0');
      else
        if oaddr = "1000" then
          ledout(47 downto 32) <= dob;
        end if;
      end if;

      if ocs = inwait then
        ledout(63 downto 48)   <= (others => '0');
      else
        if oaddr = "1001" then
          ledout(63 downto 48) <= dob;
        end if;
      end if;

      if ocs = inwait then
        ledout(79 downto 64)   <= (others => '0');
      else
        if oaddr = "1010" then
          ledout(79 downto 64) <= dob;
        end if;
      end if;

      if ocs = inwait then
        ledout(95 downto 80)   <= (others => '0');
      else
        if oaddr = "1011" then
          ledout(95 downto 80) <= dob;
        end if;
      end if;


      -- final outputs
      EARX  <= leaout(somabackplane.N - 1 downto 0);
      EDOUT <= ledout;


    end if;
  end process main_out;


  fsm_out : process(ocs, ECYCLE, epos, ibp, obp)
  begin
    case ocs is
      when none =>
        if ecycle = '1' then
          ons <= inwait;
        else
          ons <= none;
        end if;

      when inwait =>
        if epos > 980 then
          ons   <= none;
        else
          if ibp /= obp then
            ons <= oaddrinc;
          else
            ons <= inwait;
          end if;
        end if;

      when oaddrinc =>
        if oaddr = X"B" then
          ons <= obpwinc;
        else
          ons <= oaddrinc;
        end if;

      when obpwinc =>
        ons <= donew;

      when donew =>
        if ECYCLE = '1' then
          ons <= inwait;
        else
          ons <= donew;
        end if;

      when others =>
        ons <= none;
    end case;
  end process fsm_out;


  rambuffer : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "NONE")

    port map (
      DOA   => open,
      DOB   => dob,
      DOPA  => open,
      DOPB  => open,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => DIN,
      DIB   => X"0000",
      DIPA  => "00",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => iaddrinc,
      WEB   => '0'
      );

end Behavioral;


