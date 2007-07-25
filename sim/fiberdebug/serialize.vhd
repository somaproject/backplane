library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;


-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serialize is
  generic (filename :     string := "input.dat");
  port ( START      : in  std_logic;
         DOUT       : out std_logic;
         DONE       : out std_logic);
end serialize;

architecture Behavioral of serialize is
-- SERIALIZE.VHD                        -- strictly behavioral implementation of
-- serializer for testbenches. We generate an internal 8 Mhz clock
-- and then 8b/10b encode the data from the input filename. 
-- That file has a '1' or a '0' based on whether or not this is
-- a K character, followed by 8 bits of data
-- 


  signal data        : std_logic_vector(7 downto 0) := (others => '0');
  signal kchar       : std_logic                    := '0';
  signal encdata     : std_logic_vector(9 downto 0) := (others => '0');
  signal clk, encode : std_logic                    := '0';


  component encode8b10b is
                          port (
                            din  : in  std_logic_vector(7 downto 0);
                            kin  : in  std_logic;
                            clk  : in  std_logic;
                            dout : out std_logic_vector(9 downto 0);
                            ce   : in  std_logic);
  end component;
  signal pos                     :     integer := 0;
begin
  clk <= not clk after 62.5 ns;

  encoder : encode8b10b port map (
    din  => data,
    kin  => kchar,
    clk  => clk,
    dout => encdata,
    ce   => encode);


  reading             : process(clk, START)
    variable starting : std_logic := '0';
    variable ending   : std_logic := '0';
    variable toencode : bit_vector(7 downto 0);
    variable tok      : bit;
    file inputfile    : text open read_mode is filename;
    variable L        : line;

  begin

    if rising_edge(START) then
      starting := '1';

    else

      if rising_edge(clk) then


        if pos = 9 then
          pos <= 0;
        else
          pos <= pos + 1;
        end if;

        if pos = 8 then
          if starting = '1' and (not endfile(inputfile)) then
            readline(inputfile, L);
            read(L, tok);
            read(L, toencode);
            data  <= TO_X01Z(toencode);
            kchar <= TO_X01Z(tok);
          end if;

        end if;

        if endfile(inputfile) then
          done <= '1';
        else
          done <= '0';
        end if;


        if pos = 8 then
          encode <= '1';
        else
          encode <= '0';
        end if;
      end if;
    end if;
  end process reading;

  DOUT <= encdata(pos);

end Behavioral;
