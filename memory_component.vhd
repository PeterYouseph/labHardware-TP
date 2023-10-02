library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
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
end entity memory;

architecture rtl of memory is
  type memory_array is array (0 to 255) of std_logic_vector(7 downto 0);
  signal mem : memory_array := (others => (others => '0'));
begin
  process (clk, reset)
  begin
    if reset = '1' then
      mem <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if write_enable = '1' then
        mem(to_integer(unsigned(address))) <= data;
      end if;
      if read_enable = '1' then
        instruction_out <= mem(to_integer(unsigned(address))) when instruction = '1' else
          (others => '0');
        data_out <= mem(to_integer(unsigned(address))) when instruction = '0' else
          (others => '0');
      end if;
    end if;
  end process;
end architecture rtl;