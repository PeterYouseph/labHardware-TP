library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  generic
  (
    addr_width : natural := 16; -- Memory Address Width (in bits)
    data_width : natural := 8 -- Data Width (in bits)
  );
  port
  (
    clock      : in std_logic; -- Clock signal; Write on Falling-Edge
    data_read  : in std_logic; -- When '1', read data from memory
    data_write : in std_logic; -- When '1', write data to memory
    data_addr  : in std_logic_vector(addr_width - 1 downto 0);
    data_in    : in std_logic_vector((data_width * 2) - 1 downto 0);
    data_out   : out std_logic_vector((data_width * 4) - 1 downto 0)
  );
end entity;

architecture behavioral of memory is
  type memory_array is array (natural range 0 to 2 ** addr_width - 1) of std_logic_vector(data_width - 1 downto 0);
  signal mem : memory_array;
begin
  process (clock)
  begin
    if falling_edge(clock) then
      if data_write = '1' then
        -- Write data to memory at the specified address
        -- Escreve os dados na memória, conforme o endereço especificado
        mem(to_integer(unsigned(data_addr))) <= data_in(data_width - 1 downto 0);
      elsif data_read = '1' then
        -- Read data from memory at the specified address
        -- Lê os dados da memória, conforme o endereço especificado
        data_out(data_width - 1 downto 0) <= mem(to_integer(unsigned(data_addr)));
      end if;
    end if;
  end process;
end architecture behavioral;