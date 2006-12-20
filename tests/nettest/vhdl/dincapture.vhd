library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity dincapture is
  port (
    CLK   : in std_logic;
    DINEN : in std_logic;
    DIN   : in std_logic_vector(15 downto 0)
    ); 
end dincapture;

architecture Behavioral of dincapture is

  signal dinenl : std_logic := '0';
  signal dinenll : std_logic := '0';

  signal wordcnt : std_logic_vector(7 downto 0) := (others => '0');
  signal framecnt : std_logic_vector(1 downto 0) := (others => '0');
                                      
  signal dinl, dob : std_logic_vector(15 downto 0) := X"ABCD";

  signal inaddr : std_logic_vector(9 downto 0) := (others => '0');
  signal outaddr : std_logic_vector(15 downto 0) := (others => '0');

  signal bitcnt : integer range 0 to 15 := 0;

  signal otdi : std_logic := '0';

  signal odrck, osel, oshift, oupdate, otdo : std_logic             := '0';
  
begin  -- Beh

    eventbuffer_inst : RAMB16_S18_S18
    generic map (
      SIM_COLLISION_CHECK => "NONE",     
      -- Address 0 to 255
      INIT_00             => X"AAA1AAA2AAA3AAA4AAA5AAA6AAA7AAA8AAA9AAA01AAAA32AAFEDCB9876543210",
      INIT_01             => X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0DC2",
      INIT_02             => X"BCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC0FE3",
      INIT_03             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4",
      INIT_04             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5",
      INIT_05             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6",
      INIT_06             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7",
      INIT_07             => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8",
      INIT_08             => X"FFF0000000000000000000000000000000000000000000000000000000000009",
      INIT_09             => X"000000000000000000000000000000000000000000000000000000000000000A")

      port map (
      DOA                 => open,
      DOB                 => dob, 
      DOPA                => open,
      DOPB                => open,
      ADDRA               => inaddr,
      ADDRB               => outaddr(9 downto 0),
      CLKA                => CLK,
      CLKB                => oupdate,
      DIA                 => dinl,
      DIB                 => X"0000",
      DIPA                => "00",   
      DIPB                => "00",   
      ENA                 => '1',    
      ENB                 => osel,    
      SSRA                => '0',    
      SSRB                => '0',    
      WEA                 => dinenl, 
      WEB                 => '0'
      );

  inaddr <= framecnt & wordcnt ;


  BSCAN_OUT_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => 4)
    port map (
      CAPTURE    => open,
      DRCK       => odrck,
      reset      => open,
      SEL        => osel,
      SHIFT      => oshift,
      TDI        => otdi,
      UPDATE     => oupdate,
      TDO        => otdo);
    
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        dinenl <= DINEN;
        dinenll <= dinenl;
        
        dinl <= DIN;

        if dinenl = '0' then
          wordcnt <= (others => '0');
        else
          wordcnt <= wordcnt + 1; 
        end if;

        if dinenl ='0' and dinenll = '1' then
          framecnt <= framecnt + 1; 
        end if;
                  
      end if;
    end process main; 

  -- output jtag proces
  jtagin : process(ODRCK, OUPDATE)
  begin
    if OUPDATE = '1' then
      bitcnt     <= 0;
    else
      if rising_edge(ODRCK) then
        if osel = '1' and oshift = '1' then
          bitcnt <= bitcnt + 1;
          outaddr <= otdi & outaddr(15 downto 1); 
        end if;
      end if;
    end if;
  end process jtagin;

  otdo <= dob(bitcnt); 

    
end Behavioral;
