library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity nicserialioaddr is
  port (
    CLK     : in  std_logic;
    ADDRI   : in  std_logic_vector(3 downto 0);
    DIN     : in  std_logic_vector(15 downto 0);
    ADDRO   : in  std_logic_vector(3 downto 0);
    DOUT    : out std_logic_vector(15 downto 0);
    WE      : in  std_logic;
    RD      : in  std_logic;
    NICSOUT : out std_logic;
    NICSIN  : in  std_logic;
    NICSCLK : out std_logic;
    NICSCS  : out std_logic);

end nicserialioaddr;

architecture Behavioral of nicserialioaddr is

  signal serrw   : std_logic                    := '0';
  signal seraddr : std_logic_vector(5 downto 0) := (others => '0');

  signal serdin  : std_logic_vector(31 downto 0) := (others => '0');
  signal serdout : std_logic_vector(31 downto 0) := (others => '0');

  signal serstart : std_logic := '0';
  signal serdone  : std_logic := '0';

  signal serdonel : std_logic := '0';



begin  -- Behavioral

  nicserialio_inst : entity nicserialio
    port map (
      CLK   => CLK,
      START => serstart,
      RW    => serrw,
      ADDR  => seraddr,
      DIN   => serdin,
      DOUT  => serdout,
      DONE  => serdone,
      SCLK  => NICSCLK,
      SOUT  => NICSOUT,
      SIN   => NICSIN,
      SCS   => NICSCS);

  DOUT <= "000000000000000" & serdonel when addro = "0000" else
          serdout(15 downto 0) when addro = "0011" else
          serdout(31 downto 16);


  serstart <= '1' when addri = "0000" and WE = '1' else '0';
  
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        if WE = '1' then
          if ADDRI = "0001"  then
            serrw <= DIN(0); 
          end if;

          if ADDRI = "0010"  then
            seraddr <= DIN(5 downto 0); 
          end if;

          if ADDRI = "0011"  then
            serdin(15 downto 0) <= DIN; 
          end if;

          if ADDRI = "0100"  then
            serdin(31 downto 16) <= DIN; 
          end if;

        end if;

        if RD = '1' and  addro = "0000" then
            serdonel <= '0';
        else
          if serdone = '1' then
            serdonel <= '1'; 
          end if;
        end if;
        
      end if;
    end process main; 

end Behavioral;

