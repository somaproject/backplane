library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack;
use WORK.somabackplane.all;
use Work.somabackplane;


entity datareceiver is
  port (
    typ       : in  integer   := 0;
    src       : in  integer   := 0;
    CLK       : in  std_logic;
    DIN       : in  std_logic_vector(15 downto 0);
    NEWFRAME  : in  std_logic;
    RXGOOD    : out std_logic := '0';
    RXCNT     : out integer   := 0;
    RXMISSING : out std_logic := '0');
end datareceiver;


architecture Behavioral of datareceiver is
  -- rxcnt is the count of data packets successfully received
  -- rxgood                             -- the most recent NEWFRAME cycle
  --                                    -- was a good packet
  -- RXMISSING : oops, we missed one
  -- RXERROR : valid packet, invalid data

  signal rxcntint   : integer                       := 0;
  signal newframel  : std_logic                     := '0';
  signal maybegood  : std_logic                     := '0';
  signal bytepos    : integer                       := 0;
  signal id_pending : integer                       := 0;
  signal id_input   : std_logic_vector(31 downto 0) := (others => '0');

begin  -- Behavioral
  RXCNT <= rxcntint;

  process(CLK)
    variable id : std_logic_vector(31 downto 0) := (others => '0');
  begin
    if rising_edge(CLK) then
      newframel <= NEWFRAME;
      id                                        := std_logic_vector(TO_UNSIGNED(id_pending, 32));
      if NEWFRAME = '0' then
        bytepos <= 0;
      elsif NEWFRAME = '1' and newframel = '0' then
        bytepos <= 1;
      else
        bytepos <= bytepos + 1;
      end if;

      if newframe = '1' and newframel = '0' then
        maybegood                  <= '1';
      else
        case bytepos is
          when 1  => when 2 => when 3 =>
            if DIN /= X"FFFF" then
              maybegood            <= '0';
            end if;
          when 19 =>
            if DIN /= std_logic_vector(TO_UNSIGNED(4000 + typ * 64 + src, 16))
            then
              maybegood            <= '0';
            end if;
          when 22 =>
            id_input(31 downto 16) <= DIN;
          when 23 =>
            id_input(15 downto 0)  <= DIN;
          when 24 =>
            if TO_INTEGER(unsigned(id_input)) = id_pending then
              RXMISSING            <= '0';
            elsif TO_INTEGER(unsigned(id_input)) > id_pending then
              if maybegood = '1' then
                RXMISSING            <= '1';
              end if;
              maybegood            <= '0';
            else
              maybegood            <= '0';
            end if;
            if DIN /= std_logic_vector(TO_UNSIGNED(typ, 8)) &
              std_logic_vector(TO_UNSIGNED(src, 8)) then
              maybegood            <= '0';
            end if;

          when others =>
            null;
        end case;
      end if;

      if newframe = '0' and newframel = '1' then
        RXGOOD       <= maybegood;
        if maybegood = '1' then
          rxcntint   <= rxcntint + 1;
          id_pending <= id_pending + 1;
        end if;
      end if;
    end if;
  end process;

end Behavioral;
