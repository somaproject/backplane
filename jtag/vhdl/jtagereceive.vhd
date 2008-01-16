library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

library soma;
use soma.somabackplane.all;
use soma.somabackplane;

library UNISIM;
use UNISIM.VComponents.all;

entity jtagereceive is
  generic (
    JTAG_CHAIN_MASK :    integer := 1;
    JTAG_CHAIN_OUT  :    integer := 1
    );
  port (
    CLK             : in std_logic;

    ECYCLE : in  std_logic;
    EDTX   : in  std_logic_vector(7 downto 0);
    EATX   : in  std_logic_vector(somabackplane.N - 1 downto 0);
    DEBUG  : out std_logic_vector(3 downto 0)
    );
end jtagereceive;


architecture Behavioral of jtagereceive is
  -- output side
  signal dob : std_logic_vector(15 downto 0) := (others => '0');

  signal addrb : std_logic_vector(9 downto 0) := (others => '0');

  signal dout, doutl : std_logic_vector(95 downto 0) := (others => '0');

  signal odrck, osel, oshift, oupdate, otdo : std_logic             := '0';
  signal bitcnt                             : integer range 0 to 95 := 0;

  type ostates is (eoutw, ew0, ew1, ew2, ew3, ew4, ew5, ew6, selwait, wwrite, outwait, outdone);
  signal ocs, ons : ostates := eoutw;

  signal addrbinc : std_logic := '0';

  -- input side
  signal cp : std_logic_vector(9 downto 0) := (others => '0');

  signal wea   : std_logic                     := '0';
  signal addra : std_logic_vector(9 downto 0)  := (others => '0');
  signal eoutd : std_logic_vector(15 downto 0) := (others => '0');

  signal enext  : std_logic                    := '0';
  signal eouta  : std_logic_vector(2 downto 0) := (others => '0');
  signal evalid : std_logic;

  --input side
  type istates is (ewaita, edone, scheck, ew0, ew1, ew2, ew3, ew4, ew5, ewritten);
  signal ics, ins : istates := ewaita;

  signal addrainc : std_logic := '0';

  signal fifocnt : integer range 0 to 255 := 0;

  -- input mask
  signal smdrck                          : std_logic := '0';
  signal smsel                           : std_logic := '0';
  signal smshift                         : std_logic := '0';
  signal smupdate, smupdatel, smupdatell : std_logic := '0';

  signal smtdi      : std_logic                     := '0';
  signal smaskreg   : std_logic_vector(79 downto 0) := (others => '0');
  signal smaskregl  : std_logic_vector(79 downto 0) := (others => '0');
  signal smaskregll : std_logic_vector(79 downto 0) := (others => '0');
  signal smask      : std_logic                     := '0';


-- component rxeventfifo
-- port (
-- CLK : in std_logic;
-- RESET : in std_logic;
-- ECYCLE : in std_logic;
-- EATX : in std_logic_vector(somabackplane.N -1 downto 0);
-- EDTX : in std_logic_vector(7 downto 0);
--  -- outputs
--     EOUTD  : out std_logic_vector(15 downto 0);
--     EOUTA  : in std_logic_vector(2 downto 0);
--     EVALID : out std_logic;
--     ENEXT  : in  std_logic
--     );
-- end component;


