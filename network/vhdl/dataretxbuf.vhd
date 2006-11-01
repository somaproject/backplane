library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dataretxbuf is
  port (
    CLK    : in std_logic;
    DIN    : in std_logic_vector(15 downto 0);
    ADDRIN : in std_logic_vector(8 downto 0);
    WE     : in std_logic;
    INDONE : in std_logic;

    -- output
    MEMCLK   : in  std_logic;
    WID      : out std_logic_vector(13 downto 0);
    WDOUT    : out std_logic_vector(15 downto 0);
    WADDR    : out std_logic_vector(8 downto 0);
    WROUT    : out std_logic;
    WDONE    : out std_logic;
    WPENDING : in  std_logic
    );
end dataretxbuf;

architecture Behavioral of dataretxbuf is
  -- input
  signal fpos          : std_logic_vector(2 downto 0)  := (others => '0');
  signal addra         : std_logic_vector(11 downto 0) := (others => '0');
  signal fposl, fposll : std_logic_vector(2 downto 0)  := (others => '0');

  -- output side
  signal outen   : std_logic                    := '0';
  signal nextout : std_logic                    := '0';
  signal fopos   : std_logic_vector(2 downto 0) := (others => '0');
  signal bpos    : std_logic_vector(7 downto 0) := (others => '0');

  signal addrb : std_logic_vector(11 downto 0) := (others => '0');

  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  signal src : std_logic_vector(1 downto 0);
  signal id  : std_logic_vector(31 downto 0) := (others => '0');
  signal typ : std_logic_vector(1 downto 0)  := (others => '0');


  type states is (none, wrstart, wrwait, done, wpendh, wpendl);
  signal cs, ns : states := none;


begin  -- Behavioral

  rams : for i in 0 to 3 generate

    RAMB16_S4_S4_inst : RAMB16_S4_S4
      generic map (
        SIM_COLLISION_CHECK => "NONE", )
      port map (
        DOA                 => open,
        DOB                 => dob(i*4 + 3 downto i*4),
        ADDRA               => addra,
        ADDRB               => addrb,
        CLKA                => CLK,
        CLKB                => MEMCLK,
        DIA                 => DIN(i*4 + 3 downto i*4),
        DIB                 => X"0",
        ENA                 => '1',
        ENB                 => '1',
        SSRA                => '0',
        SSRB                => '0',
        WEA                 => WE,
        WEB                 => '0'
        );

  end generate rams;

  addra <= fpos & addrin;

  WIDA <= typ & src & id(5 downto 0);

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      fposll <= fposl;
      if INDONE = '1' then
        fpos <= fpos + 1;
      end if;

      fposl <= fpos;
    end if;
  end process main;

  addrb <= fopos & bpos;

  mainout : process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then

      cs <= ns;

      if nextout = '1' then
        bpos   <= (others => '0');
      else
        if outen = '1' then
          bpos <= bpos + 1;
        end if;
      end if;

      if nextout = '1' then
        fopos <= fopos + 1;
      end if;

      WADDR <= '0' & bpos;
      WROUT <= outen;

      if bpos = X"13" then
        src <= dob(1 downto 0);
        typ <= dob(9 downto 8);
      end if;

      if bpos = X"11" then
        id(31 downto 16) <= dob;
      end if;

      if bpos =X"12" then
        id(15 downto 0) <= dob;
      end if;
    end if;
  end process mainout;

  fsm : process(cs, fposll, fopos, bpos, WPENDING)
  begin
    case cs is
      when none =>
        outen   <= '0';
        nextout <= '0';
        if fposll /= fopos then
          ns    <= wrstart;
        else
          ns    <= none;
        end if;

      when wrstart =>
        outen   <= '1';
        nextout <= '0';
        ns      <= wrwait;

      when wrwait =>
        outen   <= '1';
        nextout <= '0';
        if bpos = X"00" then
          ns    <= done;
        else
          ns    <= wrwait;
        end if;

      when wrdone =>
        outen   <= '0';
        nextout <= '1';
        ns      <= wpendh;

      when wpendh =>
        outen   <= '0';
        nextout <= '0';
        if wrpending = '1' then
          ns    <= wpendl;
        else
          ns    <= wpendh;
        end if;

      when wpendl =>
        outen   <= '0';
        nextout <= '0';
        if wrpending = '0' then
          ns    <= none;
        else
          ns    <= wpendl;
        end if;

      when others =>
        outen   <= '0';
        nextout <= '0';
        ns      <= none;

    end case;

  end process fsm;
end Behavioral;

