library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dataacquire is

  port (
    CLK    : in  std_logic;
    ECYCLE : in  std_logic;
    DIN    : in  std_logic_vector(7 downto 0);
    DIEN   : in  std_logic;
    DOUT   : out std_logic_vector(15 downto 0);
    ADDR   : in std_logic_vector(8 downto 0);
    LEN    : out std_logic_vector(9 downto 0));

end dataacquire;


architecture Behavioral of dataacquire is

  signal addra : std_logic_vector(10 downto 0) := (others => '0');

  signal bsel, nbsel : std_logic                    := '0';
  signal addrb       : std_logic_vector(9 downto 0) := (others => '0');
  signal dob         : std_logic_vector(15 downto 0);

  signal lenint : std_logic_vector(9 downto 0) := (others => '0');
  
begin  -- Beahavioral

  nbsel     <= not bsel;
  addra(10) <= nbsel;
  addrb(9)  <= bsel;

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      -- input counter
      if ecycle = '1' then
        addra(9 downto 0)   <= (others => '0');
      else
        if DIEN = '1' then
          addra(9 downto 0) <= addra(9 downto 0) + 1;
        end if;
      end if;

      if ECYCLE = '1' then
        bsel <= nbsel;

        lenint <= addra(9 downto 0);
      end if;

    end if;

  end process main;

  LEN <= '0' & lenint(9 downto 1); 
  addrb(8 downto 0) <= ADDR;
  DOUT <= dob(7 downto 0) & dob(15 downto 8);
  
  RAMB16_S9_S18_inst : RAMB16_S9_S18
    port map (
      DOA   => open,
      DOB   => dob,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => DIN,
      DIB   => X"0000",
      DIPA  => "0",
      DIPB  => "00",
      ENA   => '1',
      ENB   => '1',
      SSRA  => '0',
      SSRB  => '0',
      WEA   => DIEN,
      WEB   => '0'

      );


end Behavioral;
