library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.somabackplane.all;
use work.somabackplane;


library UNISIM;
use UNISIM.VComponents.all;


entity mmcfpgaboot is

  generic (
    M : integer := 20);

  port (
    CLK      : in  std_logic;
    RESET    : in  std_logic;
    BOOTASEL : in  std_logic_vector(M-1 downto 0);
    SEROUT   : out std_logic_vector(M-1 downto 0);
    BOOTADDR : in  std_logic_vector(15 downto 0);
    BOOTLEN  : in  std_logic_vector(15 downto 0);
    START    : in  std_logic;
    DONE     : out std_logic;
    SDOUT    : out std_logic;
    SDIN     : in  std_logic;
    SCLK     : out std_logic;
    SCS      : out std_logic);

end mmcfpgaboot;

architecture Behavioral of mmcfpgaboot is

  signal mcnt             : std_logic_vector(15 downto 0) := (others => '0');
  signal mcntinc, mcntrst : std_logic                     := '0';
  signal mmcioreset : std_logic := '1';
  signal mmciostartdelay : integer range 0 to 500000 := 0;
  
  
  signal incnt : std_logic_vector(10 downto 0) := (others => '0');

  signal mmcdata, mmcdatarev        : std_logic_vector(7 downto 0)
    := (others => '0');
  signal dstart, dvalid : std_logic                    := '0';
  signal ddone          : std_logic                    := '0';

  signal fdin   : std_logic_vector(0 downto 0)  := (others => '0');
  signal outcnt : std_logic_vector(13 downto 0) := (others => '0');
  signal outinc : std_logic                     := '0';

  signal outrst : std_logic := '0';

  signal fprog, fclk, fset, fdone : std_logic := '0';

  signal addr : std_logic_vector(15 downto 0) := (others => '0');

  type states is (none, fprogs, fprogw, fproge, mmcwait, nextbl,
                  enddone, blreads, blreadw, bitwrite, bitsclk, bitsclk0, bits,
                  clk0, bitnext, bitnext2);
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

  component mmcio
    port ( CLK      : in  std_logic;
           RESET    : in  std_logic;
           SCS      : out std_logic;
           SDIN     : in  std_logic;
           SDOUT    : out std_logic;
           SCLK     : out std_logic;
           DOUT     : out std_logic_vector(7 downto 0);
           DSTART   : in  std_logic;
           ADDR     : in  std_logic_vector(15 downto 0);
           DVALID   : out std_logic;
           DREADING : out std_logic;
           DDONE    : out std_logic
           );
  end component;

