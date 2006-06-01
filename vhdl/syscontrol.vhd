library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;

entity syscontrol is

  port (
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    EDTX    : in  std_logic_vector(7 downto 0);
    EATX    : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0)
    );
end syscontrol;

architecture Behavioral of syscontrol is

  signal romaddr : std_logic_vector(8 downto 0)      := (others => '0');
  signal bootevt : std_logic_vector(16*6-1 downto 0) := (others => '0');

  signal edrxall : std_logic_vector(16*6-1 downto 0) := (others => '0');

  signal osel : std_logic := '0';

  signal boot_id : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal learx    : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal learxset : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');
  signal learxin  : std_logic_vector(somabackplane.N -1 downto 0) := (others => '0');

  signal addrset : std_logic := '0';

  signal bootaddrlen : std_logic_vector(31 downto 0) := (others => '0');

  signal bootmask : std_logic_vector(31 downto 0) := (others => '0');




  -- event inputs
  signal enext : std_logic                     := '0';
  signal eouta : std_logic_vector(2 downto 0)  := (others => '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');

  signal evalid : std_logic := '0';

  type states is (none, acheck, ecyclew, respw, erespchk, enext1, erespchk2, esuccess, enext2, notyet);
  signal cs, ns : states := acheck;

  component rxeventfifo
    port (
      CLK    : in  std_logic;
      RESET  : in  std_logic;
      ECYCLE : in  std_logic;
      EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
      EDTX   : in  std_logic_vector(7 downto 0);
      -- outputs
      EOUTD  : out std_logic_vector(15 downto 0);
      EOUTA  : in  std_logic_vector(2 downto 0);
      EVALID : out std_logic;
      ENEXT  : in  std_logic
      );
  end component;


begin  -- Behavioral

  boot_id(2) <= '1';

  EDRX <= edrxall(7 downto 0)   when EDSELRX = X"1" else
          edrxall(15 downto 8)  when EDSELRX = X"0" else
          edrxall(23 downto 16) when EDSELRX = X"3" else
          edrxall(31 downto 24) when EDSELRX = X"2" else
          edrxall(39 downto 32) when EDSELRX = X"5" else
          edrxall(47 downto 40) when EDSELRX = X"4" else
          edrxall(55 downto 48) when EDSELRX = X"7" else
          edrxall(63 downto 56) when EDSELRX = X"6" else
          edrxall(71 downto 64) when EDSELRX = X"9" else
          edrxall(79 downto 72) when EDSELRX = X"8" else
          edrxall(87 downto 80) when EDSELRX = X"B" else
          edrxall(95 downto 88);

  rxeventfifo_inst : rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      eoutd  => eoutd,
      eouta  => eouta,
      EVALID => evalid,
      ENEXT  => enext);


  destmask_ram : RAMB16_S36
    generic map (
      INIT       => X"000000000",       --  Value of output RAM registers at startup
      SRVAL      => X"000000000",       --  Ouput value upon SSR assertion
      write_mode => "WRITE_FIRST",      --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 127
      INIT_00    =>
      X"0000000000000000000000000000000000000000000000000000000000000001",
      INIT_01    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F    =>
      X"0000000000000000000000000000000000000000000000000000000000000000")
    port map (
      DO         => bootmask,
      DOP        => open,
      ADDR       => romaddr,
      CLK        => clk,
      DI         => X"00000000",
      DIP        => X"0",
      EN         => '1',
      SSR        => RESET,
      WE         => '0'
      );

  addrlen_ram : RAMB16_S36
    generic map (
      INIT       => X"000000000",       --  Value of output RAM registers at startup
      SRVAL      => X"000000000",       --  Ouput value upon SSR assertion
      write_mode => "WRITE_FIRST",      --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      -- The following INIT_xx declarations specify the initial contents of the RAM
      -- Address 0 to 127
      INIT_00    =>
      X"0000000000000000000000000000000000000000000000000000000010002000",
      INIT_01    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E    =>
      X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F    =>
      X"0000000000000000000000000000000000000000000000000000000000000000")
    port map (
      DO         => bootaddrlen,
      DOP        => open,
      ADDR       => romaddr,
      CLK        => clk,
      DI         => X"00000000",
      DIP        => X"0",
      EN         => '1',
      SSR        => RESET,
      WE         => '0'
      );

  learxset <= boot_id when osel = '0' else learxin;

  bootevt(15 downto 0)  <= X"2001";
  bootevt(31 downto 16) <= bootmask(31 downto 16); 
  bootevt(47 downto 32) <= bootmask(15 downto 0);
  bootevt(63 downto 48) <= bootaddrlen(31 downto 16);
  bootevt(79 downto 64) <= bootaddrlen(15 downto 0);
  bootevt(95 downto 80) <= X"0000";

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs      <= none;
      romaddr <= (others => '0');
    else
      if rising_edge(CLK) then
        cs    <= ns;

        if cs = esuccess then
          romaddr <= romaddr + 1;
        end if;

        if ECYCLE = '1' then
          EARX <= learx;

          if osel = '0' then
            edrxall <= bootevt;
          else
            -- something else here
          end if;
        end if;

        if ECYCLE = '1' then
          learx   <= (others => '0');
        else
          if addrset = '1' then
            learx <= learxset;
          end if;
        end if;

      end if;
    end if;
  end process main;


  fsm : process(cs, ECYCLE, evalid, eoutd, bootevt)
  begin
    case cs is
      when none   =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';
        ns      <= acheck;
      when acheck =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';

        if bootmask = X"00000000" then
          ns <= notyet;
        else
          ns <= ecyclew;
        end if;

      when ecyclew =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '1';

        if ECYCLE = '1' then
          ns <= respw;
        else
          ns <= ecyclew;
        end if;

      when respw =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';

        if evalid = '1' then
          ns <= erespchk;
        else
          ns <= respw;
        end if;

      when erespchk =>
        osel    <= '0';
        eouta   <= "001";
        enext   <= '0';
        addrset <= '0';

        if EOUTD = X"2002" then
          ns <= erespchk2;
        else
          ns <= enext1;
        end if;

      when enext1 =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '1';
        addrset <= '0';
        ns      <= respw;

      when erespchk2 =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';

        if EOUTD = X"0002" then
          ns <= esuccess;
        else
          ns <= enext1;
        end if;

      when esuccess =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';
        ns      <= enext2;

      when enext2 =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '1';
        addrset <= '0';
        ns      <= acheck;

      when notyet =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';
        ns      <= notyet;
      when others =>
        osel    <= '0';
        eouta   <= "000";
        enext   <= '0';
        addrset <= '0';
        ns      <= acheck;
    end case;
  end process fsm;



end Behavioral;
