-- Declaração da entidade: A entidade memory é declarada com vários sinais de entrada e saída. Esses sinais incluem o sinal de clock, sinais para leitura e escrita de dados na memória, sinais para endereços de dados na memória, e sinais para dados de entrada e saída da memória.

-- Declaração da arquitetura: A arquitetura comportamental da memory é declarada. Isso inclui a declaração de um tipo de array memory_array que será usado para armazenar os dados na memória, e um sinal mem que será a memória.

-- Processo: Um processo é iniciado que é sensível ao sinal de clock. Dentro deste processo:

-- Se o sinal de clock estiver na borda de descida:
-- Se o sinal de escrita de dados for ‘1’, os dados são escritos na memória no endereço especificado.
-- Se o sinal de leitura de dados for ‘1’, os dados são lidos da memória no endereço especificado.
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
    data_addr  : in std_logic_vector(addr_width - 1 downto 0); -- Address to read/write data
    data_in    : in std_logic_vector((data_width * 2) - 1 downto 0);  -- Data to write to memory 
    data_out   : out std_logic_vector((data_width * 4) - 1 downto 0) -- Data read from memory
  );
end entity;

architecture behavioral of memory is

  type memory_array is array (natural range 0 to 2 ** addr_width - 1) of std_logic_vector(data_width - 1 downto 0); -- Declaração do tipo de dado que será armazenado na memória

  signal mem : memory_array; -- Declaração do sinal que será a memória

begin

  process (clock)
  begin
    if falling_edge(clock) then -- A memória só é escrita na borda de descida do clock
  
      if data_write = '1' then
        mem(to_integer(unsigned(data_addr))) <= data_in(data_width - 1 downto 0); -- Escreve os dados na memória, conforme o endereço especificado

      elsif data_read = '1' then 
        data_out(data_width - 1 downto 0) <= mem(to_integer(unsigned(data_addr))); -- Lê os dados da memória, conforme o endereço especificado

      end if;
    end if;
  end process;
end architecture behavioral;