begin  -- Behavioral

    bootserialize_inst : bootserialize
      generic map (
        M      => M)
      port map (
        CLK    => CLK,
        FPROG  => fprog,
        FCLK   => fclk,
        FDIN   => fdin(0),
        FSET   => fset,
        FDONE  => fdone,
        SEROUT => SEROUT,
        ASEL   => BOOTASEL);

   mmcio_inst : mmcio
     port map (
       CLK      => CLK,
       RESET    => mmcioreset,
       SCS      => SCS,
       SDIN     => SDIN,
       SDOUT    => SDOUT,
       SCLK     => SCLK,
       DOUT     => mmcdata,
       DSTART   => dstart,
       DVALID   => dvalid,
       ADDR     => addr,
       DREADING => open,
       DDONE    => ddone);

  addr <= mcnt + BOOTADDR;

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
    else
      if rising_edge(CLK) then

        cs <= ns;

        -- MCNT
        if cs = none then
          mcnt   <= (others => '0');
        else
          if mcntinc = '1' then
            mcnt <= mcnt + 1;
          end if;
        end if;

        -- acnt
        if dstart = '1' then
          incnt   <= (others => '0');
        else
          if dvalid = '1' then
            incnt <= incnt + 1;
          end if;
        end if;


        -- out counter
        if outrst = '1' then
          outcnt   <= (others => '0');
        else
          if outinc = '1' then
            outcnt <= outcnt + 1;
          end if;
        end if;

        -- start delay
        if mmciostartdelay < 500000 then
          mmciostartdelay <= mmciostartdelay + 1;
          mmcioreset <= '1'; 
        else
          mmcioreset <= '0'; 
        end if;
        
      end if;
    end if;

  end process main;



  fsm : process (cs, start, fdone, outcnt, mcnt, BOOTLEN, ddone)
  begin
    case cs is
      when none =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if START = '1' then
          ns    <= fprogs;
        else
          ns    <= none;
        end if;

      when fprogs =>
        outrst  <= '1';
        outinc  <= '0';
        fprog   <= '0';
        fset    <= '1';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if fdone = '1' then
          ns    <= fprogw;
        else
          ns    <= fprogs;
        end if;

      when fprogw =>
        outrst  <= '0';
        outinc  <= '1';
        fprog   <= '0';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if outcnt = 1024 then
          ns    <= fproge;
        else
          ns    <= fprogw;
        end if;

      when fproge =>
        outrst  <= '1';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '1';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if fdone = '1' then
          ns    <= mmcwait;
        else
          ns    <= fproge;
        end if;
      when mmcwait =>
        outrst  <= '1';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '1';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if ddone = '1' then
          ns    <= blreads;
        else
          ns    <= mmcwait;
        end if;

      when blreads =>
        outrst  <= '1';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '1';
        mcntinc <= '0';
        DONE    <= '0';
        ns      <= blreadw;

      when blreadw =>
        outrst  <= '1';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if ddone = '1' then
          ns    <= bitwrite;
        else
          ns    <= blreadw;
        end if;

      when bitwrite =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '1';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if fdone = '1' then
          ns    <= bitsclk;
        else
          ns    <= bitwrite;
        end if;

      when bitsclk =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '1';
        fclk    <= '1';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if fdone = '1' then
          ns    <= bitsclk0;
        else
          ns    <= bitsclk;
        end if;

      when bitsclk0 =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '1';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if fdone = '1' then
          ns    <= bitnext;
        else
          ns    <= bitsclk0;
        end if;

      when bitnext =>
        outrst  <= '0';
        outinc  <= '1';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if outcnt = "00111111111111" then
          ns    <= bitnext2;
        else
          ns    <= bitwrite;
        end if;

      when bitnext2 =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '1';
        DONE    <= '0';
        ns      <= nextbl;

      when nextbl =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '1';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        if mcnt = BOOTLEN then
          ns    <= enddone;
        else
          ns    <= blreads;
        end if;

      when enddone =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '0';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '1';
        ns      <= none;
      when others  =>
        outrst  <= '0';
        outinc  <= '0';
        fprog   <= '0';
        fset    <= '0';
        fclk    <= '0';
        dstart  <= '0';
        mcntinc <= '0';
        DONE    <= '0';
        ns      <= none;
    end case;
  end process fsm;


    mmcdatarev(0) <= mmcdata(7);
    mmcdatarev(1) <= mmcdata(6);
    mmcdatarev(2) <= mmcdata(5);
    mmcdatarev(3) <= mmcdata(4);
    mmcdatarev(4) <= mmcdata(3);
    mmcdatarev(5) <= mmcdata(2);
    mmcdatarev(6) <= mmcdata(1);
    mmcdatarev(7) <= mmcdata(0);
    



  eventbuffer : RAMB16_S1_S9
    generic map (
      INIT_A              => "0",
      INIT_B              => X"000",
      SRVAL_A             => "0",
      SRVAL_B             => X"000",
      SIM_COLLISION_CHECK => "NONE"
      )

    port map (

      DOA   => fdin,
      DOB   => open,
      DOPB  => open,
      ADDRA => outcnt,
      ADDRB => incnt,
      CLKA  => CLK,
      CLKB  => CLK,
      DIA   => "0",
      DIB   => mmcdatarev,
      DIPB  => "0",
      ENA   => '1',
      ENB   => '1',
      SSRA  => RESET,
      SSRB  => RESET,
      WEA   => '0',
      WEB   => DVALID
      );



end Behavioral;
