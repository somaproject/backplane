library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library SOMA;
use SOMA.somabackplane.all;
use soma.somabackplane;

library eproc;
use eproc.all;

library UNISIM;
use UNISIM.VComponents.all;

entity syscontrol is
  generic (
    DEVICE      : std_logic_vector(7 downto 0) := X"01";
    RAM_INIT_00 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_01 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_02 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_03 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_04 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_05 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_06 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_07 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_08 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_09 : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0A : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0B : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0C : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0D : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0E : bit_vector(0 to 255)         := (others => '0');
    RAM_INIT_0F : bit_vector(0 to 255)         := (others => '0');

    RAM_INIT_10 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_11 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_12 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_13 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_14 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_15 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_16 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_17 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_18 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_19 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_1F : bit_vector(0 to 255) := (others => '0');

    RAM_INIT_20 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_21 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_22 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_23 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_24 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_25 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_26 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_27 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_28 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_29 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_2F : bit_vector(0 to 255) := (others => '0');

    RAM_INIT_30 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_31 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_32 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_33 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_34 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_35 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_36 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_37 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_38 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_39 : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3A : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3B : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3C : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3D : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3E : bit_vector(0 to 255) := (others => '0');
    RAM_INIT_3F : bit_vector(0 to 255) := (others => '0');

    RAM_INITP_00 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_01 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_02 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_03 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_04 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_05 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_06 :     bit_vector(0 to 255) := (others => '0');
    RAM_INITP_07 :     bit_vector(0 to 255) := (others => '0')
    );
  port (
    CLK          : in  std_logic;
    CLK2X        : in  std_logic;
    RESET        : in  std_logic;
    DEBUG        : out std_logic_vector(7 downto 0);
    -- event interface
    EDTX         : in  std_logic_vector(7 downto 0);
    EATX         : in  std_logic_vector(somabackplane.N -1 downto 0);
    ECYCLE       : in  std_logic;
    EARX         : out std_logic_vector(somabackplane.N - 1 downto 0);
    EDRX         : out std_logic_vector(7 downto 0);
    EDSELRX      : in  std_logic_vector(3 downto 0);
    -- Boot control output
    SEROUT       : out std_logic_vector(19 downto 0);
    -- devicelink monitoring
    DLINKUP      : in  std_logic_vector(31 downto 0);
    dldebug_A : in std_logic_vector(15 downto 0);  -- these are a bit hackish
    dldebug_B : in std_logic_vector(15 downto 0);
    dldebug_C : in std_logic_vector(15 downto 0);
    dldebug_D : in std_logic_vector(15 downto 0)  
    );


end syscontrol;

architecture Behavioral of syscontrol is

  component bootserperipheral
    port (
      CLK    : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      ADDRIN : in  std_logic_vector(2 downto 0);
      WEIN   : in  std_logic;
      SEROUT : out std_logic_vector(19 downto 0));
  end component;


  signal iaddr : std_logic_vector(9 downto 0)  := (others => '0');
  signal idata : std_logic_vector(17 downto 0) := (others => '0');

  signal oportaddr   : std_logic_vector(7 downto 0);
  signal oportdata   : std_logic_vector(15 downto 0);
  signal oportstrobe : std_logic := '0';

  signal iportaddr   : std_logic_vector(7 downto 0);
  signal iportdata   : std_logic_vector(15 downto 0);
  signal iportstrobe : std_logic := '0';


  signal bsperwe : std_logic := '0';

  signal eaout, eaoutl                 : std_logic_vector(somabackplane.N-1 downto 0) := (others => '0');
  signal edout, edoutl                 : std_logic_vector(95 downto 0)                := (others => '0');
  signal enewout               : std_logic                                    := '0';
  signal enewoutl, enewoutslow : std_logic                                    := '0';

  type dlink_countarray is array (0 to 31) of std_logic_vector(7 downto 0);
  signal dlinkcount : dlink_countarray := (others => (others => '0'));
  signal dlinkupl : std_logic_vector(31 downto 0) := (others => '0');
  
  
