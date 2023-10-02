--FILEPATH: processor_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_tb is
end entity processor_tb;

architecture testbench of processor_tb is
  signal clk      : std_logic                    := '0';
  signal reset    : std_logic                    := '0';
  signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
  signal data_out : std_logic_vector(7 downto 0);

  component processor is
    port
    (
      clk      : in std_logic;
      reset    : in std_logic;
      data_in  : in std_logic_vector(7 downto 0);
      data_out : out std_logic_vector(7 downto 0)
    );
  end component processor;

begin
  uut : processor
  port map
  (
    clk      => clk,
    reset    => reset,
    data_in  => data_in,
    data_out => data_out
  );

  process
  begin
    reset <= '1';
    wait for 10 ns;
    reset <= '0';

    wait for 10 ns;
    data_in <= x"01";
    wait for 10 ns;
    assert data_out = x"00" report "Test 1 failed" severity error;

    wait for 10 ns;
    data_in <= x"02";
    wait for 10 ns;
    assert data_out = x"01" report "Test 2 failed" severity error;

    wait for 10 ns;
    data_in <= x"03";
    wait for 10 ns;
    assert data_out = x"00" report "Test 3 failed" severity error;

    wait for 10 ns;
    data_in <= x"04";
    wait for 10 ns;
    assert data_out = x"00" report "Test 4 failed" severity error;

    wait for 10 ns;
    data_in <= x"05";
    wait for 10 ns;
    assert data_out = x"01" report "Test 5 failed" severity error;

    wait for 10 ns;
    data_in <= x"06";
    wait for 10 ns;
    assert data_out = x"01" report "Test 6 failed" severity error;

    wait for 10 ns;
    data_in <= x"07";
    wait for 10 ns;
    assert data_out = x"FE" report "Test 7 failed" severity error;

    wait;
  end process;

  process
  begin
    while now < 100 ns loop
      clk <= not clk;
      wait for 5 ns;
    end loop;
    wait;
  end process;

end architecture testbench;