library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


entity fiberdebugtx is
  generic (
    DEVICE   :     std_logic_vector(7 downto 0) := X"01"
    );
  port (
    CLK      : in  std_logic;
    TXCLK    : in  std_logic;
    RESET    : in  std_logic;
    -- Event bus interface
    ECYCLE   : in  std_logic;
    EATX     : in  std_logic_vector(somabackplane.N - 1 downto 0);
    EDTX     : in  std_logic_vector(7 downto 0);
    -- Fiber interfaces
    FIBEROUT : out std_logic;
    -- debug interface
    DEBUG: out std_logic_vector(7 downto 0) 
    );

end fiberdebugtx;

architecture Behavioral of fiberdebugtx is

  constant CMDSEND : std_logic_vector(7 downto 0) := X"50";

  signal sendcmd : std_logic := '0';
  

  -- interface
  signal enext  : std_logic                     := '0';
  signal eouta  : std_logic_vector(2 downto 0)  := (others => '0');
  signal evalid : std_logic                     := '0';
  signal eoutd  : std_logic_vector(15 downto 0) := (others => '0');

  signal cmdin : std_logic_vector(47 downto 0) := (others => '0');

  type states is (none, chkcmd, word1en, word2en, word3en, sendevent, nextevt);

  signal cs, ns : states := none;

  component fibertx
    port ( CLK      : in  std_logic;
           CMDIN    : in  std_logic_vector(47 downto 0);
           SENDCMD  : in  std_logic;
           FIBEROUT : out std_logic);
  end component;

  component rxeventfifo 
  port (
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    ECYCLE : in  std_logic;
    EATX   : in  std_logic_vector(somabackplane.N -1 downto 0);
    EDTX   : in  std_logic_vector(7 downto 0); 
    -- outputs
    EOUTD  : out std_logic_vector(15 downto 0);
    EOUTA  : in std_logic_vector(2 downto 0);
    EVALID : out std_logic;
    ENEXT  : in  std_logic
    );
end component;

begin  -- Behavioral

  DEBUG(0) <= sendcmd;
  
  fibertx_inst : fibertx
    port map (
      CLK      => TXCLK,
      CMDIN    => cmdin,
      SENDCMD  => sendcmd,
      FIBEROUT => FIBEROUT);

  rxeventfifo_inst: rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => RESET,
      ECYCLE => ECYCLE,
      EATX   => EATX,
      EDTX   => EDTX,
      EOUTD  => eoutd,
      EOUTA  => eouta,
      ENEXT  => enext,
      EVALID => evalid); 
    
  
  main : process(CLK)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        if cs = word1en then
          cmdin(3 downto 0) <= eoutd(3 downto 0);
          cmdin(7 downto 4) <= eoutd(11 downto 8);
        end if;

        if cs = word2en then
          cmdin(39 downto 24) <= eoutd;
        end if;

        if cs = word3en then

          cmdin(23 downto 8) <= eoutd;
        end if;

      end if;
    end if;

  end process main;

  fsm : process(cs, evalid, eoutd, sendcmd)
  begin
    case cs is
      when none =>
        eouta   <= "000";
        sendcmd <= '0';
        enext   <= '0';
        if evalid = '1' then
          ns    <= chkcmd;
        else
          ns    <= none;
        end if;

      when chkcmd =>
        eouta   <= "001";
        sendcmd <= '0';
        enext   <= '0';
        if eoutd(15 downto 8) = CMDSEND then
          ns    <= word1en;
        else
          ns    <= nextevt;
        end if;

      when word1en =>
        eouta   <= "010";
        sendcmd <= '0';
        enext   <= '0';
        ns      <= word2en;

      when word2en =>
        eouta   <= "011";
        sendcmd <= '0';
        enext   <= '0';
        ns      <= word3en;

      when word3en =>
        eouta   <= "011";
        sendcmd <= '0';
        enext   <= '0';
        ns      <= sendevent;

      when sendevent =>
        eouta   <= "000";
        sendcmd <= '1';
        enext   <= '0';
        ns      <= nextevt;

      when nextevt =>
        eouta   <= "000";
        sendcmd <= '0';
        enext   <= '1';
        ns      <= none;

      when others =>
        eouta   <= "000";
        sendcmd <= '0';
        enext   <= '0';
        ns      <= none;
    end case;
  end process fsm;

end Behavioral;
