library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity bootcontrol is

  generic (
    M       :     integer                      := 20;
    DEVICE  :     std_logic_vector(7 downto 0) := X"01"
    );
  port (
    CLK     : in  std_logic;
    RESET   : in  std_logic;
    ECYCLE  : in  std_logic;
    EARX    : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRX    : out std_logic_vector(7 downto 0);
    EDSELRX : in  std_logic_vector(3 downto 0);
    EOUTD  : in std_logic_vector(15 downto 0);
    EOUTA  : out  std_logic_vector(2 downto 0);
    EVALID : in std_logic;
    ENEXT  : out  std_logic;
    BOOTASEL : out  std_logic_vector(M-1 downto 0);
    BOOTADDR : out  std_logic_vector(15 downto 0);
    BOOTLEN  : out  std_logic_vector(15 downto 0);
    MMCSTART    : out  std_logic;
    MMCDONE     : in std_logic
    );
  

end bootcontrol;

architecture Behavioral of bootcontrol is

  constant CMD : std_logic_vector := X"20";

  -- event input

  -- boot parameters

  signal booting : std_logic := '0';

  signal mmcdonel          : std_logic := '0';

  signal errstate : std_logic                    := '0';
  signal srcl     : std_logic_vector(7 downto 0) := (others => '0');

  signal oset : std_logic := '0';

  signal estatus : std_logic_vector(7 downto 0) := (others => '0');

  signal learx   : std_logic_vector(somabackplane.N - 1 downto 0);
  signal addrset : std_logic := '0';

  signal dval : std_logic_vector(7 downto 0) := (others => '0');


  type states is (ecyclew, donechk, senddone, readevt, ebootchk,
                  bootchk, booterr, noop, bootst, wrboota1,
                  wrboota2, wrboota3, wrboota4, wrboote);

  signal cs, ns : states := ecyclew;





begin  -- Behavioral

  -- event data mux
  EDRX <= CMD     when edselrx = X"0" else
          DEVICE  when edselrx = X"1" else
          ESTATUS when edselrx = X"2" else
          X"00";


  dval   <= eoutd(7 downto 0) when errstate = '1' else srcl;
  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs <= ecyclew;

    else
      if rising_edge(CLK) then
        cs <= ecyclew;


        if cs = bootst then
          srcl <= eoutd(7 downto 0);
        end if;

        if cs = wrboota1 then
          bootasel(31 downto 16) <= eoutd;
        end if;

        if cs = wrboota2 then
          bootasel(15 downto 0) <= eoutd;
        end if;

        if cs = wrboota3 then
          bootlen <= eoutd;
        end if;

        if cs = wrboota4 then
          bootaddr <= eoutd;
        end if;

        -- set/reset for boot status
        if cs = senddone then
          booting   <= '0';
          mmcdonel  <= '0';
        else
          if cs = wrboote then
            booting <= '1';
          end if;

          if mmcdone = '1' then
            mmcdonel <= '1';
          end if;
        end if;


        if oset = '1' then
          if errstate = '1' then
            estatus <= X"02";

          else
            estatus <= X"01";
          end if;
        end if;


        -- decoder architecture

        if ECYCLE = '1' then
          learx                               <= (others => '0');
        else
          if addrset = '1' then
            learx(to_integer(unsigned(dval))) <= '1';
          end if;
        end if;


        if ECYCLE = '1' then
          EARX <= learx;
        end if;


      end if;
    end if;

  end process main;

  fsm : process(cs, ECYCLE, mmcdonel, evalid, eoutd, booting)
  begin
    case cs is
      when ecyclew =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if ECYCLE = '1' then
          ns     <= donechk;
        else
          ns     <= ecyclew;
        end if;

      when donechk =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if mmcdonel = '1' then
          ns     <= senddone; 
        else
          ns     <= readevt;
        end if;

      when senddone =>
        errstate <= '0';
        addrset  <= '1';
        oset     <= '1';
        eouta    <= "000";
        enext    <= '0';
        ns       <= ecyclew;

      when readevt =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if ECYCLE = '1' then
          ns     <= donechk;
        else
          if evalid = '1' then
            ns   <= ebootchk;
          else
            ns   <= readevt;
          end if;
        end if;

      when ebootchk =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if eoutd(15 downto 8) = CMD then
          ns     <= bootchk;
        else
          ns     <= noop;
        end if;

      when noop =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '1';
        ns       <= readevt;

      when bootchk =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        if booting = '1' then
          ns     <= booterr;
        else
          ns     <= bootst;
        end if;

      when booterr =>
        errstate <= '1';
        addrset  <= '1';
        oset     <= '1';
        eouta    <= "000";
        enext    <= '0';
        ns       <= noop;

      when bootst =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "001";
        enext    <= '0';
        ns       <= wrboota1;

      when wrboota1 =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "010";
        enext    <= '0';
        ns       <= wrboota2;

      when wrboota2 =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "011";
        enext    <= '0';
        ns       <= wrboota3;

      when wrboota3 =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "100";
        enext    <= '0';
        ns       <= wrboota4;

      when wrboota4 =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "101";
        enext    <= '0';
        ns       <= wrboote;

      when wrboote =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '1';
        ns       <= readevt;

      when others =>
        errstate <= '0';
        addrset  <= '0';
        oset     <= '0';
        eouta    <= "000";
        enext    <= '0';
        ns       <= ecyclew;
    end case;
  end process fsm;


end Behavioral;
