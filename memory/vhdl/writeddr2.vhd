library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity writeddr2 is
  generic (
    CASLATENCY : in  integer);
  port (
    CLK        : in  std_logic;
    START      : in  std_logic;
    DONE       : out std_logic;
    -- ram interface
    CS         : out std_logic;
    RAS        : out std_logic;
    CAS        : out std_logic;
    WE         : out std_logic;
    ADDR       : out std_logic_vector(12 downto 0);
    BA         : out std_logic_vector(1 downto 0);
    DOUT       : out std_logic_vector(31 downto 0);
    TS         : out std_logic;
    -- input data interface
    ROWTGT     : in  std_logic_vector(14 downto 0);
    WADDR      : out std_logic_vector(7 downto 0);
    WDATA      : in  std_logic_vector(31 downto 0)
    );
end writeddr2;

architecture Behavioral of writeddr2 is

  signal lcs   : std_logic                     := '0';
  signal lras  : std_logic                     := '1';
  signal lcas  : std_logic                     := '1';
  signal lwe   : std_logic                     := '1';
  signal laddr : std_logic_vector(12 downto 0) := (others => '0');

  signal lba : std_logic_vector(1 downto 0) := (others => '0');

  signal lts   : std_logic                     := '0';
  signal ldout : std_logic_vector(31 downto 0) := (others => '0');

  signal acnt, acntl    : std_logic_vector(7 downto 0) := (others => '0');
  signal incacnt : std_logic                    := '0';
  signal asel    : std_logic                    := '0';

  signal precnt : integer range 0 to 15 := 0;
  

  type states is (none, act, write, nop1, nop2, nop3, prenopw,
                  doneprec, dones);
  signal ocs, ons : states := none;

  type doutsreg_t is array (10 downto 0) of std_logic_vector(31 downto 0);
  signal doutsreg : doutsreg_t := (others => (others => '0'));

  signal tssreg : std_logic_vector(10 downto 0) := (others => '1');


begin  -- Behavioral

  laddr <= ("0000" & acnt(7 downto 1) & "00") when asel = '1' else rowtgt(12 downto 0);
  lba   <= rowtgt(14 downto 13);


  lts <= tssreg(2)   when CASLATENCY = 3 else
           tssreg(3) when CASLATENCY = 4 else
           tssreg(4) when CASLATENCY = 5; 


  DONE <= '1' when ocs = dones else '0';

  WADDR <= acnt;

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      ocs <= ons;

      BA   <= lba;
      TS   <= lts;

      CS  <= lcs;
      RAS <= lras;
      CAS <= lcas;
      WE  <= lwe;

      if ocs = none then
        acnt   <= (others => '0');
      else
        if incacnt = '1' then
          acnt <= acnt + 1;
          acntl <= acnt;
        end if;
      end if;

      -- shift regitsrs

      tssreg   <= tssreg(9 downto 0) & (not incacnt);
      doutsreg <= doutsreg(9 downto 0) & WDATA;



      if ocs = none then
        precnt <= 0;
      else
        if ocs = prenopw then
          precnt <= precnt + 1;
        end if; 
      end if;
               
      ADDR <= laddr; 
    end if;
  end process main;



  DOUT <= doutsreg(0) when CASLATENCY = 3 else  
          doutsreg(1) when CASLATENCY = 4 else
          doutsreg(2) when CASLATENCY = 5;



  fsm : process(ocs, start, acnt, acntl, precnt)
  begin
    case ocs is
      when none =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if START = '1' then
          ons   <= act;
        else
          ons   <= none;
        end if;


      when act =>
        incacnt <= '0';
        asel    <= '0';
        lcs     <= '0';
        lras    <= '0';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= write;

      when write =>
        incacnt <= '1';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '0';
        lwe     <= '0';
        ons     <= nop3;                -- debugging

      when nop3 =>
        incacnt <= '1';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if acnt = X"FF" then
          ons   <= prenopw;
        else
          ons   <= write;
        end if;

      when prenopw =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        if precnt = 10 then
          ons   <= doneprec;
        else
          ons   <= prenopw;
        end if;

      when doneprec =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '0';
        lcas    <= '1';
        lwe     <= '0';
        ons     <= dones;

      when dones =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= none;

      when others =>
        incacnt <= '0';
        asel    <= '1';
        lcs     <= '0';
        lras    <= '1';
        lcas    <= '1';
        lwe     <= '1';
        ons     <= none;

    end case;

  end process fsm;

end Behavioral;
