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


entity eventreceiver is
  port (
    CLK       : in  std_logic;
    DIN       : in  std_logic_vector(15 downto 0);
    NEWFRAME  : in  std_logic;
    RXGOOD    : out std_logic := '0';
    RXCNT     : out integer   := 0;
    RXMISSING : out std_logic := '0');
end eventreceiver;


architecture Behavioral of eventreceiver is
  signal rxcntint     : integer                       := 0;
  signal newframel    : std_logic                     := '0';
  signal maybegood    : std_logic                     := '0';
  signal bytepos      : integer                       := 0;
  signal time_pending : integer                       := 0;
  signal time_input   : std_logic_vector(31 downto 0) := (others => '0');
  signal read_len     : integer                       := 0;
  signal rxmissingint : std_logic                     := '0';

begin  -- Behavioral
  RXCNT     <= rxcntint;
  RXMISSING <= rxmissingint;

  process(CLK)
    variable tim : std_logic_vector(47 downto 0) := (others => '0');
  begin
    if rising_edge(CLK) then
      newframel <= NEWFRAME;

      tim := std_logic_vector(TO_UNSIGNED(time_pending, 48));

      if NEWFRAME = '0' then
        bytepos <= 0;
      elsif NEWFRAME = '1' and newframel = '0' then
        bytepos <= 1;
      else
        bytepos <= bytepos + 1;
      end if;

      if newframe = '1' and newframel = '0' then
        maybegood                    <= '1';
      else
        case bytepos is
          when 1  => when 2 => when 3 =>
            if DIN /= X"FFFF" then
              maybegood              <= '0';
            end if;
          when 19 =>
            if DIN /= std_logic_vector(TO_UNSIGNED(5000, 16))
            then
              maybegood              <= '0';
            end if;
          when 22 =>
            read_len                 <= TO_INTEGER(unsigned(DIN));
            if DIN /= std_logic_vector(TO_UNSIGNED(somabackplane.N, 16)) then
              maybegood              <= '0';
            end if;
          when 23 =>
            if DIN /= X"1000" then
              maybegood              <= '0';
            end if;
          when 24 =>
            --time_input(47 downto 32) <= DIN;
            null;
          when 25 =>
            time_input(31 downto 16) <= DIN;
          when 26 =>
            time_input(15 downto 0)  <= DIN;
          when 27 =>
            if maybegood = '1' then

              if TO_INTEGER(unsigned(time_input))
                 = time_pending then
                RXMISSINGint <= '0';
              elsif TO_INTEGER(unsigned(time_input))
                /= time_pending then
                RXMISSINGint <= '1';
                maybegood    <= '0';
              else
                maybegood    <= '0';
              end if;


            end if;
          when others =>
            null;
        end case;
      end if;

      if newframe = '0' and newframel = '1' then
        RXGOOD <= maybegood;
        if maybegood = '1' then
          report "Received correct event packet";

          rxcntint     <= rxcntint + 1;
          time_pending <= time_pending + 1;

          -- if RXMISSING and maybegood then
          -- this is an error
          if rxmissingint = '1' and maybegood = '1' then
            report "Missing Event packet" severity error;
          end if;

        end if;
      end if;
    end if;
  end process;

end Behavioral;
