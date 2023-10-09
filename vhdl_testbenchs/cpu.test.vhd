library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end entity cpu_tb;

architecture testbench of cpu_tb is
  component cpu is
    generic
    (
      addr_width : natural := 16; -- Memory Address Width (in bits)
      data_width : natural := 8 -- Data Width (in bits)
    );
    port
    (
      clock : in std_logic; -- Clock signal
      halt  : in std_logic; -- Halt processor execution when '1'

      ---- Begin Memory Signals ---
      -- Instruction byte received from memory
      instruction_in : in std_logic_vector(data_width - 1 downto 0);
      -- Instruction address given to memory
      instruction_addr : out std_logic_vector(addr_width - 1 downto 0);

      mem_data_read  : out std_logic; -- When '1', read data from memory
      mem_data_write : out std_logic; -- When '1', write data to memory
      -- Data address given to memory
      mem_data_addr : out std_logic_vector(addr_width - 1 downto 0);
      -- Data sent from memory when data_read = '1' and data_write = '0'
      mem_data_in : out std_logic_vector((data_width * 2) - 1 downto 0);
      -- Data sent to memory when data_read = '0' and data_write = '1'
      mem_data_out : in std_logic_vector((data_width * 4) - 1 downto 0);
      ---- End Memory Signals ---

      ---- Begin Codec Signals ---
      codec_interrupt : out std_logic; -- Interrupt signal
      codec_read      : out std_logic; -- Read signal
      codec_write     : out std_logic; -- Write signal
      codec_valid     : in std_logic; -- Valid signal

      -- Byte written to codec
      codec_data_out : in std_logic_vector(7 downto 0);
      -- Byte read from codec
      codec_data_in : out std_logic_vector(7 downto 0)
      ---- End Codec Signals ---
    );
  end component cpu;

  signal clock            : std_logic                     := '0';
  signal halt             : std_logic                     := '0';
  signal instruction_in   : std_logic_vector(7 downto 0)  := (others => '0');
  signal instruction_addr : std_logic_vector(15 downto 0) := (others => '0');
  signal mem_data_read    : std_logic                     := '0';
  signal mem_data_write   : std_logic                     := '0';
  signal mem_data_addr    : std_logic_vector(15 downto 0) := (others => '0');
  signal mem_data_in      : std_logic_vector(15 downto 0) := (others => '0');
  signal mem_data_out     : std_logic_vector(31 downto 0) := (others => '0');
  signal codec_interrupt  : std_logic;
  signal codec_read       : std_logic;
  signal codec_write      : std_logic;
  signal codec_valid      : std_logic;
  signal codec_data_out   : std_logic_vector(7 downto 0);
  signal codec_data_in    : std_logic_vector(7 downto 0);

begin
  uut : cpu
  generic
  map
  (
  addr_width => 16,
  data_width => 8
  )
  port map
  (
    clock            => clock,
    halt             => halt,
    instruction_in   => instruction_in,
    instruction_addr => instruction_addr,
    mem_data_read    => mem_data_read,
    mem_data_write   => mem_data_write,
    mem_data_addr    => mem_data_addr,
    mem_data_in      => mem_data_in,
    mem_data_out     => mem_data_out,
    codec_interrupt  => codec_interrupt,
    codec_read       => codec_read,
    codec_write      => codec_write,
    codec_valid      => codec_valid,
    codec_data_out   => codec_data_out,
    codec_data_in    => codec_data_in
  );

  -- Clock signal generation
  clock_gen : process
  begin
    while true loop
      clock <= not clock;
      wait for 10 ns;
    end loop;
  end process;

  -- Test HLT instruction
  hlt_test : process
  begin
    wait for 100 ns;
    instruction_in <= "00000000"; -- HLT instruction
    mem_data_read  <= '1';
    wait for 10 ns;
    assert halt = '1' report "HLT instruction did not halt the processor" severity error;
    wait;
  end process;

  -- Test JEQ instruction
  -- jeq_test : process
  -- begin
  --   wait for 200 ns;
  --   instruction_in <= "11110000"; -- JEQ instruction
  --   mem_data_read  <= '1';
  --   op1            <= "00000001"; -- Set op1 to 1
  --   op2            <= "00000001"; -- Set op2 to 1
  --   imm            <= "00000010"; -- Set imm to 2
  --   wait for 10 ns;
  --   assert unsigned(instruction_addr) = 2 report "JEQ instruction did not jump to the correct address" severity error;
  --   wait;
  -- end process;

end architecture testbench;