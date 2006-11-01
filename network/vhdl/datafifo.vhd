library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity datafifo is
  port (
    CLK    : in  std_logic;
    -- input interfaces
    DIN    : in  std_logic_vector(15 downto 0);
    ADDRIN : in  std_logic_vector(8 downto 0);
    WEIN   : in  std_logic;
    INDONE : in  std_logic;
    -- output interface
    DOEN   : out std_logic;
    ARM    : out std_logic;
    DOUT   : out std_logic_vector(15 downto 0);
    GRANT  : in  std_logic);
end datafifo;

architecture Behavioral of datafifo is
  -- input signals
  signal addra : std_logic_vector(13 downto 0) := (others => '0');
  signal bpin  : std_logic_vector(4 downto 0)  := (others => '0');

  signal bpinl : std_logic_vector(4 downto 0) := (others => '0');

  -- output signals
  signal bcnt  : std_logic_vector(8 downto 0)  := (others => '0');
  signal bpout : std_logic_vector(4 downto 0)  := (others => '0');
  signal addrb : std_logic_vector(13 downto 0) := (others => '0');

  signal len : std_logic_vector(9 downto 0) := (others => '0');

  type states is (none, armw, outwrw, dones);
  signal cs, ns : states := none;

  signal bcntinc : std_logic := '0';

  signal wea : std_logic := '0';

  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  component bigmem
    port (
      CLK     : in  std_logic;
      DIN     : in  std_logic_vector(15 downto 0);
      WEIN    : in  std_logic;
      ADDRIN  : in  std_logic_vector(13 downto 0);
      DOUT    : out std_logic_vector(15 downto 0);
      ADDROUT : in  std_logic_vector(13 downto 0)
      );
  end component;


begin  -- Behavioral

  mem : bigmem
    port map (
      CLK     => CLK,
      DIN     => DIN,
      WEIN    => WEIN,
      ADDRIN  => addra,
      DOUT    => dob,
      ADDROUT => addrb);


  addra <= bpin & ADDRIN;
  addrb <= bpout & bcnt;

  DOUT <= dob;

  main_clk : process(CLK)
  begin
    if rising_edge(CLK) then

      cs <= ns;

      if INDONE = '1' then
        bpin <= bpin + 1;
      end if;


      bpinl <= bpin;

      if cs = none then
        bcnt   <= (others => '0');
      else
        if bcntinc = '1' then
          bcnt <= bcnt + 1;
        end if;
      end if;


      DOEN <= bcntinc;

      if cs = dones then
        bpout <= bpout + 1;
      end if;

      if bcnt = "000000000" then
        len <= dob(10 downto 1);
      end if;

    end if;
  end process main_clk;

  fsm : process(len, addrb, cs, bpinl, bpout, GRANT, bcnt)
  begin
    case cs is
      when none =>
        ARM     <= '0';
        bcntinc <= '0';
        if bpinl /= bpout then
          ns    <= armw;
        else
          ns    <= none;
        end if;

      when armw =>
        ARM     <= '1';
        bcntinc <= '0';
        if GRANT = '1' then
          ns    <= outwrw;
        else
          ns    <= armw;
        end if;

      when outwrw =>
        ARM     <= '0';
        bcntinc <= '1';
        if bcnt = len(8 downto 0) then
          ns    <= dones;
        else
          ns    <= outwrw;
        end if;

      when dones =>
        ARM     <= '0';
        bcntinc <= '0';
        ns      <= none;

      when others =>
        ARM     <= '0';
        bcntinc <= '0';
        ns      <= none;

    end case;
  end process fsm;


end Behavioral;
