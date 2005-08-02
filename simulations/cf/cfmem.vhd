library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;


library UNISIM;
use UNISIM.VComponents.all;

entity CFMEM is
  generic (filename  :       string := "adcin.dat" );
  port ( RESET       : in    std_logic;
         A           : in    std_logic_vector(10 downto 0);
         D           : inout std_logic_vector(15 downto 0);
         WAT         : out   std_logic;
         REG         : in    std_logic;
         CE1         : in    std_logic;
         WE          : in    std_logic;
         OE          : in    std_logic;
         CD1         : out   std_logic;
         CARDPRESENT : in    std_logic;
         INPUTDONE   : out   std_logic);
end CFMEM;

architecture Behavioral of CFMEM is
-- a behavioral simulation of the CF in memory mode.
--

  signal rddata, wrdata, err, features,
    sectorcount, status, command : std_logic_vector(7 downto 0) := (others => '0');

  signal lba : std_logic_vector(27 downto 0) := (others => '0');

  signal bufpos : integer := 0;

  type bufferblock is array (511 downto 0) of std_logic_vector(7 downto 0);

  signal foundsector : std_logic := '0';

begin


  CD1 <= not CARDPRESENT;

  main                    : process
    variable sectorbuffer : bufferblock := (others => X"00");
    file inputfile        : text;
    variable L            : line;

    variable sectaddrin, sectbyte : integer;

  begin  -- process main
    while 1 = 1 loop
      if RESET = '0' then
        sectorcount <= X"00";
        lba         <= (others => '0');
        command     <= X"00";
        bufpos      <= 0;

      else

        if rising_edge(WR) and CE1 = '0' then
          if A(2 downto 0) = "000" then
            -- nothing
            -- 
          elsif A(2 downto 0) = "001" then
            features          <= d(7 downto 0);
          elsif A(2 downto 0) = "010" then
            sectorcount       <= d(7 downto 0);
          elsif A(2 downto 0) = "011" then
            lba(7 downto 0)   <= d(7 downto 0);
          elsif A(2 downto 0) = "100" then
            lba(15 downto 8)  <= d(7 downto 0);
          elsif A(2 downto 0) = "101" then
            lba(23 downto 16) <= d(7 downto 0);
          elsif A(2 downto 0) = "110" then
            lba(27 downto 24) <= d(3 downto 0);
          elsif A(2 downto 0) = "111" then
            command           <= d(7 downto 0);

            -- command processing
            if command = X"20" then
              -- read command


              foundsector <= '0';
              file_open(inputfile, filename, read_mode);
              while not endfile(inputfile) and foundsector = '0' loop

                readline(inputfile, L);
                read(L, sectaddrin);
                if conv_std_logic_vector(sectaddrin, 28) = lba then
                  -- read into buffer
                  for i in 0 to 511 loop
                    read(L, sectbyte);
                    sectorbuffer(i) <= conv_std_logic_vector(sectbyte, 8);

                  end loop;  -- i 
                  foundsector <= '1';
                end if;
              end loop;
              assert foundsector = '0' report "Sector Not Found" severity error;

              file_close(inputfile);
              bufpos <= 0;              -- reset buffer pos
            end if;


          end if;
        elsif falling_edge(OE) and CE1 = '0' then
          if A(2 downto 0) = "000" then
            -- output buffer, inc
            d(7 downto 0) <= sectorbuffer(bufpos);
            bufpos        <= bufpos + 1;

            file_open(inputfile, filename, read_mode);

          elsif A(2 downto 0) = "001" then
            d(7 downto 0) <= features;
          elsif A(2 downto 0) = "010" then
            d(7 downto 0) <= sectorcount;
          end if;
        end if;
      end if;
    end loop;
  end process main;
end Behavioral;
