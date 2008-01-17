library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;


library UNISIM;
use UNISIM.vcomponents.all;

entity udpburst is
  port (
    CLK      : in  std_logic;
    NEWFRAME : out std_logic;
    DOUT     : out std_logic_vector(15 downto 0)); 
end udpburst;

architecture Behavioral of udpburst is

  signal lnewframe : std_logic := '0';
  signal ldout     : std_logic_vector(15 downto 0);

  signal dop : std_logic_vector(1 downto 0) := (others => '0');

  signal addr     : std_logic_vector(9 downto 0)  := (others => '0');
  signal cyclecnt : std_logic_vector(31 downto 0) := (others => '0');

begin  -- Behavioral

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      addr       <= addr + 1;
      if addr = "1111111111" then
        cyclecnt <= cyclecnt + 1;
      end if;

      NEWFRAME <= lnewframe;
      if addr = "0000011000" then
        DOUT <= cyclecnt(31 downto 16);
      elsif addr = "0000011001" then
        DOUT <= cyclecnt(15 downto 0);
      else
        DOUT     <= ldout;
      end if;

    end if;

  end process main;

  lnewframe <= dop(0);

  buffer_state : ramb16_S18
    generic map (
      INIT_00  => X"0002c0a8f8694011000000000032450008001234BEEFDEADFFFFFFFFFFFF0042",
      INIT_01  => X"00000000000000000000000000000000000000000000000E13889c4000ffc0a8",
      INIT_02  => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03  => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_00 => X"000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000" )


    port map (
      CLK  => CLK,
      EN   => '1',
      WE   => '0',
      ADDR => addr,
      DI   => X"0000",
      DO   => ldout,
      DIP  => "00",
      SSR  => '0',
      DOP  => dop); 

end Behavioral;