begin  -- Behavioral


  instruction_ram : RAMB16_S18_S18
    generic map (
      INIT_00 => RAM_INIT_00,
      INIT_01 => RAM_INIT_01,
      INIT_02 => RAM_INIT_02,
      INIT_03 => RAM_INIT_03,
      INIT_04 => RAM_INIT_04,
      INIT_05 => RAM_INIT_05,
      INIT_06 => RAM_INIT_06,
      INIT_07 => RAM_INIT_07,
      INIT_08 => RAM_INIT_08,
      INIT_09 => RAM_INIT_09,
      INIT_0A => RAM_INIT_0A,
      INIT_0B => RAM_INIT_0B,
      INIT_0C => RAM_INIT_0C,
      INIT_0D => RAM_INIT_0D,
      INIT_0E => RAM_INIT_0E,
      INIT_0F => RAM_INIT_0F,

      INIT_10 => RAM_INIT_10,
      INIT_11 => RAM_INIT_11,
      INIT_12 => RAM_INIT_12,
      INIT_13 => RAM_INIT_13,
      INIT_14 => RAM_INIT_14,
      INIT_15 => RAM_INIT_15,
      INIT_16 => RAM_INIT_16,
      INIT_17 => RAM_INIT_17,
      INIT_18 => RAM_INIT_18,
      INIT_19 => RAM_INIT_19,
      INIT_1A => RAM_INIT_1A,
      INIT_1B => RAM_INIT_1B,
      INIT_1C => RAM_INIT_1C,
      INIT_1D => RAM_INIT_1D,
      INIT_1E => RAM_INIT_1E,
      INIT_1F => RAM_INIT_1F,

      INIT_20 => RAM_INIT_20,
      INIT_21 => RAM_INIT_21,
      INIT_22 => RAM_INIT_22,
      INIT_23 => RAM_INIT_23,
      INIT_24 => RAM_INIT_24,
      INIT_25 => RAM_INIT_25,
      INIT_26 => RAM_INIT_26,
      INIT_27 => RAM_INIT_27,
      INIT_28 => RAM_INIT_28,
      INIT_29 => RAM_INIT_29,
      INIT_2A => RAM_INIT_2A,
      INIT_2B => RAM_INIT_2B,
      INIT_2C => RAM_INIT_2C,
      INIT_2D => RAM_INIT_2D,
      INIT_2E => RAM_INIT_2E,
      INIT_2F => RAM_INIT_2F,

      INIT_30 => RAM_INIT_30,
      INIT_31 => RAM_INIT_31,
      INIT_32 => RAM_INIT_32,
      INIT_33 => RAM_INIT_33,
      INIT_34 => RAM_INIT_34,
      INIT_35 => RAM_INIT_35,
      INIT_36 => RAM_INIT_36,
      INIT_37 => RAM_INIT_37,
      INIT_38 => RAM_INIT_38,
      INIT_39 => RAM_INIT_39,
      INIT_3A => RAM_INIT_3A,
      INIT_3B => RAM_INIT_3B,
      INIT_3C => RAM_INIT_3C,
      INIT_3D => RAM_INIT_3D,
      INIT_3E => RAM_INIT_3E,
      INIT_3F => RAM_INIT_3F,

      INITP_00 => RAM_INITP_00,
      INITP_01 => RAM_INITP_01,
      INITP_02 => RAM_INITP_02,
      INITP_03 => RAM_INITP_03,
      INITP_04 => RAM_INITP_04,
      INITP_05 => RAM_INITP_05,
      INITP_06 => RAM_INITP_06,
      INITP_07 => RAM_INITP_07)
    port map (

      DOA   => idata(15 downto 0),
      DOPA  => idata(17 downto 16),
      ADDRA => iaddr,
      CLKA  => clk2x,
      DIA   => X"0000",
      DIPA  => "00",
      ENA   => '1',
      WEA   => '0',
      SSRA  => RESET,
      DOB   => open,
      DOPB  => open,
      ADDRB => "0000000000",
      CLKB  => clk2x,
      DIB   => X"0000",
      DIPB  => "00",
      ENB   => '0',
      WEB   => '0',
      SSRB  => RESET);

  eproc_inst : entity eproc.eproc
    port map (
      CLK         => clk,
      RESET       => RESET,
      EDTX        => EDTX,
      EATX        => EATX,
      ECYCLE      => ECYCLE,
      EAOUT       => eaout,
      EDOUT       => edout,
      ENEWOUT     => enewout,
      CLKHI       => CLK2X,
      IADDR       => iaddr,
      IDATA       => idata,
      OPORTADDR   => oportaddr,
      OPORTDATA   => oportdata,
      OPORTSTROBE => oportstrobe,
      IPORTADDR   => iportaddr,
      IPORTDATA   => iportdata,
      IPORTSTROBE => iportstrobe,
      DEVICE      => DEVICE);

  txeventbuffer_inst : entity eproc.txeventbuffer
    port map (
      CLK      => clk,
      EVENTIN  => edoutl,
      EADDRIN  => eaoutl,
      NEWEVENT => enewoutslow,
      ECYCLE   => ECYCLE,
      EDRX     => EDRX,
      EDRXSEL  => EDSELRX,
      EARX     => EARX);


  bootserp_inst : bootserperipheral
    port map (
      CLK    => CLK2X,
      DIN    => OPORTDATA,
      ADDRIN => OPORTADDR(2 downto 0),
      WEIN   => bsperwe,
      SEROUT => SEROUT);

  bsperwe <= '1' when oportaddr(7 downto 3) = "00001" and OPORTSTROBE = '1'
             else '0';


  dlinkcnt: for i in 0 to 17 generate
    process (CLK2x)
      begin
        if rising_edge(CLK2x) then
          if dlinkupl(i) = '1' and DLINKUP(i) = '0' then
            -- dropped link!
            dlinkcount(i) <= dlinkcount(i) + 1; 
          end if; 
        end if;
      end process;
  end generate dlinkcnt;
  
  process(CLK2x)
  begin
    if rising_edge(CLK2x) then

      dlinkupl <= DLINKUP; 
      enewoutl      <= enewout;
      if enewout = '1'  then
        eaoutl <= eaout;
        edoutl <= edout; 
      end if;
      enewoutslow   <= enewout or enewoutl;
      if iportstrobe = '1' then
        if iportaddr = X"00" then
          iportdata <= DLINKUP(15 downto 0);
        elsif iportaddr = X"01" then
          iportdata <= DLINKUP(31 downto 16);
        elsif iportaddr = X"02" then
          iportdata <= DLINKUP(15 downto 0);
        elsif iportaddr = X"32" then
          iportdata <= X"1234";
        elsif iportaddr(7 downto 4) = X"4" then
          iportdata <= X"00" & dlinkcount(TO_INTEGER(UNSIGNED(iportaddr(3 downto 0))));
        elsif iportaddr = X"50" then
          iportdata <= dldebug_A;
        elsif iportaddr = X"51" then
          iportdata <= dldebug_B;
        elsif iportaddr = X"52" then
          iportdata <= dldebug_C;
        elsif iportaddr = X"53" then
          iportdata <= dldebug_D;
          
       end if;
      end if;
    end if;
  end process;

end Behavioral;
