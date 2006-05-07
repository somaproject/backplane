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
         DREADING : out std_logic;
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
                  init0, init1,  initrw, initr, initdone,
                  datardy, rdcmd, rdw1, rdw2, rdaddr1, rdaddr2,
                  rdchk, rddelay1, rddelay2, rdtokw, rdtokchk, rddata,
                  rddatadl, rdchk1, rdchk2, rddatadn);
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

  pin <= X"40"            when bsel = 0 else
          X"41"            when bsel = 1 else
          X"51"            when bsel = 2 else
          X"FF"            when bsel = 3 else
          X"00"            when bsel = 4 else
          X"95"            when bsel = 5 else
          ADDR(6 downto 0) & '0' when bsel = 6 else
          ADDR(14 downto 7);



  DOUT <= pout;
  
  main : process (CLK, RESET)
  begin
    if RESET = '1' then
      cs           <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;
        
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


  fsm : process(cs, bstart, bdone, bcnt, dstart, pout)
  begin
    case cs is
      when none      =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0'; 
        ns      <= initticks;
      when initticks =>
        scs     <= '1';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns    <= initwait;
        else
          ns    <= initticks;
        end if;

      when initwait =>
        scs     <= '1';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
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
        DREADING <= '0';
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
        DREADING <= '0';
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
        DREADING <= '0';
        if bcnt = 3  then
          ns <= srstchk; 
        else
          ns    <= srst1; 
        end if;

      when srstchk =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 5;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
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
        DREADING <= '0';
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
        DREADING <= '0';
        if pout(7) = '0' and pout(0) = '1' then
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
        DREADING <= '0';
       ns <= initcmd;                  
        
      when initcmd =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 1;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
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
        bsel    <= 5;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
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
        bsel    <= 5;                
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bcnt = 4 then
          ns <= initrw; 
        else
          ns    <= init0;  
        end if;


      when initrw =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
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
        DREADING <= '0';
        if pout(7) = '0' then
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
        DREADING <= '0';
        if pout(7) = '0' and pout(0) = '0' then
          ns <= datardy;
        else
          ns <= initcmd; 
        end if;
      when datardy =>
        scs     <= '1';
        bstart  <= '0';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 1;
        DVALID  <= '0';
        DDONE   <= '1';
        DREADING <= '0';
        if DSTART = '1' then
          ns <= rdcmd;
        else
          ns <= datardy;                
        end if;

      when rdcmd =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 2;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdw1;
        else
          ns <= rdcmd; 
        end if;

      when rdw1 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdaddr1;
        else
          ns <= rdw1; 
        end if;

      when rdw2 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdchk;
        else
          ns <= rdw2; 
        end if;

      when rdaddr1 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 7;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdaddr2;
        else
          ns <= rdaddr1; 
        end if;

      when rdaddr2 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 6;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdw2;
        else
          ns <= rdaddr2; 
        end if;

      when rdchk =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 6;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rddelay1;
        else
          ns <= rdchk; 
        end if;

      when rddelay1 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rddelay2;
        else
          ns <= rddelay1; 
        end if;

      when rddelay2 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 4;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if pout(7) = '0' then
          ns <= rdtokw;
        else
          ns <= rddelay1; 
        end if;

      when rdtokw =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdtokchk;
        else
          ns <= rdtokw;  
        end if;
        
      when rdtokchk =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '1';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if pout = X"FE" then
          
          ns <= rddata;
        else
          ns <= rdtokw; 
        end if;

      when rddata =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '1';
        if bdone = '1' then          
          ns <= rddatadl; 
        else
          ns <= rddata; 
        end if;

      when rddatadl =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '1'; 
        bsel    <= 3;
        DVALID  <= '1';
        DDONE   <= '0';
        DREADING <= '1';
        if bcnt = 511 then
          ns <= rdchk1; 
        else
          ns <= rddata; 
        end if;
        
      when rdchk1 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rdchk2;
        else
          ns <= rdchk1; 
        end if;

      when rdchk2 =>
        scs     <= '0';
        bstart  <= '1';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '0';
        DREADING <= '0';
        if bdone = '1' then
          ns <= rddatadn;
        else
          ns <= rdchk2; 
        end if;

      when rddatadn =>
        scs     <= '0';
        bstart  <= '0';
        bcntrst <= '0';
        bcnten <= '0'; 
        bsel    <= 3;
        DVALID  <= '0';
        DDONE   <= '1';
        DREADING <= '0';
        
        ns <= datardy; 
        
        
    end case;
  end process fsm;



end Behavioral;

