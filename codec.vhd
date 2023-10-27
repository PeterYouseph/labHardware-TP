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
  signal data_buffer        : std_logic_vector(7 downto 0) := (others => '0'); -- Buffer de dados para armazenar os dados a serem lidos do codec
  signal is_data_valid      : boolean                      := false; -- Sinal para indicar se os dados no buffer são válidos
  file input_file           : text open READ_MODE is "input.bin"; -- Arquivo de entrada
  file output_file          : text open WRITE_MODE is "output.bin"; -- Arquivo de saída
  shared variable file_line : line; -- Variável para ler do arquivo de entrada 
  shared variable file_data : integer := 0; -- Variável para ler do arquivo de entrada 
  shared variable file_sum  : integer := 0; -- Variável para calcular a soma do arquivo de entrada 

begin
  process (interrupt, read_signal, write_signal, codec_data_in) -- Processo que é sensível aos sinais interrupt, read_signal, write_signal e codec_data_in
  begin
    if interrupt = '1' then -- Se o sinal de interrupção for '1'
      if read_signal = '1' then -- Se o sinal de leitura for '1'
        if not is_data_valid then -- Se os dados no buffer não forem válidos
          -- Leitura do arquivo
          if not endfile(input_file) then -- Se não for o fim do arquivo de entrada
            readline(input_file, file_line); -- Lê uma linha do arquivo de entrada
            read(file_line, file_data); -- Lê os dados da linha do arquivo de entrada 
            file_sum := file_sum + file_data; -- Calcula a soma dos dados do arquivo de entrada 
          end if;

          if endfile(input_file) then -- Se for o fim do arquivo de entrada 
            data_buffer   <= std_logic_vector(to_unsigned(file_sum, 8)); -- Armazena a soma dos dados do arquivo de entrada no buffer de dados 
            is_data_valid <= true; -- Define que os dados no buffer são válidos 
          end if;
        end if;
      elsif write_signal = '1' then -- Se o sinal de escrita for '1'
        -- Escrita no arquivo 
        if not is_data_valid then -- Se os dados no buffer não forem válidos 
          for cont_loop in 0 to 7 loop -- Loop para cada bit no byte 
            write(file_line, integer'image(to_integer(unsigned'("0" & codec_data_in(cont_loop))))); -- Escreve cada bit no byte no arquivo de saída 
          end loop;
          writeline(output_file, file_line); -- Escreve a linha no arquivo de saída 
          is_data_valid <= true; -- Define que os dados no buffer são válidos 
        end if;
      end if;
    end if;

    if is_data_valid then -- Se os dados no buffer forem válidos 
      codec_data_out <= data_buffer; -- Define que os dados lidos do codec são os dados no buffer 
      valid          <= '1'; -- Define que os dados são válidos 
    else
      valid <= '0'; -- Define que os dados não são válidos 
    end if;
  end process;

end architecture behavioral;