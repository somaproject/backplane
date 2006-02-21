library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity datamux is
  port ( CLK  : in  std_logic;
         BIN  : in  std_logic_vector(3 downto 0);
         DOEN : out std_logic;
         DOUT : out std_logic
         );

end datamux;

architecture Behavioral of datamux is
  signal bl                             : std_logic_vector(3 downto 0) := (others => '0');
  signal bll                            : std_logic_vector(3 downto 0) := (others => '0');
  signal tran30, tran01, tran12, tran23 : std_logic                    := '0';

  signal spos, sposl, sposll : std_logic_vector(1 downto 0) := (others => '0');
  signal ldout, lldout       : std_logic                    := '0';
  signal bll3l               : std_logic                    := '0';
begin

  tran30 <= bll3l xor bll(0);
  tran01 <= bll(0) xor bll(1);
  tran12 <= bll(1) xor bll(2);
  tran23 <= bll(2) xor bll(3);

  spos <= "00" when tran30 = '1' else
          "01" when tran01 = '1' else
          "10" when tran12 = '1' else
          "11";


  lldout <= bll(0) when sposl = "11" else
            bll(1) when sposl = "00" else
            bll(2) when sposl = "01" else
            bll(3);


  main : process (CLK)
  begin
    if rising_edge(CLK) then
      bl      <= bin;
      bll     <= bl;
      sposll  <= sposl;
      if tran30 = '1' or tran01 = '1' or tran12 = '1' or tran23 = '1' then
        sposl <= spos;
      end if;
      if (sposll = "10" and sposl = "11") then  --or (sposll = "01" and sposl = "00") then
        DOEN  <= '0';
      else
        DOEN  <= '1';
      end if;

      bll3l <= bll(3);

      ldout <= lldout;
      DOUT  <= ldout;
    end if;

  end process main;



end Behavioral;

