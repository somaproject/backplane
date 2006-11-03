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

entity retxreq is
  port (
    CLK       : in  std_logic;
    NEXTFRAME : in  std_logic;
    DOEN      : out std_logic;
    DOUT      : out std_logic_vector(15 downto 0);
    REQ       : in  std_logic;
    SRC       : in  integer;
    TYP       : in  integer;
    ID        : in  std_logic_vector(31 downto 0);
    DONE      : out std_logic);
end retxreq;


architecture Behavioral of retxreq is

  type membuffer_t is array (31 downto 0) of std_logic_vector(15 downto 0);
  signal membuffer : membuffer_t := (others => X"0000");
  signal pos       : integer     := 34;

begin  -- Behavioral

  membuffer(0)  <= X"0032";
  membuffer(1)  <= X"FFFF";
  membuffer(2)  <= X"FFFF";
  membuffer(3)  <= X"FFFF";
  membuffer(4)  <= X"0011";
  membuffer(5)  <= X"D882";
  membuffer(6)  <= X"A689";
  membuffer(7)  <= X"0800";
  membuffer(8)  <= X"4500";
  membuffer(9)  <= X"0022";
  membuffer(10) <= X"0000";
  membuffer(11) <= X"4000";
  membuffer(12) <= X"4011";
  membuffer(13) <= X"B879";
  membuffer(14) <= X"C0A8";
  membuffer(15) <= X"0002";
  membuffer(16) <= X"C0A8";
  membuffer(17) <= X"00FF";
  membuffer(18) <= X"9C40";
  membuffer(19) <= X"1130";
  membuffer(20) <= X"000E";
  membuffer(21) <= X"7B5A";
  membuffer(22) <= (std_logic_vector(TO_UNSIGNED(typ, 8)) & std_logic_vector(TO_UNSIGNED(src, 8)));
  membuffer(23) <= ID(31 downto 16);
  membuffer(24) <= ID(15 downto 0);
  membuffer(25) <= X"0000";
  membuffer(26) <= X"0000";
  membuffer(27) <= X"0000";
  membuffer(28) <= X"0000";
  membuffer(29) <= X"0000";
  membuffer(30) <= X"0000";
  membuffer(31) <= X"0000";

  process(CLK)
  begin
    if rising_edge(CLK) then

      if pos = 32 then
        DONE <= '1';
      else
        DONE <= '0';
      end if;

      if REQ = '1' then
        if pos < 32 then
          -- pending event, do nothing
        else
          pos <= 0; 
        end if;
      else
        if NEXTFRAME = '1' then
          pos <= pos + 1;
          
        end if;
      end if;
      
      if NEXTFRAME = '1' then
        if pos < 32 and pos >= 0 then
          DOUT <= membuffer(pos);
          DOEN <= '1';
        else
          DOUT <= X"0000";
          DOEN <= '0';
        end if;
      else
          DOEN <= '0';
      end if;

    end if;
  end process;

end Behavioral;
