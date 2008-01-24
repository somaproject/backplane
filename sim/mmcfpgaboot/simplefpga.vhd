library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity simplefpga is

  port (
    START     : in  std_logic;
    BOOTADDR  : in  std_logic_vector(15 downto 0);
    BOOTLEN   : in  std_logic_vector(15 downto 0);
    FCLK      : in  std_logic;
    FDIN      : in  std_logic;
    FPROG     : in  std_logic;
    VALIDBOOT : out std_logic
    );

end simplefpga;


architecture Behavioral of simplefpga is

  signal bootaddrl, bootlenl : std_logic_vector(15 downto 0)
 := (others => '0');

  signal bootaddrpos : std_logic_vector(15 downto 0) := (others => '0');

  signal readword : std_logic_vector(7 downto 0) := (others => '0');
  signal readwordl : std_logic_vector(7 downto 0) := (others => '0');

  signal blockaddr : std_logic_vector(31 downto 0) := (others => '0');


  signal lvalidboot : std_logic := '0';
  signal bitpos : integer := 0;
  
  type states is (none, fprogwait, datawait, done);
  signal status : states := none;

  
begin  -- Behavioral

  main : process
  begin
    while true loop
      status <= none; 
      wait until rising_edge(START);
      status <= fprogwait; 
      -- begin
      bootaddrl   <= BOOTADDR;
      bootlenl    <= BOOTLEN;
      bootaddrpos <= BOOTADDR;
      lvalidboot   <= '1';

      assert FPROG = '1'
        report "FPROG asserted at beginning of boot cycle" severity error;
      if FPROG = '0' then
        lvalidboot <= '0';
      end if;
      wait until falling_edge(FPROG);
      wait for 20 us;
      wait until rising_edge(FPROG);
      status <= datawait; 

      -- boot len is in blocks
      for i in 0 to TO_INTEGER(unsigned(bootlenl)) - 1 loop
        -- first four words are addresses
        bitpos <= 0; 
        for k in 0 to 3 loop
          for j in 0 to 7 loop
            wait until rising_edge(FCLK);
            bitpos <= bitpos + 1 after 200 ns; 
            readword <= FDIN & readword(7 downto 1); 
          end loop;
          wait for 2 ns;          
          readwordl <= readword; 
          wait for 2 ns;
          
          blockaddr(31 - k*8 downto 24 -
                    k*8) <= readwordl ;
        end loop;

        -- validate address
        if blockaddr(25 downto 9) /= bootaddrpos then
          assert False report "incorrect boot word address" severity Error;
          lvalidboot <= '0'; 
        end if;
        
        -- against bootaddrpos

        bootaddrpos <= bootaddrpos + 1;

        for k in 0 to 511 - 4 loop
          for j in 0 to 7 loop
            wait until rising_edge(FCLK);
            bitpos <= bitpos + 1 after 200 ns; 
            readword <= FDIN & readword(7 downto 1) ;

          end loop;
          wait for 2 ns;
          readwordl <= readword;
          wait for 2 ns;
          
          assert
            readwordl = std_logic_vector(TO_UNSIGNED((k + 4) mod 256, 8 ))
            report "Error reading block data" severity error;
        end loop;

      end loop;
      status <= done; 
      VALIDBOOT <= lvalidboot;
      
    end loop;
  end process;

end Behavioral;

