-- Declaração da entidade: A entidade codec é declarada com vários sinais de entrada e saída. Esses sinais incluem sinais para interrupção, leitura e escrita de dados, validação de dados e dados de entrada e saída do codec.

-- Declaração da arquitetura: A arquitetura comportamental do codec é declarada. Isso inclui a declaração de vários sinais e variáveis que serão usados no processo subsequente. Isso inclui um buffer de dados para armazenar os dados a serem lidos do codec, um sinal para indicar se os dados no buffer são válidos, arquivos de entrada e saída, e variáveis para ler do arquivo de entrada e calcular a soma dos dados do arquivo de entrada.

-- Processo: Um processo é iniciado que é sensível aos sinais interrupt, read_signal, write_signal e codec_data_in. Dentro deste processo:

-- Se o sinal de interrupção for ‘1’:
-- Se o sinal de leitura for ‘1’ e os dados no buffer não forem válidos, o script lê do arquivo de entrada e calcula a soma dos dados do arquivo.
-- Se o sinal de escrita for ‘1’ e os dados no buffer não forem válidos, o script escreve cada bit no byte no arquivo de saída.
-- Se os dados no buffer forem válidos, os dados lidos do codec são definidos como os dados no buffer e o sinal válido é definido como ‘1’. Caso contrário, o sinal válido é definido como ‘0’.
library ieee; -- Importa a biblioteca padrão IEEE
use ieee.std_logic_1164.all; -- Usa o pacote std_logic_1164 da biblioteca IEEE
use ieee.numeric_std.all; -- Usa o pacote numeric_std da biblioteca IEEE
use std.textio.all; -- Usa o pacote textio da biblioteca padrão

entity codec is -- Declaração da entidade codec
  port
  (
    interrupt      : in std_logic; -- Sinal de interrupção
    read_signal    : in std_logic; -- Sinal de leitura
    write_signal   : in std_logic; -- Sinal de escrita
    valid          : out std_logic; -- Sinal de validação
    codec_data_in  : in std_logic_vector(7 downto 0); -- Byte escrito no codec
    codec_data_out : out std_logic_vector(7 downto 0) -- Byte lido do codec
  );
end entity codec;

architecture behavioral of codec is -- Declaração da arquitetura comportamental do codec
  signal data_buffer   : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de dados para armazenar os dados a serem lidos do codec
  signal is_data_valid : boolean                      := false; -- Sinal para indicar se os dados no buffer são válidos
  subtype logic is std_logic_vector(7 downto 0); -- Subtipo de std_logic_vector
  type type_file is file of logic; -- Tipo de arquivo
  file input_file           : type_file open READ_MODE is "input.bin"; -- Arquivos de entrada
  file output_file          : type_file open WRITE_MODE is "output.bin"; -- Arquivos de saída
  shared variable file_data : logic; -- Variável para ler do arquivo de entrada 

begin
  process (interrupt, read_signal, write_signal, codec_data_in)
  begin
    if interrupt = '1' then
      if read_signal = '1' then -- Leitura do arquivo

        while not endfile(input_file) loop -- Enquanto não chegar ao fim do arquivo
          read(input_file, file_data);
          codec_data_out <= file_data;
        end loop;
        is_data_valid <= true;

      elsif write_signal = '1' then -- Escrita no arquivo 

        for i in 0 to 7 loop
          write(output_file, codec_data_in); -- Escreve cada bit no byte no arquivo de saída
        end loop;
        is_data_valid <= true; -- Define que os dados no buffer são válidos
      else
        is_data_valid <= false;
      end if;
    end if;
    if is_data_valid then -- Se os dados no buffer forem válidos 
      valid <= '1'; -- Define que os dados são válidos 
    else
      valid <= '0'; -- Define que os dados não são válidos 
    end if;
  end process;

end architecture behavioral;