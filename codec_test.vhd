-- Definição de Sinais: Os sinais interrupt, read_signal, write_signal, valid, codec_data_in e codec_data_out são definidos. Esses sinais serão usados para interagir com o componente codec.

-- Instanciação do Componente Codec: O componente codec é instanciado com os sinais definidos conectados aos seus respectivos portos.

-- Teste de Operação de Escrita: Um processo é iniciado para testar a operação de escrita do codec. O sinal de interrupção é ativado, o sinal de escrita é ativado e um exemplo de dados é fornecido ao codec_data_in. Após um tempo simulado, o sinal de escrita e os dados são resetados. O sinal valid é então verificado para garantir que a operação de escrita foi bem-sucedida.

-- Teste de Operação de Leitura: Um segundo processo é iniciado para testar a operação de leitura do codec. O sinal de interrupção é ativado e o sinal de leitura é ativado. Após um tempo simulado, o sinal valid é verificado para garantir que a operação de leitura foi bem-sucedida.

library ieee;
use ieee.std_logic_1164.all;

entity codec_test is
end codec_test;

architecture testbench of codec_test is

  signal interrupt      : std_logic := '0';
  signal read_signal    : std_logic := '0';
  signal write_signal   : std_logic := '0';
  signal valid          : std_logic;
  signal codec_data_in  : std_logic_vector(7 downto 0) := (others => '0');
  signal codec_data_out : std_logic_vector(7 downto 0);

  -- Instantiate the codec component
  component codec
    port
    (
      interrupt      : in std_logic;
      read_signal    : in std_logic;
      write_signal   : in std_logic;
      valid          : out std_logic;
      codec_data_in  : in std_logic_vector(7 downto 0);
      codec_data_out : out std_logic_vector(7 downto 0)
    );
  end component;

begin

  -- Connect the signals
  unit_tests : codec port map
  (
    interrupt      => interrupt,
    read_signal    => read_signal,
    write_signal   => write_signal,
    valid          => valid,
    codec_data_in  => codec_data_in,
    codec_data_out => codec_data_out
  );

  -- Write operation test
  process
  begin
    -- Activate interrupt signal
    interrupt <= '1';

    -- Activate write signal
    write_signal  <= '1';
    codec_data_in <= "11001100"; -- Example data

    wait for 10 ns; -- Simulate some time

    -- Reset write signal and data
    write_signal  <= '0';
    codec_data_in <= (others => '0');

    -- Check if valid is asserted
    assert valid = '1'
    report "Write operation failed: valid signal not asserted"
      severity error;

    wait;
  end process;

  -- Read operation test
  process
  begin
    -- Activate interrupt signal
    interrupt <= '1';

    -- Activate read signal
    read_signal <= '1';

    wait for 10 ns; -- Simulate some time

    -- Check if valid is asserted
    assert valid = '1'
    report "Read operation failed: valid signal not asserted"
      severity error;

    wait;
  end process;

end testbench;