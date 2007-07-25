library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity AcqboardFiberRX is
  port ( CLK     : in  std_logic;
         FIBERIN : in  std_logic;
         RESET   : in  std_logic;
         DATA    : out std_logic_vector(31 downto 0) := (others => '0');
         CMD     : out std_logic_vector(3 downto 0);
         NEWCMD  : out std_logic;
         PENDING : in  std_logic;
         CMDID   : out std_logic_vector(3 downto 0);
         CHKSUM  : out std_logic_vector(7 downto 0));
end AcqboardFiberRX;

architecture Behavioral of AcqboardFiberRX is
-- FIBERRX.VHD
-- system to deserialize 8B/10B bitstream and then
-- parse command packets, eventually rendering a valid packet.
-- Stolen from the acqboard source tree. Whee.


  signal indata : std_logic_vector(7 downto 0) := (others => '0');

  signal code_err, disp_err, err : std_logic := '0';
  signal newpkt, kout            : std_logic := '0';
  signal chksumvalid             : std_logic := '1';

-- fsm signals
  type states is (none, startpkt, cmdl, data1w, data1l,
                  data2w, data2l, data3w, data3l, data4w,
                  data4l, chksumw, chksumc, validpkt, pendw);

  signal cs, ns : states := none;

-- input decoder/deserializer
  component acqboarddecoder
    port ( CLK      : in  std_logic;
           DIN      : in  std_logic;
           DATAOUT  : out std_logic_vector(7 downto 0);
           KOUT     : out std_logic;
           CODE_ERR : out std_logic;
           DISP_ERR : out std_logic;
           DATALOCK : out std_logic;
           RESET    : in  std_logic);
  end component;

begin

  decoder_inst : acqboarddecoder
    port map (
      CLK      => CLK,
      DIN      => FIBERIN,
      DATAOUT  => indata,
      KOUT     => kout,
      CODE_ERR => code_err,
      DISP_ERR => disp_err,
      DATALOCK => newpkt,
      RESET    => RESET);

  err <= code_err or disp_err;

  clock : process(CLK, RESET, cs, newpkt)
  begin
    if RESET = '1' then
      cs                 <= none;
      DATA               <= (others => '0');
      CMDID              <= (others => '0');
      CMD                <= (others => '0');
      CHKSUM(7 downto 1) <= (others => '0');

    else
      if rising_edge(clk) then
        cs <= ns;


        -- latch outputs
        case cs is
          when cmdl    =>
            CMD                <= indata(3 downto 0);
            CMDID              <= indata(7 downto 4);
          when data1l  =>
            DATA(7 downto 0)   <= indata;
          when data2l  =>
            DATA(15 downto 8)  <= indata;
          when data3l  =>
            DATA(23 downto 16) <= indata;
          when data4l  =>
            DATA(31 downto 24) <= indata;
          when chksumc =>
            CHKSUM(7 downto 1) <= indata(7 downto 1);  -- DEBUGGING!

          when others =>
            null;
        end case;
        if newpkt = '1' then
          if err = '0' then
            chksum(0) <= kout;
          end if;

        end if;

      end if;
    end if;



  end process clock;

  fsm : process(cs, ns, newpkt, err, kout, indata, chksumvalid, PENDING)
  begin
    case cs is
      when none     =>
        NEWCMD <= '0';
        if newpkt = '1' and kout = '1'
          and err = '0' and indata = "10111100" then
          ns   <= startpkt;
        else
          ns   <= none;
        end if;
      when startpkt =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= cmdl;
          else
            ns <= none;
          end if;
        else
          ns   <= startpkt;
        end if;
      when cmdl     =>
        NEWCMD <= '0';
        if indata(3 downto 0) = "0000" then
          ns   <= none;
        else
          ns   <= data1w;
        end if;
      when data1w   =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= data1l;
          else
            ns <= none;
          end if;
        else
          ns   <= data1w;
        end if;
      when data1l   =>
        NEWCMD <= '0';
        ns     <= data2w;
      when data2w   =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= data2l;
          else
            ns <= none;
          end if;
        else
          ns   <= data2w;
        end if;
      when data2l   =>
        NEWCMD <= '0';
        ns     <= data3w;
      when data3w   =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= data3l;
          else
            ns <= none;
          end if;
        else
          ns   <= data3w;
        end if;
      when data3l   =>
        NEWCMD <= '0';
        ns     <= data4w;
      when data4w   =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= data4l;
          else
            ns <= none;
          end if;
        else
          ns   <= data4w;
        end if;
      when data4l   =>
        NEWCMD <= '0';
        ns     <= chksumw;
      when chksumw  =>
        NEWCMD <= '0';
        if newpkt = '1' then
          if kout = '0' and err = '0' then
            ns <= chksumc;
          else
            ns <= none;
          end if;
        else
          ns   <= chksumw;
        end if;
      when chksumc  =>
        NEWCMD <= '0';
        if chksumvalid = '1' then
          ns   <= validpkt;
        else
          ns   <= none;
        end if;
      when validpkt =>
        NEWCMD <= '1';
        if PENDING = '0' then
          ns   <= validpkt;
        else
          ns   <= pendw;

        end if;
      when pendw  =>
        NEWCMD <= '0';
        if PENDING = '1' then
          ns   <= pendw;
        else
          ns   <= none;
        end if;
      when others =>
        NEWCMD <= '0';
        ns     <= none;
    end case;

  end process fsm;
end Behavioral;
