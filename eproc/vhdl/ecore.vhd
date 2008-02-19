library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ecore is
  port (
    CLK         : in  std_logic;
    CPHASEOUT   : out std_logic;
    RESET       : in  std_logic;
    -- instruction interface
    IADDR       : out std_logic_vector(9 downto 0);
    IDATA       : in  std_logic_vector(17 downto 0);
    -- event interface
    EADDR       : out std_logic_vector(2 downto 0);
    EDATA       : in  std_logic_vector(15 downto 0);
    -- io ports
    OPORTADDR   : out std_logic_vector(7 downto 0);
    OPORTDATA   : out std_logic_vector(15 downto 0);
    OPORTSTROBE : out std_logic;

    IPORTADDR   : out std_logic_vector(7 downto 0);
    IPORTDATA   : in  std_logic_vector(15 downto 0);
    IPORTSTROBE : out std_logic;
    -- interrupt interface ports
    FORCEJUMP   : in  std_logic;
    FORCEADDR   : in  std_logic_vector(9 downto 0)
    );

end ecore;

architecture Behavioral of ecore is

  -- general control
  signal cphase : std_logic := '0';

  -- register-file-related signals
  signal regin : std_logic_vector(15 downto 0) := (others => '0');
  signal rega  : std_logic_vector(15 downto 0) := (others => '0');
  signal regb  : std_logic_vector(15 downto 0) := (others => '0');

  signal regaddra, regaddrb : std_logic_vector(3 downto 0) := (others => '0');

  signal reginsel, useevt, bsel : std_logic := '0';

  signal rwe, wea : std_logic := '0';

  signal immval : std_logic_vector(7 downto 0) := (others => '0');

  signal isel : std_logic := '0';
  
  -- alu signals
  signal aop, aopl              : std_logic_vector(3 downto 0)  := (others => '0');
  signal alua, alub, aluy : std_logic_vector(15 downto 0) := (others => '0');

  signal aluzero, alugtz, alultz : std_logic := '0';
  signal alucout, alucoutl         : std_logic := '0';
  signal laluzero, lalugtz, lalultz, lalucout : std_logic := '0';
  

  -- program counter control
  signal lpc, pc        : std_logic_vector(9 downto 0) := (others => '0');
  signal jexec          : std_logic                    := '0';
  signal jdec           : std_logic                    := '0';
  signal jumpdest, jtgt : std_logic_vector(9 downto 0) := (others => '0');
  signal jtyp           : std_logic_vector(1 downto 0) := (others => '0');


  -- io port signals
  signal loportstrobe : std_logic := '0';
  signal odir         : std_logic := '0';

  signal opclass : std_logic_vector(1 downto 0) := (others => '0');

  component alu
    port (
      A    : in  std_logic_vector(15 downto 0);
      B    : in  std_logic_vector(15 downto 0);
      Y    : out std_logic_vector(15 downto 0);
      AOP  : in  std_logic_vector(3 downto 0);
      CIN  : in  std_logic;
      COUT : out std_logic;
      ZERO : out std_logic;
      GTZ  : out std_logic;
      LTZ  : out std_logic
      );
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

  -- instantiate the ALU
  alu_inst : alu
    port map (
      A    => alua,
      B    => alub,
      Y    => aluy,
      AOP  => aopl,
      CIN  => alucoutl, 
      COUT => lalucout,
      ZERO => laluzero,
      GTZ  => lalugtz,
      LTZ  => lalultz);

  -- instatntiate the regfile
  reg_inst : regfile
    generic map (
      BITS  => 16)
    port map (
      CLK   => CLK,
      DIA   => regin,
      ADDRA => regaddra,
      ADDRB => regaddrb,
      WEA   => wea,
      DOA   => rega,
      DOB   => regb);

  reginsel <= '1' when opclass = "11" else '0'; 
  regin <= aluy when reginsel = '0' else iportdata;

  wea <= rwe and cphase;


  -- decoded signals

  regaddra <= IDATA(3 downto 0);
  regaddrb <= IDATA(7 downto 4);
  EADDR    <= IDATA(10 downto 8);
  aop      <= IDATA(15 downto 12);
  immval   <= IDATA(11 downto 4);
  useevt   <= IDATA(11) when opclass = "00" else '0';

  opclass  <= IDATA(17 downto 16);
  jumpdest <= IDATA(13 downto 4);

  rwe <= '1' when opclass = "00" or opclass = "10"
         or (opclass = "11"  and odir = '0')
       else '0';

  -- jump logic
  lpc  <= pc + 1 when jexec = '0'
          else jtgt;
  
  jtgt <= IDATA(13 downto 4) when forcejump = '0' else FORCEADDR;

  jexec <= jdec or FORCEJUMP;
  jtyp <= IDATA(15 downto 14); 
  jdec <= '1' when opclass = "01" and (jtyp = "00" or
                                       (jtyp = "01" and aluzero = '1' ) or
                                       (jtyp = "10" and alugtz = '1' ) or
                                       (jtyp = "11" and alultz = '1' ) )
          else '0';


  -- output port
  loportstrobe <= '1' when (opclass = "11" and odir = '1' and cphase = '0')
                  else '0';
  odir <= IDATA(15); 
  isel <= IDATA(14); 

  bsel <= '1' when opclass = "10" else '0';
  
  IADDR <= pc; 
  CPHASEOUT  <= cphase;

  
  IPORTSTROBE <= '1' when opclass = "11" and odir = '0' and cphase = '0' else '0';

  IPORTADDR <= immval when isel = '0' else regb(7 downto 0);
  

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cphase <= '0';
      pc     <= (others => '1');
    else
      if rising_edge(CLK) then

        cphase <= not cphase;

        -- program counter
        if cphase = '0' then
          pc <= lpc;
        end if;

        if cphase = '1' then
          aluzero <= laluzero;
          alugtz <= lalugtz;
          alultz <= lalultz;
          alucout <= lalucout; 
        end if;

        alucoutl <= alucout;
        
        if useevt = '1' then
          alua <= EDATA;
        else
          alua <= rega;
        end if;

        if bsel = '0' then
          alub <= regb;
        else
          alub <= "00000000" & immval;
        end if;
        aopl <= aop; 
        -- output port
        if loportstrobe = '1' then
          if isel = '0' then
            OPORTADDR <= immval;  
          else
            OPORTADDR <= regb(7 downto 0); 
          end if;

          OPORTDATA <= rega;
        end if;
        OPORTSTROBE <= loportstrobe;

      end if;
    end if;

  end process main;


end Behavioral;

