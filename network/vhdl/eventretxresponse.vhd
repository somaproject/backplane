library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity eventretxresponse is
  port (
    CLK       : in  std_logic;
    -- IO interface
    START     : in  std_logic;
    DONE      : out std_logic;
    INPKTDATA : in  std_logic_vector(15 downto 0);
    INPKTADDR : out std_logic_vector(9 downto 0);
    -- retx interface
    RETXDIN   : in  std_logic_vector(15 downto 0);
    RETXADDR  : in  std_logic_vector(8 downto 0);
    RETXWE    : in  std_logic;
    RETXREQ   : out std_logic;
    RETXDONE  : in  std_logic;
    RETXID   : out std_logic_vector(13 downto 0);
    -- output
    ARM       : out std_logic;
    GRANT     : in  std_logic;
    DOUT      : out std_logic_vector(15 downto 0);
    DOEN      : out std_logic);
end eventretxresponse;

architecture Behavioral of eventretxresponse is

  signal len      : std_logic_vector(8 downto 0) := (others => '0');
  signal bcnt     : std_logic_vector(9 downto 0) := (others => '0');
  signal lretxreq : std_logic                    := '0';


  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  signal bcntinc : std_logic := '0';


  type states is (none, getseqh, getseql,
                  retxst, retxw, armw, outwrw, dones);

  signal cs, ns : states := none;

  signal addra : std_logic_vector(9 downto 0) := (others => '0');

  signal retxseq : std_logic_vector(31 downto 0) := (others => '0');

  
  

begin  -- Behavioral

  addra <= '0' & RETXADDR;
  DOUT  <= dob;


  DONE <= '1' when cs = dones else '0';

  RETXID <= retxseq(13 downto 0);
  
  buffer_inst : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "NONE")
    port map (
      DOA                 => open,
      DOB                 => dob,
      ADDRA               => addra,
      ADDRB               => bcnt,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => RETXDIN,
      DIB                 => X"0000",
      DIPA                => "00",
      DIPB                => "00",
      ENA                 => '1',
      ENB                 => '1',
      SSRA                => '0',
      SSRB                => '0',
      WEA                 => RETXWE,
      WEB                 => '0'
      );

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

      RETXREQ   <= lretxreq;

      if cs = getseql then
        retxseq(31 downto 16) <= INPKTDATA;
      end if;

      if cs = retxst then
        retxseq(15 downto 0) <= INPKTDATA;
      end if;

      if cs = none then
        bcnt   <= (others => '0');
      else
        if bcntinc = '1' then
          bcnt <= bcnt + 1;
        end if;
      end if;

      DOEN <= bcntinc;

      if bcnt(8 downto 0) = "000000000" then
        len <= dob(9 downto 1);
      end if;


    end if;
  end process main;


  fsm : process(cs, START, RETXDONE, GRANT, bcnt, len)
  begin
    case cs is
      when none              =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        if START = '1' then
          ns      <= getseqh;
        else
          ns      <= none;
        end if;

      when getseqh =>
        INPKTADDR <= "0000010110";
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        ns        <= getseql;

      when getseql =>
        INPKTADDR <= "0000010111";
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        ns        <= retxst;

      when retxst            =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '1';
        bcntinc   <= '0';
        ns        <= retxw;

      when retxw             =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        if RETXDONE = '1' then
          ns      <= armw;
        else
          ns      <= retxw;
        end if;

      when armw              =>
        INPKTADDR <= (others => '0');
        ARM       <= '1';
        lretxreq  <= '0';
        bcntinc   <= '0';
        if GRANT = '1' then
          ns      <= outwrw;
        else
          ns      <= armw;
        end if;

      when outwrw            =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '1';
        if bcnt(8 downto 0) = len -1 then
          ns      <= dones;
        else
          ns      <= outwrw;
        end if;

      when dones             =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        ns        <= none;

      when others            =>
        INPKTADDR <= (others => '0');
        ARM       <= '0';
        lretxreq  <= '0';
        bcntinc   <= '0';
        ns        <= none;
    end case;
  end process fsm;
end Behavioral;
