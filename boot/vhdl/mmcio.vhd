library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity mmcio is
  port ( CLK    : in  std_logic;
         RESET  : in  std_logic;
         SCS    : out std_logic;
         SDIN   : in  std_logic;
         SDOUT  : out std_logic;
         SCLK   : out std_logic;
         DOUT   : out std_logic_vector(7 downto 0);
         DSTART : in  std_logic;
         ADDR   : in std_logic_vector(15 downto 0);
         DVALID : out std_logic;
         DDONE  : out std_logic
         );
end mmcio;

architecture Behavioral of mmcio is

  signal bcnt : integer range 0 to 511 := 0;

  signal pin, pout : std_logic_vector(7 downto 0) := (others => '0');

  signal bstart, bdone : std_logic := '0';

  signal bcnten, bcntrst : std_logic := '0';

  type states is (none, initticks, initwait, srst0, srst1, srst2,
                  srstchk, srstrwt, srstrwtw, srstdone, initcmd,
                  init0, init1, initchk, initrw, initr, initdone,
                  datardy, rdcmd, rdw1, rdw2, rdaddr1, rdaddr2,
                  rdchk, rddelay1, rddelay2, rdtokw, rdtokchk, rddata,
                  rddatadn, rddata1);
  signal cs, ns : states := none;

  signal bsel : integer range 0 to 7 := 0;

  component byteio
    port ( CLK    : in  std_logic;
           PIN    : in  std_logic_vector(7 downto 0);
           POUT   : out std_logic_vector(7 downto 0);
           SDIN   : in  std_logic;
           SDOUT  : out std_logic;
           SCLK   : out std_logic;
           BSTART : in  std_logic;
           BDONE  : out std_logic
           );
  end component;

begin

  byteio_inst : byteio
    port map (
      CLK    => CLK,
      PIN    => pin,
      POUT   => pout,
      SDIN   => SDIN,
      SDout  => SDOUT,
      SCLK   => SCLK,
      BSTART => bstart,
      BDONE  => bdone);

  pout <= X"40"            when bsel = 0 else
          X"41"            when bsel = 1 else
          X"51"            when bsel = 2 else
          X"FF"            when bsel = 3 else
          X"00"            when bsel = 4 else
          X"95"            when bsel = 5 else
          ADDR(7 downto 0) when bsel = 6 else
          ADDR(15 downto 8);




  main : process (CLK, RESET)
  begin
    if RESET = '1' then
      cs           <= none;
    else
      if rising_edge(CLK) then
        if bcntrst = '1' then
          bcnt     <= 0;
        else
          if bcnten = '1' then
            if bcnt = 511 then
              bcnt <= 0;
            else
              bcnt <= bcnt + 1;
            end if;
          end if;
        end if;

      end if;
    end if;
  end process main;


  fsm : process(cs, bstart, bdone, bcnt, dstart)
  begin
    case cs is
      when none      =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 0;
        DVALID  <= '0';
        DDONE   <= '0';
        ns      <= initticks;
      when initticks =>
        scs     <= '1';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 0;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns    <= initwait;
        else
          ns    <= initticks;
        end if;

      when initwait =>
        scs     <= '1';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 0;
        DVALID  <= '0';
        DDONE   <= '0';
        if bcnt = 10  then
          ns    <= srst0; 
        else
          ns    <= initticks; 
        end if;
        
      when srst0 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 0;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1'  then
          ns <= srst1; 
        else
          ns    <= srst0; 
        end if;

      when srst1 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1'  then
          ns <= srst2; 
        else
          ns    <= srst1; 
        end if;

      when srst2 =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        if bcnt = 4  then
          ns <= srst2; 
        else
          ns    <= srst0; 
        end if;

      when srstchk =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 5;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1'  then
          ns <= srstrwt; 
        else
          ns    <= srstchk; 
        end if;

      when srstrwt =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns <= srstrwtw; 
        else
          ns    <= srstrwt; 
        end if;

      when srstrwtw =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        if pin(7) = '0' and pin(0) = '1' then
          ns <= srstdone; 
        else
          ns    <= srstrwt; 
        end if;

      when srstdone =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        ns <= initcmd;
        
      when initcmd =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 1;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns <= init0;
        else
          ns    <= initcmd; 
        end if;

      when init0 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns <= init1;
        else
          ns    <= init0; 
        end if;

      when init1 =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        if bcnt = 4 then
          ns <= initchk; 
        else
          ns    <= init0;  
        end if;

      when initchk =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 5;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns <= initrw; 
        else
          ns    <= initchk;  
        end if;

      when initrw =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        if bdone = '1' then
          ns <= initr; 
        else
          ns    <= initrw; 
        end if;

      when initr =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        if pin(7) = '0' then
          ns <= initdone; 
        else
          ns    <= initrw;  
        end if;

      when initdone =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        if pin(7) = '0' and pin(1) = '0' then
          ns <= datardy;
        else
          ns <= initcmd; 
        end if;
      when others =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
    end case;


  end process fsm;



end Behavioral;

