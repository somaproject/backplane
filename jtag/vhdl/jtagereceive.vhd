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

entity jtagereceive is
  generic (
    JTAG_CHAIN_MASK : integer := 1;
    JTAG_CHAIN_OUT  : integer := 1
    );
  port (
    CLK : in std_logic;

    ECYCLE : in  std_logic;
    EDTX   : in  std_logic_vector(7 downto 0);
    EATX   : out std_logic_vector(somabackplane.N - 1 downto 0)
    );
end jtagereceive;


architecture Behavioral of jtagereceive is
  -- output side
  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal dout, doutl : std_logic_vector(95 downto 0) := (others => '0');

  signal odrck, osel, oshift, oupdate, otdo : std_logic             := '0';
  signal bitcnt                             : integer range 0 to 95 := 0;

  type ostates is (eoutw, ew0, ew1, ew2, ew3, ew4, ew5, selwait, wwrite, outwait, outdone);
  signal ocs, ons : ostates := eoutw;

  signal addrbinc : std_logic := '0';

  -- input side
  signal cp : std_logic_vector(9 downto 0) := (others => '0');

  signal wea   : std_logic                     := '0';
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');


begin  -- Behavioral

  eventbuffer_inst : RAMB16_S18_S18
    generic map (
      SRVAL_B             => X"00000",  --  Port B ouput value upon SSR assertion
      WRITE_MODE_A        => "WRITE_FIRST",  --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      WRITE_MODE_B        => "WRITE_FIRST",  --  WRITE_FIRST, READ_FIRST or NO_CHANGE
      SIM_COLLISION_CHECK => "ALL",     -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
      -- Address 0 to 255
      INIT_00             => X"0000000000000000000000000000000000000000000000000000000000000001",
      INIT_01             => X"0000000000000000000000000000000000000000000000000000000000000002",
      INIT_02             => X"0000000000000000000000000000000000000000000000000000000000000003",
      INIT_03             => X"0000000000000000000000000000000000000000000000000000000000000004",
      INIT_04             => X"0000000000000000000000000000000000000000000000000000000000000005",
      INIT_05             => X"0000000000000000000000000000000000000000000000000000000000000006",
      INIT_06             => X"0000000000000000000000000000000000000000000000000000000000000007",
      INIT_07             => X"0000000000000000000000000000000000000000000000000000000000000008",
      INIT_08             => X"0000000000000000000000000000000000000000000000000000000000000009",
      INIT_09             => X"000000000000000000000000000000000000000000000000000000000000000A",
      INIT_0A             => X"000000000000000000000000000000000000000000000000000000000000000B",
      INIT_0B             => X"000000000000000000000000000000000000000000000000000000000000000C",
      INIT_0C             => X"000000000000000000000000000000000000000000000000000000000000000D",
      INIT_0D             => X"000000000000000000000000000000000000000000000000000000000000000E",
      INIT_0E             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F             => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 256 to 511
      INIT_10             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F             => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 512 to 767
      INIT_20             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F             => X"0000000000000000000000000000000000000000000000000000000000000000",
      -- Address 768 to 1023
      INIT_30             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E             => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F             => X"0000000000000000000000000000000000000000000000000000000000000000")
    port map (
      DOA                 => open,
      DOB                 => dob,
      DOPA                => open,
      DOPB                => open,
      ADDRA               => addra,
      ADDRB               => addrb,
      CLKA                => CLK,
      CLKB                => CLK,
      DIA                 => eoutd,
      DIB                 => X"0000",
      DIPA                => "00",      -- Port A 2-bit parity Input
      DIPB                => "00",      -- Port-B 2-bit parity Input
      ENA                 => '1',       -- Port A RAM Enable Input
      ENB                 => '1',       -- PortB RAM Enable Input
      SSRA                => '0',       -- Port A Synchronous Set/Reset Input
      SSRB                => '0',       -- Port B Synchronous Set/Reset Input
      WEA                 => wea,       -- Port A Write Enable Input
      WEB                 => '0'
      );

  BSCAN_OUT_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => JTAG_CHAIN_OUT)
    port map (
      CAPTURE    => open,
      DRCK       => odrck,
      reset      => open,
      SEL        => osel,
      SHIFT      => oshift,
      TDI        => open,
      UPDATE     => oupdate,
      TDO        => otdo);


  -- output jtag proces
  jtagout : process(ODRCK, OUPDATE)
  begin
    if OUPDATE = '1' then
      bitcnt     <= 0;
    else
      if rising_edge(ODRCK) then
        if osel = '1' and oshift = '1' then
          bitcnt <= bitcnt + 1;
        end if;
      end if;
    end if;
  end process jtagout;

  cp <= "0000000001";

  otdo <= doutl(bitcnt);


  main : process(CLK)
  begin
    if rising_edge(CLK) then

      -- output side
      ocs <= ons;

      if addrbinc = '1' then
        addrb <= addrb + 1;
      end if;

      if ocs = ew0 then
        dout(15 downto 0)  <= dob;
      end if;
      if ocs = ew1 then
        dout(31 downto 16) <= dob;
      end if;
      if ocs = ew2 then
        dout(47 downto 32) <= dob;
      end if;
      if ocs = ew3 then
        dout(63 downto 48) <= dob;
      end if;
      if ocs = ew4 then
        dout(79 downto 64) <= dob;
      end if;
      if ocs = ew5 then
        dout(95 downto 80) <= dob;
      end if;

      if ocs = outdone then
        doutl   <= (others => '0');
      else
        if ocs = wwrite then
          doutl <= dout;
        end if;
      end if;

    end if;
  end process main;

  outfsm : process(addrb, cp, osel, oupdate, ocs)
  begin
    case ocs is
      when eoutw =>
        addrbinc <= '0';
        if addrb /= cp then
          ons     <= ew0;
        else
          ons     <= eoutw;
        end if;
      when ew0   =>
        addrbinc <= '1';
        ons       <= ew1;

      when ew1 =>
        addrbinc <= '1';
        ons       <= ew2;

      when ew2 =>
        addrbinc <= '1';
        ons       <= ew3;

      when ew3 =>
        addrbinc <= '1';
        ons       <= ew4;

      when ew4 =>
        addrbinc <= '1';
        ons       <= ew5;

      when ew5 =>
        addrbinc <= '1';
        ons       <= selwait;

      when selwait =>
        addrbinc <= '0';
        if osel = '0' then
          ons     <= wwrite;
        else
          ons     <= selwait;
        end if;

      when wwrite =>
        addrbinc <= '0';
        ons       <= outwait;

      when outwait =>
        addrbinc <= '0';
        if oupdate = '1' and osel = '1' then
          ons     <= outdone;
        else
          ons     <= outwait;
        end if;

      when outdone  =>
        addrbinc <= '0';
        ons       <= eoutw;

      when others  =>
        addrbinc <= '0';
        ons       <= eoutw;

    end case;
  end process outfsm;

end Behavioral;
