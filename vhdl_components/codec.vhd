library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity codec is
  port
  (
    interrupt      : in std_logic; -- Interrupt signal - Sinal de interrupção
    read_signal    : in std_logic; -- Read signal - Leitura de sinal
    write_signal   : in std_logic; -- Write signal - Escrita de sinal
    valid          : out std_logic; -- Valid signal - Sinal válido
    codec_data_in  : in std_logic_vector(7 downto 0); -- Byte written to codec - Byte escrito no codec
    codec_data_out : out std_logic_vector(7 downto 0) -- Byte read from codec - Byte lido pelo codec
  );
end entity codec;

architecture behavioral of codec is
  signal data_buffer   : std_logic_vector(7 downto 0) := (others => '0'); -- Data buffer to hold the byte read from/written to codec - Buffer de dados para armazenar o byte lido / escrito no codec
  signal is_data_valid : boolean                      := false; -- Flag to indicate whether data is valid or not - Flag de indicação se os dados são válidos ou não
begin
  process (interrupt, read_signal, write_signal, codec_data_in)
  begin
    if interrupt = '1' then
      if read_signal = '1' then
        -- Instruction is IN, read a byte from the simulated input device - Se instrução é IN, leia um byte do dispositivo de entrada simulado
        -- data_buffer   <= "FALTA ADICIONAR A LÓGICA DE LEITURA DOS ARQUIVOS";
        is_data_valid <= true; -- Signal that valid data is available - Sinal is_data_valid que dados válidos estão disponíveis
      elsif write_signal = '1' then
        -- Instruction is OUT, write a byte to the simulated output device - Se instrução é OUT, escreva um byte
        -- Extract the data to be written from codec_data_in - Extraia os dados a serem gravados de codec_data_in
        data_buffer   <= codec_data_in;
        is_data_valid <= true; -- Signal that data has been written successfully - Sinal is_data_valid que os dados foram gravados com sucesso
      end if;
    else
      is_data_valid <= false; -- No valid data available - Nenhum dado válido disponível
    end if;
  end process;

  valid <= '1' when is_data_valid else
    '0'; -- Set valid signal based on is_data_valid flag - Define o sinal válido com base na flag do is_data_valid

  -- Output the data in data_buffer when valid = '1' - Dados de saída no data_buffer quando valid = '1'
  codec_data_out <= data_buffer when is_data_valid else
    (others => 'Z');
end architecture behavioral;