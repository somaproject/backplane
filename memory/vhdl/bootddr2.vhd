library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity bootddr2 is

  port (
    CLK   : in  std_logic;
    START : in  std_logic;
    DONE  : out std_logic;
    -- ram interface
    CKE   : out std_logic := '0';
    CS    : out std_logic;
    RAS   : out std_logic;
    CAS   : out std_logic;
    WE    : out std_logic;
    ADDR  : out std_logic_vector(12 downto 0);
    BA    : out std_logic_vector(1 downto 0);
    -- parameters
    EMR   : in  std_logic_vector(12 downto 0);
    MR    : in  std_logic_vector(12 downto 0)
    );

end bootddr2;

architecture Behavioral of bootddr2 is

  signal bcnt : integer range 0 to 2**16-1 := 0;

  signal lCKE  : std_logic                     := '0';
  signal lCS   : std_logic                     := '1';
  signal lRAS  : std_logic                     := '1';
  signal lCAS  : std_logic                     := '1';
  signal lWE   : std_logic                     := '1';
  signal laddr : std_logic_vector(15 downto 0) := (others => '0');
  signal lBA   : std_logic_vector(1 downto 0)  := (others => '0');

  type states is ( none, resetall, startw1, startw2,
                   startw3, propw1, propw2, propw3, prewait, 
                   propw4, nexttick, datainc, propdone, bootnop,
                   loademr2, loademr3, lemrden, lmrdrst, dlllckw, preall,
                   ref1w, ref1, ref2, ref2w, dww, dw, dww2, loadmr,
                   loadmrw,
                   lemrex0, lemrex0w, lemren0, lemren0w, 
                   dones ); 


  signal ocs, ons : states := none;

begin  -- Behavioral

  DONE <= '1' when ocs = dones else '0';
  
  main : process(CLK)
  begin
    if rising_edge(CLK) then

      ocs <= ons;

      CKE  <= lcke;
      CS   <= lcs;
      RAS  <= lras;
      CAS  <= lcas;
      WE   <= lwe;
      ADDR <= laddr(12 downto 0);
      BA   <= lba;

      if ocs = none or ocs = dones then
        bcnt <= 0;
      else
        bcnt <= bcnt + 1;
      end if;

    end if;
  end process main;

  fsm : process(ocs, bcnt, START)
  begin
    case ocs is
      when none          =>
        lcke  <= '1';
        lcas  <= '0';
        lras  <= '0';
        lcs   <= '0';
        lwe   <= '0';
        laddr <= (others => '0');
        lba   <= "00";
        if START = '1' then
          ons  <= bootnop;
        else
          ons  <= none;
        end if;

      when bootnop       =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= (others => '0');
        lba   <= "00";
        if bcnt = 30000 then
          ons  <= prewait;
        else
          ons  <= bootnop;
        end if;

      when prewait =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0200";
        lba   <= "00";
       if bcnt = 32000 then
          ons  <= loademr2; 
        else
          ons  <= prewait;
        end if;

      when loademr2 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= X"0000";
        lba   <= "10";
        ons    <= loademr3;

      when loademr3 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= X"0000";
        lba   <= "11";
        ons    <= lemrden;

      when lemrden =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= X"0000";
        lba   <= "01";
        ons    <= lmrdrst;

      when lmrdrst =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= X"0100";
        lba   <= "00";
        ons    <= dlllckw;

      when dlllckw =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        if bcnt = 40000 then
          ons  <= preall;
        else
          ons  <= dlllckw;
        end if;

      when preall =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '1';
        lwe   <= '0';
        laddr <= X"0200";
        lba   <= "00";
        ons    <= ref1w;

      when ref1w =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        if bcnt = 42000 then
          ons  <= ref1;
        else
          ons  <= ref1w;
        end if;

      when ref1 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= ref2w;

      when ref2w =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        if bcnt = 42500 then
          ons  <= ref2;
        else
          ons  <= ref2w;
        end if;

      when ref2 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= dww;

      when dww =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        if bcnt = 43000 then
          ons  <= dw;
        else
          ons  <= dww;
        end if;

      when dw =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= dww2;


      when dww2 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        if bcnt = 44000 then
          ons  <= loadmr;
        else
          ons  <= dww2;
        end if;

      when loadmr =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= "000" & MR;
        lba   <= "00";
        ons    <= loadmrw;

      when loadmrw =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= lemren0;

      when lemren0 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= "000" & EMR;
        lba   <= "01";
        ons    <= lemren0w;

      when lemren0w =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= lemrex0;


      when lemrex0 =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '0';
        lcas  <= '0';
        lwe   <= '0';
        laddr <= "000" & EMR;
        lba   <= "01";
        ons    <= lemrex0w;

      when lemrex0w =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= dones; 

      when dones =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= dones;

      when others =>
        lcke  <= '1';
        lcs   <= '0';
        lras  <= '1';
        lcas  <= '1';
        lwe   <= '1';
        laddr <= X"0000";
        lba   <= "00";
        ons    <= none;

    end case;

  end process fsm;
end Behavioral;
