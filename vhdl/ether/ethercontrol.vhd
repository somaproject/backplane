library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity ethercontrol is
  generic (
    DEVICE   :     std_logic_vector(7 downto 0) := X"01"
    );
  port (
    CLK      : in  std_logic;
    RESET    : in  std_logic;
    ECYCLE   : in  std_logic;
    EARX     : out std_logic_vector(somabackplane.N - 1 downto 0)
    := (others => '0');
    EDRX     : out std_logic_vector(7 downto 0);
    EDSELRX  : in  std_logic_vector(3 downto 0);
    EOUTD    : in  std_logic_vector(15 downto 0);
    EOUTA    : out std_logic_vector(2 downto 0);
    EVALID   : in  std_logic;
    ENEXT    : out std_logic;
    RW : out std_logic;
    ADDR : out std_logic_vector(5 downto 0);
    DIN: out std_logic_vector(31 downto 0);
    DOUT : in std_logic_vector(31 downto 0);
    NICSTART : out std_logic;
    NICDONE : in std_logic
    );

end ethercontrol;

architecture Behavioral of ethercontrol is

  constant CMD : std_logic_vector := X"30";

  -- event input

  -- boot parameters

  signal pending : std_logic := '0';

  signal donewait : std_logic := '0';

  signal addrsel : integer range 0 to 1                    := 0;
  signal srcl     : std_logic_vector(7 downto 0) := (others => '0');

  signal oset : std_logic := '0';

  signal estatus : std_logic_vector(7 downto 0) := (others => '0');

  signal learx   : std_logic_vector(somabackplane.N - 1 downto 0)
    := (others => '0');
  signal addrset : std_logic := '0';

  signal dval : std_logic_vector(7 downto 0) := (others => '0');
  signal eosel : integer range 0 to 3 := 0;

  type states is (ecyclew, donechk, senddone, readevt, eserchk,
                  serchk, sererr, noop, serinit, wrnicrw,
                  wrnicaddr, wrnicd1, wrnicd2, serstart);

  signal cs, ns : states := ecyclew;

  signal edrxall : std_logic_vector(16*6 -1 downto 0);
  signal edrxin : std_logic_vector(16*6 -1 downto 0);

  -- output commands
  signal errorpending : std_logic_vector(16*6 -1 downto 0) := (others => '0');
  signal linkstatus : std_logic_vector(16*6 -1 downto 0) := (others => '0');
  signal validresp : std_logic_vector(16*6 -1 downto 0) := (others => '0');

  signal nicdonel : std_logic := '0';
  
begin  -- Behavioral

  -- event data mux
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

 
    edrxin <= errorpending when eosel = 0 else
              linkstatus when eosel = 1 else
              validresp when eosel = 2 else
              (others => '0');
    
    errorpending(15 downto 0) <= X"30" &  DEVICE;
    errorpending(31 downto 16) <= X"0002";

    validresp(15 downto 0) <= X"30" & DEVICE;
    validresp(31 downto 16) <= X"0001"; 
    validresp(47 downto 32) <= DOUT(31 downto 16);
    validresp(63 downto 48) <= DOUT(15 downto 0); 
  dval   <= EOUTD(7 downto 0) when addrsel = 1 else srcl;

  NICSTART <= '1' when cs = serstart else '0';
  
  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs <= ecyclew;

    else
      if rising_edge(CLK) then
        cs <= ns;

        if NICDONE = '1'  then
          nicdonel <= '1';
        else
          if cs = senddone then
            nicdonel <= '0'; 
          end if;
        end if;
        
        if cs = serinit then
          srcl <= EOUTD(7 downto 0);
        end if;

        -- data capture
        if cs = wrnicrw then
          RW <= EOUTD(0); 
        end if;

        if cs = wrnicaddr then
          ADDR <= EOUTD(5 downto 0); 
        end if;

        if cs = wrnicd1 then
          din(31 downto 16) <= EOUTD; 
        end if;
        
        if cs = wrnicd2 then
          din(15 downto 0) <= EOUTD; 
        end if;
        
        -- set/reset for boot status
        if cs = senddone then
          pending  <= '0';
          donewait  <= '0';
        else
          if cs = serstart then
            pending <= '1';
          end if;

          if NICDONE = '1' then
            donewait <= '1';
          end if;
        end if;


        
        -- decoder architecture

        if ECYCLE = '1' then
          learx                               <= (others => '0');
        else
          if addrset = '1' then
            learx(conv_integer(dval)) <= '1';
          end if;
        end if;


        if ECYCLE = '1' then
          EARX <= learx;
        end if;


        if oset = '1' then
          edrxall <= edrxin; 
        end if;
      end if;
    end if;

  end process main;

  fsm : process(cs, ECYCLE, nicdonel, evalid, eoutd, pending)
  begin
    case cs is
      when ecyclew =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if ECYCLE = '1' then
          ns     <= donechk;
        else
          ns     <= ecyclew;
        end if;

      when donechk =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if nicdonel = '1' then
          ns     <= senddone;
        else
          ns     <= readevt;
        end if;

      when senddone =>
        addrset  <= '1';
        eosel <= 2;
        addrsel <= 0; 
        oset     <= '1';
        eouta    <= "000";
        enext    <= '0';
        ns       <= ecyclew;

      when readevt =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if ECYCLE = '1' then
          ns     <= donechk;
        else
          if evalid = '1' then
            ns   <= eserchk;
          else
            ns   <= readevt;
          end if;
        end if;

      when eserchk =>
        addrset  <= '0';
        eosel <= 2;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if eoutd(15 downto 8) = CMD then
          ns     <= serchk;
        else
          ns     <= noop;
        end if;

      when noop =>
        addrset  <= '0'; 
        eosel <= 2;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '1';
        ns       <= readevt;

      when serchk =>
        addrset  <= '0';
        eosel <= 2;
        addrsel <= 0; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if pending = '1' then
          ns     <= sererr;
        else
          ns     <= serinit;
        end if;

      when sererr =>
        addrset  <= '1';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '1';
        eouta    <= "000";
        enext    <= '0';
        ns       <= noop;

      when serinit =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "001";
        enext    <= '0';
        ns       <= wrnicrw;

      when wrnicrw =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "010";
        enext    <= '0';
        ns       <= wrnicaddr;

      when wrnicaddr =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "011";
        enext    <= '0';
        ns       <= wrnicd1;

      when wrnicd1 =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "100";
        enext    <= '0';
        ns       <= wrnicd2;

      when wrnicd2 =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "101";
        enext    <= '0';
        ns       <= serstart;

      when serstart =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '1';
        ns       <= readevt;

      when others =>
        addrset  <= '0';
        eosel <= 0;
        addrsel <= 1; 
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        ns       <= ecyclew;
    end case;
  end process fsm;


end Behavioral;
