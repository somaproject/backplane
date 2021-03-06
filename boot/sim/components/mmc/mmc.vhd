library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library UNISIM;
use UNISIM.VComponents.all;

entity mmc is
  generic (
    mode : integer := 0);
  port (
    RESET : in  std_logic;
    SCLK  : in  std_logic;
    SDIN  : in  std_logic;
    SDOUT : out std_logic;
    SCS   : in  std_logic  );
end mmc;

architecture Behavioral of mmc is
  signal incmd     : std_logic_vector(47 downto 0) := (others => '1'); 
                                                       
  signal mmcmode   : std_logic                    := '0';
  signal r1resp    : std_logic_vector(7 downto 0) := (others => '0');
  signal initdone  : std_logic                    := '0';
  signal initstart : std_logic                    := '0';
  signal byteout   : std_logic_vector(7 downto 0) := (others => '0');

  signal readaddr : std_logic_vector(31 downto 0) := (others => '0');
  



begin  -- Behavioral

  main : process
  begin  -- process main

    SDOUT <= '1';

    for i in 1 to 75 loop               -- initial clock consumption
      wait until rising_edge(SCLK);
    end loop;  -- i

    while true loop

      -- read cmd
      if mmcmode = '1' then
        wait until falling_edge(SCS);

        for bitpos in 47 downto 0 loop
          wait until rising_edge(SCLK);
          incmd(bitpos) <= SDIN;
        end loop;
        wait until falling_edge(SCLK);

      else
        wait until rising_edge(SCLK);
        incmd(47) <= SDIN;
        if SDIN = '0' then


          for bitpos in 46 downto 0 loop
            wait until rising_edge(SCLK);
            incmd(bitpos) <= SDIN;
          end loop;
          wait until falling_edge(SCLK);
        end if;

      end if;




      -- we now have a cmd

      if incmd = X"400000000095" then   -- SET SPI MODE

        if SCS = '0' then
          mmcmode <= '1';
        end if;

        for i in 1 to 4*8 loop
          -- NCR                        -- 4 bytes long
          wait until rising_edge(SCLK);
        end loop;  -- i 

        r1resp  <= X"01";
        for i in 7 downto 0 loop
          wait until falling_edge(SCLK);
          SDOUT <= r1resp(i);
          wait until rising_edge(SCLK);
        end loop;  -- i

        -- done

      elsif incmd(47 downto 40) = X"41" then
        -- start init cmd

        if initstart = '0' then
          initstart <= '1';
          initdone  <= '1' after 4 ms;  -- shorter delay than normal
        end if;

        for i in 1 to 3*8 loop
          -- NCR                        -- 4 bytes long
          wait until rising_edge(SCLK);
        end loop;  -- i 

        if initdone = '1' then
          r1resp <= X"00";

        else
          r1resp <= X"01";
        end if;

        for i in 7 downto 0 loop
          wait until falling_edge(SCLK);
          SDOUT <= r1resp(i);
          wait until rising_edge(SCLK);
        end loop;  -- i

      elsif incmd(47 downto 40) = X"51" then
        -- read single block command
        readaddr <= incmd(39 downto 8); 
        -- command not appropriate at this time; init not done
        for i in 1 to 3*8 loop
          -- NCR                        -- 4 bytes long
          wait until rising_edge(SCLK);
        end loop;  -- i 

        if initdone = '1' then
          r1resp <= X"00";
        else
          r1resp <= X"01";
        end if;

        for i in 7 downto 0 loop
          wait until falling_edge(SCLK);
          SDOUT <= r1resp(i);
          wait until rising_edge(SCLK);
        end loop;  -- i

        if initdone = '1' then          -- actually send the data

          for i in 1 to 5*8 loop
            -- random wait cycles
            wait until rising_edge(SCLK);
          end loop;  -- i 

          r1resp <= X"FE";

          -- send data token
          for i in 7 downto 0 loop
            wait until falling_edge(SCLK);
            SDOUT <= r1resp(i);
            wait until rising_edge(SCLK);
          end loop;  -- i

          -- send 512 bytes of data at addr
          for bytepos in 0 to 511 loop
            for i in 7 downto 0 loop
              wait until falling_edge(SCLK);
              if mode = 0 then
              SDOUT <= byteout(i);
              elsif mode = 1 then
                -- address-sending mode
                if bytepos < 4 then
                  SDOUT <= readaddr((3-bytepos) * 8 + i) ; 
                else
                  SDOUT <= byteout(i); 
                end if;
              end if;

              wait until rising_edge(SCLK);
            end loop;  -- i
            byteout <= byteout + 1;
          end loop;  -- bytepos

          -- send 2-byte crc
          for i in 15 downto 0 loop
            wait until falling_edge(SCLK);
            SDOUT <= '0';
            wait until rising_edge(SCLK);
          end loop;  -- i

        end if;

      end if;
      SDOUT <= '1';
    end loop;

  end process main;


end Behavioral;
