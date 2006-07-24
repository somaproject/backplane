library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity datafifo is

  port (
    MEMCLK   : in  std_logic;
    DIN      : in  std_logic_vector(15 downto 0);
    FIFOFULL : out std_logic;
    ADDRIN   : in  std_logic_vector(8 downto 0);
    WE       : in  std_logic;
    INDONE   : in  std_logic;
    -- output interface
    CLK      : in  std_logic;
    DOEN     : out std_logic;
    ARM      : out std_logic;
    GRANT    : in  std_logic);

end datafifo;


architecture Behavioral of datafifo is
  -- input signals
  signal addra : std_logic_vector(10 downto 0) := (others => '0');
  signal bpin  : std_logic_vector(1 downto 0)  := (others => '0');

  signal bpinl : std_logic_vector(1 downto 0) := (others => '0');

  -- output signals
  signal bcnt  : std_logic_vector(8 downto 0)  := (others => '0');
  signal bpout : std_logic_vector(1 downto 0)  := (others => '0');
  signal addrb : std_logic_vector(10 downto 0) := (others => '0');

  signal len : std_logic_vector(8 downto 0) := (others => '0');

  type states is (none, armw, outwrw, dones);
  signal cs, ns : states := none;


begin  -- Behavioral

  addra <= bpin & ADDRIN;
  addrb <= bpout & bcnt;

  FIFOFULL   <= '1' when (BPIN = "11" and BPOUT = "00") or
              (BPIN = "00" and BPOUT = "01") or
              (BPIN = "01" and BPOUT = "10") or
              (BPIN = "10" and BPOUT = "11") else
              '0';

  
  main_memclk : process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then
      if INDONE = '1' then
        bpin <= bpin + 1;
      end if;
    end if;
  end process main_memclk;

  main_clk : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;
      
      if bitinc = '1' then
        bcnt <= bcnt + 1;
      end if;
      
      DOEN <= bitinc; 

      if cs = dones then
        bpout <= bpout + 1; 
      end if;

      if bcnt = "000000000" then
        len <= dout(10 downto 1); 
      end if;

      
    end if;
  end process main_memclk;

  fsm: process(len, addrb, cs, bpinl, bpout, GRANT, bcnt)
    begin
      case cs is
        when none =>
          ARM <= '0';
          bcntinc <= '0';
          if bpinl /= bpout then
            ns <= armw;
          else
            ns <= none; 
          end if;
          
        when armw =>
          ARM <= '1';
          bcntinc <= '0';
          if GRANT = '1' then
            ns <= outwrw;
          else
            ns <= armw;  
          end if;
          
        when outwrw =>
          ARM <= '0';
          bcntinc <= '1';
          if bcnt = len then
            ns <= dones;
          else
            ns <= outwrw;  
          end if;

        when dones =>
          ARM <= '0';
          bcntinc <= '0';
          ns <= none;
          
        when others =>
          ARM <= '0';
          bcntinc <= '0';
          ns <= none; 

      end case;
    end process fsm; 


    buffer_high : RAMB16_S9_S9
   generic map (
      SIM_COLLISION_CHECK => "NONE")
      port map (
      DOA => open, 
      DOB => DOUT(15 downto 8) ,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA => MEMCLK,
      CLKB => CLK, 
      DIA => DIN(15 downto 8),
      DIB => X"0000",     
      DIPA => "00",   
      DIPB => "00",   
      ENA => '1',     
      ENB => '1',     
      SSRA => '0', 
      SSRB => '0',   
      WEA => WEIN,     
      WEB => '0'      
   );
    
    buffer_low : RAMB16_S9_S9
   generic map (
      SIM_COLLISION_CHECK => "NONE")
      port map (
      DOA => open, 
      DOB => DOUT(7 downto 0) ,
      ADDRA => addra,
      ADDRB => addrb,
      CLKA => MEMCLK,
      CLKB => CLK, 
      DIA => DIN(7 downto 0),
      DIB => X"0000",     
      DIPA => "00",   
      DIPB => "00",   
      ENA => '1',     
      ENB => '1',     
      SSRA => '0', 
      SSRB => '0',   
      WEA => WEIN,     
      WEB => '0'      
   );

end Behavioral;
