library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity netsigtest is
  port (
    CLKIN        : in  std_logic;
    SDOUT        : out std_logic;
    SDIN         : in  std_logic;
    SCLK         : out std_logic;
    SCS          : out std_logic;
    LEDPOWER     : out std_logic;
    LEDEVENT     : out std_logic;
    NICFPROG     : out std_logic;
    NICSCLK      : out std_logic;
    NICSIN       : in  std_logic;
    NICSOUT      : out std_logic;
    NICSCS       : in  std_logic;       -- change from normal
    NICDOUT      : out std_logic_vector(15 downto 0);
    NICNEWFRAME  : out std_logic;
    NICDIN       : in  std_logic_vector(15 downto 0);
    NICNEXTFRAME : out std_logic;
    NICDINEN     : in  std_logic;
    NICDOUTEN    : in  std_logic;
    NICIOCLK     : out std_logic
    );
end netsigtest;

architecture Behavioral of netsigtest is

  signal td, td1, td2, td3, td4 :
    std_logic_vector(31 downto 0) := (others => '0');

  signal indata : std_logic_vector(31 downto 0) := (others => '0');


  signal cdrck, csel, cshift, cupdate, cupdatel,
    ctdo, ctdi : std_logic := '0';


  signal clk : std_logic := '0';

  signal errcnt, csreg : std_logic_vector(32*4-1 + 8 downto 0) := (others => '0');

  
begin  -- Behavio

  clk <= CLKIN; 
  NICFPROG <= '1';

  NICIOCLK <= clk;
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      td(19 downto 0) <= td(19 downto 0) + 1;
      td1 <= td;
      td2 <= td1;
      td3 <= td2;
      td4 <= td3; 

      NICDOUT      <= td(15 downto 0);
      NICNEWFRAME  <= td(16);
      NICSCLK      <= td(17);
      NICSOUT      <= td(18);
      NICNEXTFRAME <= td(19);

      indata(15 downto 0) <= NICDIN;
      indata(16)          <= NICDINEN;
      indata(17)          <= NICSIN;
      indata(18)          <= NICSCS;
      indata(19)          <= NICDOUTEN;

      
    end if;
  end process main;

  errcnt(32*4 - 1 +8 downto  32*4  ) <= X"AB"; 
                                            
  tester: for i in 0 to 31 generate
    process(CLK)
      begin
        if rising_edge(CLK) then
          if indata(i) /= td4(i) then
            errcnt((i+1)*4-1 downto i*4) <= errcnt((i+1)*4-1 downto i*4) + 1; 
          end if;
        end if;
      end process ; 
  end generate tester;

  BSCAN_control_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE    => open,
      DRCK       => cdrck,
      reset      => open,
      SEL        => csel,
      SHIFT      => cshift,
      TDI        => ctdi,
      UPDATE     => cupdate,
      TDO        => ctdo);


  process(cdrck, cupdate)
    variable pos : integer range 0 to 32*4-1 + 8  := 0;

  begin
    if cupdate = '1' then
      pos   := 0;
      csreg <= errcnt; 
      
    else
      if rising_edge(cdrck) then
        ctdo   <= csreg(pos); 
        pos := pos + 1;
      end if;
    end if;
  end process;


end Behavioral;
