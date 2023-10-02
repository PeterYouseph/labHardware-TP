library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_tb is
end entity memory_tb;

architecture testbench of memory_tb is
  component memory is
    port
    (
      clk             : in std_logic;
      reset           : in std_logic;
      address         : in std_logic_vector(7 downto 0);
      instruction     : in std_logic_vector(7 downto 0);
      data            : in std_logic_vector(7 downto 0);
      read_enable     : in std_logic;
      write_enable    : in std_logic;
      instruction_out : out std_logic_vector(7 downto 0);
      data_out        : out std_logic_vector(7 downto 0)
    );
  end component memory;

  signal clk             : std_logic                    := '0';
  signal reset           : std_logic                    := '1';
  signal address         : std_logic_vector(7 downto 0) := (others => '0');
  signal instruction     : std_logic_vector(7 downto 0) := (others => '0');
  signal data            : std_logic_vector(7 downto 0) := (others => '0');
  signal read_enable     : std_logic                    := '0';
  signal write_enable    : std_logic                    := '0';
  signal instruction_out : std_logic_vector(7 downto 0);
  signal data_out        : std_logic_vector(7 downto 0);

begin
  uut : memory
  port map
  (
    clk             => clk,
    reset           => reset,
    address         => address,
    instruction     => instruction,
    data            => data,
    read_enable     => read_enable,
    write_enable    => write_enable,
    instruction_out => instruction_out,
    data_out        => data_out
  );

  clk_gen : process
  begin
    while true loop
      clk <= not clk;
      wait for 10 ns;
    end loop;
  end process;

  reset_proc : process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait;
  end process;

  write_test : process
  begin
    wait for 200 ns;
    address      <= "00000001";
    data         <= "00001111";
    write_enable <= '1';
    wait for 10 ns;
    write_enable <= '0';
    wait for 10 ns;
    address      <= "00000000";
    data         <= "10101010";
    write_enable <= '1';
    wait for 10 ns;
    write_enable <= '0';
    wait for 10 ns;
    address      <= "11111111";
    data         <= "11110000";
    write_enable <= '1';
    wait for 10 ns;
    write_enable <= '0';
    wait;
  end process;

  read_test : process
  begin
    wait for 500 ns;
    address     <= "00000001";
    instruction <= "0";
    read_enable <= '1';
    wait for 10 ns;
    assert data_out = "00001111" report "Read data does not match expected value" severity error;
    read_enable <= '0';
    wait for 10 ns;
    address     <= "00000000";
    instruction <= "1";
    read_enable <= '1';
    wait for 10 ns;
    assert instruction_out = "10101010" report "Read instruction does not match expected value" severity error;
    read_enable <= '0';
    wait for 10 ns;
    address     <= "11111111";
    instruction <= "0";
    read_enable <= '1';
    wait for 10 ns;
    assert data_out = "11110000" report "Read data does not match expected value" severity error;
    read_enable <= '0';
    wait;
  end process;

end architecture testbench;