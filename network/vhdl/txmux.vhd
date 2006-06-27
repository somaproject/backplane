library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

library WORK;
use WORK.networkstack; 

entity txmux is
  port (
    CLK   : in std_logic;
    DEN   : in std_logic_vector(networkstack.N-1 downto 0);
    DIN   : in networkstack.dataarray;
    GRANT : out std_logic_vector(networkstack.N-1 downto 0);
    ARM : in std_logic_vector(networkstack.N-1 downto 0);
    DOUT : out std_logic_vector(15 downto 0);
    NEWFRAME : out std_logic
    );

end txmux;


architecture Behavioral of txmux is


  signal dinmux : std_logic_vector(15 downto 0) := (others => '0');
  signal denmux : std_logic := '0';
  
  signal chan : integer range 0 to networkstack.N-1 := 0;
  signal arml : std_logic_vector(networkstack.N-1 downto 0) := (others => '0');
  signal armll : std_logic := '0';
  
  signal grantmux : std_logic := '0';

  signal chaninc : std_logic := '0';

  
  type states is (start, grants, grantw, nextchan);
  signal cs, ns : states := start;

  
begin  -- Behavioral

  dinmux <= DIN(chan);
  denmux <= DEN(chan);

  armll <= arml(chan);
  

  setregs: for i in 0 to networkstack.N-1 generate
    process (CLK)
      begin
        if rising_edge(CLK) then
          if cs = grantw and chan = i then
            arml(i) <= '0';
          else
            if ARM(i) = '1' then
              arml(i) <= '1'; 
            end if;
          end if;

          if grantmux = '1' and chan = i then
            grant(i) <= '1';
          else
            grant(i) <= '0'; 
          end if;
          
        end if;
        
      end process; 
  end generate setregs;


  
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        cs <= ns;

        DOUT <= dinmux;
        NEWFRAME <= denmux;

        if chaninc = '1' then
          
          if chan = networkstack.N-1 then
            chan <= 0;
          else
            chan <= chan + 1; 
          end if;
          
        end if;
        
        
      end if;
    end process main;

    fsm: process(cs, armll, denmux)
      begin
        case cs is
          when start =>
            grantmux <= '0';
            chaninc <= '0';
            if armll = '1' then
              ns <= grants;
            else
              ns <= nextchan; 
            end if;

          when grants =>
            grantmux <= '1';
            chaninc <= '0';
            if denmux = '1' then
              ns <= grantw;
            else
              ns <= grants; 
            end if;

          when grantw =>
            grantmux <= '1';
            chaninc <= '0';
            if denmux = '0' then
              ns <= nextchan;
            else
              ns <= grantw; 
            end if;

          when nextchan =>
            grantmux <= '0';
            chaninc <= '1';
            ns <= start;
            
          when others =>
            grantmux <= '0';
            chaninc <= '1';
            ns <= start; 

        end case;
      end process fsm;

      
end Behavioral;
