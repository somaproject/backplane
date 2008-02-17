library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library eproc;
use eproc.all;

entity txcounter is
  port (
    CLK      : in  std_logic;
    PKTLENEN : in  std_logic;
    PKTLEN   : in  std_logic_vector(15 downto 0);
    TXCHAN   : in  std_logic_vector(2 downto 0);
    -- RESETs
    RSTCHAN  : in  std_logic_vector(3 downto 0);
    RSTCNT   : in  std_logic;
    -- outputs
    OSEL     : in  std_logic_vector(3 downto 0);
    CNTOUT   : out std_logic_vector(47 downto 0)
    );
end txcounter;

architecture Behavioral of txcounter is

  signal dia, doa, dob : std_logic_vector(47 downto 0) := (others => '0');
  signal sum, sumi     : std_logic_vector(47 downto 0) := (others => '0');

  signal addra, addrb : std_logic_vector(3 downto 0) := (others => '0');

  signal wea : std_logic := '0';

  signal incwe : std_logic := '0';

  type states is (none, inccnt, inclen);

  signal cs, ns : states := none;

  signal txchanl : std_logic_vector(3 downto 0) := (others => '0');

  signal pktlenl : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- Behavioral

  regfile_counter : entity eproc.regfile
    generic map (
      BITS    => 48)
      port map (
        CLK   => CLK,
        DIA   => dia,
        DOA   => doa,
        ADDRA => addra,
        WEA   => wea,
        DOB   => dob,
        ADDRB => addrb
        );

  sumi(15 downto 0) <= X"0001" when txchanl(0) = '1' else pktlenl;

  sum <= sumi + doa;
  
  wea   <= incwe or rstcnt;
  addra <= txchanl when RSTCNT = '0' else RSTCHAN;

  dia <= sum when RSTCNT = '0' else (others => '0');

  addrb  <= OSEL;
  CNTOUT <= dob;


  main : process(CLK)
  begin
    if rising_edge(CLK) then

      cs                    <= ns;
      
      if PKTLENEN = '1' then
        pktlenl             <= PKTLEN;
        txchanl(3 downto 1) <= TXCHAN;
      end if;

    end if;

  end process;


  fsm : process(cs, PKTLENEN)
  begin
    case cs is
      when none =>
        txchanl(0) <= '0';
        if PKTLENEN = '1' then
          ns       <= inccnt;
        else
          ns       <= none;
        end if;

      when inccnt =>
        txchanl(0) <= '0';
        ns         <= inclen;

      when inclen =>
        txchanl(0) <= '1';
        ns         <= none;

      when others =>
        txchanl(0) <= '0';
        ns         <= none;
    end case;
  end process fsm;

end Behavioral;
