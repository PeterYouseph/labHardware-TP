library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- A 255x8 single-port RAM in VHDL
entity memory is
  port
  (
    clk             : in std_logic; -- Input do clock na RAM
    reset           : in std_logic; -- O Reset da RAM
    address         : in std_logic_vector(7 downto 0); -- Endereço para escrever/ler na RAM
    instruction     : in std_logic_vector(7 downto 0); -- Instrução que será feita na RAM
    data            : in std_logic_vector(7 downto 0); -- Data para escrever na RAM
    read_enable     : in std_logic; -- Habilitar a leitura
    write_enable    : in std_logic; -- Habilitar a escrita
    instruction_out : out std_logic_vector(7 downto 0); -- Instrução de saida da RAM
    data_out        : out std_logic_vector(7 downto 0) -- Data de saida da RAM
  );
end entity memory;

architecture rtl of memory is
  -- Define um novo tipo para a memoria RAM de 255x8
  type memory_array is array (0 to 255) of std_logic_vector(7 downto 0);
  -- "Setar" valores iniciais para a RAM
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
