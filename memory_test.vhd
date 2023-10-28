-- Definição de Sinais: Os sinais interrupt, read_signal, write_signal, valid, codec_data_in e codec_data_out são definidos. Esses sinais serão usados para interagir com o componente codec.

-- Instanciação do Componente Codec: O componente codec é instanciado com os sinais definidos conectados aos seus respectivos portos.

-- Teste de Operação de Escrita: Um processo é iniciado para testar a operação de escrita do codec. O sinal de interrupção é ativado, o sinal de escrita é ativado e um exemplo de dados é fornecido ao codec_data_in. Após um tempo simulado, o sinal de escrita e os dados são resetados. O sinal valid é então verificado para garantir que a operação de escrita foi bem-sucedida.

-- Teste de Operação de Leitura: Um segundo processo é iniciado para testar a operação de leitura do codec. O sinal de interrupção é ativado e o sinal de leitura é ativado. Após um tempo simulado, o sinal valid é verificado para garantir que a operação de leitura foi bem-sucedida.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_test is
end entity memory_test;

architecture testbench of memory_test is
  component memory is
    generic
    (
      addr_width : natural := 16; -- Memory Address Width (in bits) - Largura do endereço da memória (em bits)
      data_width : natural := 8 -- Data Width (in bits) - Largura do endereço da memória (em bits)
    );
    port
    (
      clock      : in std_logic; -- Clock signal; Write on Falling-Edge - Sinal de clock; Escreva na borda de descida
      data_read  : in std_logic; -- When '1', read data from memory - Quando '1', leia os dados da memória
      data_write : in std_logic; -- When '1', write data to memory - Quando '1', escreva na memória
      data_addr  : in std_logic_vector(addr_width - 1 downto 0);
      data_in    : in std_logic_vector((data_width * 2) - 1 downto 0);
      data_out   : out std_logic_vector((data_width * 4) - 1 downto 0)
    );
  end component memory;

  signal clock      : std_logic                     := '0';
  signal data_read  : std_logic                     := '0';
  signal data_write : std_logic                     := '0';
  signal data_addr  : std_logic_vector(15 downto 0) := (others => '0');
  signal data_in    : std_logic_vector(15 downto 0) := (others => '0');
  signal data_out   : std_logic_vector(31 downto 0);

begin
  unit_tests : memory
  generic
  map
  (
  addr_width => 16,
  data_width => 8
  )
  port map
  (
    clock      => clock,
    data_read  => data_read,
    data_write => data_write,
    data_addr  => data_addr,
    data_in    => data_in,
    data_out   => data_out
  );

  -- Clock signal generation - Geração do sinal de clock
  clock_gen : process
  begin
    while true loop
      clock <= not clock;
      wait for 10 ns;
    end loop;
  end process;

  -- Writing test in valid address - teste de escrita em endereço válido
  write_test : process
  begin
    wait for 100 ns;
    data_addr  <= "0000000000000001";
    data_in    <= "0000111100001111";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait for 10 ns;
    data_addr  <= "0000000000000000";
    data_in    <= "1010101010101010";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait for 10 ns;
    data_addr  <= "1111111111111111";
    data_in    <= "1111000011110000";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait;
  end process;

  -- Reading test in valid address - Teste de leitura em endereço válido 
  read_test : process
  begin
    wait for 500 ns;
    data_addr <= "0000000000000001";
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "00001111000011110000111100001111" report "Read data does not match expected value - Dados lidos possuem valores inválidos" severity error;
    data_read <= '0';
    wait for 10 ns;
    data_addr <= "0000000000000000";
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "10101010101010100000000000000000" report "Read data does not match expected value - Dados lidos possuem valores inválidos " severity error;
    data_read <= '0';
    wait for 10 ns;
    data_addr <= "1111111111111111";
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "11110000111100001111111111111111" report "Read data does not match expected value - Dados lidos possuem valores inválidos" severity error;
    data_read <= '0';
    wait;
  end process;

  read_write_test : process
  begin
    wait for 200 ns;

    -- Teste de escrita seguido por leitura no mesmo endereço
    data_addr  <= "0000000000000010";
    data_in    <= "1100110011001100";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait for 10 ns;
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "11001100110011001100110011001100" report "Read data does not match expected value - Dados lidos possuem valores inválidos" severity error;
    data_read <= '0';
    wait for 10 ns;

    -- Teste de escrita em endereço inválido (fora do alcance da memória)
    data_addr  <= "1000000000000000"; -- Endereço inválido (maior que a capacidade da memória)
    data_in    <= "0011001100110011";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait for 10 ns;

    -- Teste de leitura em endereço inválido (fora do alcance da memória)
    data_addr <= "1000000000000000"; -- Endereço inválido (maior que a capacidade da memória)
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "-1" report "Read data should be undefined for an out-of-range address - Dados lidos deveriam ser indefinidos para um endereço fora do range/tamanhos dos endereços" severity note;
    data_read <= '0';
    wait for 10 ns;
    -- Teste de escrita em endereço válido seguido por leitura
    data_addr  <= "0000000000000011"; -- Endereço válido
    data_in    <= "0101010101010101";
    data_write <= '1';
    wait for 10 ns;
    data_write <= '0';
    wait for 10 ns;
    data_read <= '1';
    wait for 10 ns;
    assert data_out = "01010101010101010101010101010101" report "Read data does not match expected value - Dados lidos possuem valores inválidos" severity error;
    data_read <= '0';
    wait for 10 ns;

    wait;
  end process;

end architecture testbench;