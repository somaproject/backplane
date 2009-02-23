library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memcontmux is
  port (
    CLK      : in  std_logic;
    DSEL     : in  integer range 0 to 3;
    -- RAM!
    CKE      : out std_logic := '0';
    CAS      : out std_logic := '1';
    RAS      : out std_logic := '1';
    CS       : out std_logic := '1';
    WE       : out std_logic := '1';
    ADDR     : out std_logic_vector(12 downto 0) := (others => '0');
    BA       : out std_logic_vector(1 downto 0) := (others => '0');     
    -- Boot module interface
    BOOTCKE  : in  std_logic := '0';
    BOOTCAS  : in  std_logic;
    BOOTRAS  : in  std_logic;
    BOOTCS   : in  std_logic;
    BOOTWE   : in  std_logic;
    BOOTADDR : in  std_logic_vector(12 downto 0);
    BOOTBA   : in  std_logic_vector(1 downto 0);
    -- Refresh module interface
    REFCKE   : in  std_logic := '0';
    REFCAS   : in  std_logic;
    REFRAS   : in  std_logic;
    REFCS    : in  std_logic;
    REFWE    : in  std_logic;
    REFADDR  : in  std_logic_vector(12 downto 0);
    REFBA    : in  std_logic_vector(1 downto 0);
    -- write module interface
    WCKE     : in  std_logic := '0';
    WCAS     : in  std_logic;
    WRAS     : in  std_logic;
    WCS      : in  std_logic;
    WWE      : in  std_logic;
    WADDR    : in  std_logic_vector(12 downto 0);
    WBA      : in  std_logic_vector(1 downto 0);
    -- read module interface
    RCKE     : in  std_logic := '0';
    RCAS     : in  std_logic;
    RRAS     : in  std_logic;
    RCS      : in  std_logic;
    RWE      : in  std_logic;
    RADDR    : in  std_logic_vector(12 downto 0);
    RBA      : in  std_logic_vector(1 downto 0)
    );
end memcontmux;

architecture Behavioral of memcontmux is

  
  signal lcke  : std_logic                     := '0';
  signal lras  : std_logic                     := '1';
  signal lcas  : std_logic                     := '1';
  signal lcs   : std_logic                     := '1';
  signal lwe   : std_logic                     := '1';
  signal laddr : std_logic_vector(12 downto 0) := (others => '0');
  signal lba   : std_logic_vector(1 downto 0)  := (others => '0');

begin  -- Behavioral


  lcke <= refcke  when dsel = 0 else
          bootcke when dsel = 1 else
          wcke    when dsel = 2 else
          rcke;

  lcas <= refcas  when dsel = 0 else
          bootcas when dsel = 1 else
          wcas    when dsel = 2 else
          rcas;

  lras <= refras  when dsel = 0 else
          bootras when dsel = 1 else
          wras    when dsel = 2 else
          rras;

  lcs <= refcs  when dsel = 0 else
         bootcs when dsel = 1 else
         wcs    when dsel = 2 else
         rcs;

  lwe <= refwe  when dsel = 0 else
         bootwe when dsel = 1 else
         wwe    when dsel = 2 else
         rwe;

  laddr <= REFADDR  when dsel = 0 else
           bootaddr when dsel = 1 else
           waddr    when dsel = 2 else
           raddr;

  lba <= REFBA  when dsel = 0 else
         bootba when dsel = 1 else
         wba    when dsel = 2 else
         rba;


  main : process(CLK)
  begin

    if rising_edge(CLK) then

      CKE  <= lcke;
      RAS  <= lras;
      CAS  <= lcas;
      CS   <= lcs;
      WE   <= lwe;
      ADDR <= laddr;
      BA   <= lba;
    end if;
  end process main;


end Behavioral;
