library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity jtagbufdump is
  port (
    CLKA    : in std_logic;
    DIN     : in std_logic_vector(31 downto 0);
    DINEN   : in std_logic;
    NEXTBUF : in std_logic;
    -- readout side
    CLKB :  in std_logic;
    READADDR : in std_logic_vector(11 downto 0);
    DOUT : out std_logic_vector(31 downto 0)    
    );
end jtagbufdump;

architecture Behavioral of jtagbufdump is

  signal bufaddr : std_logic_vector(2 downto 0) := (others => '0');

  signal wea : std_logic_vector(7 downto 0) := (others => '0');

  
  signal inaddr, inaddrl : std_logic_vector(8 downto 0) := (others => '0');
  signal dinl : std_logic_vector(31 downto 0) := (others => '0');

  type dob_t is array (0 to 7) of std_logic_vector(31 downto 0);
  signal dob : dob_t := (others => (others => '0'));
  
begin  -- Behavioral
  rambuf: for i in 0 to 7 generate
    
  bufferA_inst : RAMB16_S36_S36
    generic map (
      SIM_COLLISION_CHECK => "NONE",     
      -- Address 0 to 255
      INIT_00             => X"AAA1AAA2AAA3AAA4AAA5AAA6AAA7AAA8AAA9AAA01AAAA32AAFEDCB9876543210",
      INIT_01             => X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0DC2",
      INIT_02             => X"BCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC0FE3",
      INIT_03             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4",
      INIT_04             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5",
      INIT_05             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6",
      INIT_06             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7",
      INIT_07             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8",
      INIT_08             => X"FFF0000000000000000000000000000000000000000000000000000000000009",
      INIT_09             => X"000000000000000000000000000000000000000000000000000000000000000A")

      port map (
      DOA                 => open,
      DOB                 => dob(i), 
      DOPA                => open,
      DOPB                => open,
      ADDRA               => inaddrl,
      ADDRB               => readaddr(8 downto 0),
      CLKA                => CLKA,
      CLKB                => CLKB,
      DIA                 => dinl,
      DIB                 => X"00000000",
      DIPA                => "0000",   
      DIPB                => "0000",   
      ENA                 => '1',    
      ENB                 => '1',    
      SSRA                => '0',    
      SSRB                => '0',    
      WEA                 => wea(i), 
      WEB                 => '0'
      );
  end generate rambuf;

  DOUT <= dob(0) when readaddr(11 downto 9) = "000" else
          dob(1) when readaddr(11 downto 9) = "001" else
          dob(2) when readaddr(11 downto 9) = "010" else
          dob(3) when readaddr(11 downto 9) = "011" else
          dob(4) when readaddr(11 downto 9) = "100" else
          dob(5) when readaddr(11 downto 9) = "101" else
          dob(6) when readaddr(11 downto 9) = "110" else
          dob(7); 
          
  main_a:  process (CLKA)
    begin
      if rising_edge(CLKA) then

        dinl <= DIN;
        if DINEN = '1'  then
          if bufaddr = "0000" then
            wea(0) <= '1'; 
          end if;
          
          if bufaddr = "0001" then
            wea(1) <= '1'; 
          end if;
          
          if bufaddr = "0010" then
            wea(2) <= '1'; 
          end if;
          
          if bufaddr = "0011" then
            wea(3) <= '1'; 
          end if;
          
          if bufaddr = "0100" then
            wea(4) <= '1'; 
          end if;
          
          if bufaddr = "0101" then
            wea(5) <= '1'; 
          end if;
          
          if bufaddr = "0110" then
            wea(6) <= '1'; 
          end if;

          if bufaddr = "0111" then
            wea(7) <= '1'; 
          end if;

        else
          wea <= (others => '0'); 
        end if;
        
        if nextbuf = '1' then
          if bufaddr > "0111" then
            null;
          else
            bufaddr <= bufaddr + 1;
          end if;
        end if;

        if nextbuf = '1'  then
          inaddr <= (others => '0');
        else
          if dinen = '1'  then
            if inaddr = "111111111" then
              null;
            else
               inaddr <= inaddr + 1;
             end if; 
          end if;
        end if;
        inaddrl <= inaddr;
        
      end if;
    end process main_a; 

end Behavioral;
