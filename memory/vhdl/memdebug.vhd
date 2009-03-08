library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memdebug is
  port (
    -- MEMDDR2 Interface
    MEMCLK   : in  std_logic;
    MEMRESET : out std_logic := '0';
    MEMIFSEL : out std_logic := '0';
    MEMREADY : in  std_logic;
    START    : out std_logic;
    RW       : out std_logic;
    DONE     : in  std_logic;
    ROWTGT   : out std_logic_vector(14 downto 0);
    WRADDR   : in  std_logic_vector(7 downto 0);
    WRDATA   : out std_logic_vector(31 downto 0);
    RDADDR   : in  std_logic_vector(7 downto 0);
    RDDATA   : in  std_logic_vector(31 downto 0);
    RDWE     : in  std_logic;
    --  CONTROL interface
    CCLK     : in  std_logic;
    CRDADDR  : in  std_logic_vector(3 downto 0);
    CWRADDR  : in  std_logic_vector(3 downto 0);
    CWE      : in  std_logic;
    CRD      : in  std_logic;
    CDOUT    : out std_logic_vector(15 downto 0);
    CDIN     : in  std_logic_vector(15 downto 0)

    );

end memdebug;

architecture Behavioral of memdebug is

  -- internal mode / state registers
  signal currenttxnrw : std_logic                     := '0';
  signal noncepending : std_logic_vector(15 downto 0) := (others => '0');
  signal noncedone    : std_logic_vector(15 downto 0) := (others => '0');

  signal wea, weal : std_logic                    := '0';
  signal addraint  : std_logic_vector(9 downto 0) := (others => '0');

  signal dina, douta : std_logic_vector(15 downto 0) := (others => '0');

  signal debugreg : std_logic_vector(15 downto 0) := (others => '0');

  signal lrowtgt : std_logic_vector(14 downto 0) := (others => '0');

  signal memreadstart, memwritestart : std_logic := '0';

  signal wrdataint : std_logic_vector(31 downto 0) := (others => '0');

  -- memory side
  type   memstate is (none, memreadst, memreadw, memwritest, memwritew, memdone);
  signal web, lrw     : std_logic                    := '0';
  signal memcs, memns : memstate                     := none;
  signal memreadyl    : std_logic                    := '0';
  signal memaddrint   : std_logic_vector(8 downto 0) := (others => '0');

  signal lstart, donel : std_logic := '0';

  signal lcdout : std_logic_vector(15 downto 0) := (others => '0');

  signal writecounts : std_logic_vector(15 downto 0) := (others => '0');
  
begin  -- Behavioral
  -- The A interface is the smaller, 16-bit one
  
  
  WriteFifoA : RAMB16_S18_S36
    generic map (
      SIM_COLLISION_CHECK => "NONE")
    port map (
      WEA   => weal,
      ENA   => '1',
      SSRA  => '0',
      CLKA  => CCLK,
      ADDRA => addraint,
      DIA   => dina,
      dipa  => "00",
      DOPA  => open,
      DOA   => douta,
      WEB   => web,
      ENB   => '1',
      SSRB  => '0',
      CLKB  => memclk,
      ADDRB => memaddrint,
      DIB   => RDDATA,
      DIPB  => "0000",
      DOPB  => open,
      DOB   => WRDATAint);


  lCDOUT <= DEBUGREG when CRDADDR = X"0" else
            X"00" & "0000000" & memreadyl when CRDADDR = X"2" else
            "0" & lrowtgt                 when CRDADDR = X"3" else
            "000000" & addraint           when CRDADDR = X"4" else
            douta                         when CRDADDR = X"9" else
            writecounts                   when CRDADDR = X"B" else
            noncedone                     when CRDADDR = X"E" else
            X"0000";

  web <= RDWE;
  maincont : process (CCLK)
  begin  -- process maincont
    if rising_edge(CCLK) then
      memreadyl <= MEMREADY;

      if CRD = '1' then
        CDOUT <= lcdout;
        
      end if;
      weal <= wea;
      if CWE = '1' then
        writecounts <= writecounts + 1;
        if CWRADDR = X"0" then
          debugreg <= CDIN;
        elsif CWRADDR = X"1" then
          MEMRESET <= CDIN(0);
        elsif CWRADDR = X"3" then
          lrowtgt <= CDIN(14 downto 0);
        elsif CWRADDR = X"4" then
          addraint <= CDIN(9 downto 0);
        elsif CWRADDR = X"5" then
          dina <= CDIN;
        end if;
      end if;

      if CWE = '1' and CWRADDR = X"5" then
        wea <= '1';
      else
        wea <= '0';
      end if;

      if CWE = '1' and CWRADDR = X"C" then
        memreadstart <= '1';
      else
        memreadstart <= '0';
      end if;

      if CWE = '1' and CWRADDR = X"7" then
        MEMIFSEL <= CDIN(0);
      end if;

      if CWE = '1' and CWRADDR = X"D" then
        memwritestart <= '1';
      else
        memwritestart <= '0';
      end if;

      if CWE = '1' and (CWRADDR = X"C" or CWRADDR = X"D") then
        noncepending <= CDIN;
      end if;
    end if;
    
  end process maincont;

  memproc : process(MEMCLK)
  begin
    if rising_edge(MEMCLK) then
      memcs  <= memns;
      START  <= lstart;
      RW     <= lrw;
      donel  <= DONE;
      ROWTGT <= lrowtgt;
      WRDATA <= wrdataint;
      if memcs = memdone then
        noncedone <= noncepending;
      end if;
--      if memcs = memreadw or memcs = memreadst then
--        memaddrint(7 downto 0) <= RDADDR;
--      else
--        memaddrint(7 downto 0) <= WRADDR;
--      end if;
    end if;
  end process;
  memaddrint(7 downto 0) <= RDADDR when memcs = memreadw or memcs = memreadst
                            else WRADDR;
  
  memfsm : process(memcs, memreadstart, memwritestart, donel)
  begin
    case memcs is
      when none =>
        lstart <= '0';
        lrw    <= '0';
        if memreadstart = '1' then
          memns <= memreadst;
        elsif memwritestart = '1' then
          memns <= memwritest;
        else
          memns <= none;
        end if;

      when memreadst =>
        lstart <= '1';
        lrw    <= '0';
        memns  <= memreadw;
        
      when memreadw =>
        lstart <= '0';
        lrw    <= '0';
        if donel = '1' then
          memns <= memdone;
        else
          memns <= memreadw;
        end if;
        
        
      when memwritest =>
        lstart <= '1';
        lrw    <= '1';
        memns  <= memwritew;
        
      when memwritew =>
        lstart <= '0';
        lrw    <= '1';
        if donel = '1' then
          memns <= memdone;
        else
          memns <= memwritew;
        end if;
        
      when memdone =>
        lstart <= '0';
        lrw    <= '0';
        memns  <= none;
        
      when others =>
        lstart <= '0';
        lrw    <= '0';
        memns  <= none;
        
    end case;

  end process memfsm;

end Behavioral;