begin  -- Behavioral

  eventbuffer_inst : RAMB16_S18_S18
    generic map (
      SRVAL_B             => X"000000000",
      WRITE_MODE_A        => "WRITE_FIRST",
      WRITE_MODE_B        => "WRITE_FIRST",
      SIM_COLLISION_CHECK => "ALL",
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


  DEBUG(0) <= odrck;
  DEBUG(1) <= osel;
  DEBUG(2) <= oshift;
  DEBUG(3) <= otdo;

  -- output jtag proces
  jtagin : process(ODRCK, OUPDATE)
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
  end process jtagin;

  otdo <= doutl(bitcnt);
  --otdo <= smaskregll(bitcnt); 

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      -- output side
      ocs <= ons;

      if addrbinc = '1' then
        addrb              <= addrb + 1;
      end if;
      if ocs = ew1 then
        dout(15 downto 0)  <= dob(7 downto 0) & dob(15 downto 8);
      end if;
      if ocs = ew2 then
        dout(31 downto 16) <= dob(7 downto 0) & dob(15 downto 8);
      end if;
      if ocs = ew3 then
        dout(47 downto 32) <= dob(7 downto 0) & dob(15 downto 8);
      end if;
      if ocs = ew4 then
        dout(63 downto 48) <= dob(7 downto 0) & dob(15 downto 8);
      end if;
      if ocs = ew5 then
        dout(79 downto 64) <= dob(7 downto 0) & dob(15 downto 8);
      end if;
      if ocs = ew6 then
        dout(95 downto 80) <= dob(7 downto 0) & dob(15 downto 8);
      end if;


      if ocs = eoutw then
        doutl   <= (others => '0');
      else
        if ocs = wwrite then
          doutl <= dout;
        end if;
      end if;

      -- input side
      ics <= ins;

      if addrainc = '1' then
        addra <= addra + 1;
      end if;

      if ics = ewritten then
        cp <= addra;
      end if;

      -- mask side
      smupdatel <= smupdate;
      smupdatell <= smupdatel;
      if smupdatel = '1' and smupdatell = '0' and smsel = '1' then
        smaskregl    <= smaskreg;         
      end if;

      if enext = '1' then
        smaskregll <= smaskregl;
      end if;

      -- fifocounter

      if ics = ewritten and ocs /= wwrite then
        fifocnt <= fifocnt + 1;
      elsif ics /= ewritten and ocs = wwrite then
        fifocnt <= fifocnt - 1;
      end if;


    end if;
  end process main;

  outfsm : process(addrb, cp, osel, oupdate, ocs)
  begin
    case ocs is
      when eoutw =>
        --DEBUG <= X"0"; 
        addrbinc <= '0';
        if addrb /= cp then
          ons    <= ew0;
        else
          ons    <= eoutw;
        end if;
      when ew0   =>
        --DEBUG <= X"1";
        addrbinc <= '1';
        ons      <= ew1;

      when ew1 =>
        --DEBUG <= X"2";
        addrbinc <= '1';
        ons      <= ew2;

      when ew2 =>
        --DEBUG <= X"3";
        addrbinc <= '1';
        ons      <= ew3;

      when ew3 =>
        --DEBUG <= X"4";
        addrbinc <= '1';
        ons      <= ew4;

      when ew4 =>
        --DEBUG <= X"5";
        addrbinc <= '1';
        ons      <= ew5;

      when ew5 =>
        --DEBUG <= X"6";
        addrbinc <= '1';
        ons      <= ew6;

      when ew6 =>
        --DEBUG <= X"6";
        addrbinc <= '0';
        ons      <= selwait;

      when selwait =>
        --DEBUG <= X"7";
        addrbinc <= '0';
        if oshift = '0' then
          ons    <= wwrite;
        else
          ons    <= selwait;
        end if;

      when wwrite =>
        --DEBUG <= X"8";
        addrbinc <= '0';
        ons      <= outwait;

      when outwait =>
        --DEBUG <= X"9";
        addrbinc <= '0';
        if oshift = '1' and osel = '1' then
          ons    <= outdone;
        else
          ons    <= outwait;
        end if;

      when outdone =>
        --DEBUG <= X"A";
        addrbinc <= '0';
        if oshift = '0' and osel = '1'then
          ons    <= eoutw;
        else
          ons    <= outdone;
        end if;

      when others =>
        --DEBUG <= X"B";
        addrbinc <= '0';
        ons      <= eoutw;

    end case;
  end process outfsm;


  -- input
  rxeventfifo_inst : entity soma.rxeventfifo
    port map (
      CLK    => CLK,
      RESET  => '0',
      EDTX   => EDTX,
      EATX   => EATX,
      ECYCLE => ECYCLE,
      ENEXT  => enext,
      EOUTA  => eouta,
      EVALID => evalid,
      EOUTD  => eoutd);



  BSCAN_MASK_inst : BSCAN_VIRTEX4
    generic map (
      JTAG_CHAIN => JTAG_CHAIN_MASK)
    port map (
      CAPTURE    => open,
      DRCK       => smdrck,
      reset      => open,
      SEL        => smsel,
      SHIFT      => smshift,
      TDI        => smtdi,
      UPDATE     => smupdate,
      TDO        => '0');


  jtagout : process(SMDRCK, smupdate, smaskreg)
  begin
    if SMUPDATE = '1' then
      
    else
      if rising_edge(smdrck) then
        if smsel = '1' and smshift = '1' then
          smaskreg <= smtdi & smaskreg(79 downto 1);
        end if;
      end if;
    end if;
  end process jtagout;


  infsm : process (ics, evalid, smask, addra, addrb, fifocnt)
  begin
    case ics is
      when ewaita =>
        eouta    <= "000";
        enext    <= '0';
        wea      <= '0';
        addrainc <= '0';

        if evalid = '1' then
          ins <= scheck;
        else
          ins <= ewaita;
        end if;

      when scheck =>
        eouta    <= "000";
        enext    <= '0';
        wea      <= '0';
        addrainc <= '0';

        if smask = '1' and fifocnt < 100 then
          ins <= ew0;
        else
          ins <= edone;
        end if;

      when edone =>
        eouta    <= "000";
        enext    <= '1';
        wea      <= '0';
        addrainc <= '0';
        ins      <= ewaita;

      when ew0 =>
        eouta    <= "001";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ew1;

      when ew1 =>
        eouta    <= "010";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ew2;

      when ew2 =>
        eouta    <= "011";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ew3;

      when ew3 =>
        eouta    <= "100";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ew4;

      when ew4 =>
        eouta    <= "101";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ew5;

      when ew5 =>
        eouta    <= "110";
        enext    <= '0';
        wea      <= '1';
        addrainc <= '1';
        ins      <= ewritten;

      when ewritten =>
        eouta    <= "000";
        enext    <= '0';
        wea      <= '0';
        addrainc <= '0';
        ins      <= edone;

      when others =>
        eouta    <= "000";
        enext    <= '0';
        wea      <= '0';
        addrainc <= '0';
        ins      <= ewaita;
    end case;
  end process infsm;


  smask <= smaskregll(conv_integer(eoutd(7 downto 0)));

end Behavioral;
