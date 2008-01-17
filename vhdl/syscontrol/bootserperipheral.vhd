library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity bootserperipheral is
  port (
    CLK    : in  std_logic;
    DIN    : in  std_logic_vector(15 downto 0);
    ADDRIN : in  std_logic_vector(2 downto 0);
    WEIN   : in  std_logic;
    SEROUT : out std_logic_vector(19 downto 0));
end bootserperipheral;

architecture Behavioral of bootserperipheral is

  signal addra : std_logic_vector(3 downto 0) := (others => '0');
  signal wea   : std_logic                    := '0';

  signal dob, dobflip : std_logic_vector(15 downto 0) := (others => '0');
  signal addrb        : std_logic_vector(3 downto 0)  := (others => '0');
  signal bsel         : integer range 0 to 15         := 0;

  signal fprog, fclk, fdin, fset, fdone : std_logic := '0';

  signal asel : std_logic_vector(19 downto 0);


  type states is (none, fprogst1, fprogw1, fprogst2, fprogw2,
                  sendbitl, sendbitlw, sendbith, sendbithw,
                  nextbit, nextaddr, done);
  signal cs, ns : states := none;

  component bootserialize
    generic (
      M      :     integer := 20);
    port (
      CLK    : in  std_logic;
      FPROG  : in  std_logic;
      FCLK   : in  std_logic;
      FDIN   : in  std_logic;
      FSET   : in  std_logic;
      FDONE  : out std_logic;
      SEROUT : out std_logic_vector(M-1 downto 0);
      ASEL   : in  std_logic_vector(M-1 downto 0));
  end component;


  component regfile
    generic (
      BITS  :     integer := 16);
    port (
      CLK   : in  std_logic;
      DIA   : in  std_logic_vector(BITS-1 downto 0);
      DOA   : out std_logic_vector(BITS -1 downto 0);
      ADDRA : in  std_logic_vector(3 downto 0);
      WEA   : in  std_logic;
      DOB   : out std_logic_vector(BITS -1 downto 0);
      ADDRB : in  std_logic_vector(3 downto 0)
      );
  end component;


begin  -- Behavioral

  fdin    <= dob(bsel);
  dob(15) <= dobflip(0);
  dob(14) <= dobflip(1);
  dob(13) <= dobflip(2);
  dob(12) <= dobflip(3);
  dob(11) <= dobflip(4);
  dob(10) <= dobflip(5);
  dob(9)  <= dobflip(6);
  dob(8)  <= dobflip(7);
  dob(7)  <= dobflip(8);
  dob(6)  <= dobflip(9);
  dob(5)  <= dobflip(10);
  dob(4)  <= dobflip(11);
  dob(3)  <= dobflip(12);
  dob(2)  <= dobflip(13);
  dob(1)  <= dobflip(14);
  dob(0)  <= dobflip(15);

  wea <= '1' when wein = '1' and addrin = "010" else '0';

  bootserialize_inst : bootserialize
    generic map (
      M      => 20)
    port map (
      CLK    => CLK,
      FPROG  => fprog,
      FCLK   => fclk,
      FDIN   => fdin,
      FSET   => fset,
      FDONE  => fdone,
      SEROUT => serout,
      ASEL   => asel);

  regfile_inst : regfile
    generic map (
      bits  => 16)
    port map (
      CLK   => CLK,
      DIA   => DIN,
      DOA   => open,
      ADDRA => addra,
      WEA   => wea,
      DOB   => dobflip,
      addrb => addrb);

  main : process(CLK)
  begin
    if rising_edge(CLK) then
      cs <= ns;

      if wein = '1' then
        if addrin = "000" then
          asel(15 downto 0)  <= DIN;
        end if;
        if addrin = "001" then
          asel(19 downto 16) <= DIN(3 downto 0);
        end if;

      end if;

      if wein = '1' and addrin = "010" then
        addra   <= addra + 1;
      else
        if cs = done then
          addra <= (others => '0');
        end if;
      end if;

      if cs = nextaddr then
        addrb   <= addrb + 1;
      else
        if cs = done then
          addrb <= (others => '0');
        end if;
      end if;

      if cs = nextbit then
        if bsel = 15 then
          bsel <= 0;
        else
          bsel <= bsel + 1;
        end if;
      end if;

    end if;

  end process main;

  fsm : process(cs, wein, addrin, fdone, bsel, addrb, addra)
  begin
    case cs is
      when none =>
        fprog  <= '1';
        fset   <= '0';
        fclk   <= '0';
        if WEIN = '1' then
          if addrin = "011" then
            ns <= fprogst1;
          elsif addrin = "100" then
            ns <= sendbitl;
          else
            ns <= none;
          end if;
        else
          ns   <= none;
        end if;

        ---------------------------------------------------------------------
        -- FPROG
        --------------------------------------------------------------------
      when fprogst1 =>
        fprog <= '0';
        fset  <= '1';
        fclk  <= '0';
        ns    <= fprogw1;

      when fprogw1 =>
        fprog <= '0';
        fset  <= '0';
        fclk  <= '0';
        if fdone = '1' then
          ns  <= fprogst2;
        else
          ns  <= fprogw1;
        end if;

      when fprogst2 =>
        fprog <= '1';
        fset  <= '1';
        fclk  <= '0';
        ns    <= fprogw2;

      when fprogw2 =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        if fdone = '1' then
          ns  <= none;
        else
          ns  <= fprogw2;
        end if;

        -----------------------------------------------------------------------
        -- BIT TX
        -----------------------------------------------------------------------
      when sendbitl =>
        fprog <= '1';
        fset  <= '1';
        fclk  <= '0';
        ns    <= sendbitlw;

      when sendbitlw =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        if fdone = '1' then
          ns  <= sendbith;
        else
          ns  <= sendbitlw;
        end if;

      when sendbith =>
        fprog <= '1';
        fset  <= '1';
        fclk  <= '1';
        ns    <= sendbithw;

      when sendbithw =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '1';
        if fdone = '1' then
          ns  <= nextbit;
        else
          ns  <= sendbithw;
        end if;

      when nextbit =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        if bsel = 15 then
          ns  <= nextaddr;
        else
          ns  <= sendbitl;
        end if;

      when nextaddr =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        if addrb = addra - 1 then
          ns  <= done;
        else
          ns  <= sendbitl;
        end if;

      when done =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        ns    <= none;

      when others =>
        fprog <= '1';
        fset  <= '0';
        fclk  <= '0';
        ns    <= done;

    end case;

  end process fsm;

end Behavioral;
