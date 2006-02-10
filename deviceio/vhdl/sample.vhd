library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity sample is
  port ( CLK   : in  std_logic;
         CLK90 : in  std_logic;
         DIN   : in  std_logic;
         DOUT  : out std_logic_vector(3 downto 0)
         );

end sample;

architecture Behavioral of sample is

  signal dinl, dinll, dinlll      : std_logic_vector(3 downto 0) := (others => '0');

attribute RLOC : string;
  --attribute RLOC of dinl : signal  is "X0Y1 X0Y0 X0Y1 X0Y0";

  signal notclk, notclk90 : std_logic := '0';

  signal rst : std_logic := '0';
begin

  notclk90 <= not clk90; 
  notclk <= not clk;   
ff_a0 : fdc port map(d => din,  c => clk, clr => rst, q => dinl(0));
ff_a1 : fdc port map(d => dinl(0), c => clk, clr => rst, q => dinll(0));
ff_a2 : fdc port map(d => dinll(0), c => clk, clr => rst, q => dinlll(0));
ff_a3 : fdc port map(d => dinlll(0), c => clk, clr => rst, q => DOUT(0));

ff_b0 : fdc port map(d => din,  c => clk90, clr => rst, q => dinl(1));
ff_b1 : fdc port map(d => dinl(1), c => clk,   clr => rst, q => dinll(1));
ff_b2 : fdc port map(d => dinll(1), c => clk,   clr => rst, q => dinlll(1));
ff_b3 : fdc port map(d => dinlll(1), c => clk,   clr => rst, q => DOUT(1));	

ff_c0 : fdc port map(d => din,  c => notclk, clr => rst, q => dinl(2));
ff_c1 : fdc port map(d => dinl(2), c => clk90,  clr => rst, q => dinll(2));
ff_c2 : fdc port map(d => dinll(2), c => clk,    clr => rst, q => dinlll(2));
ff_c3 : fdc port map(d => dinlll(2), c => clk,    clr => rst, q => DOUT(2));	

ff_d0 : fdc port map(d => din,  c => notclk90, clr => rst, q => dinl(3));
ff_d1 : fdc port map(d => dinl(3), c => notclk,   clr => rst, q => dinll(3));
ff_d2 : fdc port map(d => dinll(3), c => clk90,    clr => rst, q => dinlll(3));
ff_d3 : fdc port map(d => dinlll(3), c => clk,      clr => rst, q => DOUT(3));	


--   main1 : process (CLK)
--   begin
--     if rising_edge(CLK) then
--       dinl(0)  <= DIN;
--       dinll(0) <= dinl(0);
--       dinll(1) <= dinl(1);
--       dinlll(2) <= dinll(2);
--       dinlll(1) <= dinll(1);
--       dinlll(0) <= dinll(0);
      
      
--       DOUT <= dinlll;

--     end if;
--   end process main1;

--   main2 : process (CLK90)
--   begin
--     if rising_edge(CLK90) then
--       dinl(1)  <= DIN;
--       dinll(2) <= dinl(2);
--       dinlll(3) <= dinll(3); 
--     end if;
--   end process main2;


--   main3 : process (nclk)
--   begin
--     if rising_edge(nclk) then
--       dinl(2)  <= DIN;
--       dinll(3) <= dinl(3);
--     end if;
--   end process main3;



--   main4 : process (nclk90)
--   begin
--     if rising_edge(nclk90) then
--       dinl(3) <= DIN; 
--     end if;
--   end process main4;


end Behavioral;

