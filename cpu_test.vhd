library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_test is
end entity cpu_test;

architecture testbench of cpu_test is
  signal clock_tb : std_logic := '0';
  signal halt_tb  : std_logic := '0';

  -- Memory signals
  signal instruction_in_tb : std_logic_vector(7 downto 0) := (others => '0');
  signal mem_data_read_tb  : std_logic;
  signal mem_data_write_tb : std_logic;
  signal mem_data_addr_tb  : std_logic_vector(15 downto 0);
  signal mem_data_in_tb    : std_logic_vector(15 downto 0);
  signal mem_data_out_tb   : std_logic_vector(31 downto 0);

  -- Codec signals
  signal codec_interrupt_tb : std_logic;
  signal codec_read_tb      : std_logic;
  signal codec_write_tb     : std_logic;
  signal codec_valid_tb     : std_logic;
  signal codec_data_in_tb   : std_logic_vector(7 downto 0);
  signal codec_data_out_tb  : std_logic_vector(7 downto 0);

begin
  -- Clock process
  process
  begin
    wait for 5 ns; -- initial wait
    while now < 100 ns loop
      clock_tb <= not clock_tb;
      wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus process
  process
  begin
    wait for 10 ns; -- initial wait

    -- Write some instructions to memory
    mem_data_addr_tb  <= "0000000000000000";
    mem_data_in_tb    <= "1100000011000000"; -- Example instruction: PUSH 192
    mem_data_write_tb <= '1';
    wait for 10 ns;

    mem_data_addr_tb  <= "0000000000000001";
    mem_data_in_tb    <= "1110000000000001"; -- Example instruction: JMP 1
    mem_data_write_tb <= '1';
    wait for 10 ns;

    mem_data_write_tb <= '0'; -- Disable write

    wait for 100 ns;

    -- Stop the simulation
    wait;

  end process;

  -- Instantiate the cpu entity
  uut : entity work.cpu
    generic
    map (
    addr_width => 16,
    data_width => 8
    )
    port map
    (
      clock            => clock_tb,
      halt             => halt_tb,
      instruction_in   => instruction_in_tb,
      instruction_addr => open,
      mem_data_read    => mem_data_read_tb,
      mem_data_write   => mem_data_write_tb,
      mem_data_addr    => mem_data_addr_tb,
      mem_data_in      => mem_data_in_tb,
      mem_data_out     => mem_data_out_tb,
      codec_interrupt  => codec_interrupt_tb,
      codec_read       => codec_read_tb,
      codec_write      => codec_write_tb,
      codec_valid      => codec_valid_tb,
      codec_data_out   => codec_data_out_tb,
      codec_data_in    => open
    );

  -- Add other signal assignments here if needed

end architecture testbench;